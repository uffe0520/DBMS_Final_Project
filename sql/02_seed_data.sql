-- ====================================================================
-- HKU COMP3278A — Final Project Realistic Seed Data
-- System: FilmCraft (Letterboxd+) Cinema & Festival Curator Platform
-- Engine: MySQL 8.x
-- ====================================================================

USE `filmcraft`;

-- --------------------------------------------------------------------
-- 1. Seed Users (Superclass & ISA Subclasses)
-- --------------------------------------------------------------------
INSERT INTO `users` (`user_id`, `username`, `email`, `password_hash`, `role`, `created_at`) VALUES
(1, 'alex_chen', 'alex.chen@connect.hku.hk', '$2b$12$e8YkY.k1QoD9jA5l0Y3.YeB4t.uG5n9p0o1i2u3y4t5r6e7w8q9', 'CINEPHILE', '2026-01-15 10:20:00'),
(2, 'sarah_wong', 'sarah.wong@gmail.com', '$2b$12$e8YkY.k1QoD9jA5l0Y3.YeB4t.uG5n9p0o1i2u3y4t5r6e7w8q9', 'CINEPHILE', '2026-02-01 14:35:00'),
(3, 'marcus_lee', 'marcus.lee@variety.com', '$2b$12$e8YkY.k1QoD9jA5l0Y3.YeB4t.uG5n9p0o1i2u3y4t5r6e7w8q9', 'CRITIC', '2026-02-10 09:15:00'),
(4, 'clara_oswald', 'clara.o@sightandsound.org', '$2b$12$e8YkY.k1QoD9jA5l0Y3.YeB4t.uG5n9p0o1i2u3y4t5r6e7w8q9', 'CRITIC', '2026-03-05 16:40:00'),
(5, 'david_kim', 'david.kim@outlook.com', '$2b$12$e8YkY.k1QoD9jA5l0Y3.YeB4t.uG5n9p0o1i2u3y4t5r6e7w8q9', 'CINEPHILE', '2026-03-20 11:00:00'),
(6, 'elena_rostova', 'elena@cannes-fest.org', '$2b$12$e8YkY.k1QoD9jA5l0Y3.YeB4t.uG5n9p0o1i2u3y4t5r6e7w8q9', 'CURATOR', '2026-04-01 08:30:00'),
(7, 'kenneth_tsang', 'k.tsang@hkiff.org.hk', '$2b$12$e8YkY.k1QoD9jA5l0Y3.YeB4t.uG5n9p0o1i2u3y4t5r6e7w8q9', 'CURATOR', '2026-04-15 13:20:00'),
(8, 'hku_film_soc', 'filmsoc@hku.hk', '$2b$12$e8YkY.k1QoD9jA5l0Y3.YeB4t.uG5n9p0o1i2u3y4t5r6e7w8q9', 'CINEPHILE', '2026-05-01 19:00:00');

-- Cinephiles
INSERT INTO `cinephiles` (`user_id`, `bio`, `favorite_genre`, `membership_tier`) VALUES
(1, 'HKU CS student & 35mm IMAX enthusiast. Obsessed with non-linear narratives.', 'Sci-Fi', 'PATRON'),
(2, 'Casual film-goer exploring East Asian cinema and animated classics.', 'Animation', 'PRO'),
(5, 'Screenwriting hobbyist, massive Denis Villeneuve fan.', 'Drama', 'FREE'),
(8, 'Official HKU Student Film Society account. Screening indie gems on campus.', 'Documentary', 'PATRON');

-- Film Critics
INSERT INTO `film_critics` (`user_id`, `publication_name`, `critic_license_no`, `is_verified`) VALUES
(3, 'Variety Film Weekly', 'HK-FCA-2024-8891', TRUE),
(4, 'Sight & Sound BFI', 'UK-CRIT-9921-X', TRUE);

-- Festival Curators
INSERT INTO `festival_curators` (`user_id`, `festival_organization`, `accreditation_id`) VALUES
(6, 'Festival de Cannes Selection Committee', 'CAN-CUR-2026-014'),
(7, 'Hong Kong International Film Festival Society', 'HKIFF-CUR-2026-002');

