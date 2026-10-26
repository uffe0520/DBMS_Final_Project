# FilmCraft (Letterboxd+) — Conceptual ER Model & Reduction Notes

> **Course:** HKU COMP3278A — Introduction to Database Management Systems  
> **Topic:** Chapter 2 (Entity-Relationship Model & Reduction to Relational Schemas)  
> **System:** FilmCraft — Cinema Tracking, Theatrical Screenings & Festival Curator Platform

---

## 1. Business Requirements & Domain Scope

FilmCraft provides a unified relational platform for film enthusiasts (cinephiles), accredited critics, and festival curators:
1. **User Accounts & Roles:** Users register and specialize into standard **Cinephiles**, accredited **FilmCritics** (verified by publications), or **FestivalCurators** (organizing festival editions).
2. **Movies & Film Catalog:** Movies have titles, release years, runtimes, languages, and synopses. A movie can optionally have a **prequel** (another movie), forming a franchise hierarchy. Movies have one or more **genres** (multi-valued attribute).
3. **Film Professionals (Cast & Crew):** Directors, actors, writers, and cinematographers are represented as film professionals. A professional can participate in multiple movies under various roles, with specific character names and billing order.
4. **Cinemas & Theatrical Screenings:** Theaters contain physical screening rooms. A screening room is uniquely identified only within its theater (weak entity). Screenings occur in specific rooms at scheduled dates and times for a specific movie at a set ticket price.
5. **Reviews & Ratings:** Users rate and review movies on a 1–10 scale, indicating whether the review contains spoilers and the date watched.
6. **Curated Watchlists:** Users can create named, public or private watchlists containing ranked movie selections with custom notes.
7. **Film Festivals & Awards:** Film festivals host annual editions with official award categories (Best Picture, Best Director). Movies and professionals receive nominations with a win flag.

---

## 2. Entity Sets & Attributes

### Strong Entity Sets
- **`User`**: `user_id` (PK), `username` (UNIQUE), `email` (UNIQUE), `password_hash`, `role`, `created_at`
- **`Movie`**: `movie_id` (PK), `title`, `release_year`, `duration_minutes`, `language`, `synopsis`, `prequel_movie_id` (Self-referencing FK)
  - *Multi-valued Attribute:* `genre` (reduced to `MovieGenre`)
- **`FilmProfessional`**: `person_id` (PK), `name`, `birth_date`, `nationality`, `biography`
- **`Theater`**: `theater_id` (PK), `name`, `city`, `address`
- **`Watchlist`**: `list_id` (PK), `user_id` (FK), `title`, `description`, `is_public`, `created_at`
- **`Festival`**: `festival_id` (PK), `name`, `city`, `established_year`

### Weak Entity Sets
- **`TheaterRoom`**:
  - *Identifying Entity:* `Theater`
  - *Identifying Relationship:* `HousesRoom` (Double diamond)
  - *Discriminator / Partial Key:* `room_number` (dashed underline)
  - *Attributes:* `seating_capacity`, `screen_format` (e.g. IMAX, 3D, Standard)
  - *Participation:* Total on `TheaterRoom` (double rectangle, double line)
- **`TheaterScreening`**:
  - *Identifying Entity:* `TheaterRoom`
  - *Identifying Relationship:* `HostsScreening` (Double diamond)
  - *Discriminator / Partial Key:* `screening_datetime` (dashed underline)
  - *Attributes:* `ticket_price`, `audio_format`
  - *Referenced Entity:* `Movie` (1:N from Movie to Screening)
- **`FestivalAward`**:
  - *Identifying Entity:* `Festival`
  - *Identifying Relationship:* `PresentsAward` (Double diamond)
  - *Discriminator / Partial Key:* `category_name`, `award_year`

### Specialization / Generalization (ISA Hierarchy)
- **Superclass:** `User`
- **Disjoint & Total Specialization:** Every user must belong to exactly one subclass:
  - `Cinephile`: `favorite_genre`, `membership_tier`
  - `FilmCritic`: `publication_name`, `critic_license_no`, `is_verified`
  - `FestivalCurator`: `festival_organization`, `accreditation_id`

---

## 3. Relationship Sets & Cardinalities

| Relationship Set | Participating Entities | Cardinality | Participation | Descriptive Attributes |
| :--- | :--- | :--- | :--- | :--- |
| **`MovieCastCrew`** | `Movie` $\times$ `FilmProfessional` | N : M | Partial on both | `role_type`, `character_name`, `billing_order` |
| **`Review`** | `User` $\times$ `Movie` | N : M | Partial on both | `rating` (1–10), `review_text`, `contains_spoilers`, `watch_date`, `created_at` |
| **`WatchlistEntry`**| `Watchlist` $\times$ `Movie` | N : M | Total on Entry | `rank_order`, `curator_note` |
| **`AwardNomination`**| `FestivalAward` $\times$ `Movie` $\times$ `FilmProfessional` | Ternary | Partial on all | `is_winner` (BOOLEAN) |
| **`FranchisePrequel`**| `Movie` (Self-referencing) | 1 : N | Partial on both | `is_canonical` |
| **`ScreensMovie`** | `Movie` $\times$ `TheaterScreening` | 1 : N (Arrow to Movie) | Total on Screening | — |

