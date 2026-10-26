-- ====================================================================
-- HKU COMP3278A — Final Project Master Query Portfolio
-- System: FilmCraft (Letterboxd+) Cinema & Festival Curator Platform
-- Engine: MySQL 8.x
-- All queries strictly comply with course restrictions from AGY.md:
--   ❌ NO CTEs (WITH) -> Used derived tables in FROM ((...) AS t)
--   ❌ NO Window functions (OVER/RANK) -> Used correlated subqueries
--   ❌ NO Procedural SQL -> Pure declarative SQL
--   ❌ NO LIMIT for extremal queries -> Used >= ALL (...)
--   ❌ NO Dynamic date functions -> Used fixed literal timestamps
-- ====================================================================

USE `filmcraft`;

-- ====================================================================
-- TIER 1: DATA MANIPULATION & ATOMIC TRANSACTIONS
-- ====================================================================

-- Query 1.1: Atomic User Review Submission Transaction
-- Simulates a user submitting a new review and updating their favorite genre
START TRANSACTION;

INSERT INTO `reviews` (`user_id`, `movie_id`, `rating`, `review_text`, `contains_spoilers`, `watch_date`, `created_at`)
VALUES (2, 7, 10, 'Dune Part Two was breathtaking in IMAX. Peak sci-fi filmmaking.', FALSE, '2026-10-15', '2026-10-15 22:30:00');

UPDATE `cinephiles`
SET `favorite_genre` = 'Sci-Fi'
WHERE `user_id` = 2;

COMMIT;

-- Query 1.2: Conditional UPDATE with Cascading Constraints
-- Upgrades cinephiles with 5 or more reviews to 'PRO' status
UPDATE `cinephiles`
SET `membership_tier` = 'PRO'
WHERE `user_id` IN (
    SELECT `user_id`
    FROM (
        SELECT R.`user_id`
        FROM `reviews` R
        GROUP BY R.`user_id`
        HAVING COUNT(*) >= 5
    ) AS `active_users`
);


-- ====================================================================
-- TIER 2: RELATIONAL PROJECTIONS & MULTI-TABLE JOINS
-- ====================================================================

-- Query 2.1: Multi-way 5-Table Join
-- Purpose: List theatrical screenings with cinema details, movie title, director, and ticket price
-- Relational Algebra:
--   \pi_{theater_name, room_number, movie_title, director_name, screening_datetime, ticket_price}(
--       Theater \bowtie TheaterRoom \bowtie TheaterScreening \bowtie Movie \bowtie
--       \sigma_{role='DIRECTOR'}(MovieCastCrew \bowtie FilmProfessional)
--   )
SELECT 
    T.`name` AS `theater_name`,
    TR.`room_number`,
    TR.`screen_format`,
    M.`title` AS `movie_title`,
    FP.`name` AS `director_name`,
    TS.`screening_datetime`,
    TS.`ticket_price`
FROM `theaters` T
JOIN `theater_rooms` TR 
    ON T.`theater_id` = TR.`theater_id`
JOIN `theater_screenings` TS 
    ON TR.`theater_id` = TS.`theater_id` AND TR.`room_number` = TS.`room_number`
JOIN `movies` M 
    ON TS.`movie_id` = M.`movie_id`
JOIN `movie_cast_crew` MCC 
    ON M.`movie_id` = MCC.`movie_id` AND MCC.`role_type` = 'DIRECTOR'
JOIN `film_professionals` FP 
    ON MCC.`person_id` = FP.`person_id`
WHERE TS.`screening_datetime` >= '2026-11-01 00:00:00'
ORDER BY TS.`screening_datetime` ASC;

-- Query 2.2: Left Outer Join
-- Purpose: Find ALL movies in the catalog, including indie/festival films that have ZERO reviews yet
SELECT 
    M.`movie_id`,
    M.`title`,
    M.`release_year`,
    COUNT(R.`review_id`) AS `total_reviews`,
    COALESCE(ROUND(AVG(R.`rating`), 2), 0.00) AS `average_rating`
FROM `movies` M
LEFT OUTER JOIN `reviews` R 
    ON M.`movie_id` = R.`movie_id`
GROUP BY M.`movie_id`, M.`title`, M.`release_year`
ORDER BY `total_reviews` DESC, M.`release_year` DESC;