-- --------------------------------------------------------------------
-- 2. Seed Movies & Franchises (Self-Referencing Prequels)
-- --------------------------------------------------------------------
INSERT INTO `movies` (`movie_id`, `title`, `release_year`, `duration_minutes`, `language`, `synopsis`, `prequel_movie_id`) VALUES
(1, 'Memento', 2000, 113, 'English', 'A man with short-term memory loss attempts to track down his wife’s murderer.', NULL),
(2, 'The Dark Knight', 2008, 152, 'English', 'When the menace known as the Joker wreaks havoc on Gotham City, Batman must accept one of the greatest tests.', NULL),
(3, 'Inception', 2010, 148, 'English', 'A thief who steals corporate secrets through the use of dream-sharing technology is given an inverse task.', NULL),
(4, 'Interstellar', 2014, 169, 'English', 'When Earth becomes uninhabitable in the future, a team of explorers travels through a wormhole.', NULL),
(5, 'Oppenheimer', 2023, 180, 'English', 'The story of American scientist J. Robert Oppenheimer and his role in the development of the atomic bomb.', NULL),
(6, 'Dune: Part One', 2021, 155, 'English', 'Paul Atreides arrives on Arrakis, the most dangerous planet in the universe, to secure the future of his people.', NULL),
(7, 'Dune: Part Two', 2024, 166, 'English', 'Paul Atreides unites with Chani and the Fremen while seeking revenge against the conspirators.', 6),
(8, 'Spirited Away', 2001, 125, 'Japanese', 'During her family’s move to the suburbs, a 10-year-old girl wanders into a world ruled by spirits.', NULL),
(9, 'Princess Mononoke', 1997, 134, 'Japanese', 'On a journey to find the cure for a curse, Ashitaka finds himself in the middle of a war.', NULL),
(10, 'Parasite', 2019, 132, 'Korean', 'Greed and class discrimination threaten the newly formed symbiotic relationship between the wealthy Park family and the destitute Kim clan.', NULL),
(11, 'Pulp Fiction', 1994, 154, 'English', 'The lives of two mob hitmen, a boxer, a gangster and his wife intertwine in four tales of violence and redemption.', NULL);

-- Movie Genres
INSERT INTO `movie_genres` (`movie_id`, `genre_name`) VALUES
(1, 'Mystery'), (1, 'Thriller'),
(2, 'Action'), (2, 'Crime'), (2, 'Drama'),
(3, 'Action'), (3, 'Sci-Fi'), (3, 'Adventure'),
(4, 'Adventure'), (4, 'Drama'), (4, 'Sci-Fi'),
(5, 'Biography'), (5, 'Drama'), (5, 'History'),
(6, 'Action'), (6, 'Adventure'), (6, 'Sci-Fi'),
(7, 'Action'), (7, 'Adventure'), (7, 'Sci-Fi'),
(8, 'Animation'), (8, 'Adventure'), (8, 'Family'),
(9, 'Animation'), (9, 'Action'), (9, 'Fantasy'),
(10, 'Drama'), (10, 'Thriller'), (10, 'Comedy'),
(11, 'Crime'), (11, 'Drama');

