# 💡 HKU COMP3278A — Final Project Idea Showcase

> **Course:** HKU COMP3278A — Introduction to Database Management Systems  
> **Repository:** [uffe0520/DBMS_Final_Project](https://github.com/uffe0520/DBMS_Final_Project)  
> **Purpose:** 10 curated project proposals designed to hit 100% of the course syllabus (E-R Modeling, BCNF Normalization, 6-Tier SQL, Relational Division, B+ Tree Indexing, and SQL Injection Security).

---

## Quick Comparison Table

| # | Project Name | Domain & Concept | Key Weak Entity | Relational Division Query ("For ALL...") |
| :-: | :--- | :--- | :--- | :--- |
| **1** | **SteamQuest** | Indie game store, user libraries & trophy tracker | `GameAchievement` | Gamers who unlocked ALL achievements in 'Souls-like' games |
| **2** | **BoulderingHub** | Indoor rock climbing routes & video beta sharing | `RouteAttempt` | Climbers who flashed ALL routes set by Setter X on the 45° wall |
| **3** | **FilmCraft (Letterboxd+)**| Cinema club, screenings & director filmographies | `TheaterScreening` | Cinephiles who watched & rated ALL films by Christopher Nolan |
| **4** | **HypeVault** | Limited sneaker & streetwear live auction house | `ItemSizeVariant` | Collectors who bid on ALL limited Nike SB releases in October |
| **5** | **LateNightHKU** | HKU midnight food delivery & hall drop-offs | `OrderItem` / `HallDrop` | Students who ordered from ALL Main Campus canteens in exam week |
| **6** | **VanLife / TravelNest** | Unique glamping (treehouses, yurts, boats) | `NightlyAvailability` | Guests who stayed in ALL property categories in Japan |
| **7** | **FitDuel** | Gamified gym RPG & 1v1 PR rivalry battles | `WorkoutSet` | Lifters who hit PRs across ALL compound lifts this month |
| **8** | **FestivalPass** | Music festival schedule & stage clash solver | `StageSlot` | Attendees with sets at EVERY stage across the 3-day festival |
| **9** | **AdoptPaws** | Animal shelter rescue, foster & vet care tracker | `VaccinationRecord` | Foster homes that fostered pets across ALL HK shelter branches |
| **10**| **CoffeeRoast** | Specialty coffee tasting passport & bean tracker | `TastingLog` | Drinkers who tasted ALL processing methods from Ethiopian roasters |

---

## Detailed Idea Breakdown

### 1. 🎮 SteamQuest — Indie Game Store & Trophy Tracker
* **Concept:** Steam / itch.io clone featuring game stores, libraries, community reviews, and player achievements.
* **Weak Entity:** `GameAchievement` (code weak on `Game`).
* **ISA Specialization:** `User` $\to$ `Gamer` vs `GameDeveloper` vs `Curator`.
* **Hierarchical / Self-Join:** `Game` $\leftrightarrow$ `GameDLC` (DLCs referencing base game `parent_game_id`).
* **Relational Division:** *"Find gamers who unlocked ALL achievements for games in the 'Souls-like' genre."*
* **Web UI Highlights:** Storefront browse grid, user trophy cabinet, developer sales analytics.

---

### 2. 🧗 BoulderingHub — Rock Climbing Route Tracker & Beta Sharing
* **Concept:** Climbing gym logbook for boulder problems (V0–V12), grade voting, video beta, and gym leaderboards.
* **Weak Entity:** `RouteAttempt` (attempt number weak on `Climber` + `GymRoute`).
* **ISA Specialization:** `GymMember` $\to$ `RecreationalClimber` vs `RouteSetter` vs `GymOwner`.
* **Hierarchical / Self-Join:** Route extensions/variations referencing parent routes.
* **Relational Division:** *"Find climbers who flashed (completed on 1st try) ALL routes set by Setter X on the overhang wall."*
* **Web UI Highlights:** Visual wall problem map, difficulty distribution graphs, climber rankings.

---

### 3. 🍿 FilmCraft (Letterboxd+) — Cinema Club & Film Festival Curator
* **Concept:** Letterboxd-style platform tracking movie screenings, director filmographies, awards, and reviews.
* **Weak Entity:** `TheaterScreening` (screening time weak on `TheaterRoom`).
* **ISA Specialization:** `FilmProfessional` $\to$ `Director` vs `Actor` vs `Cinematographer`.
* **Hierarchical / Self-Join:** Sequels and prequels referencing original film (`prequel_movie_id`).
* **Relational Division:** *"Find cinephiles who logged and rated EVERY film directed by Christopher Nolan."*
* **Web UI Highlights:** Poster collection cards, 5-star rating drawers, director completeness gauges.

---

### 4. 👟 HypeVault — Limited Sneaker & Streetwear Auction Marketplace
* **Concept:** StockX/GOAT-style live auction platform with buyer/seller bidding, shoe condition grading, and payout tracking.
* **Weak Entity:** `ItemSizeVariant` (size weak on `SneakerModel`) or `BidHistory` (weak on `AuctionListing`).
* **ISA Specialization:** `User` $\to$ `Buyer` vs `VerifiedSeller` vs `ExpertAuthenticator`.
* **Hierarchical / Self-Join:** Retro colorway re-releases referencing the original silhouette model.
* **Relational Division:** *"Find collectors who placed bids on EVERY limited Nike SB Dunk release in October."*
* **Web UI Highlights:** Real-time price chart ticker, authentication status tracker, seller analytics.

---

### 5. 🍜 LateNightHKU — Campus Midnight Food & Secret Canteen Delivery
* **Concept:** Food delivery tailored for HKU students (Main Campus canteens, Western District cha chaan teng, hall drops).
* **Weak Entity:** `OrderItem` (weak on `Order`) and `HallDropPoint` (room/floor weak on `ResidentialCollege`).
* **ISA Specialization:** `HKUUser` $\to$ `Student` vs `Professor/Staff` vs `StudentCourier`.
* **Hierarchical / Self-Join:** Restaurant chains (Main branch $\leftrightarrow$ campus satellite kiosks).
* **Relational Division:** *"Find students who ordered late-night food from ALL canteens on Main Campus during midterms week."*
* **Web UI Highlights:** Dish customizer, real-time delivery status timeline, hall spending leaderboards.

---

### 6. ⛺ VanLife / TravelNest — Unique Glamping & Tiny Home Rentals
* **Concept:** Airbnb for unique accommodations: treehouses, yurts, and houseboats with seasonal availability calendars.
* **Weak Entity:** `ListingPhoto` or `NightlyAvailability` (date weak on `Listing`).
* **ISA Specialization:** `User` $\to$ `Guest` vs `Superhost` vs `MaintenancePartner`.
* **N:M with Attributes:** `ListingAmenity` (`amenity_id`, `listing_id`, `is_extra_charge`, `quantity`).
* **Relational Division:** *"Find guests who booked stays across ALL unique categories (Treehouse, Yurt, Boat) in Japan."*
* **Web UI Highlights:** Interactive calendar picker, amenity checklist, host revenue charts.

---

### 7. ⚔️ FitDuel — Gamified Gym RPG & Fitness Rivalry League
* **Concept:** Strava meets RPG: log sets, challenge gym friends to 1v1 PR battles, level up muscle groups.
* **Weak Entity:** `WorkoutSet` (set number weak on `ExerciseSession`).
* **ISA Specialization:** `Exercise` $\to$ `Weightlifting` vs `Cardio` vs `Calisthenics`.
* **Hierarchical / Self-Join:** Rivalry challenges (`challenger_id` $\leftrightarrow$ `opponent_id`).
* **Relational Division:** *"Find lifters who hit a new PR across ALL compound lifts (Bench, Squat, Deadlift, OHP) this month."*
* **Web UI Highlights:** 1v1 match-up comparison, muscle group heatmap, personal record charts.

---

### 8. 🎵 FestivalPass — Music Festival Lineup & Stage Clash Planner
* **Concept:** Music festival timetable planner where attendees resolve schedule clashes, rate DJ sets, and build itineraries.
* **Weak Entity:** `StageSlot` (slot number weak on `Stage` + `FestivalDay`).
* **ISA Specialization:** `FestivalParticipant` $\to$ `Attendee` vs `PerformingArtist` vs `StageManager`.
* **Hierarchical / Self-Join:** Back-to-Back (B2B) artist sets (`primary_artist_id` $\leftrightarrow$ `guest_artist_id`).
* **Relational Division:** *"Find attendees with custom schedules featuring acts at EVERY stage across the 3-day festival."*
* **Web UI Highlights:** Drag-and-drop timeline scheduler, clash-detector alerts, crowd buzz ratings.

---

### 9. 🐶 AdoptPaws — Animal Shelter Rescue, Foster & Medical Care Hub
* **Concept:** Pet adoption platform with veterinary medical records, foster parent diaries, and shelter donations.
* **Weak Entity:** `VaccinationRecord` (dose number weak on `PetProfile`).
* **ISA Specialization:** `User` $\to$ `Adopter` vs `FosterParent` vs `LicensedVeterinarian`.
* **Hierarchical / Self-Join:** Pet lineage / littermate relationships (`mother_id`, `litter_group_id`).
* **Relational Division:** *"Find approved foster homes that fostered pets across ALL shelter branches in HK."*
* **Web UI Highlights:** Swipeable adoption cards, pet medical timeline, application approval pipeline.

---

### 10. ☕ CoffeeRoast — Specialty Coffee Tasting Passport & Bean Tracker
* **Concept:** Specialty coffee passport tracking espresso extractions, origin beans, roasteries, and tasting notes.
* **Weak Entity:** `TastingLog` (tasting entry weak on `BeanBag`).
* **ISA Specialization:** `User` $\to$ `CoffeeEnthusiast` vs `Barista` vs `RoasteryOwner`.
* **Hierarchical / Self-Join:** Coffee blends referencing multiple single-origin bean batches.
* **Relational Division:** *"Find coffee lovers who tasted coffees from ALL processing methods (Washed, Natural, Honey, Anaerobic) from Ethiopian roasters."*
* **Web UI Highlights:** Flavor wheel selector, extraction brew parameters tracker, origin world map.

---

## 🔗 Related Documentation
- [Master Project Blueprint (GOAL.md)](../GOAL.md)
- [SQL Rules & Syllabus Matrix (SQL_RULES.md)](../SQL_RULES.md)
- [AI Agent Instructions (AGENT.md)](../AGENT.md)
