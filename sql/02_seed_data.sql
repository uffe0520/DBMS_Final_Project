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
-- 5. Seed Reviews (0-5 Discrete Star Scale)
-- Completionists: alex_chen (Nolan 5/5), clara_oswald (Miyazaki 2/2),
--                 david_kim (Villeneuve 2/2)
-- --------------------------------------------------------------------
INSERT INTO `reviews` (`review_id`, `user_id`, `movie_id`, `rating`, `review_text`, `contains_spoilers`) VALUES
(1,  1, 1,  5, 'A reverse-chronological masterclass in unreliable narration.',                              FALSE),
(2,  1, 2,  5, 'Unrivaled tension and Heath Ledger''s unforgettable performance.',                        FALSE),
(3,  1, 3,  4, 'Stunning dream-heist architecture with Zimmer''s iconic score.',                          FALSE),
(4,  1, 4,  5, 'Visually overwhelming and deeply emotional sci-fi.',                                      TRUE),
(5,  1, 5,  5, 'Relentless three-hour biographical thriller shot in 70mm IMAX.',                            FALSE),
(6,  2, 2,  5, 'Still the gold standard for superhero cinema.',                                           FALSE),
(7,  2, 3,  4, 'Complex narrative layers that reward every rewatch.',                                     FALSE),
(8,  2, 8,  5, 'Pure animated magic; every single frame belongs in a gallery.',                           FALSE),
(9,  2, 7,  5, 'Dune: Part Two was breathtaking in IMAX. Peak sci-fi filmmaking.',                        FALSE),
(10, 3, 5,  5, 'Nolan''s most mature technical achievement; Cillian Murphy is phenomenal.',               FALSE),
(11, 3, 7,  5, 'Science fiction on a grand, operatic scale.',                                             FALSE),
(12, 3, 10, 5, 'Bong Joon-ho dissects class warfare with surgical precision.',                             TRUE),
(13, 4, 8,  5, 'Miyazaki crafts a timeless allegory of identity and consumerism.',                        FALSE),
(14, 4, 9,  4, 'An ambitious ecological epic without simple heroes or villains.',                         FALSE),
(15, 5, 6,  4, 'Slow-burn world building with jaw-dropping desert cinematography.',                       FALSE),
(16, 5, 7,  5, 'Desert warfare and soundscapes are mindblowing. Best theater experience of 2024.',        FALSE),
(17, 6, 11, 4, 'Sharp, rhythmic dialogue that redefined 1990s independent cinema.',                       FALSE),
(18, 3, 12, 5, 'A dark, hypnotic portrait of urban alienation and obsession.',                            FALSE);
