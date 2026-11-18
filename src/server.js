const express = require('express');
const mysql = require('mysql2/promise');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 3001;
const POSTERS_DIR = path.join(__dirname, '..', 'posters');

fs.mkdirSync(POSTERS_DIR, { recursive: true });

app.use(express.json({ limit: '10mb' }));

// Disable browser caching during development and live demos
app.use((req, res, next) => {
    res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, proxy-revalidate');
    res.setHeader('Pragma', 'no-cache');
    res.setHeader('Expires', '0');
    next();
});

// Serve static frontend assets and single-source posters folder
app.use(express.static(path.join(__dirname, 'public'), { etag: false, maxAge: 0 }));
app.use('/posters', express.static(POSTERS_DIR, { etag: false, maxAge: 0 }));

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

// Helper: Normalize local poster paths (Linux/macOS/Windows) into web-accessible /posters/<filename>
function normalizePosterUrl(raw) {
    if (!raw || !raw.trim()) return null;
    const trimmed = raw.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        return trimmed;
    }
    const unixStyle = trimmed.replace(/\\/g, '/');
    if (unixStyle.includes('posters/')) {
        const filename = unixStyle.split('/').pop();
        return filename ? '/posters/' + filename : null;
    }
    if (!unixStyle.startsWith('/')) {
        return '/posters/' + unixStyle.split('/').pop();
    }
    return unixStyle;
}

// Helper: Resolve or insert a director by name inside an active transaction
async function resolveDirectorId(conn, directorName) {
    if (!directorName || !directorName.trim()) return null;
    const cleanName = directorName.trim();
    const [existing] = await conn.query(
        `SELECT director_id FROM directors WHERE name = ?;`,
        [cleanName]
    );
    if (existing.length > 0) {
        return existing[0].director_id;
    }
    const [inserted] = await conn.query(
        `INSERT INTO directors (name, nationality, biography) VALUES (?, 'International', 'Filmmaker catalogued in FilmCraft.');`,
        [cleanName]
    );
    return inserted.insertId;
}