---

## 4. Anti-Pitfall Checklist (from `cheatseet1.pdf`)

- [x] **Arrow Direction Rule:** An arrow points **TO the "1" side** of the relationship (`TheaterScreening` $\to$ `Movie`).
- [x] **Weak Entity Integrity:** Never draw the identifying owner's primary key (`theater_id`) as an ellipse attribute on `TheaterRoom`. The double diamond relationship carries the foreign key connection.
- [x] **Relationship Attributes:** Attributes that depend on the combination of entities (e.g. `character_name` and `role_type` for actors in a movie; `rating` and `watch_date` for user reviews) are placed on the relationship diamond, not the entity rectangle.
- [x] **Multi-Valued Attributes:** `genre` on `Movie` is represented as a double ellipse and reduced to a distinct relation `MovieGenre(movie_id, genre_name)`.

---

## 5. Reduction to Relational Schemas

Following the formal reduction algorithm from Chapter 2:

1. **`User` (Superclass):**
   - `User(user_id, username, email, password_hash, role, created_at)`
   - PK: `{user_id}`
2. **ISA Subclasses:**
   - `Cinephile(user_id, favorite_genre, membership_tier)` — FK `{user_id}` ref `User`
   - `FilmCritic(user_id, publication_name, critic_license_no, is_verified)` — FK `{user_id}` ref `User`
   - `FestivalCurator(user_id, festival_organization, accreditation_id)` — FK `{user_id}` ref `User`
3. **`Movie` & Franchise Hierarchy:**
   - `Movie(movie_id, title, release_year, duration_minutes, language, synopsis, prequel_movie_id)`
   - PK: `{movie_id}`
   - FK: `{prequel_movie_id}` references `Movie{movie_id}` (`ON DELETE SET NULL`)
4. **Multi-Valued `MovieGenre`:**
   - `MovieGenre(movie_id, genre_name)`
   - PK: `{movie_id, genre_name}`
   - FK: `{movie_id}` references `Movie{movie_id}` (`ON DELETE CASCADE`)
5. **`FilmProfessional`:**
   - `FilmProfessional(person_id, name, birth_date, nationality, biography)`
   - PK: `{person_id}`
6. **`MovieCastCrew` (N:M Relationship):**
   - `MovieCastCrew(movie_id, person_id, role_type, character_name, billing_order)`
   - PK: `{movie_id, person_id, role_type}`
   - FK: `{movie_id}` references `Movie{movie_id}` (`ON DELETE CASCADE`)
   - FK: `{person_id}` references `FilmProfessional{person_id}` (`ON DELETE CASCADE`)
7. **`Theater` (Strong Entity):**
   - `Theater(theater_id, name, city, address)`
   - PK: `{theater_id}`
8. **`TheaterRoom` (Weak Entity on `Theater`):**
   - `TheaterRoom(theater_id, room_number, seating_capacity, screen_format)`
   - PK: `{theater_id, room_number}`
   - FK: `{theater_id}` references `Theater{theater_id}` (`ON DELETE CASCADE`)
9. **`TheaterScreening` (Weak Entity / Event):**
   - `TheaterScreening(screening_id, theater_id, room_number, movie_id, screening_datetime, ticket_price)`
   - PK: `{screening_id}` (or composite `{theater_id, room_number, screening_datetime}`)
   - FK: `{theater_id, room_number}` references `TheaterRoom{theater_id, room_number}` (`ON DELETE CASCADE`)
   - FK: `{movie_id}` references `Movie{movie_id}` (`ON DELETE RESTRICT`)
10. **`Review` (N:M Relationship with Composite PK or Surrogate PK):**
    - `Review(review_id, user_id, movie_id, rating, review_text, contains_spoilers, watch_date, created_at)`
    - PK: `{review_id}`, UNIQUE: `{user_id, movie_id}`
    - FK: `{user_id}` references `User{user_id}` (`ON DELETE CASCADE`)
    - FK: `{movie_id}` references `Movie{movie_id}` (`ON DELETE CASCADE`)
11. **`Watchlist` & `WatchlistEntry`:**
    - `Watchlist(list_id, user_id, title, description, is_public, created_at)`
    - `WatchlistEntry(list_id, movie_id, rank_order, curator_note)`
    - PK: `{list_id, movie_id}`
    - FK: `{list_id}` references `Watchlist{list_id}` (`ON DELETE CASCADE`)
    - FK: `{movie_id}` references `Movie{movie_id}` (`ON DELETE CASCADE`)
12. **`Festival` & `FestivalAward` & `AwardNomination`:**
    - `Festival(festival_id, name, city, established_year)`
    - `FestivalAward(award_id, festival_id, category_name, award_year)`
    - `AwardNomination(nomination_id, award_id, movie_id, person_id, is_winner)`
