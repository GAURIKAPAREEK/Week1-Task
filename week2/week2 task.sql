-- step 1  Load dataset into a SQL database


-- CREATE TABLE db (
--     row_id INTEGER,
--     order_id VARCHAR(50),
--     order_date VARCHAR(20),
--     ship_date VARCHAR(20),
--     ship_mode VARCHAR(50),
--     customer_id VARCHAR(50),
--     customer_name VARCHAR(100),
--     segment VARCHAR(50),
--     country VARCHAR(50),
--     city VARCHAR(100),
--     state VARCHAR(100),
--     postal_code VARCHAR(20),
--     region VARCHAR(50),
--     product_id VARCHAR(50),
--     category VARCHAR(50),
--     sub_category VARCHAR(50),
--     product_name VARCHAR(500),
--     sales NUMERIC(12,4),
--     quantity INTEGER,
--     discount NUMERIC(5,4),
--     profit NUMERIC(12,4)
-- );
-- ..............................................................................................................................
-- step 2 - DISPLAY WHOLE DATASET /sample data/structure or schema

-- SELECT*FROM db
-- .......................................................
-- #TOTAL ROWS IN TABLE

-- SELECT COUNT(*) AS total_rows
-- FROM db;
-- .......................................................
-- #sample data

-- SELECT *
-- FROM db
-- LIMIT 10;

-- ..............................................................
-- #schema/structure
-- SELECT column_name, data_type
-- FROM information_schema.columns
-- WHERE table_name = 'db';

-- ..............................................................................................................................
-- step 3 USE OF WHERE CLAUSE

-- #REGION

-- SELECT *
-- FROM db
-- WHERE region = 'West';

-- .........................................................
-- #category

-- SELECT *
-- FROM db
-- WHERE category = 'Furniture';

-- ...........................................................
-- #sales

-- SELECT *
-- FROM db
-- WHERE sales > 500;

-- .................................................................
-- #date

-- SELECT *
-- FROM db
-- WHERE TO_DATE(order_date,'MM/DD/YYYY')
-- BETWEEN '2017-01-01' AND '2017-12-31';
-- .............................................................................................................................................
-- step 4 Use GROUP BY for aggregations

-- #SALES BY REGION

-- SELECT region,
--        SUM(sales) AS total_sales
-- FROM db
-- GROUP BY region
-- ORDER BY total_sales DESC;
-- .......................................................
-- #QUANTITY BY CATEGORY

-- SELECT category,
--        SUM(quantity) AS total_quantity
-- FROM db
-- GROUP BY category;
-- .........................................................
-- #AVERAGE SALES BY CATEGORY
-- SELECT category,
--        ROUND(AVG(sales),2) AS avg_sales
-- FROM db
-- GROUP BY category;
-- ............................................................................................................................................
-- #step 5 Sort and limit results

--# Top 10 Products by Sales

-- SELECT product_name,
--        SUM(sales) AS total_sales
-- FROM db
-- GROUP BY product_name
-- ORDER BY total_sales DESC
-- LIMIT 10;
-- ...........................................................
-- #Top Categories by Profit

-- SELECT category,
--        SUM(profit) AS total_profit
-- FROM db
-- GROUP BY category
-- ORDER BY total_profit DESC;
-- ....................................................................................................................................................................
-- step 6  use cases

--# monthly trends

-- 1.Monthly Profit Analysis

-- ALTER TABLE db
-- ALTER COLUMN order_date TYPE DATE
-- USING TO_DATE(order_date, 'MM/DD/YYYY');

-- SELECT
--     DATE_TRUNC('month', order_date) AS month,
--     ROUND(SUM(profit),2) AS total_profit
-- FROM db
-- GROUP BY month
-- ORDER BY month;

-- .................................................................
-- 2.Monthly Sales Analysis

-- SELECT
--     DATE_TRUNC('month', order_date) AS month,
--     ROUND(SUM(sales),2) AS total_sales
-- FROM db
-- GROUP BY month
-- ORDER BY month;
-- ..................................................................................
-- #top customers

-- SELECT customer_name,
--        COUNT(*) AS total_orders,
--        ROUND(SUM(sales),2) AS total_sales,
--        ROUND(SUM(profit),2) AS total_profit
-- FROM db
-- GROUP BY customer_name
-- ORDER BY total_sales DESC
-- LIMIT 10;

-- .....................................................................
-- duplicate detection

-- SELECT order_id,
--        COUNT(*)
-- FROM db
-- GROUP BY order_id
-- HAVING COUNT(*) > 1;

-- .................................................................................................................................................................................
-- step 7 Data Quality Checks

--# SALES EQUAL TO HAVE NO OUTPUT  BECAUSE THERE IS NO RECORD LIKE THAT 
-- SELECT *
-- FROM db
-- WHERE sales = 0;  

-- #Null Values HAVE NO OUTPUT  BECAUSE THERE IS NO RECORD LIKE THAT 
-- SELECT *
-- FROM db
-- WHERE order_id IS NULL
--    OR customer_name IS NULL;

-- ............................................................................
-- # ROW COUNT
-- SELECT COUNT(*) AS total_rows
-- FROM db;