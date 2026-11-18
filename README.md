# FilmCraft — Cinema Review & Archive

> **Course:** HKU COMP3278A — Introduction to Database Management Systems  
> **Stack:** MySQL 8.x · Node.js (Express) · HTML / Tailwind CSS  
> **Database Scope:** 5 relational tables with full Create, Read, Update, and Delete (CRUD) operations.
---

## 1. Prerequisites

- **Node.js** v18+ (`node -v`) and **npm** (`npm -v`)
- **MySQL Server** 8.x (`mysql --version`), running locally on `127.0.0.1:3306`

---

## 2. Database Setup & Initial Data

Run the two SQL scripts in order to create the `filmcraft` database, all 5 tables, and the initial dataset (6 users, 6 directors, 12 films with posters, genres, and 22 reviews):

```bash
mysql -u root < sql/01_schema.sql
mysql -u root < sql/02_seed_data.sql
```

> If your MySQL `root` user requires a password, add `-p`:
> ```bash
> mysql -u root -p < sql/01_schema.sql
> mysql -u root -p < sql/02_seed_data.sql
> ```

*(Optional)* Verify all key SQL queries directly in MySQL:
```bash
mysql -u root < sql/03_queries.sql
```

---

## 3. Configuration

By default, `src/server.js` connects to MySQL using:

| Variable | Default Value | Description |
|---|---|---|
| `DB_HOST` | `127.0.0.1` | MySQL server hostname |
| `DB_PORT` | `3306` | MySQL server port |
| `DB_USER` | `root` | MySQL username |
| `DB_PASSWORD` | `""` (empty) | MySQL password |
| `DB_NAME` | `filmcraft` | Database name |
| `PORT` | `3001` | Local web server port |

If your local MySQL instance uses a password or different credentials, pass them as environment variables when starting the server:

```bash
DB_USER=root DB_PASSWORD=your_password npm start
```

---

## 4. Installation & Run Instructions

From the project root directory:

```bash
npm install
npm start
```

You should see:
```text

The FilmCraft Web Server is running!
Your Local URL: http://localhost:3001
Enjoy with joy!

Connected to MySQL `filmcraft` database
```

Open **[http://localhost:3001](http://localhost:3001)** in your browser.

### Stopping the Server

- In the terminal window running `npm start`, press **`Ctrl + C`** (works on macOS, Linux, and Windows).
- If the server is still running in the background on port `3001`:
  - **macOS / Linux:** `lsof -ti :3001 | xargs kill`
  - **Windows (PowerShell):** `Stop-Process -Id (Get-NetTCPConnection -LocalPort 3001).OwningProcess`

---

## 5. Database Tables & Keys (5 Tables)

- **`users`**: `user_id` (PK), `username` (UNIQUE), `email` (UNIQUE), `role` (`CINEPHILE` | `CRITIC`), `membership_tier` (`FREE` | `PRO` | `PATRON`, for `CINEPHILE`), `publication_name` (for `CRITIC`) — total & disjoint specialization enforced via `CHECK`
- **`directors`**: `director_id` (PK), `name` (UNIQUE), `nationality`, `biography`
- **`movies`**: `movie_id` (PK), `title`, `release_year` (`>= 1888`), `duration_minutes` (`> 0`), `language`, `synopsis`, `poster_url`, `director_id` (FK → `directors.director_id`), `prequel_movie_id` (FK → `movies.movie_id`)
- **`movie_genres`**: `movie_id` (PK, FK → `movies.movie_id`), `genre_name` (PK) — multi-valued attribute `{genre_name}` of `movies`
- **`reviews`**: `review_id` (PK), `user_id` (FK → `users.user_id`), `movie_id` (FK → `movies.movie_id`), `rating` (`0–5`), `review_text`, `contains_spoilers` — `UNIQUE (user_id, movie_id)`

---

## 6. Application Features

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
- **Completionist Challenge (`Tab 5`):** Relational Division finding reviewers who completed every catalogued film by any selected director (`GET /api/division?directorId=`).

---

## 7. Repository Structure

```text
DBMS_Final_Project/
├── README.md
├── package.json
├── posters/                  # Shared movie posters + default_blank.svg
├── sql/
│   ├── 00_reset_db.sql       # Optional full database drop/recreate
│   ├── 01_schema.sql         # 5-table BCNF schema definition
│   ├── 02_seed_data.sql      # Initial dataset (6 users, 6 directors, 12 films, 22 reviews)
│   └── 03_queries.sql        # Key standard SQL statements for presentation reference
└── src/
    ├── server.js             # Express REST API + MySQL connection pool
    └── public/
        └── index.html        # Editorial broadsheet frontend UI
```
