-- ============================================================
-- FINOVA DATA ANALYSIS
-- 02 - CUSTOMER ANALYSIS
-- ============================================================
-- Tujuan:
-- Memahami customer base, segmentasi, active/inactive customer,
-- serta distribusi customer berdasarkan segment.
-- ============================================================


-- ============================================================
-- 1. TOTAL CUSTOMER
-- ============================================================

SELECT
    COUNT(DISTINCT customer_id) AS total_customer
FROM tb_cust;


-- ============================================================
-- 2. CUSTOMER BERDASARKAN SEGMENT
-- ============================================================

SELECT
    customer_segment,
    COUNT(DISTINCT customer_id) AS total_customer
FROM tb_cust
GROUP BY customer_segment
ORDER BY total_customer DESC;


-- ============================================================
-- 3. CUSTOMER ACTIVE VS INACTIVE
-- ============================================================

SELECT
    COUNT(DISTINCT c.customer_id) AS total_customer,
    COUNT(DISTINCT t.customer_id) AS active_customer,
    COUNT(DISTINCT c.customer_id)
        - COUNT(DISTINCT t.customer_id) AS inactive_customer
FROM tb_cust c
LEFT JOIN tb_transaction t
    ON c.customer_id = t.customer_id;


-- ============================================================
-- 4. ACTIVE VS INACTIVE PER SEGMENT
-- ============================================================

SELECT
    c.customer_segment,

    COUNT(DISTINCT c.customer_id) AS total_customer,

    COUNT(DISTINCT t.customer_id) AS active_customer,

    COUNT(DISTINCT c.customer_id)
        - COUNT(DISTINCT t.customer_id) AS inactive_customer,

    ROUND(
        COUNT(DISTINCT t.customer_id)
        / COUNT(DISTINCT c.customer_id) * 100,
        2
    ) AS activation_rate

FROM tb_cust c
LEFT JOIN tb_transaction t
    ON c.customer_id = t.customer_id

GROUP BY c.customer_segment
ORDER BY activation_rate DESC;


-- ============================================================
-- 5. CUSTOMER TANPA TRANSACTION
-- ============================================================

SELECT
    c.customer_segment,
    COUNT(c.customer_id) AS inactive_customer
FROM tb_cust c
LEFT JOIN tb_transaction t
    ON c.customer_id = t.customer_id
WHERE t.transaction_id IS NULL
GROUP BY c.customer_segment
ORDER BY inactive_customer ASC;


-- ============================================================
-- 6. DISTRIBUSI CUSTOMER BERDASARKAN JUMLAH TRANSACTION
-- ============================================================

SELECT
    transaction_count,
    COUNT(*) AS total_customer

FROM (
    SELECT
        customer_id,
        COUNT(transaction_id) AS transaction_count
    FROM tb_transaction
    GROUP BY customer_id
) AS customer_activity

GROUP BY transaction_count
ORDER BY transaction_count ASC;


-- ============================================================
-- 7. CUSTOMER DENGAN TRANSACTION TERBANYAK
-- ============================================================

SELECT
    c.customer_id,
    c.customer_name,
    c.customer_segment,
    COUNT(t.transaction_id) AS total_transaction
FROM tb_cust c
JOIN tb_transaction t
    ON c.customer_id = t.customer_id
GROUP BY
    c.customer_id,
    c.customer_name,
    c.customer_segment
ORDER BY total_transaction DESC
LIMIT 10;