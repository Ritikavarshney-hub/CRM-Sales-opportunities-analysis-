-- exploratory  sql 
 -- q1 row level check 
 
 SELECT COUNT(*) AS total_accounts
FROM accounts;

SELECT COUNT(*) AS total_products
FROM products;

SELECT COUNT(*) AS total_sales_teams
FROM sales_teams;

SELECT COUNT(*) AS total_pipeline
FROM sales_pipeline;

-- q2 checking rows data 

SELECT * FROM accounts LIMIT 20;

SELECT * FROM products LIMIT 20;

SELECT * FROM sales_teams LIMIT 20;

SELECT * FROM sales_pipeline LIMIT 20;

-- q3 checking primary key uniqueness 

SELECT
COUNT(*) AS total_rows,
COUNT(DISTINCT account) AS unique_accounts
FROM accounts;

SELECT
COUNT(*) total_rows,
COUNT(DISTINCT product) unique_products
FROM products;

SELECT
COUNT(*) total_rows,
COUNT(DISTINCT sales_agent) unique_agents
FROM sales_teams;

SELECT
COUNT(*) total_rows,
COUNT(DISTINCT opportunity_id) unique_opportunities
FROM sales_pipeline;

-- q4 deal stage distribution 

SELECT
deal_stage,
COUNT(*) AS total_deals,
ROUND(
100 * COUNT(*) / SUM(COUNT(*)) OVER (),
2
) AS percentage
FROM sales_pipeline
GROUP BY deal_stage
ORDER BY total_deals DESC;

-- sector distribution 

SELECT
sector,
COUNT(*) AS total_accounts
FROM accounts
GROUP BY sector
ORDER BY total_accounts DESC;

-- regional office distribution 

SELECT
regional_office,
COUNT(*) AS total_agents
FROM sales_teams
GROUP BY regional_office
ORDER BY total_agents DESC;

-- product series 
SELECT
series,
COUNT(*) AS total_products
FROM products
GROUP BY series
ORDER BY total_products DESC;

-- office location distribution 

SELECT
office_location,
COUNT(*) total_accounts
FROM accounts
GROUP BY office_location
ORDER BY total_accounts DESC;

-- won deals 

SELECT
MIN(close_value) AS minimum,
MAX(close_value) AS maximum,
ROUND(AVG(close_value),2) AS average,
ROUND(STDDEV(close_value),2) AS std_deviation
FROM sales_pipeline
WHERE deal_stage='Won';

-- data range 
SELECT
MIN(engage_date) earliest_engagement,
MAX(engage_date) latest_engagement,
MIN(close_date) earliest_close,
MAX(close_date) latest_close
FROM sales_pipeline;

-- revenue statistics
SELECT MIN(revenue) minimum, MAX(revenue) maximum, ROUND(AVG(revenue),2) average FROM accounts; 

-- employee statistcs 
SELECT MIN(employees) minimum, MAX(employees) maxiumum, ROUND(AVG(employees),2) average FROM accounts; 

-- product statistics 
SELECT
MIN(sales_price) minimum,
MAX(sales_price) maximum,
ROUND(AVG(sales_price),2) average
FROM products;

-- sales cycle length 
-- won deals 
SELECT
MIN(DATEDIFF(close_date,engage_date)) minimum_days,
MAX(DATEDIFF(close_date,engage_date)) maximum_days,
ROUND(AVG(DATEDIFF(close_date,engage_date)),2) average_days
FROM sales_pipeline
WHERE deal_stage='Won';

-- lost deals
SELECT
MIN(DATEDIFF(close_date,engage_date)) minimum_days,
MAX(DATEDIFF(close_date,engage_date)) maximum_days,
ROUND(AVG(DATEDIFF(close_date,engage_date)),2) average_days
FROM sales_pipeline
WHERE deal_stage='Lost';

-- RELATIONSHIPS 
-- 1 deals per account 
SELECT account, COUNT(*) total_deals FROM sales_pipeline GROUP BY account ORDER BY total_deals DESC LIMIT 20;

-- 2 deals per sales_agent 
SELECT sales_agent, COUNT(*) total_deals FROM sales_pipeline GROUP BY sales_agent ORDER BY total_deals DESC LIMIT 20;

-- 3 agents per manager 
SELECT manager, COUNT(*) total_agents FROM sales_teams GROUP BY manager ORDER BY total_agents DESC LIMIT 20;

-- 4 agents per regional office 
SELECT regional_office , COUNT(*) total_agents FROM sales_teams GROUP BY regional_office ORDER BY total_agents DESC LIMIT 20;

-- 5 subsidary vs independent account 
SELECT 
CASE 
WHEN subsidiary_of IS NULL THEN 'independent' ELSE 'subsidiary' END AS account_type, COUNT(*) total_accounts FROM accounts GROUP BY account_type;
-- CHECKING NULLS 
-- 1
SELECT COUNT(*) AS null_accounts FROM sales_pipeline WHERE account IS NULL;

-- 2 
SELECT COUNT(*) AS null_engage FROM sales_pipeline WHERE engage_date IS NULL;

-- 3
SELECT COUNT(*) AS null_close FROM sales_pipeline WHERE close_date IS NULL;

-- 4 
SELECT COUNT(*) AS null_close_value FROM sales_pipeline WHERE close_value IS NULL;


-- cross table joins 
-- 1 revenue by regional office 

SELECT st.regional_office, COUNT(*) total_deals,
ROUND(SUM(sp.close_value),2) total_revenue
FROM sales_pipeline sp
JOIN sales_teams st
ON sp.sales_agent=st.sales_agent
WHERE sp.deal_stage='Won'
GROUP BY st.regional_office
ORDER BY total_revenue DESC;

-- 2 revenue by product series 
SELECT
p.series,
ROUND(SUM(sp.close_value),2) total_revenue
FROM sales_pipeline sp
JOIN products p
ON sp.product=p.product
WHERE sp.deal_stage='Won'
GROUP BY p.series
ORDER BY total_revenue DESC;

-- 3 revenue by sector 
SELECT
a.sector,
ROUND(SUM(sp.close_value),2) total_revenue
FROM sales_pipeline sp
JOIN accounts a
ON sp.account=a.account
WHERE sp.deal_stage='Won'
GROUP BY a.sector
ORDER BY total_revenue DESC;

--  revenue distribution by product 
SELECT product, ROUND(SUM(close_value),2) revenue FROM sales_pipeline WHERE deal_stage='Won' GROUP BY product ORDER BY revenue DESC;

-- top 10 largest deals
SELECT opportunity_id, account, sales_agent, product, close_value FROM sales_pipeline WHERE deal_stage='Won' ORDER BY close_value DESC LIMIT 10;