// ====================================================================
// 0. POSTER IMAGE UPLOAD (Cross-Platform Drag & Drop into posters/)
// ====================================================================
app.post('/api/posters/upload', (req, res) => {
    const { filename, dataUrl } = req.body || {};
    if (!dataUrl || typeof dataUrl !== 'string') {
        return res.status(400).json({ success: false, error: 'Image data is required.' });
    }

    const match = dataUrl.match(/^data:(image\/(?:jpeg|jpg|png|webp|gif));base64,([A-Za-z0-9+/=\r\n]+)$/);
    if (!match) {
        return res.status(400).json({
            success: false,
            error: 'Unsupported image format. Please use JPG, PNG, WebP, or GIF.'
        });
    }

    const extMap = {
        'image/jpeg': '.jpg',
        'image/jpg': '.jpg',
        'image/png': '.png',
        'image/webp': '.webp',
        'image/gif': '.gif'
    };
    const ext = extMap[match[1]] || '.jpg';

    const rawBase = String(filename || 'poster')
        .replace(/\\/g, '/')
        .split('/')
        .pop()
        .replace(/\.[^.]+$/, '')
        .replace(/[^a-zA-Z0-9_-]/g, '_')
        .slice(0, 48) || 'poster';

    const safeFilename = `${rawBase}_${Date.now()}${ext}`;
    const destPath = path.join(POSTERS_DIR, safeFilename);

    try {
        fs.mkdirSync(POSTERS_DIR, { recursive: true });
        fs.writeFileSync(destPath, Buffer.from(match[2], 'base64'));
        res.status(201).json({
            success: true,
            filename: safeFilename,
            poster_url: `/posters/${safeFilename}`
        });
    } catch (err) {
        res.status(500).json({ success: false, error: 'Failed to save poster: ' + err.message });
    }
});

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
                M.director_id,
                M.prequel_movie_id,
                P.title AS prequel_title,
                D.name AS director_name,
                COUNT(R.review_id) AS total_reviews,
                AVG(R.rating) AS average_rating
            FROM movies M
            LEFT OUTER JOIN movies P ON M.prequel_movie_id = P.movie_id
            LEFT OUTER JOIN directors D ON M.director_id = D.director_id
            LEFT OUTER JOIN reviews R ON M.movie_id = R.movie_id
            WHERE (
                ? = ''
                OR M.title LIKE ?
                OR D.name LIKE ?
                OR EXISTS (
                    SELECT 1
                    FROM movie_genres MG
                    WHERE MG.movie_id = M.movie_id
                      AND MG.genre_name LIKE ?
                )
            )
            GROUP BY
                M.movie_id, M.title, M.release_year, M.duration_minutes,
                M.language, M.synopsis, M.poster_url, M.director_id,
                M.prequel_movie_id, P.title, D.name
            ORDER BY average_rating DESC, total_reviews DESC, M.release_year DESC;
        `, [q, searchLike, searchLike, searchLike]);

        const [genreRows] = await pool.query(`
            SELECT movie_id, genre_name
            FROM movie_genres
            ORDER BY movie_id, genre_name;
        `);

        const genresByMovie = {};
        for (const g of genreRows) {
            if (!genresByMovie[g.movie_id]) genresByMovie[g.movie_id] = [];
            genresByMovie[g.movie_id].push(g.genre_name);
        }

        const enriched = rows.map(m => ({
            ...m,
            genres: genresByMovie[m.movie_id] ? genresByMovie[m.movie_id].join(', ') : null
        }));

        res.json({ success: true, count: enriched.length, data: enriched });
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

// CREATE: Add a new movie (atomic transaction: directors + movies + movie_genres)
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

        const directorId = await resolveDirectorId(conn, director_name);

        const [movieResult] = await conn.query(`
            INSERT INTO movies (title, release_year, duration_minutes, language, synopsis, poster_url, director_id, prequel_movie_id)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?);
        `, [
            title.trim(),
            parseInt(release_year, 10),
            parseInt(duration_minutes, 10),
            language && language.trim() ? language.trim() : 'English',
            synopsis && synopsis.trim() ? synopsis.trim() : null,
            normalizePosterUrl(poster_url),
            directorId,
            prequel_movie_id ? parseInt(prequel_movie_id, 10) : null
        ]);

        const newMovieId = movieResult.insertId;

        if (genre_name && genre_name.trim()) {
            await conn.query(
                `INSERT INTO movie_genres (movie_id, genre_name) VALUES (?, ?);`,
                [newMovieId, genre_name.trim()]
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

// UPDATE: Edit an existing movie's attributes, director, and primary genre
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

        const directorId = await resolveDirectorId(conn, director_name);

        const [updateRes] = await conn.query(`
            UPDATE movies
            SET title = ?,
                release_year = ?,
                duration_minutes = ?,
                language = ?,
                synopsis = ?,
                poster_url = ?,
                director_id = ?,
                prequel_movie_id = ?
            WHERE movie_id = ?;
        `, [
            title.trim(),
            parseInt(release_year, 10),
            parseInt(duration_minutes, 10),
            language && language.trim() ? language.trim() : 'English',
            synopsis && synopsis.trim() ? synopsis.trim() : null,
            normalizePosterUrl(poster_url),
            directorId,
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

        await conn.commit();
        res.json({ success: true, message: 'Film updated.' });
    } catch (err) {
        await conn.rollback();
        res.status(500).json({ success: false, error: err.message });
    } finally {
        conn.release();
    }
});

// DELETE: Remove a movie (cascades to movie_genres and reviews; sets sequels' prequel_movie_id to NULL)
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
                R.contains_spoilers
            FROM reviews R
            JOIN users U ON R.user_id = U.user_id
            WHERE R.movie_id = ?
            ORDER BY R.review_id DESC;
        `, [movieId]);

        res.json({ success: true, count: rows.length, data: rows });
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

