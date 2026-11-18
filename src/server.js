const express = require('express');
const mysql = require('mysql2/promise');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3001;

app.use(express.json());

// Disable browser caching during development and live demos
app.use((req, res, next) => {
    res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, proxy-revalidate');
    res.setHeader('Pragma', 'no-cache');
    res.setHeader('Expires', '0');
    next();
});

// Serve static frontend assets and single-source posters folder
app.use(express.static(path.join(__dirname, 'public'), { etag: false, maxAge: 0 }));
app.use('/posters', express.static(path.join(__dirname, '..', 'posters'), { etag: false, maxAge: 0 }));

// MySQL Connection Pool (configurable via environment variables for reproducibility)
const pool = mysql.createPool({
    host: process.env.DB_HOST || '127.0.0.1',
    port: parseInt(process.env.DB_PORT || '3306', 10),
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'filmcraft',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    multipleStatements: false
});

pool.getConnection()
    .then(conn => {
        console.log('✓ Connected to MySQL `filmcraft` database');
        conn.release();
    })
    .catch(err => {
        console.error('✗ Failed to connect to MySQL `filmcraft` database:', err.message);
    });

// Helper: Normalize local poster paths into web-accessible /posters/<filename>
function normalizePosterUrl(raw) {
    if (!raw || !raw.trim()) return null;
    const trimmed = raw.trim();
    if (trimmed.includes('posters/')) {
        return '/posters/' + path.basename(trimmed);
    }
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://') && !trimmed.startsWith('/')) {
        return '/posters/' + trimmed;
    }
    return trimmed;
}

// ====================================================================
// 1. MOVIES — FULL CRUD (READ, CREATE, UPDATE, DELETE)
// ====================================================================

