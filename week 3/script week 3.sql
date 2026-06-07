-- #STEP 1 Load Superstore dataset into a table


-- CREATE TABLE superstore_raw (
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

-- SELECT*FROM superstore_raw

-- ..........................................................................................................................................................
-- STEP 2- #Create tables (customers, orders, products) from the dataset.


-- CREATE TABLE customers (
--     customer_id VARCHAR(20) PRIMARY KEY,
--     customer_name VARCHAR(100),
--     segment VARCHAR(50),
--     country VARCHAR(50),
--     city VARCHAR(100),
--     state VARCHAR(100),
--     postal_code VARCHAR(20),
--     region VARCHAR(50)
-- );

-- INSERT INTO customers
-- (
--     customer_id,
--     customer_name,
--     segment,
--     country,
--     city,
--     state,
--     postal_code,
--     region
-- )
-- SELECT DISTINCT ON (customer_id)
--     customer_id,
--     customer_name,
--     segment,
--     country,
--     city,
--     state,
--     postal_code,
--     region
-- FROM superstore_raw
-- ORDER BY customer_id;
-- .............................................................................................


-- CREATE TABLE products (
--     product_id VARCHAR(50) PRIMARY KEY,
--     product_name VARCHAR(255),
--     category VARCHAR(50),
--     sub_category VARCHAR(50)
-- );

-- INSERT INTO products
-- (
--     product_id,
--     product_name,
--     category,
--     sub_category
-- )
-- SELECT DISTINCT  ON (product_id)
--     product_id,
--     product_name,
--     category,
--     sub_category
-- FROM superstore_raw;
-- .................................................................................................
-- CREATE TABLE orders (
--     row_id INT PRIMARY KEY,
--     order_id VARCHAR(50),
--     order_date DATE,
--     ship_date DATE,
--     ship_mode VARCHAR(50),
--     customer_id VARCHAR(20),
--     product_id VARCHAR(50),
--     sales NUMERIC(10,2),
--     quantity INT,
--     discount NUMERIC(5,2),
--     profit NUMERIC(10,2),

--     FOREIGN KEY (customer_id)
--         REFERENCES customers(customer_id),

--     FOREIGN KEY (product_id)
--         REFERENCES products(product_id)
-- );

-- INSERT INTO orders
-- (
--     row_id,
--     order_id,
--     order_date,
--     ship_date,
--     ship_mode,
--     customer_id,
--     product_id,
--     sales,
--     quantity,
--     discount,
--     profit
-- )
-- SELECT DISTINCT
--     row_id,
--     order_id,
--     TO_DATE(order_date,'MM/DD/YYYY'),
--     TO_DATE(ship_date,'MM/DD/YYYY'),
--     ship_mode,
--     customer_id,
--     product_id,
--     sales,
--     quantity,
--     discount,
--     profit
-- FROM superstore_raw;


-- .............................DISPLAY THESE DIMENSIONAL TABLES.................

-- SELECT *FROM customers LIMIT 10;

-- SELECT * FROM products LIMIT 10;

-- SELECT * FROM orders  LIMIT 10;

-- SELECT COUNT(*) AS total_customers
-- FROM customers;

-- SELECT COUNT(*) AS total_products
-- FROM products;

-- SELECT COUNT(*) AS total_orders
-- FROM orders;

-- ..............................................................................................................................................................
-- #STEP 3- Apply subqueries to filter data (above average sales, highest order per customer).

-- # Sales above average sales
-- SELECT *
-- FROM orders
-- WHERE sales >
-- (
--     SELECT AVG(sales)
--     FROM orders
-- );

-- ...........................................
-- #Highest Order Per Customer
-- SELECT
--     customer_id,
--     order_id,
--     sales
-- FROM orders o
-- WHERE sales =
-- (
--     SELECT MAX(sales)
--     FROM orders o2
--     WHERE o.customer_id = o2.customer_id
-- );
-- ..........................................................................................................................
-- #Step 4 CTE

-- #Total Sales Per Customer

-- WITH customer_sales AS
-- (
--     SELECT
--         customer_id,
--         SUM(sales) AS total_sales
--     FROM orders
--     GROUP BY customer_id
-- )
-- SELECT *
-- FROM customer_sales
-- ORDER BY total_sales DESC;
-- ................................................................................

-- # Total Profit Per Customer


-- WITH customer_profit AS
-- (
--     SELECT
--         customer_id,
--         SUM(profit) AS total_profit
--     FROM orders
--     GROUP BY customer_id
-- )
-- SELECT *
-- FROM customer_profit
-- ORDER BY total_profit DESC;
-- .........................................................................................................................................................
-- #step 5 Window Functions

-- #ROW_NUMBER()
-- SELECT
--     customer_id,
--     sales,
--     ROW_NUMBER() OVER
--     (
--         ORDER BY sales DESC
--     ) AS row_num
-- FROM orders;
-- ............................................................................

-- #RANK()
-- SELECT
--     customer_id,
--     sales,
--     RANK() OVER
--     (
--         ORDER BY sales DESC
--     ) AS sales_rank
-- FROM orders;

-- ..........................................................................

-- #DENSE_RANK()
-- SELECT
--     customer_id,
--     sales,
--     DENSE_RANK() OVER
--     (
--         ORDER BY sales DESC
--     ) AS dense_rank_no
-- FROM orders;
-- .................................................................................................................................................
-- #step 6  JOIN + CTE + Window Functions Combined Query


-- WITH customer_sales AS
-- (
--     SELECT
--         customer_id,
--         SUM(sales) AS total_sales
--     FROM orders
--     GROUP BY customer_id
-- )
-- SELECT
--     c.customer_id,
--     c.customer_name,
--     cs.total_sales,
--     RANK() OVER
--     (
--         ORDER BY cs.total_sales DESC
--     ) AS customer_rank
-- FROM customer_sales cs
-- JOIN customers c
-- ON cs.customer_id = c.customer_id
-- ORDER BY customer_rank;

-- ........................................................................................................................

-- #step 7 Solve Business Queries

-- 1.Top 10 customers-
-- WITH customer_sales AS
-- (
--     SELECT
--         customer_id,
--         SUM(sales) AS total_sales
--     FROM orders
--     GROUP BY customer_id
-- )
-- SELECT *
-- FROM customer_sales
-- ORDER BY total_sales DESC
-- LIMIT 10;
-- .............................................................................................
-- 2. Bottom 10 customers(low customers)-
-- WITH customer_sales AS
-- (
--     SELECT
--         customer_id,
--         SUM(sales) AS total_sales
--     FROM orders
--     GROUP BY customer_id
-- )
-- SELECT *
-- FROM customer_sales
-- ORDER BY total_sales ASC
-- LIMIT 10;
-- ............................................................................................

-- 3. Single order Customers
-- SELECT
--     customer_id,
--     COUNT(DISTINCT order_id) AS total_orders
-- FROM orders
-- GROUP BY customer_id
-- HAVING COUNT(DISTINCT order_id) = 1;

-- ..........................................................................................
-- -- 4. Customers Above Average Total Sales
-- WITH customer_sales AS
-- (
--     SELECT
--         customer_id,
--         SUM(sales) AS total_sales
--     FROM orders
--     GROUP BY customer_id
-- )
-- SELECT *
-- FROM customer_sales
-- WHERE total_sales >
-- (
--     SELECT AVG(total_sales)
--     FROM customer_sales
-- );