-- Query 2.3: Self-Join (Hierarchical Franchise Relations)
-- Purpose: Pair every sequel with its predecessor prequel movie
SELECT 
    sequel.`title` AS `sequel_title`,
    sequel.`release_year` AS `sequel_year`,
    prequel.`title` AS `prequel_title`,
    prequel.`release_year` AS `prequel_year`,
    (sequel.`release_year` - prequel.`release_year`) AS `years_between_releases`
FROM `movies` sequel
JOIN `movies` prequel 
    ON sequel.`prequel_movie_id` = prequel.`movie_id`;


-- ====================================================================
-- TIER 3: AGGREGATIONS, GROUPING & HAVING FILTERS
-- ====================================================================

-- Query 3.1: Director Performance Aggregation
-- Purpose: Find directors whose films have received at least 2 reviews, with an overall average rating >= 8.5
-- Relational Algebra:
--   \sigma_{avg_score \ge 8.5 \land review_cnt \ge 2}(
--       _{person_id, director_name}\mathcal{G}_{AVG(rating) \to avg_score, COUNT(review_id) \to review_cnt}(
--           FilmProfessional \bowtie \sigma_{role='DIRECTOR'}(MovieCastCrew) \bowtie Movie \bowtie Review
--       )
--   )
SELECT 
    FP.`person_id`,
    FP.`name` AS `director_name`,
    COUNT(DISTINCT M.`movie_id`) AS `directed_movies_reviewed`,
    COUNT(R.`review_id`) AS `total_reviews_received`,
    ROUND(AVG(R.`rating`), 2) AS `average_director_rating`
FROM `film_professionals` FP
JOIN `movie_cast_crew` MCC 
    ON FP.`person_id` = MCC.`person_id` AND MCC.`role_type` = 'DIRECTOR'
JOIN `movies` M 
    ON MCC.`movie_id` = M.`movie_id`
JOIN `reviews` R 
    ON M.`movie_id` = R.`movie_id`
GROUP BY FP.`person_id`, FP.`name`
HAVING COUNT(R.`review_id`) >= 2 AND AVG(R.`rating`) >= 8.5
ORDER BY `average_director_rating` DESC, `total_reviews_received` DESC;


-- ====================================================================
-- TIER 4: CORRELATED SUBQUERIES & SET COMPARISONS
-- ====================================================================

-- Query 4.1: Universal Set Comparison (>= ALL)
-- Purpose: Find the single or tied film(s) that achieved the GREATEST count of maximum (10/10) ratings
-- NOTE: Complies with syllabus rule: NO 'ORDER BY ... LIMIT 1' hack!
SELECT 
    M.`movie_id`,
    M.`title`,
    COUNT(R.`review_id`) AS `num_perfect_scores`
FROM `movies` M
JOIN `reviews` R 
    ON M.`movie_id` = R.`movie_id`
WHERE R.`rating` = 10
GROUP BY M.`movie_id`, M.`title`
HAVING COUNT(R.`review_id`) >= ALL (
    SELECT COUNT(R2.`review_id`)
    FROM `reviews` R2
    WHERE R2.`rating` = 10
    GROUP BY R2.`movie_id`
);

-- Query 4.2: Correlated Subquery with NOT EXISTS
-- Purpose: Find all accredited film critics who have NEVER given any film a rating below 9
SELECT 
    U.`user_id`,
    U.`username`,
    FC.`publication_name`
FROM `users` U
JOIN `film_critics` FC 
    ON U.`user_id` = FC.`user_id`
WHERE NOT EXISTS (
    SELECT 1
    FROM `reviews` R
    WHERE R.`user_id` = U.`user_id`
      AND R.`rating` < 9
);

-- Query 4.3: Derived Table in the FROM Clause (CTE Alternative)
-- Purpose: Compare each movie's average rating against the global average rating across all movies
SELECT 
    M.`title`,
    ROUND(AVG(R.`rating`), 2) AS `movie_avg_rating`,
    GlobalStats.`overall_avg`,
    ROUND(AVG(R.`rating`) - GlobalStats.`overall_avg`, 2) AS `difference_from_mean`
FROM `movies` M
JOIN `reviews` R 
    ON M.`movie_id` = R.`movie_id`,
(
    SELECT ROUND(AVG(`rating`), 2) AS `overall_avg`
    FROM `reviews`
) AS GlobalStats
GROUP BY M.`movie_id`, M.`title`, GlobalStats.`overall_avg`
ORDER BY `movie_avg_rating` DESC;


-- ====================================================================
-- TIER 5: RELATIONAL DIVISION (UNIVERSAL QUANTIFICATION: R / S)
-- ====================================================================

