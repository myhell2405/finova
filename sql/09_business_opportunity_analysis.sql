-- ============================================================
-- FINOVA ANALYTICS
-- 09_business_opportunity_analysis.sql
-- ============================================================
-- PURPOSE:
-- Mencari peluang bisnis berdasarkan customer behavior,
-- frequency, segment, dan revenue.
--
-- ANALYSIS:
-- 1. Low-frequency customers by segment
-- 2. Medium-frequency customers by segment
-- 3. High-value low-frequency customers
-- 4. Low-value high-frequency customers
-- 5. Segment revenue efficiency
-- 6. Transaction value efficiency
-- 7. Revenue per transaction by segment
-- ============================================================


-- ============================================================
-- 1. FREQUENCY DISTRIBUTION BY CUSTOMER SEGMENT
-- ============================================================

WITH customer_frequency AS (
    SELECT
        c.customer_id,
        c.customer_segment,
        COUNT(t.transaction_id) AS transaction_count
    FROM tb_cust c
    LEFT JOIN tb_transaction t
        ON c.customer_id = t.customer_id
    GROUP BY
        c.customer_id,
        c.customer_segment
)

SELECT
    customer_segment,
    CASE
        WHEN transaction_count BETWEEN 1 AND 5
            THEN 'Low Frequency'
        WHEN transaction_count BETWEEN 6 AND 20
            THEN 'Medium Frequency'
        WHEN transaction_count BETWEEN 21 AND 50
            THEN 'High Frequency'
        ELSE 'Very High Frequency'
    END AS frequency_group,
    COUNT(*) AS total_customer
FROM customer_frequency
WHERE transaction_count > 0
GROUP BY
    customer_segment,
    frequency_group
ORDER BY
    customer_segment,
    total_customer DESC;


-- ============================================================
-- 2. LOW-FREQUENCY CUSTOMERS BY SEGMENT
-- ============================================================

WITH customer_frequency AS (
    SELECT
        c.customer_id,
        c.customer_segment,
        COUNT(t.transaction_id) AS transaction_count
    FROM tb_cust c
    LEFT JOIN tb_transaction t
        ON c.customer_id = t.customer_id
    GROUP BY
        c.customer_id,
        c.customer_segment
)

SELECT
    customer_segment,
    COUNT(*) AS low_frequency_customer
FROM customer_frequency
WHERE transaction_count BETWEEN 1 AND 5
GROUP BY
    customer_segment
ORDER BY
    low_frequency_customer DESC;


-- ============================================================
-- 3. HIGH-VALUE LOW-FREQUENCY CUSTOMERS
-- ============================================================
-- Mencari customer yang transaksinya relatif sedikit tetapi
-- revenue per customer cukup tinggi.

WITH customer_value AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.customer_segment,
        COUNT(t.transaction_id) AS transaction_count,
        SUM(t.amount) AS transaction_value,
        SUM(f.fee_amount) AS total_revenue
    FROM tb_cust c
    JOIN tb_transaction t
        ON c.customer_id = t.customer_id
    JOIN tb_transaction_fees f
        ON t.transaction_id = f.transaction_id
    GROUP BY
        c.customer_id,
        c.customer_name,
        c.customer_segment
)

SELECT
    customer_id,
    customer_name,
    customer_segment,
    transaction_count,
    ROUND(transaction_value, 2) AS transaction_value,
    ROUND(total_revenue, 2) AS total_revenue
FROM customer_value
WHERE transaction_count BETWEEN 1 AND 5
ORDER BY
    total_revenue DESC
LIMIT 50;


-- ============================================================
-- 4. HIGH-FREQUENCY CUSTOMER VALUE
-- ============================================================
-- Mengetahui apakah frequency tinggi selalu berarti
-- revenue tinggi.

WITH customer_value AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.customer_segment,
        COUNT(t.transaction_id) AS transaction_count,
        SUM(f.fee_amount) AS total_revenue
    FROM tb_cust c
    JOIN tb_transaction t
        ON c.customer_id = t.customer_id
    JOIN tb_transaction_fees f
        ON t.transaction_id = f.transaction_id
    GROUP BY
        c.customer_id,
        c.customer_name,
        c.customer_segment
)

SELECT
    customer_segment,
    CASE
        WHEN transaction_count BETWEEN 21 AND 50
            THEN 'High Frequency'
        ELSE 'Very High Frequency'
    END AS frequency_group,
    COUNT(*) AS total_customer,
    ROUND(AVG(total_revenue), 2) AS avg_revenue_per_customer,
    ROUND(MIN(total_revenue), 2) AS min_revenue,
    ROUND(MAX(total_revenue), 2) AS max_revenue
FROM customer_value
WHERE transaction_count >= 21
GROUP BY
    customer_segment,
    frequency_group
ORDER BY
    customer_segment,
    avg_revenue_per_customer DESC;


-- ============================================================
-- 5. REVENUE EFFICIENCY BY CUSTOMER SEGMENT
-- ============================================================

SELECT
    c.customer_segment,
    COUNT(DISTINCT c.customer_id) AS active_customer,
    COUNT(t.transaction_id) AS total_transaction,
    ROUND(SUM(t.amount), 2) AS total_transaction_value,
    ROUND(SUM(f.fee_amount), 2) AS total_revenue,
    ROUND(
        SUM(f.fee_amount) /
        COUNT(DISTINCT c.customer_id),
        2
    ) AS revenue_per_customer,
    ROUND(
        SUM(f.fee_amount) /
        COUNT(t.transaction_id),
        2
    ) AS revenue_per_transaction
