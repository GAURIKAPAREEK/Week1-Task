
WITH customer_cohorts AS (
    SELECT 
        customer_id,
        strftime('%Y-%m', registration_date) AS cohort_month
    FROM customers
),
cohort_sizes AS (
    SELECT 
        cohort_month,
        COUNT(customer_id) AS cohort_size
    FROM customer_cohorts
    GROUP BY cohort_month
),
customer_orders_elapsed AS (
    SELECT DISTINCT
        o.customer_id,
        cc.cohort_month,
        (CAST(strftime('%Y', o.order_date) AS INTEGER) - CAST(strftime('%Y', cc.cohort_month || '-01') AS INTEGER)) * 12 +
        (CAST(strftime('%m', o.order_date) AS INTEGER) - CAST(strftime('%m', cc.cohort_month || '-01') AS INTEGER)) AS months_elapsed
    FROM orders o
    JOIN customer_cohorts cc ON o.customer_id = cc.customer_id
)
SELECT 
    cs.cohort_month,
    cs.cohort_size,
    COUNT(DISTINCT CASE WHEN coe.months_elapsed = 0 THEN coe.customer_id END) AS month_0_active_users,
    COUNT(DISTINCT CASE WHEN coe.months_elapsed = 1 THEN coe.customer_id END) AS month_1_active_users,
    COUNT(DISTINCT CASE WHEN coe.months_elapsed = 2 THEN coe.customer_id END) AS month_2_active_users,
    COUNT(DISTINCT CASE WHEN coe.months_elapsed = 3 THEN coe.customer_id END) AS month_3_active_users,
    
    ROUND(COUNT(DISTINCT CASE WHEN coe.months_elapsed = 0 THEN coe.customer_id END) * 100.0 / cs.cohort_size, 2) AS month_0_retention_pct,
    ROUND(COUNT(DISTINCT CASE WHEN coe.months_elapsed = 1 THEN coe.customer_id END) * 100.0 / cs.cohort_size, 2) AS month_1_retention_pct,
    ROUND(COUNT(DISTINCT CASE WHEN coe.months_elapsed = 2 THEN coe.customer_id END) * 100.0 / cs.cohort_size, 2) AS month_2_retention_pct,
    ROUND(COUNT(DISTINCT CASE WHEN coe.months_elapsed = 3 THEN coe.customer_id END) * 100.0 / cs.cohort_size, 2) AS month_3_retention_pct
FROM cohort_sizes cs
LEFT JOIN customer_orders_elapsed coe ON cs.cohort_month = coe.cohort_month
GROUP BY cs.cohort_month, cs.cohort_size
ORDER BY cs.cohort_month;