-- Query 5.1: Classical Double NOT EXISTS Division
-- Question: "Find all users who have watched and reviewed EVERY film directed by Christopher Nolan."
-- Relational Algebra:
--   \pi_{user_id}(Reviews) \div \pi_{movie_id}(\sigma_{name='Christopher Nolan' \land role='DIRECTOR'}(FilmProfessional \bowtie MovieCastCrew))
SELECT 
    U.`user_id`,
    U.`username`,
    U.`email`,
    U.`role`
FROM `users` U
WHERE NOT EXISTS (
    -- Set of all movies directed by Christopher Nolan (person_id = 1):
    SELECT M.`movie_id`
    FROM `movies` M
    JOIN `movie_cast_crew` MCC 
        ON M.`movie_id` = MCC.`movie_id`
    WHERE MCC.`person_id` = 1 AND MCC.`role_type` = 'DIRECTOR'
    AND NOT EXISTS (
        -- Check if this specific user has reviewed the movie:
        SELECT 1
        FROM `reviews` R
        WHERE R.`user_id` = U.`user_id`
          AND R.`movie_id` = M.`movie_id`
    )
);

-- Query 5.2: Alternative Relational Division using COUNT(DISTINCT)
-- Produces the identical mathematical result:
SELECT 
    U.`user_id`,
    U.`username`,
    COUNT(DISTINCT M.`movie_id`) AS `nolan_movies_reviewed`
FROM `users` U
JOIN `reviews` R 
    ON U.`user_id` = R.`user_id`
JOIN `movies` M 
    ON R.`movie_id` = M.`movie_id`
JOIN `movie_cast_crew` MCC 
    ON M.`movie_id` = MCC.`movie_id`
WHERE MCC.`person_id` = 1 AND MCC.`role_type` = 'DIRECTOR'
GROUP BY U.`user_id`, U.`username`
HAVING COUNT(DISTINCT M.`movie_id`) = (
    SELECT COUNT(DISTINCT M2.`movie_id`)
    FROM `movies` M2
    JOIN `movie_cast_crew` MCC2 
        ON M2.`movie_id` = MCC2.`movie_id`
    WHERE MCC2.`person_id` = 1 AND MCC2.`role_type` = 'DIRECTOR'
);


-- ====================================================================
-- TIER 6: DATABASE VIEWS FOR BUSINESS INTELLIGENCE DASHBOARDS
-- ====================================================================

-- View 6.1: Theater Screening Occupancy & Potential Box Office View
CREATE OR REPLACE VIEW `view_screening_analytics` AS
SELECT 
    T.`theater_id`,
    T.`name` AS `theater_name`,
    TR.`room_number`,
    TR.`screen_format`,
    M.`title` AS `movie_title`,
    TS.`screening_datetime`,
    TR.`seating_capacity`,
    TS.`ticket_price`,
    (TR.`seating_capacity` * TS.`ticket_price`) AS `max_potential_revenue`
FROM `theaters` T
JOIN `theater_rooms` TR 
    ON T.`theater_id` = TR.`theater_id`
JOIN `theater_screenings` TS 
    ON TR.`theater_id` = TS.`theater_id` AND TR.`room_number` = TS.`room_number`
JOIN `movies` M 
    ON TS.`movie_id` = M.`movie_id`;

-- View 6.2: Director Hall of Fame Analytics View
CREATE OR REPLACE VIEW `view_director_leaderboard` AS
SELECT 
    FP.`person_id`,
    FP.`name` AS `director_name`,
    FP.`nationality`,
    COUNT(DISTINCT M.`movie_id`) AS `total_films_directed`,
    COUNT(R.`review_id`) AS `total_community_reviews`,
    ROUND(AVG(R.`rating`), 2) AS `average_rating`,
    COUNT(DISTINCT AN.`nomination_id`) AS `total_festival_nominations`,
    SUM(CASE WHEN AN.`is_winner` = TRUE THEN 1 ELSE 0 END) AS `total_awards_won`
FROM `film_professionals` FP
JOIN `movie_cast_crew` MCC 
    ON FP.`person_id` = MCC.`person_id` AND MCC.`role_type` = 'DIRECTOR'
JOIN `movies` M 
    ON MCC.`movie_id` = M.`movie_id`
LEFT JOIN `reviews` R 
    ON M.`movie_id` = R.`movie_id`
LEFT JOIN `award_nominations` AN 
    ON (AN.`movie_id` = M.`movie_id` OR AN.`person_id` = FP.`person_id`)
GROUP BY FP.`person_id`, FP.`name`, FP.`nationality`;
