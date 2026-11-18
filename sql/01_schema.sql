-- ====================================================================
-- FilmCraft: Core Relational Database Schema (MySQL 8.x)
-- HKU COMP3278A — Introduction to Database Management Systems
-- 6 Normalized (BCNF) Core Tables:
--   1. users
--   2. movies
--   3. movie_genres
--   4. film_professionals
--   5. movie_cast_crew
--   6. reviews
-- ====================================================================

DROP DATABASE IF EXISTS `filmcraft`;
CREATE DATABASE `filmcraft`
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE `filmcraft`;

-- Clean teardown in reverse dependency order
DROP TABLE IF EXISTS `reviews`;
DROP TABLE IF EXISTS `movie_cast_crew`;
DROP TABLE IF EXISTS `film_professionals`;
DROP TABLE IF EXISTS `movie_genres`;
DROP TABLE IF EXISTS `movies`;
DROP TABLE IF EXISTS `users`;

-- --------------------------------------------------------------------
-- 1. Users (Cinephiles & Accredited Film Critics)
-- Disjoint role-attribute specialization enforced via CHECK constraint
-- --------------------------------------------------------------------
CREATE TABLE `users` (
    `user_id` INT AUTO_INCREMENT,
    `username` VARCHAR(50) NOT NULL,
    `email` VARCHAR(100) NOT NULL,
    `role` ENUM('CINEPHILE', 'CRITIC') NOT NULL DEFAULT 'CINEPHILE',
    `membership_tier` ENUM('FREE', 'PRO', 'PATRON') NULL,
    `publication_name` VARCHAR(100) NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `pk_users` PRIMARY KEY (`user_id`),
    CONSTRAINT `uq_users_username` UNIQUE (`username`),
    CONSTRAINT `uq_users_email` UNIQUE (`email`),
    CONSTRAINT `chk_users_role_attrs` CHECK (
        (`role` = 'CINEPHILE' AND `membership_tier` IS NOT NULL AND `publication_name` IS NULL) OR
        (`role` = 'CRITIC' AND `publication_name` IS NOT NULL AND `membership_tier` IS NULL)
    )
) ENGINE=InnoDB;

-- --------------------------------------------------------------------
-- 2. Movies (Self-Referencing Franchise Lineage via prequel_movie_id)
-- --------------------------------------------------------------------
CREATE TABLE `movies` (
    `movie_id` INT AUTO_INCREMENT,
    `title` VARCHAR(150) NOT NULL,
    `release_year` INT NOT NULL,
    `duration_minutes` INT NOT NULL,
    `language` VARCHAR(50) NOT NULL DEFAULT 'English',
    `synopsis` TEXT,
    `poster_url` VARCHAR(500) NULL,
    `prequel_movie_id` INT NULL,
    CONSTRAINT `pk_movies` PRIMARY KEY (`movie_id`),
    CONSTRAINT `chk_movie_year` CHECK (`release_year` >= 1888),
    CONSTRAINT `chk_movie_duration` CHECK (`duration_minutes` > 0),
    CONSTRAINT `fk_movies_prequel` FOREIGN KEY (`prequel_movie_id`)
        REFERENCES `movies` (`movie_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- --------------------------------------------------------------------
-- 3. Movie Genres (Multi-Valued Attribute Table in 1NF / BCNF)
-- --------------------------------------------------------------------
CREATE TABLE `movie_genres` (
    `movie_id` INT NOT NULL,
    `genre_name` VARCHAR(50) NOT NULL,
    CONSTRAINT `pk_movie_genres` PRIMARY KEY (`movie_id`, `genre_name`),
    CONSTRAINT `fk_genres_movie` FOREIGN KEY (`movie_id`)
        REFERENCES `movies` (`movie_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- --------------------------------------------------------------------
-- 4. Film Professionals (Directors, Actors, Writers, Cinematographers)
-- --------------------------------------------------------------------
CREATE TABLE `film_professionals` (
    `person_id` INT AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL,
    `nationality` VARCHAR(50),
    `biography` TEXT,
    CONSTRAINT `pk_film_professionals` PRIMARY KEY (`person_id`)
) ENGINE=InnoDB;

-- --------------------------------------------------------------------
-- 5. Movie Cast & Crew (M:N Relationship with Descriptive Role)
-- --------------------------------------------------------------------
CREATE TABLE `movie_cast_crew` (
    `movie_id` INT NOT NULL,
    `person_id` INT NOT NULL,
    `role_type` ENUM('DIRECTOR', 'ACTOR', 'WRITER', 'CINEMATOGRAPHER') NOT NULL,
    CONSTRAINT `pk_movie_cast_crew` PRIMARY KEY (`movie_id`, `person_id`, `role_type`),
    CONSTRAINT `fk_cast_movie` FOREIGN KEY (`movie_id`)
        REFERENCES `movies` (`movie_id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_cast_person` FOREIGN KEY (`person_id`)
        REFERENCES `film_professionals` (`person_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- --------------------------------------------------------------------
-- 6. Reviews (User M:N Movie with Rating 0-5 Stars & Critique Text)
-- --------------------------------------------------------------------
CREATE TABLE `reviews` (
    `review_id` INT AUTO_INCREMENT,
    `user_id` INT NOT NULL,
    `movie_id` INT NOT NULL,
    `rating` INT NOT NULL,
    `review_text` TEXT,
    `contains_spoilers` BOOLEAN NOT NULL DEFAULT FALSE,
    `watch_date` DATE NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `pk_reviews` PRIMARY KEY (`review_id`),
    CONSTRAINT `uq_user_movie_review` UNIQUE (`user_id`, `movie_id`),
    CONSTRAINT `chk_review_rating` CHECK (`rating` BETWEEN 0 AND 5),
    CONSTRAINT `fk_reviews_user` FOREIGN KEY (`user_id`)
        REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_reviews_movie` FOREIGN KEY (`movie_id`)
        REFERENCES `movies` (`movie_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
