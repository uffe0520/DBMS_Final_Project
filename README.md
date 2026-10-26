# HKU COMP3278A — Database Systems Final Project

> **Course:** HKU COMP3278A — Introduction to Database Management Systems  
> **Instructor:** Dr. CHEN, Yi | School of Computing & Data Science, The University of Hong Kong  
> **Repository:** `uffe0520/DBMS_Final_Project`  
> **Project Scope:** Full-Stack Web Application, Production Relational Database (MySQL 8.x), 6-Tier Analytical Query Portfolio, BCNF Normalization Proofs, B+ Tree Indexing Profiling, and SQL Injection Security Architecture.

---

## 📚 Master Framework Documentation

This repository has been configured with comprehensive academic blueprints and AI pair-programming frameworks to ensure complete syllabus coverage:

| Document | Purpose & Key Contents |
| :--- | :--- |
| **[GOAL.md](file:///Users/nr1/Documents/HKU/DBMS/DBMS_Final_Project/GOAL.md)** | **Master Project Blueprint:** Detailed 8-phase roadmap, syllabus alignment matrix, multi-vendor food platform domain architecture, definition of done, and presentation rubrics. |
| **[AGENT.md](file:///Users/nr1/Documents/HKU/DBMS/DBMS_Final_Project/AGENT.md)** | **Autonomous Agent Directives:** Operating manual for AI coding agents (Antigravity, Cursor, Copilot, Claude Code) with subagent roles (`@db-architect`, `@query-specialist`, `@fullstack-dev`, `@qa-security`), anti-hallucination guardrails, and transaction safety protocols. |
| **[SQL_RULES.md](file:///Users/nr1/Documents/HKU/DBMS/DBMS_Final_Project/SQL_RULES.md)** | **Mandatory Command Matrix:** 6-tier SQL query requirements, relational algebra equivalents ($\sigma, \pi, \bowtie, -, \cup, \div, \mathcal{G}$), B+ Tree indexing rules (`EXPLAIN ANALYZE`), and SQL injection defense. |

---

## 🏗️ Repository Architecture & Directory Structure

```text
DBMS_Final_Project/
├── docs/                             # Documentation, ER diagrams, normalization proofs
├── sql/                              # DDL schema, seed data, queries, and indexing scripts
├── presentation/                     # 5-min presentation slides & demo video script
├── src/                              # Full-stack web application source code
│   ├── backend/                      # API server & MySQL connection pool
│   └── frontend/                     # Interactive UI & Analytics Dashboard
├── AGENT.md                          # Single authoritative AI agent instructions
├── GOAL.md                           # Master project blueprint & roadmap
├── SQL_RULES.md                      # Mandatory SQL command catalog & query tiers
└── README.md                         # Main repository entry point
```
├── SQL_RULES.md                      # Mandatory SQL command catalog
└── README.md                         # Main repository entry point
```

---

## ⚡ Quickstart Guide

### 1. Database Setup (MySQL 8.x)
```bash
# Connect to your MySQL instance:
mysql -u root -p < sql/00_reset_db.sql
mysql -u root -p < sql/01_schema.sql
mysql -u root -p < sql/02_seed_data.sql
```

### 2. Verify Query Portfolio
```bash
mysql -u root -p < sql/03_queries.sql
```

### 3. Run Web Application
*(Application setup instructions will be updated in Phase 5)*

---

## 👥 Course & Group Information
- **Course Code:** COMP3278A
- **Term:** 2026/2027 Fall Semester
- **Group Members:** *(To be updated)*
- **Teaching Assistant:** CHENG, Jiatao (`chengjiatao3141@connect.hku.hk`) & ZHANG, Xue (`xue.zhang@connect.hku.hk`)
