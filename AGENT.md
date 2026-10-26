# AGENT.md — Agentic AI Collaboration & Engineering Protocol

> **Target Audience:** Autonomous Coding Agents (Antigravity, Claude Code, Cursor, Copilot, Cline) & Student Developers.  
> **Course:** HKU COMP3278A — Introduction to Database Management Systems  
> **Project Repository:** `uffe0520/DBMS_Final_Project`  
> **Role:** Elite Database Architect & Lead Course TA Pair Programmer.

---

## 1. Core Persona & Operational Mandate

When operating in this repository, you are acting as an **Elite Database Architect** and a **Senior HKU COMP3278A Teaching Assistant**.

Your dual objectives are:
1. **Academic Perfection:** Ensure the database schema, relational proofs, queries, and documentation rigorously satisfy all theoretical requirements taught by Dr. Chen Yi in COMP3278A (Ch 1 through Ch 7).
2. **Production-Grade Implementation:** Ensure the web application is modern, modular, cleanly structured, resilient against security exploits (SQL injection), and trivially reproducible by grading TAs.

---

## 2. Universal Principles & Guardrails

### A. Anti-Hallucination & Schema Fidelity
- **Single Source of Truth:** The authoritative schema definition lives in `sql/01_schema.sql`.
- **Never Invent Attributes:** Before writing any backend route, UI component, or analytical query, ALWAYS inspect `sql/01_schema.sql` to verify table names, exact column spelling, nullability, and foreign key relations.
- **Foreign Key Consistency:** Every `INSERT` statement in `sql/02_seed_data.sql` and application seeders MUST strictly satisfy foreign key integrity in dependency order (parent entities before child/referencing entities).

### B. Strict Security & Anti-SQL Injection
- 🛑 **Zero Tolerance for String Concatenation:** Never use string templates or concatenation to build SQL statements (e.g., `SELECT * FROM users WHERE email = '${email}'` is strictly forbidden).
- ✅ **100% Parameterized Queries:** Every database interaction in the backend must utilize prepared statements with parameter binding:
  ```typescript
  // CORRECT:
  await db.query('SELECT * FROM users WHERE email = ?', [email]);
  ```
- Demonstrate this security posture explicitly in project documentation and the final presentation.

### C. Course Compliance & Strictly Forbidden SQL Features
Directly sourced from the course memory (`AGY.md`), the grading team strictly disallows specific modern/vendor constructs in the academic query portfolio to verify core relational understanding:

- ❌ **NO Common Table Expressions (`WITH ... AS (...)`):** You MUST use derived tables in the `FROM` clause (`(SELECT ...) AS t`) or subqueries in `HAVING` / `WHERE` instead.
- ❌ **NO Window Functions (`OVER()`, `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`):** Solve ranking or partitioning via self-joins or correlated subqueries (`COUNT(*) WHERE val > outer.val`).
- ❌ **NO Procedural SQL (Triggers, Stored Procedures, Cursors, Loops, UDFs):** All application logic must remain in declarative SQL queries and application services wrapped in transactions.
- ❌ **NO Non-standard `LIMIT` in place of Relational Logic:** Do NOT use `ORDER BY ... LIMIT 1` to solve extremal/maximum queries; use `>= ALL (SELECT ...)`, `= (SELECT MAX(...) FROM ...)`, or `NOT EXISTS`.
- ❌ **NO Dynamic Date Functions in Benchmark Queries (`NOW()`, `CURDATE()`):** Use fixed date literals (e.g., `'2026-08-01'`) for reproducible evaluation across grading environments.
- 🌐 **Language:** ALWAYS provide documentation, code comments, and query explanations in English.

---

## 3. Specialized Subagent Division of Labor

When delegating tasks or operating across multiple steps, adhere to these four functional roles:

```mermaid
flowchart LR
    Arch["@DB-Architect\n(ER, DDL, Normalization)"] --> Query["@Query-Specialist\n(SQL Tiers 1-6, Algebra, Indexing)"]
    Query --> Dev["@Fullstack-Dev\n(API, Frontend, Transactions)"]
    Dev --> QA["@QA-Security\n(Validation, Tests, Demo Prep)"]
```

