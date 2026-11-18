-- ====================================================================
-- FilmCraft: Initial Seed Dataset (5 Core Tables)
-- HKU COMP3278A — Introduction to Database Management Systems
-- ====================================================================

USE `filmcraft`;

-- --------------------------------------------------------------------
-- 1. Seed Users (Cinephiles & Accredited Film Critics)
-- --------------------------------------------------------------------
INSERT INTO `users` (`user_id`, `username`, `email`, `role`, `membership_tier`, `publication_name`) VALUES
(1, 'alex_chen',    'alex.chen@connect.hku.hk',  'CINEPHILE', 'PATRON', NULL),
(2, 'sarah_wong',   'sarah.wong@gmail.com',      'CINEPHILE', 'PRO',    NULL),
(3, 'marcus_lee',   'marcus.lee@variety.com',    'CRITIC',    NULL,     'Variety Film Weekly'),
(4, 'clara_oswald', 'clara.o@sightandsound.org', 'CRITIC',    NULL,     'Sight & Sound BFI'),
(5, 'david_kim',    'david.kim@outlook.com',     'CINEPHILE', 'FREE',   NULL),
(6, 'hku_film_soc', 'filmsoc@hku.hk',            'CINEPHILE', 'PATRON', NULL);

-- --------------------------------------------------------------------
-- 2. Seed Directors
-- --------------------------------------------------------------------
INSERT INTO `directors` (`director_id`, `name`, `nationality`, `biography`) VALUES
(1, 'Christopher Nolan', 'British',      'Visionary director renowned for practical effects and non-linear narrative architecture.'),
(2, 'Hayao Miyazaki',    'Japanese',     'Legendary co-founder of Studio Ghibli and master of traditional hand-drawn animation.'),
(3, 'Denis Villeneuve',  'Canadian',     'Acclaimed director known for immersive sci-fi world-building and atmosphere.'),
(4, 'Bong Joon-ho',      'South Korean', 'Palme d''Or and Academy Award-winning filmmaker known for sharp social satire.'),
(5, 'Quentin Tarantino', 'American',     'Auteur filmmaker celebrated for stylized non-linear dialogues and cinema homages.'),
(6, 'Martin Scorsese',   'American',     'Master of New Hollywood cinema exploring guilt, obsession, and urban alienation.');

-- --------------------------------------------------------------------
-- 3. Seed Movies (12 Films with Director FK, Local Posters & Sequel Lineage)
-- --------------------------------------------------------------------
INSERT INTO `movies` (`movie_id`, `title`, `release_year`, `duration_minutes`, `language`, `synopsis`, `poster_url`, `director_id`, `prequel_movie_id`) VALUES
(1,  'Memento',           2000, 113, 'English',  'A man with short-term memory loss attempts to track down his wife''s murderer.',                                                  '/posters/memento.jpg',       1, NULL),
(2,  'The Dark Knight',   2008, 152, 'English',  'When the menace known as the Joker wreaks havoc on Gotham City, Batman must accept one of the greatest tests.',                  '/posters/Thedarkknight.jpg', 1, NULL),
(3,  'Inception',         2010, 148, 'English',  'A thief who steals corporate secrets through dream-sharing technology is given an inverse task of planting an idea.',            '/posters/Inception.jpg',     1, NULL),
(4,  'Interstellar',      2014, 169, 'English',  'When Earth becomes uninhabitable in the future, a team of explorers travels through a wormhole in search of a new home.',        '/posters/INterstellar.jpg',  1, NULL),
(5,  'Oppenheimer',       2023, 180, 'English',  'The story of American physicist J. Robert Oppenheimer and his pivotal role in the development of the atomic bomb.',              '/posters/Oppenheimer.jpg',   1, NULL),
(6,  'Dune: Part One',    2021, 155, 'English',  'Paul Atreides arrives on Arrakis, the most dangerous planet in the universe, to secure the future of his family and people.',    '/posters/DunePt1.jpg',       3, NULL),
(7,  'Dune: Part Two',    2024, 166, 'English',  'Paul Atreides unites with Chani and the Fremen while seeking revenge against the conspirators who destroyed his family.',        '/posters/dunept2.jpg',       3, 6),
(8,  'Spirited Away',     2001, 125, 'Japanese', 'During her family''s move to the suburbs, a 10-year-old girl wanders into a mysterious world ruled by gods and spirits.',        '/posters/SpirtedAway.jpg',   2, NULL),
(9,  'Princess Mononoke', 1997, 134, 'Japanese', 'On a journey to find the cure for a Tatarigami''s curse, Ashitaka finds himself caught in a war between forest gods and industry.','/posters/Mononoke.jpg',      2, NULL),
(10, 'Parasite',          2019, 132, 'Korean',   'Greed and class discrimination threaten the newly formed symbiotic relationship between the wealthy Park family and the Kim clan.','/posters/Parasite.jpg',      4, NULL),
(11, 'Pulp Fiction',      1994, 154, 'English',  'The lives of two mob hitmen, a boxer, a gangster, and his wife intertwine in four tales of violence and redemption.',            '/posters/PulpFiction.jpg',   5, NULL),
(12, 'Taxi Driver',       1976, 114, 'English',  'A mentally unstable veteran works as a nighttime taxi driver in New York City, where the perceived decadence fuels his descent.','/posters/taxidriver.jpg',    6, NULL);

