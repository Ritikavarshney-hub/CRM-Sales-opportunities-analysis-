# 1. Business Understanding — CRM Domain Primer

## What kind of business is this?

Looking at the 5 CSVs (`accounts`, `products`, `sales_teams`, `sales_pipeline`,
`data_dictionary`), this represents a **B2B sales CRM** — a company that sells
products to other companies through a team of human sales agents. Think
Salesforce/HubSpot data export.

## Core concepts

**1. Account** — a customer company (`accounts.csv`). Has firmographics: sector,
revenue, employee count, HQ location, founding year, and optionally a parent
company (`subsidiary_of`).

**2. Product** — what's sold (`products.csv`). Belongs to a `series` (product
family/tier) and has a list `sales_price`.

**3. Sales org** — `sales_teams.csv` gives agent → manager → regional office.
A 3-level hierarchy for rolling up performance.

**4. Opportunity / deal** — one row in `sales_pipeline.csv` = one deal being
tracked from first contact to close.

**5. The funnel (`deal_stage`)** — deals move through stages:

```
Prospecting → Engaging → Won
                       → Lost
```

This is the single most important column for business analysis — almost every
"performance" or "conversion" question hinges on it.

**6. Key dates** — `engage_date` (when active selling started) and `close_date`
(when it was won/lost). The gap between them is **sales cycle length**, a
standard efficiency metric.

**7. Close value** — actual realized revenue on a Won deal, which can differ
from the product's list price (discounting).

## Standard metrics this domain cares about

- **Win rate** = Won / (Won + Lost)
- **Average deal size** = avg(close_value) for Won deals
- **Sales cycle length** = close_date − engage_date
- **Revenue by dimension** = sum(close_value) grouped by agent/region/sector/product
- **Pipeline conversion** = how many deals survive each funnel stage

## Table relationships (conceptually)

`sales_pipeline` is the **fact table** — every row references an account, a
product, and a sales agent. `accounts`, `products`, `sales_teams` are
**dimension tables**. This is a star schema, which will matter when designing
the MySQL schema in Phase 3.

---

Next: **Dataset Audit** — inspect every table, identify keys, relationships,
and data quality issues before building the schema.
