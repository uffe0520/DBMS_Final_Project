-- ====================================================================
-- FilmCraft: Key SQL Statements (Presentation & Verification Reference)
-- HKU COMP3278A — Introduction to Database Management Systems
-- 4 Core SQL Patterns Directly Executed by the Web Application
-- ====================================================================

USE `filmcraft`;

-- --------------------------------------------------------------------
-- QUERY 1: Multi-Table JOIN with Derived Table Pre-Aggregation
-- Purpose: Populates the Film Catalog without Cartesian fan-out
--          multiplication between multi-valued genres and reviews.
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
    FP.name AS director_name,
    MG_Agg.genres,
    COALESCE(R_Agg.total_reviews, 0) AS total_reviews,
    COALESCE(R_Agg.average_rating, 0.0) AS average_rating
FROM movies M
LEFT JOIN movies P
    ON M.prequel_movie_id = P.movie_id
LEFT JOIN movie_cast_crew MCC
    ON M.movie_id = MCC.movie_id AND MCC.role_type = 'DIRECTOR'
LEFT JOIN film_professionals FP
    ON MCC.person_id = FP.person_id
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
ORDER BY average_rating DESC, total_reviews DESC, M.release_year DESC;

-- --------------------------------------------------------------------
-- QUERY 2: Full Explicit CRUD Operations (Reviews & Movies)
-- Purpose: Demonstrates parameterized CREATE, READ, UPDATE, DELETE
--          and referential integrity (ON DELETE CASCADE / SET NULL).
-- --------------------------------------------------------------------

-- [CREATE] Insert a new review (0-5 stars)
-- INSERT INTO reviews (user_id, movie_id, rating, review_text, contains_spoilers, watch_date)
-- VALUES (?, ?, ?, ?, ?, CURDATE());

-- [READ] Retrieve all reviews for a given movie with reviewer details
SELECT 
    R.review_id,
    U.username,
    U.role,
    U.membership_tier,
    U.publication_name,
    R.rating,
    R.review_text,
    R.contains_spoilers,
    R.watch_date
FROM reviews R
JOIN users U ON R.user_id = U.user_id
WHERE R.movie_id = 7
ORDER BY R.created_at DESC;

-- [UPDATE] Edit an existing review's rating, text, and spoiler flag
-- UPDATE reviews
-- SET rating = ?, review_text = ?, contains_spoilers = ?
-- WHERE review_id = ?;

-- [DELETE] Remove a review (or delete a movie, cascading to genres/cast/reviews)
-- DELETE FROM reviews WHERE review_id = ?;
-- DELETE FROM movies WHERE movie_id = ?;

-- --------------------------------------------------------------------
-- QUERY 3: Multi-Table Aggregation & Grouping (Director Leaderboard)
-- Purpose: Ranks directors by average rating across their catalogued
--          films using pre-aggregated review scores.
-- --------------------------------------------------------------------
SELECT 
    FP.name AS director_name,
    FP.nationality,
    COUNT(DISTINCT MCC.movie_id) AS total_films_directed,
    COALESCE(SUM(R_Agg.total_reviews), 0) AS total_reviews,
    COALESCE(ROUND(AVG(R_Agg.average_rating), 2), 0.00) AS average_rating
FROM film_professionals FP
JOIN movie_cast_crew MCC
    ON FP.person_id = MCC.person_id AND MCC.role_type = 'DIRECTOR'
LEFT JOIN (
    SELECT movie_id, COUNT(review_id) AS total_reviews, AVG(rating) AS average_rating
    FROM reviews
    GROUP BY movie_id
) R_Agg ON MCC.movie_id = R_Agg.movie_id
GROUP BY FP.person_id, FP.name, FP.nationality
HAVING COUNT(DISTINCT MCC.movie_id) >= 1
ORDER BY average_rating DESC, total_reviews DESC;

-- --------------------------------------------------------------------
-- QUERY 4: Relational Division via Double NOT EXISTS
-- Purpose: Finds users who have reviewed EVERY film directed by
--          Christopher Nolan in the database (Universal Quantification).
-- --------------------------------------------------------------------
SELECT 
    U.username,
    U.email,
    U.role,
    U.membership_tier
FROM users U
WHERE NOT EXISTS (
    SELECT M.movie_id
    FROM movies M
    JOIN movie_cast_crew MCC ON M.movie_id = MCC.movie_id
    JOIN film_professionals FP ON MCC.person_id = FP.person_id
    WHERE FP.name = 'Christopher Nolan'
      AND MCC.role_type = 'DIRECTOR'
      AND NOT EXISTS (
          SELECT 1
          FROM reviews R
          WHERE R.user_id = U.user_id
            AND R.movie_id = M.movie_id
      )
);
