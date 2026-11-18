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

Run the two SQL scripts in order to create the `filmcraft` database, all 5 tables, and the initial dataset (6 users, 6 directors, 12 films with posters, genres, and 18 reviews):

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

## 5. ER Model & Reduction to Relational Schema (5 Tables)

Every table in `sql/01_schema.sql` is derived directly from the conceptual Entity-Relationship (ER) diagram using the standard ER-to-Relational reduction rules covered in COMP3278A, and every table is actively queried and mutated by the web application.

### 5.1 Conceptual ER Diagram Components

- **Strong Entity Sets:**
  - **`User`**: `user_id` (PK), `username` (UNIQUE), `email` (UNIQUE)
  - **`Director`**: `director_id` (PK), `name` (UNIQUE), `nationality`, `biography`
  - **`Movie`**: `movie_id` (PK), `title`, `release_year`, `duration_minutes`, `language`, `synopsis`, `poster_url`, and multi-valued attribute **`{genre_name}`**
- **Specialization / Generalization (ISA Hierarchy):**
  - **`User`** has a **total and disjoint** specialization into two subclasses:
    - **`Cinephile`**: `membership_tier` (`FREE`, `PRO`, `PATRON`)
    - **`Critic`**: `publication_name`
- **Relationship Sets:**

| Relationship Set | Participating Entity Sets | Cardinality | Participation | Descriptive Attributes |
|---|---|---|---|---|
| **`Directs`** | `Director` ↔ `Movie` | `1 : N` (arrow to `Director`) | Partial on both | — |
| **`HasPrequel`** | `Movie` (*sequel*) ↔ `Movie` (*prequel*) | Recursive `1 : N` (arrow to *prequel*) | Partial on both | — |
| **`Reviews`** | `User` ↔ `Movie` | `M : N` | Partial on both | `rating` (0–5), `review_text`, `contains_spoilers` |

### 5.2 Step-by-Step Reduction from ER Diagram to Relational Tables

1. **Strong Entity Sets → Base Relations (`directors`, `movies`, `users`):**
   Each strong entity set maps to a table containing all of its simple attributes and its primary key (`director_id`, `movie_id`, `user_id`).
2. **Total & Disjoint ISA Specialization (`Cinephile` / `Critic` ISA `User`) → Single-Table Mapping (`users`):**
   Because the specialization is **total and disjoint** and each subclass introduces only one specific attribute, the superclass and both subclasses are folded into a single `users` table with a discriminator attribute `role` (`'CINEPHILE'` or `'CRITIC'`). Disjointness and totality are enforced directly at the database level via `CHECK` constraint `chk_users_role_attrs` (a `CINEPHILE` must have `membership_tier` and `publication_name IS NULL`; a `CRITIC` must have `publication_name` and `membership_tier IS NULL`).
3. **Many-to-One Relationship (`Directs`, `Director` 1 : N `Movie`) → Merge into the "Many" Side (`movies`):**
   Rather than creating a separate relationship table, the primary key of the `1`-side entity (`directors.director_id`) is added as a nullable foreign key in the `N`-side table `movies` (`FOREIGN KEY (director_id) REFERENCES directors(director_id)`).
4. **Recursive `1 : N` Relationship (`HasPrequel`) → Self-Referencing Foreign Key (`movies`):**
   The recursive relationship is merged into `movies` by adding the nullable self-referencing foreign key `prequel_movie_id` referencing `movies(movie_id)`.
5. **Multi-Valued Attribute (`Movie.{genre_name}`) → Separate Relation (`movie_genres`):**
   To satisfy First Normal Form (1NF) and BCNF, the multi-valued attribute `genre_name` on `Movie` is extracted into its own relation `movie_genres(movie_id, genre_name)` with composite primary key `(movie_id, genre_name)` and foreign key `movie_id` referencing `movies(movie_id)`.
6. **Many-to-Many Relationship (`Reviews`, `User` M : N `Movie`) → Separate Relationship Table (`reviews`):**
   An `M:N` relationship cannot be merged into either entity table and therefore becomes its own relation `reviews` containing the foreign keys of both participating entities (`user_id` → `users`, `movie_id` → `movies`) plus all descriptive attributes (`rating`, `review_text`, `contains_spoilers`). A surrogate key `review_id` serves as the primary key for direct API updates/deletes, while `UNIQUE (user_id, movie_id)` enforces the natural candidate key (at most one review per user per film).

### 5.3 Resulting Relational Schemas & Constraints

- `users(`**`user_id`**`, username, email, role, membership_tier, publication_name)`
- `directors(`**`director_id`**`, name, nationality, biography)`
- `movies(`**`movie_id`**`, title, release_year, duration_minutes, language, synopsis, poster_url, director_id [FK → directors], prequel_movie_id [FK → movies])`
- `movie_genres(`**`movie_id [FK → movies], genre_name`**`)`
- `reviews(`**`review_id`**`, user_id [FK → users], movie_id [FK → movies], rating, review_text, contains_spoilers)`

| Table | ER Construct Mapped | Purpose | Key Constraints |
|---|---|---|---|
| `users` | Strong Entity + Total/Disjoint ISA (`Cinephile`, `Critic`) | Community reviewers (`CINEPHILE` & `CRITIC`) | PK `user_id`, `UNIQUE (username)`, `UNIQUE (email)`, disjoint role-attribute `CHECK` |
| `directors` | Strong Entity (`1`-side of `Directs`) | Film directors (`1:N` with `movies`) | PK `director_id`, `UNIQUE (name)` |
| `movies` | Strong Entity + merged `1:N` `Directs` + recursive `HasPrequel` | Core film catalog with poster, director & franchise lineage | PK `movie_id`, `CHECK (release_year >= 1888)`, `CHECK (duration_minutes > 0)`, FK `director_id`, self-FK `prequel_movie_id` |
| `movie_genres` | Multi-Valued Attribute (`Movie.{genre_name}`) | Multi-valued genres per film (1NF / BCNF) | Composite PK `(movie_id, genre_name)`, FK `movie_id` |
| `reviews` | `M:N` Relationship Set with Descriptive Attributes | 0–5 star critiques linking users and films (`M:N`) | PK `review_id`, `UNIQUE (user_id, movie_id)`, `CHECK (rating BETWEEN 0 AND 5)`, FKs `user_id` & `movie_id` |

---

## 6. Application Features & Full CRUD Coverage

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
- **Film Leaderboard (`Tab 3`):** Ranks every film by average rating, min–max range, and review volume (`GET /api/leaderboard/films`).
- **Director Leaderboard (`Tab 4`):** Multi-table `JOIN` + `GROUP BY` + `HAVING` director ranking (`GET /api/directors`).
- **Completionist Challenge (`Tab 5`):** Relational Division finding reviewers who completed every catalogued film by any selected director (`GET /api/division?directorId=`).

---

## 7. Repository Structure

```text
DBMS_Final_Project/
├── README.md
├── package.json
├── posters/                  # Shared 2:3 movie posters + default_blank.svg (OS-independent uploads)
├── sql/
│   ├── 00_reset_db.sql       # Optional full database drop/recreate
│   ├── 01_schema.sql         # 5-table BCNF schema definition
│   ├── 02_seed_data.sql      # Initial dataset (6 users, 6 directors, 12 films, 18 reviews)
│   └── 03_queries.sql        # Key standard SQL statements for presentation reference
└── src/
    ├── server.js             # Express REST API + MySQL connection pool
    └── public/
        └── index.html        # Editorial broadsheet frontend UI
```