// READ: List all movies (with optional ?q= search across title, director, genres)
app.get('/api/movies', async (req, res) => {
    const q = (req.query.q || '').trim();
    try {
        const searchLike = `%${q}%`;
        const [rows] = await pool.query(`
            SELECT 
                M.movie_id,
                M.title,
                M.release_year,
                M.duration_minutes,
                M.language,
                M.synopsis,
                M.poster_url,
                M.prequel_movie_id,
                P.title AS prequel_title,
                FP.name AS director_name,
                MG_Agg.genres,
                COALESCE(R_Agg.total_reviews, 0) AS total_reviews,
                COALESCE(R_Agg.average_rating, 0.0) AS average_rating
            FROM movies M
            LEFT JOIN movies P ON M.prequel_movie_id = P.movie_id
            LEFT JOIN movie_cast_crew MCC ON M.movie_id = MCC.movie_id AND MCC.role_type = 'DIRECTOR'
            LEFT JOIN film_professionals FP ON MCC.person_id = FP.person_id
            LEFT JOIN (
                SELECT movie_id, GROUP_CONCAT(genre_name ORDER BY genre_name SEPARATOR ', ') AS genres
                FROM movie_genres
                GROUP BY movie_id
            ) MG_Agg ON M.movie_id = MG_Agg.movie_id
            LEFT JOIN (
                SELECT movie_id, COUNT(review_id) AS total_reviews, ROUND(AVG(rating), 1) AS average_rating
                FROM reviews
                GROUP BY movie_id
            ) R_Agg ON M.movie_id = R_Agg.movie_id
            WHERE (? = '' OR M.title LIKE ? OR COALESCE(FP.name, '') LIKE ? OR COALESCE(MG_Agg.genres, '') LIKE ?)
            ORDER BY average_rating DESC, total_reviews DESC, M.release_year DESC;
        `, [q, searchLike, searchLike, searchLike]);

        res.json({ success: true, count: rows.length, data: rows });
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

// CREATE: Add a new movie (atomic transaction: movies + movie_genres + director)
app.post('/api/movies', async (req, res) => {
    const {
        title,
        release_year,
        duration_minutes,
        language,
        synopsis,
        poster_url,
        genre_name,
        director_name,
        prequel_movie_id
    } = req.body;

    if (!title || !release_year || !duration_minutes) {
        return res.status(400).json({
            success: false,
            error: 'Title, release year, and duration (in minutes) are required.'
        });
    }

    const conn = await pool.getConnection();
    try {
        await conn.beginTransaction();

        const [movieResult] = await conn.query(`
            INSERT INTO movies (title, release_year, duration_minutes, language, synopsis, poster_url, prequel_movie_id)
            VALUES (?, ?, ?, ?, ?, ?, ?);
        `, [
            title.trim(),
            parseInt(release_year, 10),
            parseInt(duration_minutes, 10),
            language && language.trim() ? language.trim() : 'English',
            synopsis && synopsis.trim() ? synopsis.trim() : null,
            normalizePosterUrl(poster_url),
            prequel_movie_id ? parseInt(prequel_movie_id, 10) : null
        ]);

        const newMovieId = movieResult.insertId;

        if (genre_name && genre_name.trim()) {
            await conn.query(
                `INSERT INTO movie_genres (movie_id, genre_name) VALUES (?, ?);`,
                [newMovieId, genre_name.trim()]
            );
        }

        if (director_name && director_name.trim()) {
            const dirName = director_name.trim();
            const [existing] = await conn.query(
                `SELECT person_id FROM film_professionals WHERE name = ? LIMIT 1;`,
                [dirName]
            );
            let personId;
            if (existing.length > 0) {
                personId = existing[0].person_id;
            } else {
                const [personRes] = await conn.query(
                    `INSERT INTO film_professionals (name, nationality, biography) VALUES (?, 'International', 'Filmmaker catalogued in FilmCraft.');`,
                    [dirName]
                );
                personId = personRes.insertId;
            }
            await conn.query(
                `INSERT INTO movie_cast_crew (movie_id, person_id, role_type) VALUES (?, ?, 'DIRECTOR');`,
                [newMovieId, personId]
            );
        }

        await conn.commit();
        res.status(201).json({
            success: true,
            movie: { movie_id: newMovieId, title: title.trim() }
        });
    } catch (err) {
        await conn.rollback();
        res.status(500).json({ success: false, error: err.message });
    } finally {
        conn.release();
    }
});

// UPDATE: Edit an existing movie's attributes, primary genre, and director
app.put('/api/movies/:id', async (req, res) => {
    const movieId = parseInt(req.params.id, 10);
    const {
        title,
        release_year,
        duration_minutes,
        language,
        synopsis,
        poster_url,
        genre_name,
        director_name,
        prequel_movie_id
    } = req.body;

    if (isNaN(movieId) || !title || !release_year || !duration_minutes) {
        return res.status(400).json({
            success: false,
            error: 'Valid movie, title, release year, and duration are required.'
        });
    }

    const parsedPrequel = prequel_movie_id ? parseInt(prequel_movie_id, 10) : null;
    if (parsedPrequel === movieId) {
        return res.status(400).json({
            success: false,
            error: 'A film cannot be a sequel to itself.'
        });
    }

    const conn = await pool.getConnection();
    try {
        await conn.beginTransaction();

        const [updateRes] = await conn.query(`
            UPDATE movies
            SET title = ?,
                release_year = ?,
                duration_minutes = ?,
                language = ?,
                synopsis = ?,
                poster_url = ?,
                prequel_movie_id = ?
            WHERE movie_id = ?;
        `, [
            title.trim(),
            parseInt(release_year, 10),
            parseInt(duration_minutes, 10),
            language && language.trim() ? language.trim() : 'English',
            synopsis && synopsis.trim() ? synopsis.trim() : null,
            normalizePosterUrl(poster_url),
            parsedPrequel,
            movieId
        ]);

        if (updateRes.affectedRows === 0) {
            await conn.rollback();
            return res.status(404).json({ success: false, error: 'Film not found.' });
        }

        if (genre_name && genre_name.trim()) {
            await conn.query(`DELETE FROM movie_genres WHERE movie_id = ?;`, [movieId]);
            await conn.query(
                `INSERT INTO movie_genres (movie_id, genre_name) VALUES (?, ?);`,
                [movieId, genre_name.trim()]
            );
        }

        if (director_name && director_name.trim()) {
            const dirName = director_name.trim();
            const [existing] = await conn.query(
                `SELECT person_id FROM film_professionals WHERE name = ? LIMIT 1;`,
                [dirName]
            );
            let personId;
            if (existing.length > 0) {
                personId = existing[0].person_id;
            } else {
                const [personRes] = await conn.query(
                    `INSERT INTO film_professionals (name, nationality, biography) VALUES (?, 'International', 'Filmmaker catalogued in FilmCraft.');`,
                    [dirName]
                );
                personId = personRes.insertId;
            }
            await conn.query(
                `DELETE FROM movie_cast_crew WHERE movie_id = ? AND role_type = 'DIRECTOR';`,
                [movieId]
            );
            await conn.query(
                `INSERT INTO movie_cast_crew (movie_id, person_id, role_type) VALUES (?, ?, 'DIRECTOR');`,
                [movieId, personId]
            );
        }

        await conn.commit();
        res.json({ success: true, message: 'Film updated.' });
    } catch (err) {
        await conn.rollback();
        res.status(500).json({ success: false, error: err.message });
    } finally {
        conn.release();
    }
});

// DELETE: Remove a movie (cascades to movie_genres, movie_cast_crew, reviews; sets sequels' prequel_movie_id to NULL)
app.delete('/api/movies/:id', async (req, res) => {
    const movieId = parseInt(req.params.id, 10);
    if (isNaN(movieId)) {
        return res.status(400).json({ success: false, error: 'Invalid film identifier.' });
    }

    try {
        const [result] = await pool.query(`DELETE FROM movies WHERE movie_id = ?;`, [movieId]);
        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, error: 'Film not found.' });
        }
        res.json({ success: true, message: 'Film deleted.' });
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

// ====================================================================
// 2. REVIEWS — FULL CRUD (READ, CREATE, UPDATE, DELETE)
// ====================================================================

// READ: All reviews for a specific movie
app.get('/api/movies/:id/reviews', async (req, res) => {
    const movieId = parseInt(req.params.id, 10);
    if (isNaN(movieId)) {
        return res.status(400).json({ success: false, error: 'Invalid film identifier.' });
    }

    try {
        const [rows] = await pool.query(`
            SELECT 
                R.review_id,
                R.user_id,
                R.movie_id,
                U.username,
                U.role,
                U.membership_tier,
                U.publication_name,
                R.rating,
                R.review_text,
                R.contains_spoilers,
                R.watch_date,
                R.created_at
            FROM reviews R
            JOIN users U ON R.user_id = U.user_id
            WHERE R.movie_id = ?
            ORDER BY R.created_at DESC;
        `, [movieId]);

        res.json({ success: true, count: rows.length, data: rows });
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

// READ: All recent reviews across all films (for the Reviews CRUD management view)
app.get('/api/reviews', async (req, res) => {
    try {
        const [rows] = await pool.query(`
            SELECT 
                R.review_id,
                R.user_id,
                R.movie_id,
                M.title AS movie_title,
                M.release_year,
                M.poster_url,
                U.username,
                U.role,
                U.membership_tier,
                U.publication_name,
                R.rating,
                R.review_text,
                R.contains_spoilers,
                R.watch_date,
                R.created_at
            FROM reviews R
            JOIN users U ON R.user_id = U.user_id
            JOIN movies M ON R.movie_id = M.movie_id
            ORDER BY R.created_at DESC, R.review_id DESC;
        `);

        res.json({ success: true, count: rows.length, data: rows });
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

// CREATE: Insert a new review (0-5 stars)
app.post('/api/reviews', async (req, res) => {
    const { user_id, movie_id, rating, review_text, contains_spoilers } = req.body;
    const parsedUser = parseInt(user_id, 10);
    const parsedMovie = parseInt(movie_id, 10);
    const parsedRating = parseInt(rating, 10);

    if (isNaN(parsedUser) || isNaN(parsedMovie) || isNaN(parsedRating) || parsedRating < 0 || parsedRating > 5) {
        return res.status(400).json({
            success: false,
            error: 'Valid user, film, and rating (0-5 stars) are required.'
        });
    }

    try {
        const [result] = await pool.query(`
            INSERT INTO reviews (user_id, movie_id, rating, review_text, contains_spoilers, watch_date, created_at)
            VALUES (?, ?, ?, ?, ?, CURDATE(), NOW());
        `, [parsedUser, parsedMovie, parsedRating, review_text || '', contains_spoilers ? 1 : 0]);

        res.status(201).json({
            success: true,
            review_id: result.insertId,
            message: 'Review recorded.'
        });
    } catch (err) {
        if (err.code === 'ER_DUP_ENTRY') {
            return res.status(409).json({
                success: false,
                error: 'This reviewer has already reviewed this film. Use Edit below to update it.'
            });
        }
        res.status(500).json({ success: false, error: err.message });
    }
});

// UPDATE: Edit an existing review's star rating, commentary, or spoiler flag
app.put('/api/reviews/:id', async (req, res) => {
    const reviewId = parseInt(req.params.id, 10);
    const { rating, review_text, contains_spoilers } = req.body;
    const parsedRating = parseInt(rating, 10);

    if (isNaN(reviewId) || isNaN(parsedRating) || parsedRating < 0 || parsedRating > 5) {
        return res.status(400).json({
            success: false,
            error: 'Valid review and rating (0-5 stars) are required.'
        });
    }

    try {
        const [result] = await pool.query(`
            UPDATE reviews
            SET rating = ?,
                review_text = ?,
                contains_spoilers = ?
            WHERE review_id = ?;
        `, [parsedRating, review_text || '', contains_spoilers ? 1 : 0, reviewId]);

        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, error: 'Review not found.' });
        }

        res.json({ success: true, message: 'Review updated.' });
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

// DELETE: Remove a review
app.delete('/api/reviews/:id', async (req, res) => {
    const reviewId = parseInt(req.params.id, 10);
    if (isNaN(reviewId)) {
        return res.status(400).json({ success: false, error: 'Invalid review identifier.' });
    }

    try {
        const [result] = await pool.query(`DELETE FROM reviews WHERE review_id = ?;`, [reviewId]);
        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, error: 'Review not found.' });
        }
        res.json({ success: true, message: 'Review deleted.' });
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

// ====================================================================
// 3. USERS — READ & CREATE (Disjoint Cinephile / Critic Registration)
// ====================================================================

app.get('/api/users', async (req, res) => {
    try {
        const [rows] = await pool.query(`
            SELECT user_id, username, email, role, membership_tier, publication_name, created_at
            FROM users
            ORDER BY user_id ASC;
        `);
        res.json({ success: true, data: rows });
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

app.post('/api/users', async (req, res) => {
    const { username, email, role, membership_tier, publication_name } = req.body;

    if (!username || !email) {
        return res.status(400).json({ success: false, error: 'Username and email are required.' });
    }

    const assignedRole = role === 'CRITIC' ? 'CRITIC' : 'CINEPHILE';
    const tier = assignedRole === 'CINEPHILE'
        ? (['FREE', 'PRO', 'PATRON'].includes(membership_tier) ? membership_tier : 'FREE')
        : null;
    const pub = assignedRole === 'CRITIC'
        ? (publication_name && publication_name.trim() ? publication_name.trim() : 'Independent Press')
        : null;

    try {
        const [result] = await pool.query(`
            INSERT INTO users (username, email, role, membership_tier, publication_name, created_at)
            VALUES (?, ?, ?, ?, ?, NOW());
        `, [username.trim(), email.trim(), assignedRole, tier, pub]);

        res.status(201).json({
            success: true,
            user: {
                user_id: result.insertId,
                username: username.trim(),
                email: email.trim(),
                role: assignedRole
            }
        });
    } catch (err) {
        if (err.code === 'ER_DUP_ENTRY') {
            return res.status(409).json({ success: false, error: 'Username or email is already registered.' });
        }
        res.status(500).json({ success: false, error: err.message });
    }
});

// ====================================================================
// 4. ANALYTICS — KEY SQL SHOWCASE (GROUP BY + RELATIONAL DIVISION)
// ====================================================================

// Director Leaderboard (Pre-aggregated multi-table JOIN + GROUP BY + HAVING)
app.get('/api/directors', async (req, res) => {
    try {
        const [rows] = await pool.query(`
            SELECT 
                FP.person_id,
                FP.name AS director_name,
                FP.nationality,
                COUNT(DISTINCT MCC.movie_id) AS total_films_directed,
                COALESCE(SUM(R_Agg.total_reviews), 0) AS total_reviews,
                COALESCE(ROUND(AVG(R_Agg.average_rating), 2), 0.00) AS average_rating
            FROM film_professionals FP
            JOIN movie_cast_crew MCC ON FP.person_id = MCC.person_id AND MCC.role_type = 'DIRECTOR'
            LEFT JOIN (
                SELECT movie_id, COUNT(review_id) AS total_reviews, AVG(rating) AS average_rating
                FROM reviews
                GROUP BY movie_id
            ) R_Agg ON MCC.movie_id = R_Agg.movie_id
            GROUP BY FP.person_id, FP.name, FP.nationality
            HAVING COUNT(DISTINCT MCC.movie_id) >= 1
            ORDER BY average_rating DESC, total_reviews DESC;
        `);
        res.json({ success: true, data: rows });
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

// Christopher Nolan Completionist Challenge (Relational Division via Double NOT EXISTS)
app.get('/api/division/nolan', async (req, res) => {
    try {
        const [nolanMovies] = await pool.query(`
            SELECT M.movie_id, M.title, M.release_year, M.poster_url
            FROM movies M
            JOIN movie_cast_crew MCC ON M.movie_id = MCC.movie_id
            JOIN film_professionals FP ON MCC.person_id = FP.person_id
            WHERE FP.name = 'Christopher Nolan' AND MCC.role_type = 'DIRECTOR'
            ORDER BY M.release_year ASC;
        `);

        const [winners] = await pool.query(`
            SELECT U.user_id, U.username, U.email, U.role, U.membership_tier, U.publication_name
            FROM users U
            WHERE NOT EXISTS (
                SELECT M.movie_id
                FROM movies M
                JOIN movie_cast_crew MCC ON M.movie_id = MCC.movie_id
                JOIN film_professionals FP ON MCC.person_id = FP.person_id
                WHERE FP.name = 'Christopher Nolan' AND MCC.role_type = 'DIRECTOR'
                AND NOT EXISTS (
                    SELECT 1
                    FROM reviews R
                    WHERE R.user_id = U.user_id
                      AND R.movie_id = M.movie_id
                )
            );
        `);

        res.json({
            success: true,
            director: 'Christopher Nolan',
            total_nolan_movies: nolanMovies.length,
            nolan_movies: nolanMovies,
            division_winners: winners
        });
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

app.listen(PORT, () => {
    console.log(`====================================================`);
    console.log(`🎬 FilmCraft Web Server is running!`);
    console.log(`🌐 Local URL: http://localhost:${PORT}`);
    console.log(`====================================================`);
});