-- --------------------------------------------------------------------
-- 3. Seed Film Professionals & Cast/Crew
-- --------------------------------------------------------------------
INSERT INTO `film_professionals` (`person_id`, `name`, `birth_date`, `nationality`, `biography`) VALUES
(1, 'Christopher Nolan', '1970-07-30', 'British', 'Visionary director renowned for practical effects and non-linear narrative architecture.'),
(2, 'Hayao Miyazaki', '1941-01-05', 'Japanese', 'Legendary co-founder of Studio Ghibli and master of traditional hand-drawn animation.'),
(3, 'Denis Villeneuve', '1967-10-03', 'Canadian', 'Acclaimed director known for immersive sci-fi world-building and atmosphere.'),
(4, 'Bong Joon-ho', '1969-09-14', 'South Korean', 'Palme d’Or and Academy Award-winning filmmaker known for sharp social satire.'),
(5, 'Quentin Tarantino', '1963-03-27', 'American', 'Auteur filmmaker celebrated for stylized non-linear dialogues and pop culture tributes.'),
(6, 'Cillian Murphy', '1976-05-25', 'Irish', 'Celebrated actor and frequent Nolan collaborator, winner of Best Actor for Oppenheimer.'),
(7, 'Christian Bale', '1974-01-30', 'British', 'Transformative method actor who played Bruce Wayne / Batman in The Dark Knight trilogy.'),
(8, 'Leonardo DiCaprio', '1974-11-11', 'American', 'Academy Award-winning lead actor in Inception.'),
(9, 'Timothée Chalamet', '1995-12-27', 'American', 'Leading actor portraying Paul Atreides in the Dune franchise.'),
(10, 'Song Kang-ho', '1967-01-17', 'South Korean', 'Iconic South Korean actor starring in Parasite and Memories of Murder.'),
(11, 'Hoyte van Hoytema', '1971-10-04', 'Dutch', 'Oscar-winning cinematographer known for 70mm IMAX photography with Nolan.'),
(12, 'Zendaya', '1996-09-01', 'American', 'Leading actress playing Chani in the Dune franchise.');

-- Cast & Crew Linking (N:M with descriptive attributes)
INSERT INTO `movie_cast_crew` (`movie_id`, `person_id`, `role_type`, `character_name`, `billing_order`) VALUES
-- Nolan Films (Director, Actor, Cinematographer)
(1, 1, 'DIRECTOR', NULL, 1),
(2, 1, 'DIRECTOR', NULL, 1),
(2, 7, 'ACTOR', 'Bruce Wayne / Batman', 1),
(3, 1, 'DIRECTOR', NULL, 1),
(3, 8, 'ACTOR', 'Dom Cobb', 1),
(4, 1, 'DIRECTOR', NULL, 1),
(4, 11, 'CINEMATOGRAPHER', NULL, 2),
(5, 1, 'DIRECTOR', NULL, 1),
(5, 6, 'ACTOR', 'J. Robert Oppenheimer', 1),
(5, 11, 'CINEMATOGRAPHER', NULL, 2),
-- Villeneuve Films
(6, 3, 'DIRECTOR', NULL, 1),
(6, 9, 'ACTOR', 'Paul Atreides', 1),
(6, 12, 'ACTOR', 'Chani', 2),
(7, 3, 'DIRECTOR', NULL, 1),
(7, 9, 'ACTOR', 'Paul Atreides', 1),
(7, 12, 'ACTOR', 'Chani', 2),
-- Miyazaki Films
(8, 2, 'DIRECTOR', NULL, 1),
(9, 2, 'DIRECTOR', NULL, 1),
-- Bong Joon-ho Film
(10, 4, 'DIRECTOR', NULL, 1),
(10, 10, 'ACTOR', 'Kim Ki-taek', 1),
-- Tarantino Film
(11, 5, 'DIRECTOR', NULL, 1);

-- --------------------------------------------------------------------
-- 4. Seed Theaters, Screening Rooms (Weak Entity) & Screenings
-- --------------------------------------------------------------------
INSERT INTO `theaters` (`theater_id`, `name`, `city`, `address`) VALUES
(1, 'Broadway Cinematheque', 'Hong Kong', 'Prosperous Garden, 3 Public Square St, Yau Ma Tei'),
(2, 'Premiere Elements', 'Hong Kong', 'Elements Mall, 1 Austin Rd W, Tsim Sha Tsui'),
(3, 'Emperor Cinemas Times Square', 'Hong Kong', 'Level 12-14, Times Square, 1 Matheson St, Causeway Bay'),
(4, 'K11 Art House', 'Hong Kong', 'Level 4, K11 MUSEA, Victoria Dockside, Tsim Sha Tsui');

