const express = require('express');
const mysql = require('mysql2/promise');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3001;

app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// Database Connection Pool
const pool = mysql.createPool({
    host: '127.0.0.1',
    user: 'root',
    password: '',
    database: 'filmcraft',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    multipleStatements: false // Critical security guardrail against SQL injection
});

// Test connection
pool.getConnection()
    .then(conn => {
        console.log('✓ Successfully connected to MySQL `filmcraft` database');
        conn.release();
    })
    .catch(err => {
        console.error('✗ Failed to connect to MySQL `filmcraft` database:', err.message);
    });

// --------------------------------------------------------------------
// API 1: List all movies with ratings, director, and genres
// --------------------------------------------------------------------
app.get('/api/movies', async (req, res) => {
    try {
        const [rows] = await pool.query(`
            SELECT 
                M.movie_id,
                M.title,
                M.release_year,
                M.duration_minutes,
                M.language,
                M.synopsis,
                M.prequel_movie_id,
                P.title AS prequel_title,
                FP.name AS director_name,
                GROUP_CONCAT(DISTINCT MG.genre_name ORDER BY MG.genre_name SEPARATOR ', ') AS genres,
                COUNT(R.review_id) AS total_reviews,
                COALESCE(ROUND(AVG(R.rating), 1), 0.0) AS average_rating
            FROM movies M
            LEFT JOIN movies P ON M.prequel_movie_id = P.movie_id
            LEFT JOIN movie_cast_crew MCC ON M.movie_id = MCC.movie_id AND MCC.role_type = 'DIRECTOR'
            LEFT JOIN film_professionals FP ON MCC.person_id = FP.person_id
            LEFT JOIN movie_genres MG ON M.movie_id = MG.movie_id
            LEFT JOIN reviews R ON M.movie_id = R.movie_id
            GROUP BY M.movie_id, M.title, M.release_year, M.duration_minutes, M.language, M.synopsis, M.prequel_movie_id, P.title, FP.name
            ORDER BY average_rating DESC, release_year DESC;
        `);
        res.json({ success: true, count: rows.length, data: rows });
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

// --------------------------------------------------------------------
// API 2: Theatrical Screenings (Multi-Table 5-way Join)
// --------------------------------------------------------------------
app.get('/api/screenings', async (req, res) => {
    try {
        const [rows] = await pool.query(`
            SELECT 
                TS.screening_id,
                T.name AS theater_name,
                T.city,
                TR.room_number,
                TR.screen_format,
                TR.seating_capacity,
                M.movie_id,
                M.title AS movie_title,
                FP.name AS director_name,
                TS.screening_datetime,
                TS.ticket_price,
                (TR.seating_capacity * TS.ticket_price) AS potential_gross
            FROM theaters T
            JOIN theater_rooms TR ON T.theater_id = TR.theater_id
            JOIN theater_screenings TS ON TR.theater_id = TS.theater_id AND TR.room_number = TS.room_number
            JOIN movies M ON TS.movie_id = M.movie_id
            LEFT JOIN movie_cast_crew MCC ON M.movie_id = MCC.movie_id AND MCC.role_type = 'DIRECTOR'
            LEFT JOIN film_professionals FP ON MCC.person_id = FP.person_id
            ORDER BY TS.screening_datetime ASC;
        `);
        res.json({ success: true, count: rows.length, data: rows });
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

// --------------------------------------------------------------------
// API 3: Relational Division Query (Universal Quantification: R / S)
// "Find all cinephiles who reviewed EVERY Christopher Nolan film"
// --------------------------------------------------------------------
app.get('/api/division/nolan', async (req, res) => {
    try {
        const [nolanMovies] = await pool.query(`
            SELECT M.movie_id, M.title, M.release_year
            FROM movies M
            JOIN movie_cast_crew MCC ON M.movie_id = MCC.movie_id
            WHERE MCC.person_id = 1 AND MCC.role_type = 'DIRECTOR'
            ORDER BY M.release_year ASC;
        `);

        const [divisionWinners] = await pool.query(`
            SELECT 
                U.user_id,
                U.username,
                U.email,
                U.role,
                C.membership_tier,
                C.favorite_genre
            FROM users U
            JOIN cinephiles C ON U.user_id = C.user_id
            WHERE NOT EXISTS (
                SELECT M.movie_id
                FROM movies M
                JOIN movie_cast_crew MCC ON M.movie_id = MCC.movie_id
                WHERE MCC.person_id = 1 AND MCC.role_type = 'DIRECTOR'
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
            division_winners: divisionWinners,
            relational_algebra: "π_{user_id}(Reviews) ÷ π_{movie_id}(σ_{name='Christopher Nolan' ∧ role='DIRECTOR'}(FilmProfessional ⨝ MovieCastCrew))"
        });
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

// --------------------------------------------------------------------
// API 4: Director Leaderboard (Aggregations with HAVING)
// --------------------------------------------------------------------
app.get('/api/directors', async (req, res) => {
    try {
        const [rows] = await pool.query(`
            SELECT 
                FP.person_id,
                FP.name AS director_name,
                FP.nationality,
                COUNT(DISTINCT M.movie_id) AS total_films_directed,
                COUNT(R.review_id) AS total_reviews,
                COALESCE(ROUND(AVG(R.rating), 2), 0.00) AS average_rating,
                SUM(CASE WHEN AN.is_winner = TRUE THEN 1 ELSE 0 END) AS awards_won
            FROM film_professionals FP
            JOIN movie_cast_crew MCC ON FP.person_id = MCC.person_id AND MCC.role_type = 'DIRECTOR'
            JOIN movies M ON MCC.movie_id = M.movie_id
            LEFT JOIN reviews R ON M.movie_id = R.movie_id
            LEFT JOIN award_nominations AN ON (AN.movie_id = M.movie_id OR AN.person_id = FP.person_id)
            GROUP BY FP.person_id, FP.name, FP.nationality
            ORDER BY average_rating DESC, total_reviews DESC;
        `);
        res.json({ success: true, data: rows });
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

// --------------------------------------------------------------------
// API 5: Extremal Comparison (>= ALL) - Top Rated Movies
// --------------------------------------------------------------------
app.get('/api/extremal/top', async (req, res) => {
    try {
        const [rows] = await pool.query(`
            SELECT 
                M.movie_id,
                M.title,
                COUNT(R.review_id) AS num_perfect_scores
            FROM movies M
            JOIN reviews R ON M.movie_id = R.movie_id
            WHERE R.rating = 10
            GROUP BY M.movie_id, M.title
            HAVING COUNT(R.review_id) >= ALL (
                SELECT COUNT(R2.review_id)
                FROM reviews R2
                WHERE R2.rating = 10
                GROUP BY R2.movie_id
            );
        `);
        res.json({ success: true, data: rows });
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

// --------------------------------------------------------------------
// API 6: Submit a Review (Atomic Transaction)
// --------------------------------------------------------------------
app.post('/api/reviews', async (req, res) => {
    const { user_id, movie_id, rating, review_text, contains_spoilers } = req.body;

    if (!user_id || !movie_id || !rating) {
        return res.status(400).json({ success: false, error: 'user_id, movie_id, and rating are required.' });
    }

    const conn = await pool.getConnection();
    try {
        await conn.beginTransaction();

        // 1. Insert or update the review
        await conn.query(`
            INSERT INTO reviews (user_id, movie_id, rating, review_text, contains_spoilers, watch_date, created_at)
            VALUES (?, ?, ?, ?, ?, CURDATE(), NOW())
            ON DUPLICATE KEY UPDATE 
                rating = VALUES(rating), 
                review_text = VALUES(review_text),
                contains_spoilers = VALUES(contains_spoilers),
                watch_date = VALUES(watch_date);
        `, [user_id, movie_id, rating, review_text || '', contains_spoilers ? 1 : 0]);

        // 2. Fetch the movie's primary genre
        const [genreRows] = await conn.query(`
            SELECT genre_name FROM movie_genres WHERE movie_id = ? LIMIT 1;
        `, [movie_id]);

        if (genreRows.length > 0) {
            await conn.query(`
                UPDATE cinephiles 
                SET favorite_genre = ? 
                WHERE user_id = ?;
            `, [genreRows[0].genre_name, user_id]);
        }

        await conn.commit();
        res.json({ success: true, message: 'Review successfully recorded via ACID transaction.' });
    } catch (err) {
        await conn.rollback();
        res.status(500).json({ success: false, error: err.message });
    } finally {
        conn.release();
    }
});

// --------------------------------------------------------------------
// API 7: SQL Injection Demonstration Endpoint (Ch 7 Proof)
// --------------------------------------------------------------------
app.get('/api/search', async (req, res) => {
    const query = req.query.q || '';
    try {
        // Safe Parameterized Query
        const [rows] = await pool.query(`
            SELECT movie_id, title, release_year, synopsis 
            FROM movies 
            WHERE title LIKE ? OR synopsis LIKE ?;
        `, [`%${query}%`, `%${query}%`]);

        res.json({
            success: true,
            input_query: query,
            matched_records: rows.length,
            is_sanitized: true,
            security_note: "Input is bound to parameters; SQL injection payloads like `' OR '1'='1` are safely treated as raw string literals.",
            results: rows
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
