-- BUSINESS INSIGHTS 

-- A. SALES PERFORMANCE 
-- 1. Which sales agents have closed the most Won deals? 

SELECT sales_agent , COUNT(*) as won_deals FROM sales_pipeline WHERE deal_stage = 'Won' GROUP BY sales_agent ORDER BY won_deals DESC;

-- 2. Which sales agents generate the most revenue? 

SELECT sales_agent, ROUND(SUM(close_value),2) AS total_revenue FROM sales_pipeline WHERE deal_stage='Won' GROUP BY sales_agent ORDER BY total_revenue DESC;

-- 3. What is each agent's win rate? 

SELECT sales_agent, SUM(CASE WHEN deal_stage='Won' THEN 1 ELSE 0 END) AS won, SUM(CASE WHEN deal_stage='Lost' THEN 1 ELSE 0 END) AS lost,
ROUND(100.0 * SUM(CASE WHEN deal_stage='Won' THEN 1 ELSE 0 END)/ NULLIF( SUM(CASE WHEN deal_stage IN ('Won','Lost') THEN 1 ELSE 0 END),0),2) AS win_rate
FROM sales_pipeline GROUP BY sales_agent ORDER BY win_rate DESC;

-- 4. which agent have largest avg deal size? 

SELECT sales_agent , ROUND(AVG(close_value),2) AS avg_won FROM sales_pipeline WHERE deal_stage = 'won' GROUP BY sales_agent ORDER BY avg_won DESC;

-- 5.  Which agents have the shortest average sales cycle?
-- sales cycle = (end date - open date)

SELECT sales_agent, ROUND( AVG(DATEDIFF(close_date,engage_date)),2) AS avg_sales_cycle
FROM sales_pipeline WHERE deal_stage='Won' GROUP BY sales_agent ORDER BY avg_sales_cycle;

-- 6.  Which agents have the most Lost deals? 

SELECT sales_agent , COUNT(*) AS lost_deals FROM sales_pipeline WHERE deal_stage ='Lost' GROUP BY sales_agent ORDER BY lost_deals DESC;

-- 7. Rank agents within each manager's team by revenue (introducing window functions) 

SELECT st.manager , sp.sales_agent , ROUND(SUM(sp.close_value),2) AS revenue, RANK() OVER(PARTITION BY st.manager ORDER BY SUM(sp.close_value) DESC) AS manager_rank FROM sales_pipeline sp JOIN sales_teams st ON sp.sales_agent = st.sales_agent WHERE sp.deal_stage='won' GROUP BY st.manager , sp.sales_agent ORDER BY st.manager DESC;
-- 8. Which manager's team has the highest win rate? 
SELECT st.manager , ROUND( SUM(CASE WHEN sp. deal_stage = 'won' THEN 1 ELSE 0 END)/NULLIF(SUM(CASE WHEN sp.deal_stage IN ('won','lost') THEN 1 ELSE 0 END ),0),2) AS win_rate FROM sales_pipeline sp JOIN sales_teams st ON sp.sales_agent=st.sales_agent GROUP BY st.manager ORDER BY win_rate DESC;
-- 9. Which manager's team generates the most revenue?

SELECT st.manager , ROUND(SUM(sp.close_value),2) AS revenue FROM sales_pipeline sp JOIN sales_teams st ON sp.sales_agent= st.sales_agent GROUP BY st.manager ORDER BY revenue DESC;
-- 10. Compare agent revenue with manager average (most imp )

WITH agent_revenue AS (
    SELECT st.manager, sp.sales_agent, SUM(sp.close_value) AS agent_total
    FROM sales_pipeline sp
    JOIN sales_teams st ON sp.sales_agent = st.sales_agent
    WHERE sp.deal_stage = 'Won'
    GROUP BY st.manager, sp.sales_agent
)
SELECT manager, sales_agent,
       ROUND(agent_total,2) AS agent_revenue,
       ROUND(AVG(agent_total) OVER (PARTITION BY manager),2) AS manager_avg_revenue,
       ROUND(agent_total - AVG(agent_total) OVER (PARTITION BY manager),2) AS diff_from_team_avg
FROM agent_revenue
ORDER BY manager, agent_revenue DESC;


