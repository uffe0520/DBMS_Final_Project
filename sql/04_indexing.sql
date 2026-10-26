-- ====================================================================
-- HKU COMP3278A — Database Indexing & Performance Optimization
-- System: FilmCraft (Letterboxd+) Cinema Platform
-- Topic: Chapter 6 (Database Storage, B+ Tree Indexing & Query Plans)
-- ====================================================================

USE `filmcraft`;

-- --------------------------------------------------------------------
-- 1. Identify Bottlenecks & Missing Indexes
-- --------------------------------------------------------------------
-- High-frequency queries in FilmCraft:
--   1. Filter screenings by date range: WHERE screening_datetime BETWEEN ? AND ?
--   2. Join and calculate average ratings per movie: GROUP BY movie_id
--   3. Filter directors/cast by person and role: WHERE person_id = ? AND role_type = 'DIRECTOR'
--   4. Filter movies by release year: WHERE release_year = ?

-- --------------------------------------------------------------------
-- 2. Create Strategic B+ Tree Indexes
-- --------------------------------------------------------------------

-- Index 1: Composite B+ Tree Index on Reviews (movie_id, rating)
-- Accelerates GROUP BY movie_id and AVG(rating) calculations via an index-covering scan
CREATE INDEX `idx_reviews_movie_rating` 
ON `reviews` (`movie_id`, `rating`);

-- Index 2: B+ Tree Index on Theater Screenings (screening_datetime)
-- Accelerates date-range schedule lookups without scanning all historical screenings
CREATE INDEX `idx_screenings_datetime` 
ON `theater_screenings` (`screening_datetime`);

-- Index 3: Composite Index on Movie Cast/Crew (person_id, role_type)
-- Crucial for Relational Division and Director-specific queries
CREATE INDEX `idx_cast_person_role` 
ON `movie_cast_crew` (`person_id`, `role_type`);

-- Index 4: B+ Tree Index on Movies (release_year)
-- Accelerates decade/year filtering in the movie catalog
CREATE INDEX `idx_movies_release_year` 
ON `movies` (`release_year`);


-- --------------------------------------------------------------------
-- 3. Execution Plan Verification (EXPLAIN)
-- --------------------------------------------------------------------

-- Benchmark Query A: Theatrical Schedule Range Filter
-- With Index `idx_screenings_datetime`, MySQL executes a 'range' scan instead of 'ALL' (full table scan):
EXPLAIN 
SELECT * 
FROM `theater_screenings`
WHERE `screening_datetime` >= '2026-11-01 00:00:00' 
  AND `screening_datetime` < '2026-11-05 00:00:00';

-- Benchmark Query B: Composite Index Covering for Review Aggregations
-- With Index `idx_reviews_movie_rating`, MySQL uses index lookup ('ref') and avoids reading disk data blocks:
EXPLAIN 
SELECT `movie_id`, AVG(`rating`) AS `avg_score`
FROM `reviews`
WHERE `movie_id` = 5
GROUP BY `movie_id`;

-- Benchmark Query C: Director Filmography Index Scan
-- With Index `idx_cast_person_role`, MySQL uses direct 'ref' index lookup for person_id = 1:
EXPLAIN 
SELECT `movie_id`
FROM `movie_cast_crew`
WHERE `person_id` = 1 AND `role_type` = 'DIRECTOR';
