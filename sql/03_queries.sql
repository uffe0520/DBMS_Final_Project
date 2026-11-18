-- ====================================================================
-- FilmCraft: Key SQL Statements (Presentation & Verification Reference)
-- HKU COMP3278A — Introduction to Database Management Systems
-- 5 Core Tables · 100% Standard Chapter 3 SQL
-- ====================================================================

USE `filmcraft`;

-- --------------------------------------------------------------------
-- QUERY 1: Film Catalog — Multi-Table LEFT OUTER JOIN + COUNT/AVG + EXISTS
-- Purpose: Lists all films with prequel title, director, review count,
--          and average rating. Genres are fetched separately (Query 1B)
--          to avoid Cartesian fan-out against reviews.
-- --------------------------------------------------------------------
SELECT 
    M.movie_id,
    M.title,
    M.release_year,
    M.duration_minutes,
    M.language,
    M.synopsis,
    M.poster_url,
    P.title AS prequel_title,
    D.name AS director_name,
    COUNT(R.review_id) AS total_reviews,
    AVG(R.rating) AS average_rating
FROM movies M
LEFT OUTER JOIN movies P ON M.prequel_movie_id = P.movie_id
LEFT OUTER JOIN directors D ON M.director_id = D.director_id
LEFT OUTER JOIN reviews R ON M.movie_id = R.movie_id
GROUP BY
    M.movie_id, M.title, M.release_year, M.duration_minutes,
    M.language, M.synopsis, M.poster_url, P.title, D.name
ORDER BY average_rating DESC, total_reviews DESC, M.release_year DESC;

-- Query 1B: Fetch multi-valued genres cleanly without GROUP_CONCAT
SELECT movie_id, genre_name
FROM movie_genres
ORDER BY movie_id, genre_name;

-- Query 1C: Example genre search using standard EXISTS
SELECT M.movie_id, M.title, M.release_year
FROM movies M
WHERE EXISTS (
    SELECT 1
    FROM movie_genres MG
    WHERE MG.movie_id = M.movie_id
      AND MG.genre_name LIKE '%Sci-Fi%'
);

-- --------------------------------------------------------------------
-- QUERY 2: Full Explicit CRUD Operations (Reviews & Movies)
-- Purpose: Demonstrates parameterized CREATE, READ, UPDATE, DELETE
--          and referential integrity (ON DELETE CASCADE / SET NULL).
-- --------------------------------------------------------------------

-- [CREATE] Insert a new review (0-5 stars)
-- INSERT INTO reviews (user_id, movie_id, rating, review_text, contains_spoilers)
-- VALUES (?, ?, ?, ?, ?);

-- [READ] Retrieve all reviews for a given movie with reviewer details
SELECT 
    R.review_id,
    U.username,
    U.role,
    U.membership_tier,
    U.publication_name,
    R.rating,
    R.review_text,
    R.contains_spoilers
FROM reviews R
JOIN users U ON R.user_id = U.user_id
WHERE R.movie_id = 7
ORDER BY R.review_id DESC;

-- [UPDATE] Edit an existing review's rating, text, and spoiler flag
-- UPDATE reviews
-- SET rating = ?, review_text = ?, contains_spoilers = ?
-- WHERE review_id = ?;

-- [DELETE] Remove a review (or delete a movie, cascading to genres/reviews)
-- DELETE FROM reviews WHERE review_id = ?;
-- DELETE FROM movies WHERE movie_id = ?;

-- --------------------------------------------------------------------
-- QUERY 3A: Film Leaderboard (LEFT OUTER JOIN + COUNT / MIN / MAX / AVG)
-- Purpose: Ranks every catalogued film by average score and review volume.
-- --------------------------------------------------------------------
SELECT 
    M.title,
    M.release_year,
    D.name AS director_name,
    COUNT(R.review_id) AS total_reviews,
    MIN(R.rating) AS min_rating,
    MAX(R.rating) AS max_rating,
    AVG(R.rating) AS average_rating
FROM movies M
LEFT OUTER JOIN directors D ON M.director_id = D.director_id
LEFT OUTER JOIN reviews R ON M.movie_id = R.movie_id
GROUP BY M.movie_id, M.title, M.release_year, D.name
ORDER BY average_rating DESC, total_reviews DESC, M.title ASC;

-- --------------------------------------------------------------------
-- QUERY 3B: Director Leaderboard (JOIN + LEFT OUTER JOIN + GROUP BY)
-- Purpose: Ranks directors by film count, review count, and average
--          rating across all reviews of their directed films.
-- --------------------------------------------------------------------
SELECT 
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

-- --------------------------------------------------------------------
-- QUERY 4: Relational Division via Double NOT EXISTS (Any Selected Director)
-- Purpose: Finds users who have reviewed EVERY film directed by a chosen
--          director (parameterized by M.director_id = ? in src/server.js;
--          example below uses director_id = 1 for Christopher Nolan).
-- --------------------------------------------------------------------
SELECT 
    U.username,
    U.email,
    U.role,
    U.membership_tier,
    U.publication_name
FROM users U
WHERE NOT EXISTS (
    SELECT M.movie_id
    FROM movies M
    WHERE M.director_id = 1
      AND NOT EXISTS (
          SELECT 1
          FROM reviews R
          WHERE R.user_id = U.user_id
            AND R.movie_id = M.movie_id
      )
);
