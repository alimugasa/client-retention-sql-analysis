# Client Retention & Revenue Analysis — SQL

## Overview
This project analyzes client churn patterns at a bank to identify who is leaving, why, and the revenue impact. The goal is to provide actionable insights that help client services and account management teams reduce churn and prioritize retention efforts.

## Dataset
Three related tables modeling a bank's client portfolio:

| Table | Records | Description |
|-------|---------|-------------|
| `clients` | 800 | Client demographics, credit score, tenure, churn status, and exit reason |
| `accounts` | 1,537 | Account-level data including product type and balance |
| `transactions` | 18,990 | Monthly transaction summaries per account (2024–2025) |

## Tools
- **SQL** (SQLite) — JOINs, CTEs, CASE statements, window functions, aggregations
- **DB Browser for SQLite** — Query execution and testing

## Business Questions Answered

| # | Question | SQL Techniques |
|---|----------|----------------|
| 1 | What is the churn rate by geography? | GROUP BY, aggregation |
| 2 | How does churn vary by credit score tier? | CASE, GROUP BY |
| 3 | Which age groups have the highest churn? | CASE, aggregation |
| 4 | Do clients with more products churn less? | CTE, LEFT JOIN, GROUP BY |
| 5 | What is the total balance lost to churn? | JOIN, conditional aggregation |
| 6 | Which product types lost the most to churn? | CASE inside SUM, JOIN |
| 7 | Top 20 highest-value clients who churned | JOIN, ORDER BY, LIMIT |
| 8 | What are the top reasons for churn? | Window function (SUM OVER), subquery |
| 9 | At what tenure point do clients leave? | CASE, ordered grouping |
| 10 | Did churned clients show declining activity before leaving? | CTE, JOIN, GROUP BY |

## Setup
1. Download or clone this repo
2. Open DB Browser for SQLite (free) or SQLiteOnline.com
3. Run `setup_tables.sql` to create tables
4. Import the three CSV files from the `data/` folder
5. Run queries from `client_retention_analysis.sql`

## Key Findings
- Clients with only 1 product have significantly higher churn rates than multi-product holders
- The highest-value churned clients represent substantial lost revenue — a targeted win-back campaign could recover a portion
- "Fees Too High" and "Better Rates Elsewhere" are among the top exit reasons, suggesting pricing strategy review
- Churned clients show lower average transaction activity in the months before leaving

## Author
**Ali Mugasa, MBA** — [LinkedIn](https://linkedin.com) | alimugasa0@gmail.com
