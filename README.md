# FilmCraft - Cinema Review & Archive

> **Course:** HKU COMP3278A - Introduction to Database Management Systems  
> **Stack:** MySQL 8.x · Node.js (Express) · HTML / Tailwind CSS  
> **Database Scope:** 5 relational tables with full Create, Read, Update, and Delete (CRUD) operations.
---


Contributors:
Uffe Grøn Roepstorff, 3036713225
Markus Thomasson, 3036719011
Hanna Niwinska, 3036713873
Lucien Neale, 3036720486


## 1. Setting up the App

**Requirements:** Node.js 18+ and MySQL 8, with the `filmcraft` database loaded from `sql/01_schema.sql` and `sql/02_seed_data.sql`.

Add the folder to a suitable place

Open a terminal in the project folder (`Group_25_code/`), then follow the section for your system.

### macOS

```bash
npm install
npm start
```

If your MySQL `root` user has a password, start with this instead:

```bash
DB_PASSWORD='your MySQL password' npm start
```

### Windows (PowerShell)

```powershell
npm install
$env:DB_PASSWORD = "your MySQL password"
npm start
```

If your MySQL `root` user has no password, skip the `$env:DB_PASSWORD` line.

### Open the app

Go to **[http://localhost:3001](http://localhost:3001)**. Press **`Ctrl + C`** in the terminal to stop the server.

---

## 2. Database Tables & Keys (5 Tables)

- **`users`**: `user_id` (PK), `username` (UNIQUE), `email` (UNIQUE), `role` (`CINEPHILE` | `CRITIC`), `membership_tier` (`FREE` | `PRO` | `PATRON`), `publication_name` 
- **`directors`**: `director_id` (PK), `name` (UNIQUE), `nationality`, `biography`
- **`movies`**: `movie_id` (PK), `title`, `release_year` (`>= 1888`), `duration_minutes` (`> 0`), `language`, `synopsis`, `poster_url`, `director_id` (FK → `directors.director_id`), `prequel_movie_id` (FK → `movies.movie_id`)
- **`movie_genres`**: `movie_id` (PK, FK → `movies.movie_id`), `genre_name` (PK) - multi-valued attribute `{genre_name}` of `movies`
- **`reviews`**: `review_id` (PK), `user_id` (FK → `users.user_id`), `movie_id` (FK → `movies.movie_id`), `rating` (`0–5`), `review_text`, `contains_spoilers` - `UNIQUE (user_id, movie_id)`

---

## 3. Application Features

- **Films Catalog (`Tab 1`):**
  - **Read & Search:** Filter by title, director, or genre via standard `EXISTS` (`GET /api/movies?q=`).
  - **Create:** Add a new film with director, genre, prequel, and image drag and drop saved into `posters/` (`POST /api/posters/upload`, `POST /api/movies`).
  - **Update:** Edit any film's metadata, director, genre, or poster (`PUT /api/movies/:id`).
  - **Delete:** Remove a film inside an explicit transaction that clears sequel links, reviews, and genres before deleting the movie row (`DELETE /api/movies/:id`).
- **Reviews & Ratings (`Tab 2` + Film Review Modal):**
  - **Create:** Register a reviewer account (`POST /api/users`) and log a 0–5 star review (`POST /api/reviews`).
  - **Read & Sort:** Inspect reviews per film or across the full community feed sorted by **Newest**, **Film (A–Z)**, **Director (A–Z)**, or **Highest Rating** (`GET /api/reviews?sort=`).
  - **Update:** Edit any review's star rating, commentary, or spoiler tag (`PUT /api/reviews/:id`).
  - **Delete:** Delete any review with live average-rating recalculation (`DELETE /api/reviews/:id`).
- **Film Leaderboard (`Tab 3`):** Ranks films by overall average, min–max range, and Critic vs. Cinephile breakdown via derived tables in `FROM`, with filters for **Top-Rated (`>= ALL`)**, **Above Platform Avg (`HAVING` subquery)**, and **Critics' Choice** (`GET /api/leaderboard/films?filter=`).
- **Director Leaderboard (`Tab 4`):** Multi-table `JOIN` + `GROUP BY` + `HAVING` director ranking (`GET /api/directors`).
- **Completionist Challenge (`Tab 5`):** Relational Division finding reviewers who reviewed every catalogued film by any selected director (`GET /api/division?directorId=`).

---

## 4. Repository Structure

```text
DBMS_Final_Project/
├── README.md
├── package.json
├── posters/                  # Shared movie posters + default_blank.svg
├── sql/
│   ├── 00_reset_db.sql       # Optional full database drop/recreate
│   ├── 01_schema.sql         # 5-table BCNF schema definition
│   ├── 02_seed_data.sql      # Initial dataset (6 users, 6 directors, 12 films, 36 reviews)
│   └── 03_queries.sql        # Key standard SQL statements for presentation reference
└── src/
    ├── server.js             # Express REST API + MySQL connection pool
    └── public/
        └── index.html        # Editorial broadsheet frontend UI
```
