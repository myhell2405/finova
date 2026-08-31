-- ============================================================
-- FINOVA DATA ANALYSIS
-- 03 - TRANSACTION ANALYSIS
-- ============================================================
-- Tujuan:
-- Menganalisis volume transaksi, nilai transaksi,
-- dan pola transaksi customer.
-- ============================================================


-- ============================================================
-- 1. OVERALL TRANSACTION METRICS
-- ============================================================

SELECT
    COUNT(*) AS total_transaction,
    ROUND(SUM(amount), 2) AS total_transaction_value,
    ROUND(AVG(amount), 2) AS avg_transaction_value,
    ROUND(MIN(amount), 2) AS min_transaction_value,
    ROUND(MAX(amount), 2) AS max_transaction_value
FROM tb_transaction;


-- ============================================================
-- 2. TRANSACTION BERDASARKAN SEGMENT CUSTOMER
-- ============================================================

SELECT
    c.customer_segment,

    COUNT(t.transaction_id) AS total_transaction,

    ROUND(SUM(t.amount), 2) AS total_transaction_value,

    ROUND(AVG(t.amount), 2) AS avg_transaction_value

FROM tb_cust c
JOIN tb_transaction t
    ON c.customer_id = t.customer_id

GROUP BY c.customer_segment
ORDER BY total_transaction DESC;


-- ============================================================
-- 3. TRANSACTION VALUE PER CUSTOMER
-- ============================================================

SELECT
    c.customer_id,
    c.customer_name,
    c.customer_segment,

    COUNT(t.transaction_id) AS total_transaction,

    ROUND(SUM(t.amount), 2) AS total_transaction_value,

    ROUND(
        SUM(t.amount) / COUNT(t.transaction_id),
        2
    ) AS avg_transaction_value

FROM tb_cust c
JOIN tb_transaction t
    ON c.customer_id = t.customer_id

GROUP BY
    c.customer_id,
    c.customer_name,
    c.customer_segment

ORDER BY total_transaction_value DESC
LIMIT 10;


-- ============================================================
-- 4. CUSTOMER DENGAN TRANSACTION VALUE TERENDAH
-- ============================================================

SELECT
    c.customer_id,
    c.customer_name,
    c.customer_segment,

    COUNT(t.transaction_id) AS total_transaction,

    ROUND(SUM(t.amount), 2) AS total_transaction_value

FROM tb_cust c
JOIN tb_transaction t
    ON c.customer_id = t.customer_id

GROUP BY
    c.customer_id,
    c.customer_name,
    c.customer_segment

ORDER BY total_transaction_value ASC
LIMIT 10;


-- ============================================================
-- 5. DISTRIBUSI TRANSACTION VALUE
-- ============================================================

SELECT
    CASE
        WHEN amount < 100000 THEN 'Low Value'
        WHEN amount < 500000 THEN 'Medium Value'
        WHEN amount < 1000000 THEN 'High Value'
        ELSE 'Very High Value'
    END AS transaction_value_group,

    COUNT(*) AS total_transaction,

    ROUND(SUM(amount), 2) AS total_transaction_value,

    ROUND(AVG(amount), 2) AS avg_transaction_value

FROM tb_transaction

GROUP BY transaction_value_group
ORDER BY total_transaction_value DESC;