-- --------------------------------------------------------------------
-- 4. Seed Movie Genres
-- --------------------------------------------------------------------
INSERT INTO `movie_genres` (`movie_id`, `genre_name`) VALUES
(1,  'Mystery'),   (1,  'Thriller'),
(2,  'Action'),    (2,  'Crime'),     (2,  'Drama'),
(3,  'Action'),    (3,  'Sci-Fi'),    (3,  'Adventure'),
(4,  'Adventure'), (4,  'Drama'),     (4,  'Sci-Fi'),
(5,  'Biography'), (5,  'Drama'),     (5,  'History'),
(6,  'Action'),    (6,  'Adventure'), (6,  'Sci-Fi'),
(7,  'Action'),    (7,  'Adventure'), (7,  'Sci-Fi'),
(8,  'Animation'), (8,  'Adventure'), (8,  'Family'),
(9,  'Animation'), (9,  'Action'),    (9,  'Fantasy'),
(10, 'Drama'),     (10, 'Thriller'),  (10, 'Comedy'),
(11, 'Crime'),     (11, 'Drama'),
(12, 'Crime'),     (12, 'Drama');

-- --------------------------------------------------------------------
-- 5. Seed Reviews (0-5 Discrete Star Scale — 36 Reviews, 3 per Film)
-- Every film has both Accredited Critic and Cinephile coverage.
-- Completionists: alex_chen (Nolan 5/5), clara_oswald (Miyazaki 2/2),
--                 david_kim (Villeneuve 2/2)
-- --------------------------------------------------------------------
INSERT INTO `reviews` (`review_id`, `user_id`, `movie_id`, `rating`, `review_text`, `contains_spoilers`) VALUES
-- Movie 1: Memento (Christopher Nolan)
(1,  1, 1,  4, 'A reverse-chronological puzzle in unreliable narration that rewards close attention.',          FALSE),
(2,  6, 1,  4, 'Clever structural editing that keeps the mystery taut right until the final polaroid.',        TRUE),
(3,  4, 1,  5, 'A landmark neo-noir exercise in memory, self-deception, and subjective cinema.',               FALSE),

-- Movie 2: The Dark Knight (Christopher Nolan)
(4,  1, 2,  5, 'Unrivaled tension and Heath Ledger''s unforgettable performance.',                           FALSE),
(5,  2, 2,  5, 'Still the gold standard for superhero cinema and practical IMAX action.',                    FALSE),
(6,  3, 2,  5, 'Elevates the comic-book blockbuster into an operatic urban crime tragedy.',                  FALSE),

-- Movie 3: Inception (Christopher Nolan)
(7,  1, 3,  4, 'Stunning dream-heist architecture with Zimmer''s iconic brass score.',                       FALSE),
(8,  2, 3,  5, 'Complex narrative layers and rotating hallway choreography that reward every rewatch.',      FALSE),
(9,  3, 3,  3, 'Dazzling mechanical concept, though its heavy exposition occasionally outweighs emotion.',   FALSE),

