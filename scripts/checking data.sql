/* SELECT COUNT(*) AS total_rows FROM sales_pipeline;
  SELECT deal_stage, COUNT(*) FROM sales_pipeline GROUP BY deal_stage;
 SELECT DISTINCT product FROM sales_pipeline
  WHERE product NOT IN (SELECT product FROM products);
SET SQL_SAFE_UPDATES = 0;
     
  UPDATE sales_pipeline
  SET product = 'GTX Pro'
  WHERE product = 'GTXPro';

  SET SQL_SAFE_UPDATES = 1;*/
  
  /*ALTER TABLE sales_pipeline
  ADD CONSTRAINT fk_pipeline_product
  FOREIGN KEY (product) REFERENCES products(product); 
  
ALTER TABLE products MODIFY product VARCHAR(100) NOT NULL;
ALTER TABLE sales_pipeline MODIFY product VARCHAR(100);
  
  SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME IN ('products', 'sales_pipeline')
    AND COLUMN_NAME = 'product'; 
    
 ALTER TABLE sales_pipeline
  ADD CONSTRAINT fk_pipeline_product
  FOREIGN KEY (product) REFERENCES products(product); 
  
   SHOW CREATE TABLE products; 
   
 SHOW CREATE TABLE products; 
  SHOW CREATE TABLE sales_teams; 
  SHOW CREATE TABLE accounts; 
  SHOW CREATE TABLE sales_pipeline; */
  
  SHOW CREATE TABLE data_dictionary;
  
     
  