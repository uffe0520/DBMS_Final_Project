-- ====================================================================
-- HKU COMP3278A — Final Project Database Schema
-- System: FilmCraft (Letterboxd+) Cinema & Festival Curator Platform
-- Engine: MySQL 8.x
-- ====================================================================

CREATE DATABASE IF NOT EXISTS `filmcraft`
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE `filmcraft`;

-- --------------------------------------------------------------------
-- 1. Users & Specialization Hierarchy (ISA)
-- --------------------------------------------------------------------
DROP TABLE IF EXISTS `award_nominations`;
DROP TABLE IF EXISTS `festival_awards`;
DROP TABLE IF EXISTS `festivals`;
DROP TABLE IF EXISTS `watchlist_entries`;
DROP TABLE IF EXISTS `watchlists`;
DROP TABLE IF EXISTS `reviews`;
DROP TABLE IF EXISTS `theater_screenings`;
DROP TABLE IF EXISTS `theater_rooms`;
DROP TABLE IF EXISTS `theaters`;
DROP TABLE IF EXISTS `movie_cast_crew`;
DROP TABLE IF EXISTS `film_professionals`;
DROP TABLE IF EXISTS `movie_genres`;
DROP TABLE IF EXISTS `movies`;
DROP TABLE IF EXISTS `festival_curators`;
DROP TABLE IF EXISTS `film_critics`;
DROP TABLE IF EXISTS `cinephiles`;
DROP TABLE IF EXISTS `users`;

CREATE TABLE `users` (
    `user_id` INT AUTO_INCREMENT,
    `username` VARCHAR(50) NOT NULL,
    `email` VARCHAR(100) NOT NULL,
    `password_hash` VARCHAR(255) NOT NULL,
    `role` ENUM('CINEPHILE', 'CRITIC', 'CURATOR') NOT NULL DEFAULT 'CINEPHILE',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `pk_users` PRIMARY KEY (`user_id`),
    CONSTRAINT `uq_users_username` UNIQUE (`username`),
    CONSTRAINT `uq_users_email` UNIQUE (`email`)
) ENGINE=InnoDB;