-- Movie 4: Interstellar (Christopher Nolan)
(10, 1, 4,  4, 'Visually overwhelming and deeply emotional sci-fi anchored by a father-daughter bond.',      TRUE),
(11, 5, 4,  5, 'The docking sequence and organ score alone make this an all-time theatrical experience.',    FALSE),
(12, 4, 4,  3, 'Ambitious cosmic spectacle whose third-act sentimentality softens its scientific rigor.',    TRUE),

-- Movie 5: Oppenheimer (Christopher Nolan)
(13, 1, 5,  4, 'Relentless three-hour biographical thriller shot in stunning 70mm IMAX.',                    FALSE),
(14, 3, 5,  5, 'Nolan''s most mature technical achievement; Cillian Murphy is phenomenal throughout.',       FALSE),
(15, 4, 5,  5, 'A haunting chamber drama disguised as an epic, edited with relentless rhythmic dread.',      FALSE),

-- Movie 6: Dune: Part One (Denis Villeneuve)
(16, 5, 6,  4, 'Slow-burn world building with jaw-dropping desert cinematography and sound design.',         FALSE),
(17, 6, 6,  3, 'Immaculately crafted atmosphere, though it clearly ends halfway through the story.',         FALSE),
(18, 4, 6,  4, 'Monumental brutalist sci-fi that trusts visual scale over frantic exposition.',              FALSE),

-- Movie 7: Dune: Part Two (Denis Villeneuve)
(19, 2, 7,  5, 'Dune: Part Two was breathtaking in IMAX. Peak modern sci-fi filmmaking.',                    FALSE),
(20, 5, 7,  5, 'Desert warfare and soundscapes are mindblowing. Best theater experience of 2024.',           FALSE),
(21, 3, 7,  5, 'Science fiction on a grand, operatic scale with a chillingly tragic final act.',             TRUE),

-- Movie 8: Spirited Away (Hayao Miyazaki)
(22, 2, 8,  4, 'Pure animated magic; every single frame of the bathhouse belongs in a gallery.',             FALSE),
(23, 5, 8,  5, 'Heartfelt, strange, and endlessly imaginative coming-of-age storytelling.',                   FALSE),
(24, 4, 8,  5, 'Miyazaki crafts a timeless allegory of identity, greed, and quiet courage.',                 FALSE),

-- Movie 9: Princess Mononoke (Hayao Miyazaki)
(25, 6, 9,  4, 'Sweeping hand-drawn fantasy with nuanced moral conflict between nature and industry.',       FALSE),
(26, 1, 9,  4, 'Joe Hisaishi''s score and Ashitaka''s journey give this epic tremendous weight.',            FALSE),
(27, 4, 9,  4, 'An ambitious ecological tragedy that refuses simple heroes or villains.',                    FALSE),

-- Movie 10: Parasite (Bong Joon-ho)
(28, 3, 10, 5, 'Bong Joon-ho dissects class warfare with razor-sharp precision and dark humor.',             TRUE),
(29, 4, 10, 5, 'Architectural blocking and tonal control rarely seen in contemporary world cinema.',         FALSE),
(30, 6, 10, 4, 'Unpredictable genre pivots and unforgettable production design from start to finish.',       TRUE),

-- Movie 11: Pulp Fiction (Quentin Tarantino)
(31, 6, 11, 4, 'Sharp, rhythmic dialogue that redefined 1990s independent American cinema.',                 FALSE),
(32, 5, 11, 3, 'Iconic scenes and soundtrack, even if the pacing meanders slightly in the middle act.',      FALSE),
(33, 3, 11, 3, 'Playful postmodern crime mosaic whose stylistic bravura sometimes overshadows substance.',   FALSE),

-- Movie 12: Taxi Driver (Martin Scorsese)
(34, 3, 12, 5, 'A dark, hypnotic portrait of urban alienation and obsession anchored by Robert De Niro.',    FALSE),
(35, 6, 12, 3, 'Bleak, atmospheric 1970s character study that deliberately resists easy viewer sympathy.',   FALSE),
(36, 2, 12, 3, 'Unsettling neon-soaked cinematography and jazz score, though intentionally grueling.',       TRUE);
