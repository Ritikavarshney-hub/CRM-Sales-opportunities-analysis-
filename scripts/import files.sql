/*CREATE TABLE stg_sales_pipeline (
      opportunity_id VARCHAR(20),
      sales_agent    VARCHAR(100),
      product        VARCHAR(100),
      account        VARCHAR(100),
      deal_stage     VARCHAR(20),
      engage_date    VARCHAR(20),
      close_date     VARCHAR(20),
      close_value    VARCHAR(20)
  );
  
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales_pipeline.csv'
INTO TABLE stg_sales_pipeline
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; 

INSERT INTO sales_pipeline (opportunity_id, sales_agent, product, account, deal_stage, engage_date,
  close_date, close_value)
  SELECT
      opportunity_id,
      sales_agent,
      product,
      NULLIF(account, ''),
      deal_stage,
      NULLIF(engage_date, ''),
      NULLIF(close_date, ''),
      NULLIF(close_value, '') + 0   -- the +0 forces string->decimal conversion, NULL stays NULL
  FROM stg_sales_pipeline; */
  
  DROP TABLE stg_sales_pipeline;opportunity_id