-- B. Pipeline Analysis
-- 1. What is the overall distribution of deals across the 4 funnel stages?

SELECT deal_stage, COUNT(*) AS total_deals,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM sales_pipeline GROUP BY deal_stage ORDER BY total_deals DESC;

-- 2. What is the overall company-wide win rate?

SELECT ROUND(100.0 * SUM(CASE WHEN deal_stage='Won' THEN 1 ELSE 0 END)
    / NULLIF(SUM(CASE WHEN deal_stage IN ('Won','Lost') THEN 1 ELSE 0 END),0), 2) AS overall_win_rate
FROM sales_pipeline;

-- 3. What percentage of all opportunities are currently still open?

SELECT ROUND(100.0 * SUM(CASE WHEN deal_stage IN ('Prospecting','Engaging') THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_open
FROM sales_pipeline;

-- 4. Total potential value of currently open deals
-- Assumption: close_value is NULL for open deals (nothing negotiated yet),
-- so product list price is used as a proxy for potential deal value.

SELECT ROUND(SUM(p.sales_price),2) AS potential_open_pipeline_value
FROM sales_pipeline sp
JOIN products p ON sp.product = p.product
WHERE sp.deal_stage IN ('Prospecting','Engaging');

-- 5. Deals stuck in Engaging the longest (relative to the dataset's latest known date)

SELECT opportunity_id, sales_agent, product, engage_date,
       DATEDIFF((SELECT MAX(close_date) FROM sales_pipeline), engage_date) AS days_in_pipeline
FROM sales_pipeline
WHERE deal_stage = 'Engaging'
ORDER BY days_in_pipeline DESC
LIMIT 10;

-- 6. Drop-off rate between Prospecting -> Engaging
-- Note: dataset is a current-stage snapshot, not full stage-transition history,
-- so this is approximated as share still stuck at Prospecting vs. advanced further.

SELECT
    SUM(CASE WHEN deal_stage='Prospecting' THEN 1 ELSE 0 END) AS still_prospecting,
    SUM(CASE WHEN deal_stage IN ('Engaging','Won','Lost') THEN 1 ELSE 0 END) AS advanced_past_prospecting,
    ROUND(100.0 * SUM(CASE WHEN deal_stage='Prospecting' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_stuck
FROM sales_pipeline;

-- 7. Seasonal pattern of deals entering the pipeline
-- Note: engage_date marks entry into "Engaging", not "Prospecting"
-- (Prospecting deals have NULL engage_date, so true entry timing isn't tracked here).

SELECT DATE_FORMAT(engage_date, '%Y-%m') AS month, COUNT(*) AS deals_entering_engaging
FROM sales_pipeline
WHERE engage_date IS NOT NULL
GROUP BY month ORDER BY month;

-- 8. Seasonal pattern of deals closing (Won or Lost) by month

SELECT DATE_FORMAT(close_date, '%Y-%m') AS month, deal_stage, COUNT(*) AS total_deals
FROM sales_pipeline
WHERE close_date IS NOT NULL
GROUP BY month, deal_stage
ORDER BY month, deal_stage;

-- 9. Do deals that engage faster after creation have better win rates?
-- NOT ANSWERABLE AS STATED: the dataset has no "opportunity created" timestamp
-- distinct from engage_date, so time-to-engage can't be measured. Documenting
-- this as a schema limitation rather than forcing an answer.

-- 10. Average AND median sales cycle length, split Won vs Lost
-- (MySQL 8 has no built-in MEDIAN function, so it's derived via window functions)

WITH cycle_lengths AS (
    SELECT deal_stage, DATEDIFF(close_date, engage_date) AS cycle_days,
           ROW_NUMBER() OVER (PARTITION BY deal_stage ORDER BY DATEDIFF(close_date, engage_date)) AS rn,
           COUNT(*) OVER (PARTITION BY deal_stage) AS cnt
    FROM sales_pipeline
    WHERE deal_stage IN ('Won','Lost')
)
SELECT deal_stage, ROUND(AVG(cycle_days),2) AS median_cycle_days
FROM cycle_lengths
WHERE rn IN (FLOOR((cnt+1)/2), CEIL((cnt+1)/2))
GROUP BY deal_stage;


-- C. PRODUCT ANALYSIS 
-- 1. Which products generate the most total revenue? 

SELECT p.product , ROUND(SUM(sp.close_value),2) AS total_revenue FROM sales_pipeline sp JOIN products p ON p.product=sp.product GROUP BY product ORDER BY total_revenue DESC;

-- 2. Which products have the highest win rate? 
SELECT p.product , ROUND(SUM( CASE WHEN sp.deal_stage='won' THEN 1 ELSE 0 END)/NULLIF(SUM(CASE WHEN sp.deal_stage IN ('won','lost') THEN 1 ELSE 0 END),0),2) AS win_rate FROM sales_pipeline sp JOIN products p ON sp.product=p.product GROUP BY p.product ORDER BY win_rate DESC;

-- 3. Which products have the longest average sales cycle? 
SELECT p.product , ROUND(AVG(datediff(sp.close_date,sp.engage_date)),2) AS avg_sales FROM sales_pipeline sp JOIN products p ON p.product=sp.product GROUP BY product ORDER BY avg_sales DESC;

-- 4. Which product series (GTX/GTK/MG) is most profitable overall? 
SELECT p.series, ROUND(SUM(sp.close_value),2) AS total_revenue FROM sales_pipeline sp JOIN products p ON sp.product=p.product WHERE sp.deal_stage='Won' GROUP BY p.series ORDER BY total_revenue DESC;

-- 5. What is the average discount (list `sales_price` vs actual `close_value`) per product, for Won deals?
-- Assumption:
-- Each opportunity represents one unit sold.
-- Discount = List Price - Close Value.

SELECT p.product, ROUND(AVG(p.sales_price),2) AS list_price, ROUND(AVG(sp.close_value),2) AS avg_close_value, ROUND(AVG(p.sales_price - sp.close_value),2) AS avg_discount
FROM sales_pipeline sp JOIN products p ON sp.product=p.product WHERE sp.deal_stage='Won' GROUP BY p.product ORDER BY avg_discount DESC;

-- 6. Which product is sold to the widest variety of sectors? (need three tables  accounts, sales_pipeline ,product )
-- FIX: original query was missing the JOIN condition (was a cross join / cartesian product,
-- which counted every sector for every product regardless of actual relationship).

SELECT sp.product, COUNT(DISTINCT a.sector) AS sectors_served
FROM sales_pipeline sp
JOIN accounts a ON sp.account = a.account
GROUP BY sp.product
ORDER BY sectors_served DESC;

-- 7. Which products are most commonly involved in Lost deals?

SELECT product , COUNT(*) as lost_deals FROM sales_pipeline WHERE deal_stage = 'lost'GROUP BY product ORDER BY lost_deals DESC;

-- 8. Rank products by number of deals vs. by total revenue — do they agree, or does a low-volume product actually make more money?

WITH product_stats AS (
    SELECT product, COUNT(*) AS deal_count,
           SUM(CASE WHEN deal_stage='Won' THEN close_value ELSE 0 END) AS total_revenue
    FROM sales_pipeline GROUP BY product
)
SELECT product, deal_count, ROUND(total_revenue,2) AS total_revenue,
       RANK() OVER (ORDER BY deal_count DESC) AS rank_by_volume,
       RANK() OVER (ORDER BY total_revenue DESC) AS rank_by_revenue
FROM product_stats ORDER BY rank_by_revenue;

-- 9. What's the average deal size per product, and how does it compare to that product's list price?
-- (overlaps conceptually with Q5's discount calc, same insight framed differently)

SELECT p.product, p.sales_price AS list_price, ROUND(AVG(sp.close_value),2) AS avg_deal_size
FROM sales_pipeline sp JOIN products p ON sp.product = p.product
WHERE sp.deal_stage = 'Won'
GROUP BY p.product, p.sales_price
ORDER BY avg_deal_size DESC;

-- 10. Which single product contributes the highest share of total company revenue?

SELECT product, ROUND(SUM(close_value),2) AS product_revenue,
       ROUND(100 * SUM(close_value) / SUM(SUM(close_value)) OVER (), 2) AS pct_of_total_revenue
FROM sales_pipeline
WHERE deal_stage = 'Won'
GROUP BY product
ORDER BY pct_of_total_revenue DESC;


-- D. ACCOUNT ANALYSIS 
-- 1. Which accounts have generated the most total revenue?

SELECT a.account , ROUND(SUM(sp.close_value),2) AS total_revenue FROM sales_pipeline sp JOIN accounts a ON a.account=sp.account GROUP BY account ORDER BY total_revenue DESC;

-- 2. Which sectors generate the most total revenue? 
SELECT a.sector , ROUND(SUM(sp.close_value),2) AS total_revenue FROM sales_pipeline sp JOIN accounts a ON a.account=sp.account GROUP BY sector ORDER BY total_revenue DESC;
 
 -- 3. Which sectors have the highest win rate? 

SELECT a.sector, SUM(CASE WHEN sp.deal_stage='Won' THEN 1 ELSE 0 END) AS won, SUM(CASE WHEN sp.deal_stage='Lost' THEN 1 ELSE 0 END) AS lost, ROUND(100.0 *SUM(CASE WHEN sp.deal_stage='Won' THEN 1 ELSE 0 END)/NULLIF(SUM(CASE WHEN sp.deal_stage IN ('Won','Lost') THEN 1 ELSE 0 END),0),2) AS win_rate FROM sales_pipeline sp JOIN accounts a ON sp.account=a.account GROUP BY a.sector ORDER BY win_rate DESC;
-- 4. Do larger companies (by `employees`) close bigger deals?
-- 5. Do larger companies have shorter or longer sales cycles than smaller ones?
-- (answered together, bucketed by employee count)

SELECT
    CASE WHEN a.employees < 1000 THEN 'Small (<1000)'
         WHEN a.employees BETWEEN 1000 AND 5000 THEN 'Medium (1000-5000)'
         ELSE 'Large (>5000)' END AS company_size,
    COUNT(*) AS won_deals,
    ROUND(AVG(sp.close_value),2) AS avg_deal_size,
    ROUND(AVG(DATEDIFF(sp.close_date, sp.engage_date)),2) AS avg_sales_cycle
FROM sales_pipeline sp
JOIN accounts a ON sp.account = a.account
WHERE sp.deal_stage = 'Won'
GROUP BY company_size
ORDER BY avg_deal_size DESC;

-- 6. Which accounts have the most Lost deals?

SELECT a.account, COUNT(*) AS lost_deals FROM sales_pipeline sp JOIN accounts a ON sp.account = a.account WHERE sp.deal_stage='Lost' GROUP BY a.account ORDER BY lost_deals DESC;
-- 7. How many accounts are subsidiaries vs. independent, and does that correlate with deal size?

SELECT CASE WHEN a.subsidiary_of IS NULL THEN 'Independent' ELSE 'Subsidiary' END AS account_type, COUNT(DISTINCT a.account) AS total_accounts, ROUND(AVG(sp.close_value),2) AS average_deal_size FROM accounts a LEFT JOIN sales_pipeline sp ON a.account = sp.account AND sp.deal_stage='Won' GROUP BY account_type;
-- 8. Which office_location (country) generates the most revenue?
SELECT a.office_location , ROUND(SUM(sp.close_value),2) AS total_revenue FROM sales_pipeline sp JOIN accounts a ON sp.account=a.account WHERE deal_stage ='Won' GROUP BY a.office_location ORDER BY total_revenue DESC;

-- 9. Is there a relationship between account `year_established` (company age) and win rate?

SELECT CASE WHEN (2017 - a.year_established) < 20 THEN 'Young' WHEN (2017 - a.year_established) BETWEEN 20 AND 50 THEN 'Middle-aged' ELSE 'Old'END AS company_age,ROUND(100.0 *SUM(CASE WHEN sp.deal_stage='Won' THEN 1 ELSE 0 END)/NULLIF(SUM(CASE WHEN sp.deal_stage IN ('Won','Lost')THEN 1 ELSE 0 END),0),2) AS win_rate FROM sales_pipeline sp JOIN accounts a ON sp.account = a.account GROUP BY company_age ORDER BY company_age;
-- 10. Which accounts have never won a deal despite having opportunities in the pipeline?

SELECT a.account, COUNT(sp.opportunity_id) AS total_opportunities
FROM accounts a
JOIN sales_pipeline sp ON a.account = sp.account
GROUP BY a.account
HAVING SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) = 0
ORDER BY total_opportunities DESC;


-- E. TEAM ANALYSIS
-- 1. Which regional office generates the most total revenue?
-- FIX: original query was missing the JOIN condition (cross join between
-- sales_pipeline and sales_teams gave inflated/wrong totals).

SELECT st.regional_office, ROUND(SUM(sp.close_value),2) AS total_revenue
FROM sales_pipeline sp
JOIN sales_teams st ON sp.sales_agent = st.sales_agent
WHERE sp.deal_stage = 'Won'
GROUP BY st.regional_office
ORDER BY total_revenue DESC;

-- 2. Which regional office has the highest win rate? 
SELECT st.regional_office,  SUM(CASE WHEN sp.deal_stage='Won' THEN 1 ELSE 0 END) AS won, SUM(CASE WHEN sp.deal_stage='Lost' THEN 1 ELSE 0 END) AS lost, ROUND(100.0 *SUM(CASE WHEN sp.deal_stage='Won' THEN 1 ELSE 0 END)/NULLIF(SUM(CASE WHEN sp.deal_stage IN ('Won','Lost') THEN 1 ELSE 0 END),0),2) AS win_rate 
FROM sales_pipeline sp JOIN sales_teams st ON sp.sales_agent = st.sales_agent GROUP BY st.regional_office ORDER BY win_rate DESC;

-- 3. How does average deal size differ across regions? 
SELECT st.regional_office , ROUND(AVG(sp.close_value),2) AS avg_deal_size FROM sales_pipeline sp JOIN sales_teams st ON sp.sales_agent = st.sales_agent WHERE sp.deal_stage = 'Won' GROUP BY st.regional_office ORDER BY avg_deal_size DESC;

-- 4. How does average sales cycle length differ across regions?

SELECT st.regional_office,ROUND(AVG(DATEDIFF(sp.close_date, sp.engage_date)),2) AS average_sales_cycle
FROM sales_pipeline sp JOIN sales_teams st ON sp.sales_agent = st.sales_agent WHERE sp.deal_stage = 'Won' GROUP BY st.regional_office ORDER BY average_sales_cycle DESC;

-- 5. Which region has the most reps, and does more reps correlate with more revenue (or just more volume)? (important) 

SELECT st.regional_office, COUNT(DISTINCT st.sales_agent) AS total_reps, COUNT(sp.opportunity_id) AS total_deals, ROUND(SUM( CASE WHEN sp.deal_stage = 'Won' THEN sp.close_value END),2) AS total_revenue FROM sales_teams st LEFT JOIN sales_pipeline sp ON st.sales_agent = sp.sales_agent GROUP BY st.regional_office ORDER BY total_reps DESC;

-- 6. Rank regions by revenue-per-agent (efficiency, not just raw totals). (greatt query)

WITH region_summary AS
(SELECT st.regional_office, COUNT(DISTINCT st.sales_agent) AS total_agents, SUM(CASE WHEN sp.deal_stage = 'Won' THEN sp.close_value ELSE 0 END) AS total_revenue FROM sales_teams st LEFT JOIN sales_pipeline sp ON st.sales_agent = sp.sales_agent GROUP BY st.regional_office)
SELECT regional_office,total_agents,ROUND(total_revenue, 2) AS total_revenue, ROUND(total_revenue / total_agents,2) AS revenue_per_agent, RANK() OVER (ORDER BY total_revenue / total_agents DESC) AS efficiency_rank FROM region_summary ORDER BY efficiency_rank;

-- TIME BASED TRENDS

-- 1. What does monthly revenue look like across the full date range?

SELECT DATE_FORMAT(close_date, '%Y-%m') AS month, ROUND(SUM(close_value),2) AS monthly_revenue
FROM sales_pipeline WHERE deal_stage = 'Won' GROUP BY month ORDER BY month;

-- 2. Is there a month with unusually high or low deal volume?

SELECT DATE_FORMAT(close_date, '%Y-%m') AS month, COUNT(*) AS deals_closed
FROM sales_pipeline WHERE close_date IS NOT NULL GROUP BY month ORDER BY deals_closed DESC;

-- 3. How does quarter-over-quarter win rate trend across the dataset's time span?

SELECT CONCAT(YEAR(close_date), '-Q', QUARTER(close_date)) AS year_quarter,
       ROUND(100.0 * SUM(CASE WHEN deal_stage='Won' THEN 1 ELSE 0 END)
           / SUM(CASE WHEN deal_stage IN ('Won','Lost') THEN 1 ELSE 0 END), 2) AS win_rate
FROM sales_pipeline
WHERE deal_stage IN ('Won','Lost')
GROUP BY year_quarter ORDER BY year_quarter;

-- 4. Which month had the largest single deal close?

SELECT DATE_FORMAT(close_date, '%Y-%m') AS month, opportunity_id, close_value
FROM sales_pipeline WHERE deal_stage = 'Won' ORDER BY close_value DESC LIMIT 1;

-- 5. Compare the first half vs. second half of the dataset's time range

SELECT
    CASE WHEN close_date < (
        SELECT DATE_ADD(MIN(close_date), INTERVAL DATEDIFF(MAX(close_date), MIN(close_date))/2 DAY)
        FROM sales_pipeline WHERE deal_stage='Won'
    ) THEN 'First Half' ELSE 'Second Half' END AS period,
    COUNT(*) AS won_deals, ROUND(SUM(close_value),2) AS total_revenue, ROUND(AVG(close_value),2) AS avg_deal_size
FROM sales_pipeline
WHERE deal_stage = 'Won'
GROUP BY period;


-- DEAL_SIZE  (FINAL OBSERVATIONS) 
-- 1. What does the distribution of deal sizes look like (e.g. bucket into small/medium/large ranges)? 
-- Assumption:
-- Small  : < $5,000
-- Medium : $5,000 - $10,000
-- Large  : > $10,000

SELECT CASE WHEN close_value < 5000 THEN 'Small' WHEN close_value BETWEEN 5000 AND 10000 THEN 'Medium' ELSE 'Large' END AS deal_size,
COUNT(*) AS total_deals,ROUND(AVG(close_value),2) AS average_value
FROM sales_pipeline WHERE deal_stage = 'Won'
GROUP BY deal_size ORDER BY
CASE deal_size WHEN 'Small' THEN 1 WHEN 'Medium' THEN 2 ELSE 3 END;

-- 2. top 10 largest won deals 

SELECT sp.opportunity_id,sp.account,sp.sales_agent,sp.product,ROUND(sp.close_value,2) AS deal_value, st.manager, st.regional_office FROM sales_pipeline sp JOIN sales_teams st ON sp.sales_agent = st.sales_agent WHERE sp.deal_stage = 'Won' ORDER BY sp.close_value DESC LIMIT 10;

-- 3. What percentage of total revenue comes from the top 10% of deals? (Pareto-style analysis)

WITH ranked AS (
    SELECT opportunity_id, close_value,
           PERCENT_RANK() OVER (ORDER BY close_value DESC) AS pct_rank
    FROM sales_pipeline WHERE deal_stage = 'Won'
)
SELECT
    ROUND(SUM(CASE WHEN pct_rank <= 0.10 THEN close_value ELSE 0 END),2) AS top10pct_revenue,
    ROUND(SUM(close_value),2) AS total_revenue,
    ROUND(100 * SUM(CASE WHEN pct_rank <= 0.10 THEN close_value ELSE 0 END) / SUM(close_value),2) AS pct_from_top10pct
FROM ranked;


-- 4. SMALLEST WON DEALS 

SELECT opportunity_id,account,sales_agent,product,close_value FROM sales_pipeline WHERE deal_stage = 'Won'ORDER BY close_value LIMIT 1;

SELECT opportunity_id,account,sales_agent,product,close_value FROM sales_pipeline WHERE deal_stage = 'Won' AND close_value =(SELECT MIN(close_value) FROM sales_pipeline WHERE deal_stage = 'Won');