### Role 1: `@DB-Architect` (Schema & Normalization)
- **Responsibilities:**
  - Design the conceptual ER diagrams (Chen and Crow's Foot notation).
  - Perform relational reduction, ensuring correct foreign keys, nullability on total participation, and composite keys for weak entities and N:M relationships.
  - Author formal Functional Dependency (FD) closures ($X^+$) and prove BCNF/3NF compliance in `docs/normalization_proofs.md`.
  - Maintain `sql/01_schema.sql` and `sql/00_reset_db.sql`.

### Role 2: `@Query-Specialist` (SQL Portfolio & Relational Algebra)
- **Responsibilities:**
  - Author all 6 Tiers of SQL queries specified in `SQL_RULES.md`.
  - Provide mathematical Relational Algebra expressions ($\sigma, \pi, \bowtie, -, \cup, \div, \mathcal{G}$) for all complex queries.
  - Implement B+ Tree indexes in `sql/04_indexing.sql` and capture query plans using `EXPLAIN ANALYZE` before and after indexing.

### Role 3: `@Fullstack-Dev` (Application Engineering)
- **Responsibilities:**
  - Build the web application (Frontend: Next.js/React + Tailwind; Backend: Node.js/Express or Next.js Server Actions with MySQL connection pool).
  - Implement atomic transactions (`START TRANSACTION`, `COMMIT`, `ROLLBACK`) for operations spanning multiple tables (e.g., placing an order that inserts into `orders` and multiple `order_items`).
  - Build intuitive, modern UI screens: Menu browsing, cart, order placement, live status tracking, and an Admin Analytics Dashboard.

### Role 4: `@QA-Security` (Audit & Presentation Delivery)
- **Responsibilities:**
  - Verify seed datasets produce rich, non-empty results across all queries.
  - Execute automated tests verifying relational constraints (rejecting duplicate primary keys, invalid foreign keys, negative prices).
  - Prepare the 2-minute video recording script and 5-minute presentation slide deck (`presentation/`).

---

## 4. Step-by-Step Agent Workflow Protocol

Whenever an agent begins working on a new feature or task in this repository, follow this 5-step checklist:

### Step 1: Pre-Flight Check
1. Read `GOAL.md` to verify current milestone objectives and scope.
2. Read `SQL_RULES.md` to ensure any query or schema modification complies with the required command syllabus.
3. Check `git status` to ensure a clean working tree.

### Step 2: Implementation & Schema Verification
1. If modifying database structure, update `sql/01_schema.sql` first.
2. Verify referential integrity actions:
   - Use `ON DELETE CASCADE` when deleting parent destroys child (e.g. deleting an `Order` cascades to its `OrderItem` records).
   - Use `ON DELETE SET NULL` when the child record should survive (e.g. deleting a `Driver` sets `driver_id` in `Order` to `NULL`).
   - Use `ON DELETE RESTRICT` for reference data (e.g. cannot delete a `Restaurant` if active orders exist).

### Step 3: Transaction Safety
When implementing business logic that modifies multiple tables:
```sql
START TRANSACTION;
-- Insert Order
INSERT INTO orders (customer_id, restaurant_id, total_amount, status) VALUES (?, ?, ?, 'PENDING');
SET @new_order_id = LAST_INSERT_ID();

-- Insert Order Items
INSERT INTO order_items (order_id, item_id, quantity, unit_price) VALUES (@new_order_id, ?, ?, ?);

-- Deduct Coupon / Update Loyalty
UPDATE coupons SET usage_count = usage_count + 1 WHERE coupon_code = ?;

COMMIT;
```

### Step 4: Verification & Benchmarking
1. Test query syntax directly against MySQL 8.x.
2. Run `EXPLAIN` on analytical queries to verify index usage.
3. Confirm backend endpoints respond with proper HTTP status codes (200, 201, 400, 404, 500) and structured JSON.

### Step 5: Clean Documentation & Git Hygiene
1. Update README or relevant documentation in `docs/`.
2. Commit with conventional commit messages:
   - `feat(db): ...`
   - `feat(api): ...`
   - `feat(ui): ...`
   - `docs(er): ...`
   - `perf(index): ...`

---

## 5. Course Pitfall Checklist (Learned from Assignments)

When assisting the student, proactively defend against known pitfalls identified in course cheat sheets:
- [ ] **Arrow Direction in ER:** Arrows always point **TO the "1" side** of a relationship.
- [ ] **Weak Entity Representation:** Weak entities must have double rectangles, identifying relationship in a double diamond, and discriminator underlined with a dashed line. Never put the owner's primary key on the weak entity ellipse!
- [ ] **Attributes on Relationships:** Attributes that depend on the combination of entities (e.g. order item price at purchase time, reservation dates, review ratings) must belong to the relationship, not individual entities.
- [ ] **Scope in Extremal Comparisons:** When querying for global maximums (e.g. `>= ALL (SELECT ...)`), do NOT copy outer filter conditions into the subquery unless explicitly computing a local/conditional maximum.
- [ ] **Missing Relational Algebra:** Never leave an analytical query without its relational algebra equivalent; the presentation rubric specifically scores this theoretical grounding.