// READ: All reviews across all films (supports ?sort=newest|film|director|rating)
app.get('/api/reviews', async (req, res) => {
    const sortKey = req.query.sort || 'newest';
    const baseSelect = `
        SELECT 
            R.review_id,
            R.user_id,
            R.movie_id,
            M.title AS movie_title,
            M.release_year,
            M.poster_url,
            D.name AS director_name,
            U.username,
            U.role,
            U.membership_tier,
            U.publication_name,
            R.rating,
            R.review_text,
            R.contains_spoilers
        FROM reviews R
        JOIN users U ON R.user_id = U.user_id
        JOIN movies M ON R.movie_id = M.movie_id
        LEFT OUTER JOIN directors D ON M.director_id = D.director_id
    `;

    let sql;
    if (sortKey === 'film') {
        sql = baseSelect + ' ORDER BY M.title ASC, R.rating DESC, R.review_id DESC;';
    } else if (sortKey === 'director') {
        sql = baseSelect + ' ORDER BY D.name ASC, M.title ASC, R.rating DESC;';
    } else if (sortKey === 'rating') {
        sql = baseSelect + ' ORDER BY R.rating DESC, M.title ASC, R.review_id DESC;';
    } else {
        sql = baseSelect + ' ORDER BY R.review_id DESC;';
    }

    try {
        const [rows] = await pool.query(sql);
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
            INSERT INTO reviews (user_id, movie_id, rating, review_text, contains_spoilers)
            VALUES (?, ?, ?, ?, ?);
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
            SELECT user_id, username, email, role, membership_tier, publication_name
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
            INSERT INTO users (username, email, role, membership_tier, publication_name)
            VALUES (?, ?, ?, ?, ?);
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
// 4. ANALYTICS — LEADERBOARDS & RELATIONAL DIVISION
// ====================================================================

// Film Leaderboard (LEFT OUTER JOIN + COUNT/MIN/MAX/AVG + GROUP BY)
app.get('/api/leaderboard/films', async (req, res) => {
    try {
        const [rows] = await pool.query(`
            SELECT 
                M.movie_id,
                M.title,
                M.release_year,
                M.poster_url,
                D.name AS director_name,
                COUNT(R.review_id) AS total_reviews,
                MIN(R.rating) AS min_rating,
                MAX(R.rating) AS max_rating,
                AVG(R.rating) AS average_rating
            FROM movies M
            LEFT OUTER JOIN directors D ON M.director_id = D.director_id
            LEFT OUTER JOIN reviews R ON M.movie_id = R.movie_id
            GROUP BY M.movie_id, M.title, M.release_year, M.poster_url, D.name
            ORDER BY average_rating DESC, total_reviews DESC, M.title ASC;
        `);
        res.json({ success: true, data: rows });
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

// Director Leaderboard (JOIN + LEFT OUTER JOIN + GROUP BY)
app.get('/api/directors', async (req, res) => {
    try {
        const [rows] = await pool.query(`
            SELECT 
                D.director_id,
                D.name AS director_name,
                D.nationality,
                COUNT(DISTINCT M.movie_id) AS total_films_directed,
                COUNT(R.review_id) AS total_reviews,
                AVG(R.rating) AS average_rating
            FROM directors D
            JOIN movies M ON D.director_id = M.director_id
            LEFT OUTER JOIN reviews R ON M.movie_id = R.movie_id
            GROUP BY D.director_id, D.name, D.nationality
            ORDER BY average_rating DESC, total_reviews DESC;
        `);
        res.json({ success: true, data: rows });
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

// Director Completionist Challenge (Parameterized Relational Division via Double NOT EXISTS)
app.get('/api/division', async (req, res) => {
    const directorId = parseInt(req.query.directorId || '1', 10);
    if (isNaN(directorId)) {
        return res.status(400).json({ success: false, error: 'Valid director identifier is required.' });
    }

    try {
        const [dirRows] = await pool.query(
            `SELECT director_id, name FROM directors WHERE director_id = ?;`,
            [directorId]
        );
        if (dirRows.length === 0) {
            return res.status(404).json({ success: false, error: 'Director not found.' });
        }

        const [directorMovies] = await pool.query(`
            SELECT M.movie_id, M.title, M.release_year, M.poster_url
            FROM movies M
            WHERE M.director_id = ?
            ORDER BY M.release_year ASC;
        `, [directorId]);

        let winners = [];
        if (directorMovies.length > 0) {
            const [winnerRows] = await pool.query(`
                SELECT U.user_id, U.username, U.email, U.role, U.membership_tier, U.publication_name
                FROM users U
                WHERE NOT EXISTS (
                    SELECT M.movie_id
                    FROM movies M
                    WHERE M.director_id = ?
                      AND NOT EXISTS (
                          SELECT 1
                          FROM reviews R
                          WHERE R.user_id = U.user_id
                            AND R.movie_id = M.movie_id
                      )
                );
            `, [directorId]);
            winners = winnerRows;
        }

        res.json({
            success: true,
            director_id: dirRows[0].director_id,
            director_name: dirRows[0].name,
            total_movies: directorMovies.length,
            movies: directorMovies,
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
