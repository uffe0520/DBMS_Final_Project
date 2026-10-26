# 🎥 FilmCraft — 2-Minute Video Demonstration Script

> **Maximum Allowed Duration:** 120 Seconds (2 Minutes)  
> **Requirement:** Voice-over explanations are encouraged; every group member must speak.  
> **Video Format:** 1080p / 60fps MP4 recording with crisp audio.

---

## Timeline & Narration Breakdown

### [0:00 - 0:25] Scene 1: Platform Overview & User Roles (Speaker: Member 1)
- **On-Screen Action:**
  1. Open browser at `http://localhost:3000`.
  2. Show landing page displaying the trending movie catalog (Oppenheimer, Dune: Part Two, Spirited Away).
  3. Log in as user `alex_chen` (Role: Cinephile) and show profile badge.
- **Voiceover (Member 1):**
  > *"Welcome to FilmCraft, a comprehensive relational platform connecting movie enthusiasts, film critics, and festival curators. Our architecture supports distinct user roles via relational ISA specialization, allowing cinephiles and accredited critics to interact seamlessly with cinemas and festival programs."*

---

### [0:25 - 0:50] Scene 2: Movie Catalog, Franchises & Reviews (Speaker: Member 2)
- **On-Screen Action:**
  1. Click on *Dune: Part Two*.
  2. Scroll down to show the prequel banner: *"Prequel: Dune: Part One (2021)"* (demonstrating the self-referencing relationship).
  3. Show cast list featuring Timothée Chalamet and Denis Villeneuve.
  4. Submit an interactive 10/10 review with a short comment.
- **Voiceover (Member 2):**
  > *"Here on the Dune Part Two page, we can observe the hierarchical self-referencing relationship linking the sequel directly to its predecessor. Submitting a review executes an atomic database transaction that updates both the review table and the user's favorite genre statistics without race conditions."*

---

### [0:50 - 1:15] Scene 3: Theaters, Screening Rooms & Bookings (Speaker: Member 3)
- **On-Screen Action:**
  1. Navigate to the *Theaters & Screenings* tab.
  2. Select *Broadway Cinematheque* (Yau Ma Tei).
  3. Show screening room list (Weak Entity: Room 1, Room 2) with formats (IMAX / Standard).
  4. Display scheduled screenings for Oppenheimer and Spirited Away with seat capacity indicators.
- **Voiceover (Member 3):**
  > *"Our screening module models physical cinema infrastructure as weak entities dependent on parent theaters. Screenings are queried using multi-way inner joins that combine room seating capacities and ticket pricing to calculate real-time box office potential."*

---

### [1:15 - 1:45] Scene 4: Analytical Dashboard & The Division Query (Speaker: Member 4)
- **On-Screen Action:**
  1. Switch to the *Cinephile Analytics & Leaderboard* view.
  2. Show the **"Director Hall of Fame"** view displaying average ratings and award counts.
  3. Highlight the **"Director Completionists"** panel: Alex Chen is highlighted for having watched and reviewed 100% of Christopher Nolan's filmography.
- **Voiceover (Member 4):**
  > *"In our analytics dashboard, we implement relational division via double NOT EXISTS queries. Here we can see Alex Chen highlighted for completing the entire filmography of Christopher Nolan. Our queries also utilize `>= ALL` set comparisons to isolate the highest-rated films without non-standard syntax hacks."*

---

### [1:45 - 2:00] Scene 5: Security, Performance & Wrap-Up (Speaker: Member 5 / Member 1)
- **On-Screen Action:**
  1. Open terminal side-by-side.
  2. Show `EXPLAIN` query plan output demonstrating index usage.
  3. Input an injection string (`' OR '1'='1'`) into the search bar, demonstrating it is safely escaped as a literal string.
- **Voiceover (Member 5):**
  > *"Behind the scenes, our queries are accelerated using B+ Tree indexes on high-cardinality foreign keys and date ranges. All API endpoints enforce parameterized prepared statements, providing 100% immunity against SQL injection attacks. Thank you for watching!"*
