# 🎬 FilmCraft — 5-Minute Final Presentation Blueprint

> **Course:** HKU COMP3278A — Introduction to Database Management Systems  
> **Evaluation Window:** 5 Minutes Total Presentation (including a $\le$ 2-minute video demo)  
> **Grading Requirement:** Every group member must speak.

---

## Slide-by-Slide Presentation Structure (5 Minutes Total)

```text
[0:00 - 0:45] Slide 1: Introduction & System Motivation (Member 1)
[0:45 - 1:45] Slide 2: Conceptual E-R Model & Cardinalities (Member 2)
[1:45 - 2:30] Slide 3: Relational Reduction & BCNF Normalization (Member 3)
[2:30 - 3:30] Slide 4: Key SQL Queries & Relational Division (Member 4)
[3:30 - 4:45] Slide 5: Full-Stack Web App Demo Video (All Members Voiceover)
[4:45 - 5:00] Slide 6: System Architecture, Indexing & Q&A Conclusion (Member 1 / All)
```

---

### Slide 1: Title, Problem Motivation & Architecture (Speaker: Member 1)
- **Title:** *FilmCraft — A Relational Cinema Platform & Festival Curator*
- **Group Members:** [List all 3–5 member names & UID numbers]
- **The Problem:** Modern social cinema platforms (like Letterboxd) lack relational connections between film festival awards, theatrical screening schedules, and physical cinema infrastructure.
- **3-Tier System Design (Lecture 1):**
  - Presentation Tier: React / Next.js + Tailwind CSS.
  - Logic Tier: Node.js API with 100% prepared statement security (anti-SQL injection).
  - Data Tier: MySQL 8.x relational database engine with B+ Tree indexes.

---

### Slide 2: Conceptual Information Modeling (E-R Diagram) (Speaker: Member 2)
- **Visual:** Display the formal Chen Notation and Crow's Foot E-R Diagram.
- **Key Concepts to Highlight for Evaluators:**
  1. **Weak Entity Set:** `TheaterRoom` (discriminator `room_number`) identifying with `Theater`, and `TheaterScreening` identifying with `TheaterRoom`.
  2. **ISA Specialization Hierarchy:** `User` superclass disjointly specializing into `Cinephile`, `FilmCritic`, and `FestivalCurator`.
  3. **Hierarchical Self-Join:** `Movie` self-referencing `prequel_movie_id` for sequels and franchise lineages.
  4. **Multi-Valued Attribute:** `MovieGenre` reduced to a dedicated relational table.
  5. **Descriptive Attributes on Relationships:** `character_name` and `role_type` on `MovieCastCrew`; `rating` and `watch_date` on `Review`.
  6. **Participation & Cardinality:** Total participation on weak entities; arrow pointing to the "1" side.

---

### Slide 3: Relational Reduction & BCNF Normalization (Speaker: Member 3)
- **Reduction Methodology:**
  - N:M relationships (`MovieCastCrew`, `WatchlistEntry`) reduced to separate tables with composite primary keys.
  - 1:N relationships (`TheaterScreening` $\to$ `Movie`) reduced by placing the foreign key on the N-side.
- **Formal Normalization Proof (Lecture 5):**
  - Present the Functional Dependencies for `MovieCastCrew`:
    $$\{ \text{movie\_id}, \text{person\_id}, \text{role\_type} \} \to \{ \text{character\_name}, \text{billing\_order} \}$$
  - Prove BCNF: In every non-trivial FD $X \to Y$, $X$ is a superkey.
  - Zero insertion, update, or deletion anomalies with lossless join decomposition.

---

### Slide 4: Key SQL Queries & Relational Algebra (Speaker: Member 4)
- **The "Killer" Division Query ($R \div S$):**
  - Business Question: *"Find all cinephiles who have watched and reviewed EVERY film directed by Christopher Nolan."*
  - Show the double `NOT EXISTS` query alongside the mathematical expression:
    $$\pi_{\text{user\_id}}(\text{Reviews}) \div \pi_{\text{movie\_id}}(\sigma_{\text{name='Christopher Nolan' \land role='DIRECTOR'}}(\text{FilmProfessional} \bowtie \text{MovieCastCrew}))$$
- **Extremal Comparison (`>= ALL`):**
  - Find the film with the greatest count of 10/10 scores without using non-standard `LIMIT` hacks.
- **Course Compliance Note:** Explicitly mention that queries avoid CTEs and window functions in strict accordance with COMP3278A academic standards.

---

### Slide 5: The 2-Minute Demo Video (Embedded in Slide) (All Members)
*(See `demo_video_script.md` for exact timestamps and speaking roles).*

---

### Slide 6: Indexing, Security & Summary (Speaker: Member 1 & Team)
- **Physical Optimization (Lecture 6):**
  - Show the `EXPLAIN` query plan comparison before and after creating the B+ Tree index `idx_screenings_datetime` (transitioning from full table scan `type: ALL` to range index scan `type: range`).
- **Cybersecurity Architecture (Lecture 7):**
  - Parameterized queries with prepared statements preventing `' OR '1'='1'` injection attacks.
- **Conclusion & Q&A:** Invite questions from Dr. Chen Yi and the teaching assistants.
