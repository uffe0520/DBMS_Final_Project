# FilmCraft — Formal Normalization Proofs (BCNF & 3NF)

> **Course:** HKU COMP3278A — Introduction to Database Management Systems  
> **Topic:** Chapter 5 (Relational Database Design & Normalization)  
> **Objective:** Prove that all relation schemas in FilmCraft satisfy Boyce-Codd Normal Form (BCNF) or Third Normal Form (3NF) with lossless join and dependency preservation.

---

## 1. Mathematical Definitions & Criteria

1. **Functional Dependency (FD):** $X \to Y$ holds on relation schema $R$ if for all tuples $t_1, t_2 \in r(R)$, $t_1[X] = t_2[X] \implies t_1[Y] = t_2[Y]$.
2. **Superkey:** A set of attributes $K \subseteq R$ such that $K^+ = R$ (the closure of $K$ under $F$ contains all attributes of $R$).
3. **Candidate Key:** A minimal superkey (no proper subset of $K$ is a superkey).
4. **Boyce-Codd Normal Form (BCNF):** A relation schema $R$ is in BCNF with respect to a set of FDs $F$ if, for all functional dependencies in $F^+$ of the form $X \to Y$ (where $X \subseteq R$ and $Y \subseteq R$), at least one of the following holds:
   - $X \to Y$ is a **trivial** functional dependency ($Y \subseteq X$).
   - $X$ is a **superkey** for schema $R$.
5. **Third Normal Form (3NF):** A relation schema $R$ is in 3NF if for every non-trivial $X \to Y$:
   - $X$ is a superkey, **OR**
   - Each attribute in $Y \setminus X$ is a **prime attribute** (contained in some candidate key).

---

## 2. Table-by-Table FD Analysis & Proofs

### Relation 1: `User(user_id, username, email, password_hash, role, created_at)`
- **Functional Dependencies ($F_1$):**
  1. `user_id` $\to$ `{username, email, password_hash, role, created_at}`
  2. `username` $\to$ `{user_id, email, password_hash, role, created_at}`
  3. `email` $\to$ `{user_id, username, password_hash, role, created_at}`
- **Candidate Keys:** `{user_id}`, `{username}`, `{email}`.
- **Proof:**
  - For FD 1: LHS `{user_id}` is a candidate key $\implies$ superkey.
  - For FD 2: LHS `{username}` is a candidate key $\implies$ superkey.
  - For FD 3: LHS `{email}` is a candidate key $\implies$ superkey.
- **Conclusion:** `User` satisfies **BCNF**.

---

### Relation 2: `Movie(movie_id, title, release_year, duration_minutes, language, synopsis, prequel_movie_id)`
- **Functional Dependencies ($F_2$):**
  1. `movie_id` $\to$ `{title, release_year, duration_minutes, language, synopsis, prequel_movie_id}`
- **Candidate Key:** `{movie_id}`.
- **Proof:**
  - Every non-trivial FD has `{movie_id}` on the LHS, which is a superkey.
- **Conclusion:** `Movie` satisfies **BCNF**.

---

### Relation 3: `MovieGenre(movie_id, genre_name)`
- **Functional Dependencies ($F_3$):**
  - No non-trivial dependencies with a single attribute on the LHS (a movie has multiple genres, and a genre has multiple movies).
  - Trivial FDs only: `{movie_id, genre_name}` $\to$ `{movie_id}`, `{genre_name}`.
- **Candidate Key:** Composite key `{movie_id, genre_name}`.
- **Conclusion:** Since no non-trivial FDs exist where LHS is not a superkey, `MovieGenre` is trivially in **BCNF**.

---

### Relation 4: `FilmProfessional(person_id, name, birth_date, nationality, biography)`
- **Functional Dependencies ($F_4$):**
  1. `person_id` $\to$ `{name, birth_date, nationality, biography}`
- **Candidate Key:** `{person_id}`.
- **Conclusion:** LHS is a superkey $\implies$ satisfies **BCNF**.

---

