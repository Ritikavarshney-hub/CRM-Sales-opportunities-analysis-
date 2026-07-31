# 5. Business Analysis — 50+ Questions

## Purpose

This is the core deliverable of the project: using SQL to answer real
business questions a sales VP, sales ops analyst, or account exec would
actually ask about this CRM data. Organize your answers into the sections
below. For each question: write the query, run it, and note the **insight**
it reveals (not just the number) — that insight is what Phase 7
documentation will be built from, so it's worth capturing now while it's
fresh.

## Where this lives

Create `sql/03_business_analysis.sql`, mirroring the section structure
below. Suggested format per question:

```sql
-- Q#: <question in plain English>
<your query>
-- Insight: <1-2 sentence takeaway>
```

---

## Section 1 — Sales Performance (Agents & Managers)

1. Which sales agents have closed the most Won deals?
2. Which sales agents generate the most total revenue?
3. What is each agent's win rate (Won / (Won + Lost))?
4. Which agents have the largest average deal size?
5. Which agents have the shortest average sales cycle?
6. Which agents have the most Lost deals?
7. Rank agents within their manager's team by total revenue.
8. Which manager's team has the highest overall win rate?
9. Which manager's team generates the most total revenue?
10. Compare each agent's revenue to their manager's team average — who's over/under-performing?

## Section 2 — Pipeline / Funnel Analysis

11. What is the overall distribution of deals across the 4 funnel stages?
12. What is the company-wide win rate (Won / (Won+Lost), excluding open deals)?
13. What percentage of all opportunities are currently still open (Prospecting + Engaging)?
14. What is the total potential value of currently open deals? (Careful — `close_value` is NULL for open deals; think about what "potential value" even means here given the schema, and document your assumption.)
15. How many deals are stuck in "Engaging" the longest (using days since `engage_date` relative to the dataset's max date)?
16. What's the drop-off rate between Prospecting → Engaging?
17. Is there a seasonal pattern to when deals enter Prospecting (by month)?
18. Is there a seasonal pattern to when deals close (Won or Lost) by month?
19. Do deals that engage faster after creation have better win rates? (Note: dataset has no "created" date — engage_date is the earliest signal; adjust framing if needed.)
20. What's the average and median sales cycle length, split by Won vs Lost?

## Section 3 — Product Analysis

21. Which products generate the most total revenue?
22. Which products have the highest win rate?
23. Which products have the longest average sales cycle?
24. Which product series (GTX/GTK/MG) is most profitable overall?
25. What is the average discount (list `sales_price` vs actual `close_value`) per product, for Won deals?
26. Which product is sold to the widest variety of sectors?
27. Which products are most commonly involved in Lost deals?
28. Rank products by number of deals vs. by total revenue — do they agree, or does a low-volume product actually make more money?
29. What's the average deal size per product, and how does it compare to that product's list price?
30. Which single product contributes the highest share of total company revenue?

## Section 4 — Account / Sector Analysis

31. Which accounts have generated the most total revenue?
32. Which sectors generate the most total revenue?
33. Which sectors have the highest win rate?
34. Do larger companies (by `employees` or `revenue`) close bigger deals?
35. Do larger companies have shorter or longer sales cycles than smaller ones?
36. Which accounts have the most Lost deals?
37. How many accounts are subsidiaries vs. independent, and does that correlate with deal size?
38. Which office_location (country) generates the most revenue?
39. Is there a relationship between account `year_established` (company age) and win rate?
40. Which accounts have never won a deal despite having opportunities in the pipeline?

## Section 5 — Regional / Team Analysis

41. Which regional office generates the most total revenue?
42. Which regional office has the highest win rate?
43. How does average deal size differ across regions?
44. How does average sales cycle length differ across regions?
45. Which region has the most reps, and does more reps correlate with more revenue (or just more volume)?
46. Rank regions by revenue-per-agent (efficiency, not just raw totals).

## Section 6 — Time-Based Trends

47. What does monthly revenue look like across the full date range in the dataset?
48. Is there a month with unusually high or low deal volume?
49. How does quarter-over-quarter win rate trend across the dataset's time span?
50. Which month had the largest single deal close?
51. Compare the first half vs. second half of the dataset's time range — is performance improving or declining?

## Section 7 — Deal Size / Revenue Deep-Dives

52. What does the distribution of deal sizes look like (e.g. bucket into small/medium/large ranges)?
53. What are the top 10 largest Won deals, and which agent/product/account do they involve?
54. What percentage of total revenue comes from the top 10% of deals? (Pareto-style analysis)
55. What's the smallest Won deal, and is it an outlier worth investigating?

---

## Tips for writing these well

- **State your assumptions explicitly as a comment** wherever the schema is ambiguous (e.g. Q14's "potential value" of open deals) — this is exactly the kind of judgment call real analysts have to document.
- **Use CTEs** (`WITH ... AS (...)`) once queries start nesting more than one level — cleaner than deeply nested subqueries, and sets you up well for Phase 6 (Advanced SQL) where CTEs get formally introduced.
- **Reuse patterns**: many of these questions share the same shape (`GROUP BY X, filter WON, ORDER BY revenue DESC, LIMIT N`) — once you've written one well, the rest go fast.
- Don't force an answer where the data genuinely can't support one (e.g. there's no `created_date`, no explicit discount column, no quota data) — noting *why* a question can't be answered as literally stated, and how you reframed it, is itself a valuable piece of analysis.

## When you're done

You don't need to do all 55 in one sitting — work through a section at a time and share your queries + results. I'll review each batch for correctness (especially NULL-handling and join safety, since we've already hit a few of those landmines) before you move to **Phase 6: Advanced SQL**.
