-- ====================================================================
-- HKU COMP3278A — FilmCraft Database Reset & Teardown Script
-- Drops the database, recreates it, and sets utf8mb4 encoding.
-- ====================================================================

DROP DATABASE IF EXISTS `filmcraft`;
CREATE DATABASE `filmcraft`
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE `filmcraft`;
