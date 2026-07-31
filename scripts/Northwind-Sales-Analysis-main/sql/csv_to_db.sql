CREATE TABLE customers(
customer_id		VARCHAR PRIMARY KEY,
company_name	VARCHAR,
contact_name	VARCHAR,
contact_title	VARCHAR,
address			VARCHAR,
city			VARCHAR,
region			VARCHAR,
postal_code		VARCHAR,
country			VARCHAR,
phone			VARCHAR,
fax				VARCHAR
);

CREATE TABLE employees(
employee_id			SERIAL PRIMARY KEY,
last_name			VARCHAR NOT NULL,
first_name			VARCHAR NOT NULL,
title				VARCHAR,
title_of_courtesy	VARCHAR,
birth_date			DATE,
hire_date			DATE,
address				VARCHAR,
city				VARCHAR,
region				VARCHAR,
country				VARCHAR,
home_phone			VARCHAR,
salary				VARCHAR					
);

CREATE TABLE employee_territories(
employee_id		INTEGER,
territory_id	VARCHAR,
PRIMARY KEY(employee_id,territory_id)
);

CREATE TABLE categories(
category_id		SERIAL PRIMARY KEY,
category_name	VARCHAR NOT NULL,
description		TEXT
);

CREATE TABLE order_details(
order_id	INTEGER,
product_id	INTEGER,
unit_price	NUMERIC,
quantity	SMALLINT,
discount	FLOAT,
PRIMARY KEY (order_id,product_id)
);

CREATE TABLE orders(
order_id		SERIAL PRIMARY KEY,
customer_id		VARCHAR,
employee_id		INTEGER,
order_date		DATE,
required_date	DATE,
shipped_date	DATE,
ship_via		INTEGER,
freight			NUMERIC,
ship_name		VARCHAR,
ship_address	VARCHAR,
ship_city		VARCHAR,
ship_region		VARCHAR,
ship_postal_code VARCHAR,
ship_country	VARCHAR
);

CREATE TABLE products(
product_id		SERIAL PRIMARY KEY,
product_name	VARCHAR NOT NULL,
supplier_id 	INTEGER,
category_id		INTEGER,
quantity_per_unit VARCHAR,
unit_price		NUMERIC,
units_in_stock	SMALLINT,
units_on_order	SMALLINT,
reorder_level	SMALLINT,
discontinued	BOOLEAN
);

CREATE TABLE regions(
region_id			SERIAL PRIMARY KEY,
region_description 	VARCHAR
);

CREATE TABLE shippers(
shipper_id		SERIAL PRIMARY KEY,
company_name	VARCHAR NOT NULL,
phone			VARCHAR
);

CREATE TABLE suppliers(
supplier_id		SERIAL PRIMARY KEY,
company_name	VARCHAR NOT NULL,
contact_name	VARCHAR,
contact_title	VARCHAR,
address			VARCHAR,
city			VARCHAR,
region			VARCHAR,
postal_code		VARCHAR,
country			VARCHAR,
phone			VARCHAR,
fax				VARCHAR,
homepage		TEXT
);

CREATE TABLE territories(
territory_id			VARCHAR PRIMARY KEY,
territory_description	VARCHAR,
region_id				INTEGER
);

COPY suppliers(
    supplier_id,
    company_name,
    contact_name,
    contact_title,
    address,
    city,
    region,
    postal_code,
    country,
    phone,
    fax,
    homepage
) 
FROM 'D:/datasets/northwind_dataset/archive/suppliers.csv'
WITH (FORMAT CSV, HEADER, NULL 'NULL');
--imported others directly using gui

ALTER TABLE customers
ALTER COLUMN company_name SET NOT NULL;


ALTER TABLE employees
ALTER COLUMN last_name SET NOT NULL;

ALTER TABLE employees
ALTER COLUMN first_name SET NOT NULL;


ALTER TABLE employee_territories
ADD CONSTRAINT delete_territory_if_no_employee_exists
FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
ON DELETE CASCADE;

ALTER TABLE employee_territories
ADD CONSTRAINT delete_territory_if_no_territory_id_exists
FOREIGN KEY (territory_id) REFERENCES territories(territory_id)
ON DELETE CASCADE;


ALTER TABLE order_details
ALTER COLUMN unit_price SET NOT NULL;
ALTER TABLE order_details
ALTER COLUMN quantity SET NOT NULL;
ALTER TABLE order_details
ALTER COLUMN discount SET NOT NULL;

ALTER TABLE order_details
ADD CONSTRAINT chk_unit_price_positive CHECK (unit_price >= 0);
ALTER TABLE order_details
ADD CONSTRAINT chk_quantity_nonnegative CHECK (quantity >= 0);
ALTER TABLE order_details
ADD CONSTRAINT chk_discount_valid CHECK (discount BETWEEN 0 AND 1);

ALTER TABLE order_details 
ADD CONSTRAINT delete_order_details_if_no_order_id
FOREIGN KEY (order_id) REFERENCES orders(order_id)
ON DELETE CASCADE

ALTER TABLE order_details 
ADD CONSTRAINT delete_order_details_if_no_product_id
FOREIGN KEY (product_id) REFERENCES products(product_id)
ON DELETE CASCADE;

ALTER TABLE orders
ADD CONSTRAINT chk_freight_positive CHECK (freight>=0);

ALTER TABLE orders
ADD CONSTRAINT delete_order_if_no_customer_exists
FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
ON DELETE SET NULL;

ALTER TABLE orders
ADD CONSTRAINT fk_orders_employees
FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
ON DELETE SET NULL;

ALTER TABLE orders
ADD CONSTRAINT fk_orders_shipper
FOREIGN KEY (ship_via) REFERENCES shippers(shipper_id)
ON DELETE SET NULL;

ALTER TABLE products
ADD CONSTRAINT chk_unit_price_products CHECK (unit_price >= 0);
ALTER TABLE products
ADD CONSTRAINT chk_units_in_stock CHECK (units_in_stock >= 0);
ALTER TABLE products
ADD CONSTRAINT chk_units_on_order CHECK (units_on_order >= 0);
ALTER TABLE products
ADD CONSTRAINT chk_reorder_level CHECK (reorder_level >= 0);

ALTER TABLE products
ADD CONSTRAINT fk_products_supplier
FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
ON DELETE SET NULL;

ALTER TABLE products
ADD CONSTRAINT fk_products_category
FOREIGN KEY (category_id) REFERENCES categories(category_id)
ON DELETE SET NULL;



ALTER TABLE regions
ALTER COLUMN region_description SET NOT NULL;


ALTER TABLE territories
ALTER COLUMN territory_description SET NOT NULL;

ALTER TABLE territories
ADD CONSTRAINT fk_territories_region
FOREIGN KEY (region_id) REFERENCES regions(region_id)
ON DELETE CASCADE;