-- Weak Entity: TheaterRoom
INSERT INTO `theater_rooms` (`theater_id`, `room_number`, `seating_capacity`, `screen_format`) VALUES
(1, 1, 160, 'STANDARD'),
(1, 2, 115, 'STANDARD'),
(2, 1, 280, 'IMAX'),
(2, 2, 150, 'DOLBY'),
(3, 1, 210, 'IMAX'),
(3, 2, 90, 'STANDARD'),
(4, 1, 350, 'IMAX');

-- Theater Screenings
INSERT INTO `theater_screenings` (`screening_id`, `theater_id`, `room_number`, `movie_id`, `screening_datetime`, `ticket_price`) VALUES
(1, 2, 1, 5, '2026-11-01 19:30:00', 160.00), -- Oppenheimer in IMAX
(2, 2, 1, 7, '2026-11-02 20:00:00', 160.00), -- Dune 2 in IMAX
(3, 1, 1, 8, '2026-11-01 15:00:00', 95.00),  -- Spirited Away at BC
(4, 1, 1, 9, '2026-11-01 18:00:00', 95.00),  -- Princess Mononoke at BC
(5, 1, 2, 10, '2026-11-02 21:00:00', 95.00), -- Parasite at BC
(6, 3, 1, 7, '2026-11-03 14:30:00', 150.00), -- Dune 2 at Emperor
(7, 4, 1, 3, '2026-11-05 19:00:00', 170.00); -- Inception retrospective at K11

-- --------------------------------------------------------------------
-- 5. Seed Reviews & Ratings
-- NOTE: alex_chen (user_id = 1) has reviewed EVERY Christopher Nolan film (movies 1, 2, 3, 4, 5)!
-- --------------------------------------------------------------------
INSERT INTO `reviews` (`review_id`, `user_id`, `movie_id`, `rating`, `review_text`, `contains_spoilers`, `watch_date`, `created_at`) VALUES
-- Alex Chen (Cinephile 1): Complete coverage of Christopher Nolan
(1, 1, 1, 9, 'Memento is a masterclass in structural editing and neo-noir tension.', FALSE, '2026-08-01', '2026-08-01 22:00:00'),
(2, 1, 2, 10, 'Heath Ledger’s Joker is unmatched. Flawless pacing and thematic depth.', FALSE, '2026-08-10', '2026-08-10 21:30:00'),
(3, 1, 3, 10, 'Inception redefines modern blockbusters with emotional gravity and complex physics.', FALSE, '2026-08-15', '2026-08-15 23:15:00'),
(4, 1, 4, 10, 'Interstellar made me weep in 70mm IMAX. Zimmer’s organ score is transcendent.', FALSE, '2026-08-25', '2026-08-25 20:00:00'),
(5, 1, 5, 9, 'Oppenheimer is a devastating, relentless biographical thriller.', FALSE, '2026-09-01', '2026-09-01 22:45:00'),

-- Sarah Wong (Cinephile 2)
(6, 2, 8, 10, 'Spirited Away is pure magic. Nostalgic, heartwarming, visually gorgeous.', FALSE, '2026-09-05', '2026-09-05 18:20:00'),
(7, 2, 9, 9, 'Princess Mononoke handles ecological themes with incredible nuance.', FALSE, '2026-09-12', '2026-09-12 19:40:00'),
(8, 2, 2, 8, 'Great superhero movie, although slightly long in the final act.', FALSE, '2026-09-20', '2026-09-20 21:10:00'),

-- Marcus Lee (Critic 3)
(9, 3, 5, 10, 'Oppenheimer stands as the crowning achievement of Nolan’s cinematic career.', FALSE, '2026-09-15', '2026-09-15 10:00:00'),
(10, 3, 7, 9, 'Dune: Part Two is science fiction on a grand, operatic scale.', FALSE, '2026-09-18', '2026-09-18 11:30:00'),
(11, 3, 10, 10, 'Parasite is pitch-perfect in every beat, tone, and framing.', FALSE, '2026-09-22', '2026-09-22 15:45:00'),