-- Subclass 1: Cinephiles (General audience)
CREATE TABLE `cinephiles` (
    `user_id` INT NOT NULL,
    `bio` TEXT,
    `favorite_genre` VARCHAR(50),
    `membership_tier` ENUM('FREE', 'PRO', 'PATRON') NOT NULL DEFAULT 'FREE',
    CONSTRAINT `pk_cinephiles` PRIMARY KEY (`user_id`),
    CONSTRAINT `fk_cinephiles_user` FOREIGN KEY (`user_id`)
        REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Subclass 2: Film Critics (Accredited reviewers)
CREATE TABLE `film_critics` (
    `user_id` INT NOT NULL,
    `publication_name` VARCHAR(100) NOT NULL,
    `critic_license_no` VARCHAR(50) NOT NULL,
    `is_verified` BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT `pk_film_critics` PRIMARY KEY (`user_id`),
    CONSTRAINT `uq_critics_license` UNIQUE (`critic_license_no`),
    CONSTRAINT `fk_film_critics_user` FOREIGN KEY (`user_id`)
        REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Subclass 3: Festival Curators (Festival directors & programmers)
CREATE TABLE `festival_curators` (
    `user_id` INT NOT NULL,
    `festival_organization` VARCHAR(120) NOT NULL,
    `accreditation_id` VARCHAR(50) NOT NULL,
    CONSTRAINT `pk_festival_curators` PRIMARY KEY (`user_id`),
    CONSTRAINT `uq_curator_accreditation` UNIQUE (`accreditation_id`),
    CONSTRAINT `fk_curators_user` FOREIGN KEY (`user_id`)
        REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- --------------------------------------------------------------------
-- 2. Movies, Genres & Franchise Hierarchy
-- --------------------------------------------------------------------
CREATE TABLE `movies` (
    `movie_id` INT AUTO_INCREMENT,
    `title` VARCHAR(150) NOT NULL,
    `release_year` INT NOT NULL,
    `duration_minutes` INT NOT NULL,
    `language` VARCHAR(50) NOT NULL DEFAULT 'English',
    `synopsis` TEXT,
    `prequel_movie_id` INT NULL,
    CONSTRAINT `pk_movies` PRIMARY KEY (`movie_id`),
    CONSTRAINT `chk_movie_year` CHECK (`release_year` >= 1888),
    CONSTRAINT `chk_movie_duration` CHECK (`duration_minutes` > 0),
    CONSTRAINT `fk_movies_prequel` FOREIGN KEY (`prequel_movie_id`)
        REFERENCES `movies` (`movie_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Multi-valued attribute table: Movie Genres
CREATE TABLE `movie_genres` (
    `movie_id` INT NOT NULL,
    `genre_name` VARCHAR(50) NOT NULL,
    CONSTRAINT `pk_movie_genres` PRIMARY KEY (`movie_id`, `genre_name`),
    CONSTRAINT `fk_genres_movie` FOREIGN KEY (`movie_id`)
        REFERENCES `movies` (`movie_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- --------------------------------------------------------------------
-- 3. Film Professionals & Cast/Crew Relations
-- --------------------------------------------------------------------
CREATE TABLE `film_professionals` (
    `person_id` INT AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL,
    `birth_date` DATE,
    `nationality` VARCHAR(50),
    `biography` TEXT,
    CONSTRAINT `pk_film_professionals` PRIMARY KEY (`person_id`)
) ENGINE=InnoDB;

-- N:M Relationship with descriptive attributes
CREATE TABLE `movie_cast_crew` (
    `movie_id` INT NOT NULL,
    `person_id` INT NOT NULL,
    `role_type` ENUM('DIRECTOR', 'ACTOR', 'WRITER', 'CINEMATOGRAPHER') NOT NULL,
    `character_name` VARCHAR(100) NULL,
    `billing_order` INT NULL,
    CONSTRAINT `pk_movie_cast_crew` PRIMARY KEY (`movie_id`, `person_id`, `role_type`),
    CONSTRAINT `fk_cast_movie` FOREIGN KEY (`movie_id`)
        REFERENCES `movies` (`movie_id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_cast_person` FOREIGN KEY (`person_id`)
        REFERENCES `film_professionals` (`person_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- --------------------------------------------------------------------
-- 4. Theaters, Screening Rooms (Weak Entity) & Screenings
-- --------------------------------------------------------------------
CREATE TABLE `theaters` (
    `theater_id` INT AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL,
    `city` VARCHAR(50) NOT NULL,
    `address` VARCHAR(255) NOT NULL,
    CONSTRAINT `pk_theaters` PRIMARY KEY (`theater_id`)
) ENGINE=InnoDB;

-- Weak Entity: TheaterRoom (Identified by theater_id + room_number)
CREATE TABLE `theater_rooms` (
    `theater_id` INT NOT NULL,
    `room_number` INT NOT NULL,
    `seating_capacity` INT NOT NULL,
    `screen_format` ENUM('STANDARD', 'IMAX', 'DOLBY', '3D') NOT NULL DEFAULT 'STANDARD',
    CONSTRAINT `pk_theater_rooms` PRIMARY KEY (`theater_id`, `room_number`),
    CONSTRAINT `chk_seating_capacity` CHECK (`seating_capacity` > 0),
    CONSTRAINT `fk_rooms_theater` FOREIGN KEY (`theater_id`)
        REFERENCES `theaters` (`theater_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Screening Event Entity
CREATE TABLE `theater_screenings` (
    `screening_id` INT AUTO_INCREMENT,
    `theater_id` INT NOT NULL,
    `room_number` INT NOT NULL,
    `movie_id` INT NOT NULL,
    `screening_datetime` DATETIME NOT NULL,
    `ticket_price` DECIMAL(6, 2) NOT NULL,
    CONSTRAINT `pk_theater_screenings` PRIMARY KEY (`screening_id`),
    CONSTRAINT `uq_room_screening_time` UNIQUE (`theater_id`, `room_number`, `screening_datetime`),
    CONSTRAINT `chk_ticket_price` CHECK (`ticket_price` >= 0.00),
    CONSTRAINT `fk_screenings_room` FOREIGN KEY (`theater_id`, `room_number`)
        REFERENCES `theater_rooms` (`theater_id`, `room_number`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_screenings_movie` FOREIGN KEY (`movie_id`)
        REFERENCES `movies` (`movie_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- --------------------------------------------------------------------
-- 5. Reviews & Ratings
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
    CONSTRAINT `chk_rating_range` CHECK (`rating` BETWEEN 1 AND 10),
    CONSTRAINT `fk_reviews_user` FOREIGN KEY (`user_id`)
        REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_reviews_movie` FOREIGN KEY (`movie_id`)
        REFERENCES `movies` (`movie_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- --------------------------------------------------------------------
-- 6. Curated Watchlists & Watchlist Entries
-- --------------------------------------------------------------------
CREATE TABLE `watchlists` (
    `list_id` INT AUTO_INCREMENT,
    `user_id` INT NOT NULL,
    `title` VARCHAR(100) NOT NULL,
    `description` TEXT,
    `is_public` BOOLEAN NOT NULL DEFAULT TRUE,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `pk_watchlists` PRIMARY KEY (`list_id`),
    CONSTRAINT `fk_watchlists_user` FOREIGN KEY (`user_id`)
        REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `watchlist_entries` (
    `list_id` INT NOT NULL,
    `movie_id` INT NOT NULL,
    `rank_order` INT NOT NULL,
    `curator_note` VARCHAR(255),
    CONSTRAINT `pk_watchlist_entries` PRIMARY KEY (`list_id`, `movie_id`),
    CONSTRAINT `chk_rank_order` CHECK (`rank_order` > 0),
    CONSTRAINT `fk_entries_list` FOREIGN KEY (`list_id`)
        REFERENCES `watchlists` (`list_id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_entries_movie` FOREIGN KEY (`movie_id`)
        REFERENCES `movies` (`movie_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- --------------------------------------------------------------------
-- 7. Film Festivals, Categories & Award Nominations
-- --------------------------------------------------------------------
CREATE TABLE `festivals` (
    `festival_id` INT AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL,
    `city` VARCHAR(50) NOT NULL,
    `established_year` INT NOT NULL,
    CONSTRAINT `pk_festivals` PRIMARY KEY (`festival_id`)
) ENGINE=InnoDB;

CREATE TABLE `festival_awards` (
    `award_id` INT AUTO_INCREMENT,
    `festival_id` INT NOT NULL,
    `category_name` VARCHAR(80) NOT NULL,
    `award_year` INT NOT NULL,
    CONSTRAINT `pk_festival_awards` PRIMARY KEY (`award_id`),
    CONSTRAINT `uq_festival_category_year` UNIQUE (`festival_id`, `category_name`, `award_year`),
    CONSTRAINT `fk_awards_festival` FOREIGN KEY (`festival_id`)
        REFERENCES `festivals` (`festival_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `award_nominations` (
    `nomination_id` INT AUTO_INCREMENT,
    `award_id` INT NOT NULL,
    `movie_id` INT NOT NULL,
    `person_id` INT NULL,
    `is_winner` BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT `pk_award_nominations` PRIMARY KEY (`nomination_id`),
    CONSTRAINT `fk_nominations_award` FOREIGN KEY (`award_id`)
        REFERENCES `festival_awards` (`award_id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_nominations_movie` FOREIGN KEY (`movie_id`)
        REFERENCES `movies` (`movie_id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_nominations_person` FOREIGN KEY (`person_id`)
        REFERENCES `film_professionals` (`person_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;