FROM tb_cust c
JOIN tb_transaction t
    ON c.customer_id = t.customer_id
JOIN tb_transaction_fees f
    ON t.transaction_id = f.transaction_id
GROUP BY
    c.customer_segment
ORDER BY
    revenue_per_customer DESC;


-- ============================================================
-- 6. TRANSACTION VALUE VS REVENUE BY SEGMENT
-- ============================================================

SELECT
    c.customer_segment,
    COUNT(t.transaction_id) AS total_transaction,
    ROUND(SUM(t.amount), 2) AS total_transaction_value,
    ROUND(SUM(f.fee_amount), 2) AS total_revenue,
    ROUND(
        SUM(f.fee_amount) /
        SUM(t.amount) * 100,
        4
    ) AS effective_fee_rate_pct
FROM tb_cust c
JOIN tb_transaction t
    ON c.customer_id = t.customer_id
JOIN tb_transaction_fees f
    ON t.transaction_id = f.transaction_id
GROUP BY
    c.customer_segment
ORDER BY
    effective_fee_rate_pct DESC;


-- ============================================================
-- 7. PRODUCT REVENUE EFFICIENCY
-- ============================================================
-- Berbeda dengan product performance sebelumnya:
-- sekarang kita melihat revenue relatif terhadap
-- transaction value.

SELECT
    p.product_name,
    p.product_category,
    COUNT(t.transaction_id) AS total_transaction,
    ROUND(SUM(t.amount), 2) AS total_transaction_value,
    ROUND(SUM(f.fee_amount), 2) AS total_revenue,
    ROUND(
        SUM(f.fee_amount) /
        SUM(t.amount) * 100,
        4
    ) AS effective_fee_rate_pct
FROM tb_transaction_product p
JOIN tb_transaction t
    ON p.transaction_id = t.transaction_id
JOIN tb_transaction_fees f
    ON t.transaction_id = f.transaction_id
GROUP BY
    p.product_name,
    p.product_category
ORDER BY
    effective_fee_rate_pct DESC;


-- ============================================================
-- 8. PRODUCT WITH HIGH TRANSACTION BUT LOW REVENUE EFFICIENCY
-- ============================================================
-- Mencari produk yang ramai digunakan tetapi fee rate relatif
-- rendah.

WITH product_performance AS (
    SELECT
        p.product_name,
        p.product_category,
        COUNT(t.transaction_id) AS total_transaction,
        SUM(t.amount) AS transaction_value,
        SUM(f.fee_amount) AS total_revenue,
        SUM(f.fee_amount) /
            SUM(t.amount) * 100 AS effective_fee_rate_pct
    FROM tb_transaction_product p
    JOIN tb_transaction t
        ON p.transaction_id = t.transaction_id
    JOIN tb_transaction_fees f
        ON t.transaction_id = f.transaction_id
    GROUP BY
        p.product_name,
        p.product_category
)

SELECT
    product_name,
    product_category,
    total_transaction,
    ROUND(transaction_value, 2) AS transaction_value,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(effective_fee_rate_pct, 4) AS effective_fee_rate_pct
FROM product_performance
ORDER BY
    total_transaction DESC,
    effective_fee_rate_pct ASC;


-- ============================================================
-- 9. PRODUCT WITH HIGH REVENUE EFFICIENCY
-- ============================================================

WITH product_performance AS (
    SELECT
        p.product_name,
        p.product_category,
        COUNT(t.transaction_id) AS total_transaction,
        SUM(t.amount) AS transaction_value,
        SUM(f.fee_amount) AS total_revenue,
        SUM(f.fee_amount) /
            SUM(t.amount) * 100 AS effective_fee_rate_pct
    FROM tb_transaction_product p
    JOIN tb_transaction t
        ON p.transaction_id = t.transaction_id
    JOIN tb_transaction_fees f
        ON t.transaction_id = f.transaction_id
    GROUP BY
        p.product_name,
        p.product_category
)

SELECT
    product_name,
    product_category,
    total_transaction,
    ROUND(transaction_value, 2) AS transaction_value,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(effective_fee_rate_pct, 4) AS effective_fee_rate_pct
FROM product_performance
ORDER BY
    effective_fee_rate_pct DESC;


-- ============================================================
-- 10. SEGMENT + PRODUCT REVENUE OPPORTUNITY
-- ============================================================
-- Menggabungkan customer segment dan product untuk menemukan
-- kombinasi yang memiliki revenue tinggi.

SELECT
    c.customer_segment,
    p.product_category,
    COUNT(t.transaction_id) AS total_transaction,
    ROUND(SUM(t.amount), 2) AS total_transaction_value,
    ROUND(SUM(f.fee_amount), 2) AS total_revenue,
    ROUND(
        SUM(f.fee_amount) /
        COUNT(t.transaction_id),
        2
    ) AS revenue_per_transaction
FROM tb_cust c
JOIN tb_transaction t
    ON c.customer_id = t.customer_id
JOIN tb_transaction_product p
    ON t.transaction_id = p.transaction_id
JOIN tb_transaction_fees f
    ON t.transaction_id = f.transaction_id
GROUP BY
    c.customer_segment,
    p.product_category
ORDER BY
    total_revenue DESC;