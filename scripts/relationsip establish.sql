/* ALTER TABLE products
      MODIFY series VARCHAR(20),
      ADD PRIMARY KEY (product);

 ALTER TABLE sales_teams
      MODIFY sales_agent VARCHAR(100) NOT NULL,
      MODIFY manager VARCHAR(100),
      MODIFY regional_office VARCHAR(20),
      ADD PRIMARY KEY (sales_agent); 
      
      
 ALTER TABLE accounts
      MODIFY account VARCHAR(100) NOT NULL,
      MODIFY sector VARCHAR(50),
      MODIFY revenue DECIMAL(10,2),
      MODIFY office_location VARCHAR(50),
      MODIFY subsidiary_of VARCHAR(100) NULL,
      ADD PRIMARY KEY (account); 
      
 ALTER TABLE sales_pipeline
      MODIFY opportunity_id VARCHAR(20) NOT NULL,
      MODIFY sales_agent VARCHAR(100) NOT NULL,
      MODIFY account VARCHAR(100) NULL,
      MODIFY deal_stage VARCHAR(20),
      MODIFY engage_date DATE NULL,
      MODIFY close_date DATE NULL,
      MODIFY close_value DECIMAL(10,2) NULL,
      ADD PRIMARY KEY (opportunity_id); 
      
	  ALTER TABLE sales_pipeline
      ADD CONSTRAINT fk_pipeline_agent   FOREIGN KEY (sales_agent) REFERENCES
  sales_teams(sales_agent),
      ADD CONSTRAINT fk_pipeline_product FOREIGN KEY (product)     REFERENCES
  products(product),
      ADD CONSTRAINT fk_pipeline_account FOREIGN KEY (account)     REFERENCES
  accounts(account); 
  
   SELECT COUNT(*) AS total_rows FROM sales_pipeline; 
   
     TRUNCATE TABLE sales_pipeline; 
   
  
  SELECT COUNT(*) FROM sales_pipeline; 
  
  CREATE TABLE IF NOT EXISTS stg_sales_pipeline (
      opportunity_id VARCHAR(20),
      sales_agent    VARCHAR(100),
      product        VARCHAR(100),
      account        VARCHAR(100),
      deal_stage     VARCHAR(20),
      engage_date    VARCHAR(20),
      close_date     VARCHAR(20),
      close_value    VARCHAR(20)
  ); 
  
    TRUNCATE TABLE stg_sales_pipeline; 
    
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales_pipeline.csv'
  INTO TABLE stg_sales_pipeline
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 ROWS; 
  
INSERT INTO sales_pipeline (opportunity_id, sales_agent, product, account, deal_stage,
  engage_date, close_date, close_value)
  SELECT
      opportunity_id,
      sales_agent,
      CASE WHEN product = 'GTXPro' THEN 'GTX Pro' ELSE product END,
      NULLIF(REPLACE(REPLACE(account, '\r', ''), '\n', ''), ''),
      deal_stage,
      NULLIF(REPLACE(REPLACE(engage_date, '\r', ''), '\n', ''), ''),
      NULLIF(REPLACE(REPLACE(close_date, '\r', ''), '\n', ''), ''),
      NULLIF(REPLACE(REPLACE(close_value, '\r', ''), '\n', ''), '')
  FROM stg_sales_pipeline; 
  
ALTER TABLE sales_pipeline
      MODIFY opportunity_id VARCHAR(20) NOT NULL,
      MODIFY sales_agent VARCHAR(100) NOT NULL,
      MODIFY account VARCHAR(100) NULL,
      MODIFY deal_stage VARCHAR(20),
      MODIFY engage_date DATE NULL,
      MODIFY close_date DATE NULL,
      MODIFY close_value DECIMAL(10,2) NULL,
      ADD PRIMARY KEY (opportunity_id); 
  
 ALTER TABLE sales_pipeline
      ADD CONSTRAINT fk_pipeline_agent   FOREIGN KEY (sales_agent) REFERENCES
  sales_teams(sales_agent),
      ADD CONSTRAINT fk_pipeline_product FOREIGN KEY (product)     REFERENCES
  products(product),
      ADD CONSTRAINT fk_pipeline_account FOREIGN KEY (account)     REFERENCES
  accounts(account); 
  
  SELECT 'accounts' AS tbl, COUNT(*) FROM accounts
  UNION ALL SELECT 'products', COUNT(*) FROM products
  UNION ALL SELECT 'sales_teams', COUNT(*) FROM sales_teams
  UNION ALL SELECT 'sales_pipeline', COUNT(*) FROM sales_pipeline; 
  
    SELECT deal_stage, COUNT(*) FROM sales_pipeline GROUP BY deal_stage; */
    
SELECT COUNT(*) AS orphan_products FROM sales_pipeline sp
  LEFT JOIN products p ON sp.product = p.product WHERE p.product IS NULL;
  
 SELECT COUNT(*) AS orphan_agents FROM sales_pipeline sp
  LEFT JOIN sales_teams st ON sp.sales_agent = st.sales_agent WHERE st.sales_agent IS NULL;

 SELECT COUNT(*) AS orphan_accounts FROM sales_pipeline sp
  LEFT JOIN accounts a ON sp.account = a.account WHERE sp.account IS NOT NULL AND a.account IS
  NULL;
  
  SELECT COUNT(*) AS orphan_accounts FROM sales_pipeline sp
  LEFT JOIN accounts a ON sp.account = a.account WHERE sp.account IS NOT NULL AND a.account IS
  NULL;
  
  