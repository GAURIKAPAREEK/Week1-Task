# SQL Sales Data Analysis using Subqueries, CTEs, and Window Functions

## Objective

Analyze Superstore sales data using SQL concepts such as Subqueries, Common Table Expressions (CTEs), Window Functions to answer business-related questions and generate meaningful insights.

## Dataset

* Superstore Dataset
* table: `superstore_raw`

## Tasks Performed

### 1. Data Preparation

* Created `superstore_raw` table.
* Loaded Superstore dataset into the database.
* Created dimensional tables:

  * `customers`
  * `products`
  * `orders`
* Inserted data using `SELECT DISTINCT`.

### 2. Subqueries

* Customers with sales above average sales.
* Highest-value order for each customer.

### 3. Common Table Expressions (CTEs)

* Calculated total sales per customer.
* Calculated total profit per customer.

### 4. Window Functions

* `ROW_NUMBER()` for sequential numbering.
* `RANK()` for customer ranking based on sales.
* `DENSE_RANK()` for ranking without gaps.

### 5. JOIN + CTE + Window Functions

* Combined customer information with aggregated sales data.
* Ranked customers according to total sales contribution.

### 6. Business Queries

* Top 10 customers by sales.
* Bottom 10 customers by sales.
* Customers with exactly one order.
* Customers whose total sales are above average.

## Key Insights

* A small group of customers contributes the highest share of revenue.
* Several customers have only one purchase, indicating potential retention opportunities.
* Above-average customers can be targeted for loyalty programs.
* Ranking analysis helps identify high-value customers for business decisions.

## Technologies Used

* SQL
* PostgreSQL

## Outcome

Successfully applied Subqueries, CTEs, Window Functions, and Joins to perform sales analysis and answer business questions using the Superstore dataset.
