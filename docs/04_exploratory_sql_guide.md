# 4. Exploratory SQL — Guide & Checklist

## Purpose

Before jumping into the 50+ business questions (Phase 5), you need to be
fluent in what the data actually looks like *from inside MySQL* — not just
from the earlier pandas audit. This phase is about validating the load,
understanding distributions, and building the muscle memory of querying this
schema, so Phase 5 goes fast and you trust your own numbers.

**Rule of thumb:** every query here should either (a) confirm something you
already expect from the Phase 2 audit, or (b) surface something new about
shape/spread of the data. If a query does neither, skip it.

## Where this lives

Create `sql/02_exploratory.sql`. Structure it with clear section-comment
headers (see template at the bottom of this doc) so it reads top-to-bottom
as a story, not a random pile of queries. Number your queries within each
section (e.g. `-- Q1.`, `-- Q2.`) so you can reference them later in your
Phase 7 documentation.

---

## Checklist

### A. Row-level sanity checks
- [ ] Row count for each of the 4 tables — confirm it matches the audit
      (accounts=85, products=7, sales_teams=35, sales_pipeline=8800)
- [ ] `SELECT *` with `LIMIT 20` on each table — eyeball real rows, not just counts
- [ ] Confirm primary keys are unique (`COUNT(*)` vs `COUNT(DISTINCT pk)` per table)

### B. Categorical distributions
- [ ] `deal_stage` counts + percentage of total pipeline
- [ ] `sector` counts in `accounts` — do the 10 sectors look evenly spread or skewed?
- [ ] `regional_office` counts in `sales_teams` — how many agents per region?
- [ ] `series` counts in `products`, and how many products per series
- [ ] `office_location` counts in `accounts` — which countries are represented, and how concentrated is it in one location?

### C. Numeric ranges & spread
- [ ] `MIN` / `MAX` / `AVG` / `STDDEV` of `close_value` for Won deals only
- [ ] `MIN` / `MAX` of `engage_date` and `close_date` — confirm the ~14-month window (Oct 2016–Dec 2017) from the audit
- [ ] `MIN` / `MAX` / `AVG` of `revenue` and `employees` in `accounts`
- [ ] `sales_price` range across `products`
- [ ] Derived: sales cycle length (`DATEDIFF(close_date, engage_date)`) — `MIN`/`MAX`/`AVG` for Won/Lost deals

### D. Relationship / cardinality checks
- [ ] Deals per account — which accounts show up most often in the pipeline? (`GROUP BY account ORDER BY COUNT(*) DESC`)
- [ ] Deals per sales agent — is workload even across the team?
- [ ] Agents per manager, and per regional office (rolls up the org chart)
- [ ] Subsidiary accounts vs. independent accounts — how many of the 85 accounts have a non-null `subsidiary_of`?

### E. Null / completeness re-verification (now enforced by schema, so this should agree with Phase 2)
- [ ] Count of NULL `account` in `sales_pipeline` (expect 1425)
- [ ] Count of NULL `engage_date` (expect 500 — should all be `Prospecting` stage)
- [ ] Count of NULL `close_date` / `close_value` (expect 2089 each — open deals)
- [ ] Cross-check: does `deal_stage = 'Prospecting'` line up exactly with NULL `engage_date`? Does `Won`/`Lost` line up exactly with non-NULL `close_date`?

### F. Quick cross-table joins (a warm-up for Phase 5)
- [ ] Join `sales_pipeline` → `sales_teams` → show deal count and total `close_value` per `regional_office`
- [ ] Join `sales_pipeline` → `products` → total revenue per `series`
- [ ] Join `sales_pipeline` → `accounts` → total revenue per `sector`

---

## Things to watch for while writing these

- **Don't forget `WHERE deal_stage = 'Won'`** when computing revenue/averages — including `Lost`/`Engaging`/`Prospecting` rows (where `close_value` is `NULL` or `0`) will silently skew averages if you're not careful. Decide deliberately whether `AVG()` should ignore NULLs (it does, by default) versus divide by total deal count.
- **`GROUP BY` + `ORDER BY COUNT(*) DESC`** is your best friend for "which X shows up most" questions — use `LIMIT` to keep results readable.
- **Percentages**: use a subquery or window function (`SUM(cnt) OVER ()`) to compute "percent of total" columns rather than hardcoding the denominator.
- Keep a running note (in comments, or a short section at the bottom of the `.sql` file) of **anything that surprises you** — those observations are exactly what Phase 7 documentation wants ("what insight does this reveal").

## Suggested file template

```sql
-- =============================================================
-- 02_exploratory.sql
-- Phase 4: Exploratory SQL — CRM Sales Opportunities
-- =============================================================

-- -------------------------------------------------------------
-- A. Row-level sanity checks
-- -------------------------------------------------------------
-- Q1. Row counts per table
...

-- -------------------------------------------------------------
-- B. Categorical distributions
-- -------------------------------------------------------------
-- Q5. deal_stage breakdown with percentage
...

-- -------------------------------------------------------------
-- C. Numeric ranges & spread
-- -------------------------------------------------------------
...

-- -------------------------------------------------------------
-- D. Relationship / cardinality checks
-- -------------------------------------------------------------
...

-- -------------------------------------------------------------
-- E. Null / completeness re-verification
-- -------------------------------------------------------------
...

-- -------------------------------------------------------------
-- F. Quick cross-table joins
-- -------------------------------------------------------------
...
```

## When you're done

Paste the finished `sql/02_exploratory.sql` here (or a subset if it's long)
and I'll review: correctness of joins/aggregations, whether NULL-handling is
deliberate, and whether the numbers you get actually match the Phase 2
pandas audit. Once that's confirmed consistent, we move to **Phase 5:
Business Analysis (50+ questions)**.
