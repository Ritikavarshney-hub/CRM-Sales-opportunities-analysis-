-- =============================================================
-- 01_schema.sql
-- CRM Sales Opportunities — canonical schema definition
--
-- This reflects the actual final state of the database after the
-- Database Design phase (see docs/03_er_diagram.md for the ER diagram
-- and design rationale). Run this against a fresh MySQL instance to
-- rebuild the schema from scratch; then load data via sql/02_data_load.sql.
-- =============================================================

CREATE DATABASE IF NOT EXISTS crm_sales_opportunities;
USE crm_sales_opportunities;

-- -------------------------------------------------------------
-- Dimension tables (no dependencies, created first)
-- -------------------------------------------------------------

CREATE TABLE products (
    product     VARCHAR(100) NOT NULL,
    series      VARCHAR(20),
    sales_price DECIMAL(10,2),
    PRIMARY KEY (product)
);

CREATE TABLE sales_teams (
    sales_agent     VARCHAR(100) NOT NULL,
    manager         VARCHAR(100),
    regional_office VARCHAR(20),
    PRIMARY KEY (sales_agent)
    -- Note: `manager` is intentionally NOT a foreign key to sales_agent.
    -- 6 managers in this dataset never appear as agents themselves,
    -- so it's a plain descriptive column, not an enforced relationship.
);

CREATE TABLE accounts (
    account           VARCHAR(100) NOT NULL,
    sector            VARCHAR(50),
    year_established  INT,
    revenue           DECIMAL(10,2),
    employees         INT,
    office_location   VARCHAR(50),
    subsidiary_of     VARCHAR(100) NULL,
    PRIMARY KEY (account),
    CONSTRAINT fk_accounts_subsidiary
        FOREIGN KEY (subsidiary_of) REFERENCES accounts(account)
);

-- -------------------------------------------------------------
-- Fact table (depends on all three dimension tables above)
-- -------------------------------------------------------------

CREATE TABLE sales_pipeline (
    opportunity_id  VARCHAR(20)  NOT NULL,
    sales_agent     VARCHAR(100) NOT NULL,
    product         VARCHAR(100) NOT NULL,
    account         VARCHAR(100) NULL,
    deal_stage      VARCHAR(20)  NOT NULL,
    engage_date     DATE NULL,
    close_date      DATE NULL,
    close_value     DECIMAL(10,2) NULL,
    PRIMARY KEY (opportunity_id),
    CONSTRAINT fk_pipeline_agent   FOREIGN KEY (sales_agent) REFERENCES sales_teams(sales_agent),
    CONSTRAINT fk_pipeline_product FOREIGN KEY (product)     REFERENCES products(product),
    CONSTRAINT fk_pipeline_account FOREIGN KEY (account)     REFERENCES accounts(account)
    -- account is nullable: ~1,425 rows have no account (early-stage/unqualified deals)
);

-- =============================================================
-- OPTIONAL ENHANCEMENTS (not yet applied to the live database)
-- Recommended CHECK constraints for stronger data integrity.
-- Run these separately if you want them enforced going forward.
-- =============================================================

-- ALTER TABLE accounts
--     ADD CONSTRAINT chk_accounts_revenue_nonnegative CHECK (revenue >= 0),
--     ADD CONSTRAINT chk_accounts_employees_nonnegative CHECK (employees >= 0);

-- ALTER TABLE products
--     ADD CONSTRAINT chk_products_price_nonnegative CHECK (sales_price >= 0);

-- ALTER TABLE sales_pipeline
--     ADD CONSTRAINT chk_pipeline_close_value_nonnegative CHECK (close_value >= 0),
--     ADD CONSTRAINT chk_pipeline_deal_stage_valid
--         CHECK (deal_stage IN ('Prospecting', 'Engaging', 'Won', 'Lost'));