-- Clara Oswald (Critic 4): Complete coverage of Hayao Miyazaki
(12, 4, 8, 10, 'A timeless milestone of world animation cinema.', FALSE, '2026-09-10', '2026-09-10 14:00:00'),
(13, 4, 9, 10, 'Miyazaki’s magnum opus on the friction between humanity and nature.', FALSE, '2026-09-14', '2026-09-14 16:30:00'),

-- David Kim (Cinephile 5)
(14, 5, 6, 8, 'Great atmosphere and sound design, setting up the sequel nicely.', FALSE, '2026-09-28', '2026-09-28 20:30:00'),
(15, 5, 7, 10, 'Desert warfare and soundscapes are mindblowing. Best theater experience of 2024.', FALSE, '2026-10-02', '2026-10-02 22:15:00'),
(16, 5, 10, 9, 'The peach scene still gives me chills.', FALSE, '2026-10-10', '2026-10-10 19:00:00');

-- --------------------------------------------------------------------
-- 6. Seed Curated Watchlists & Entries
-- --------------------------------------------------------------------
INSERT INTO `watchlists` (`list_id`, `user_id`, `title`, `description`, `is_public`, `created_at`) VALUES
(1, 1, 'Non-Linear Cinematic Puzzles', 'Films that deconstruct narrative timelines and memory.', TRUE, '2026-08-05 12:00:00'),
(2, 4, 'Studio Ghibli Essentials', 'Core masterpieces for anyone new to Japanese animation.', TRUE, '2026-09-15 17:00:00'),
(3, 5, 'Modern Sci-Fi Masterworks', 'Immersive large-format sci-fi epics of the 21st century.', TRUE, '2026-10-05 14:00:00');

INSERT INTO `watchlist_entries` (`list_id`, `movie_id`, `rank_order`, `curator_note`) VALUES
(1, 1, 1, 'The gold standard of reverse-chronology storytelling.'),
(1, 3, 2, 'Dreams nested inside dreams.'),
(1, 11, 3, 'Tarantino’s fragmented anthology.'),
(2, 8, 1, 'Oscar-winning fantasy journey.'),
(2, 9, 2, 'Epic historical conflict between man and god-beasts.'),
(3, 4, 1, 'Emotional realism coupled with Kip Thorne’s relativity physics.'),
(3, 6, 2, 'Visually breathtaking world-building of Frank Herbert’s universe.'),
(3, 7, 3, 'The definitive sci-fi climax.');

-- --------------------------------------------------------------------
-- 7. Seed Festivals, Awards & Nominations
-- --------------------------------------------------------------------
INSERT INTO `festivals` (`festival_id`, `name`, `city`, `established_year`) VALUES
(1, 'Festival de Cannes', 'Cannes', 1946),
(2, 'Academy Awards (The Oscars)', 'Los Angeles', 1929),
(3, 'Hong Kong International Film Festival (HKIFF)', 'Hong Kong', 1977);

INSERT INTO `festival_awards` (`award_id`, `festival_id`, `category_name`, `award_year`) VALUES
(1, 1, 'Palme d’Or', 2019),
(2, 2, 'Best Picture', 2024),
(3, 2, 'Best Director', 2024),
(4, 2, 'Best Animated Feature', 2003),
(5, 3, 'Firebird Award', 2024);

INSERT INTO `award_nominations` (`nomination_id`, `award_id`, `movie_id`, `person_id`, `is_winner`) VALUES
(1, 1, 10, 4, TRUE),  -- Parasite won Palme d'Or (Bong Joon-ho)
(2, 2, 5, 1, TRUE),   -- Oppenheimer won Best Picture
(3, 3, 5, 1, TRUE),   -- Christopher Nolan won Best Director for Oppenheimer
(4, 4, 8, 2, TRUE),   -- Spirited Away won Best Animated Feature
(5, 5, 7, 3, TRUE);   -- Dune: Part Two won at HKIFF