### Relation 5: `MovieCastCrew(movie_id, person_id, role_type, character_name, billing_order)`
- **Functional Dependencies ($F_5$):**
  1. `{movie_id, person_id, role_type}` $\to$ `{character_name, billing_order}`
- **Candidate Key:** Composite key `{movie_id, person_id, role_type}`.
- **Proof:**
  - The LHS is the primary key and the minimal superkey. No partial key dependency exists (`character_name` and `billing_order` depend on the specific person's role in that specific movie).
- **Conclusion:** `MovieCastCrew` satisfies **BCNF**.

---

### Relation 6: `Theater(theater_id, name, city, address)`
- **Functional Dependencies ($F_6$):**
  1. `theater_id` $\to$ `{name, city, address}`
- **Candidate Key:** `{theater_id}`.
- **Conclusion:** Satisfies **BCNF**.

---

### Relation 7: `TheaterRoom(theater_id, room_number, seating_capacity, screen_format)`
- **Functional Dependencies ($F_7$):**
  1. `{theater_id, room_number}` $\to$ `{seating_capacity, screen_format}`
- **Candidate Key:** Composite key `{theater_id, room_number}`.
- **Proof:**
  - `room_number` alone does not determine capacity (Room 1 in Theater A has a different capacity than Room 1 in Theater B).
  - `{theater_id, room_number}` uniquely determines all room attributes.
- **Conclusion:** `TheaterRoom` satisfies **BCNF**.

---

### Relation 8: `TheaterScreening(screening_id, theater_id, room_number, movie_id, screening_datetime, ticket_price)`
- **Functional Dependencies ($F_8$):**
  1. `screening_id` $\to$ `{theater_id, room_number, movie_id, screening_datetime, ticket_price}`
  2. `{theater_id, room_number, screening_datetime}` $\to$ `{screening_id, movie_id, ticket_price}` (a room can only host one screening at a given timestamp).
- **Candidate Keys:** `{screening_id}`, `{theater_id, room_number, screening_datetime}`.
- **Proof:**
  - For FD 1: `screening_id` is a candidate key $\implies$ superkey.
  - For FD 2: `{theater_id, room_number, screening_datetime}` is a candidate key $\implies$ superkey.
- **Conclusion:** `TheaterScreening` satisfies **BCNF**.

---

### Relation 9: `Review(review_id, user_id, movie_id, rating, review_text, contains_spoilers, watch_date, created_at)`
- **Functional Dependencies ($F_9$):**
  1. `review_id` $\to$ `{user_id, movie_id, rating, review_text, contains_spoilers, watch_date, created_at}`
  2. `{user_id, movie_id}` $\to$ `{review_id, rating, review_text, contains_spoilers, watch_date, created_at}` (a user cannot submit duplicate reviews for the same movie).
- **Candidate Keys:** `{review_id}`, `{user_id, movie_id}`.
- **Proof:**
  - Both LHS sets are candidate keys $\implies$ superkeys.
- **Conclusion:** `Review` satisfies **BCNF**.

---

### Relation 10: `WatchlistEntry(list_id, movie_id, rank_order, curator_note)`
- **Functional Dependencies ($F_{10}$):**
  1. `{list_id, movie_id}` $\to$ `{rank_order, curator_note}`
- **Candidate Key:** `{list_id, movie_id}`.
- **Conclusion:** Satisfies **BCNF**.

---

## 3. Lossless-Join & Dependency Preservation Verification

- **Lossless-Join Decomposition:**
  For any binary decomposition $R = R_1 \cup R_2$, the join is lossless if and only if $R_1 \cap R_2 \to R_1$ or $R_1 \cap R_2 \to R_2$.
  - In our schema, every foreign key references a candidate key / primary key of the target table.
  - Therefore, every natural join over the common attribute set reconstructs the exact original relation without producing spurious tuples.
- **Zero Update Anomalies:**
  - No data redundancy: film metadata (title, runtime) is stored once in `Movie`.
  - Updating a director's biography in `FilmProfessional` immediately reflects across all their films without modifying `MovieCastCrew`.
  - Deleting a user safely cascades to their reviews without affecting the movie records.
