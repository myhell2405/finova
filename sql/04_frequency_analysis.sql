-- ============================================================
-- FINOVA DATA ANALYSIS
-- 04 - FREQUENCY ANALYSIS
-- ============================================================
-- Tujuan:
-- Mengelompokkan customer berdasarkan frekuensi transaksi
-- untuk melihat hubungan antara frequency, transaction value,
-- dan revenue.
-- ============================================================


-- ============================================================
-- 1. CUSTOMER TRANSACTION FREQUENCY
-- ============================================================

SELECT
    customer_id,
    COUNT(transaction_id) AS transaction_count
FROM tb_transaction
GROUP BY customer_id
ORDER BY transaction_count DESC;


-- ============================================================
-- 2. FREQUENCY DISTRIBUTION
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
-- 3. OVERALL FREQUENCY METRICS
-- ============================================================

SELECT
    COUNT(DISTINCT customer_id) AS active_customer,
    ROUND(AVG(transaction_count), 2) AS avg_transaction,
    MIN(transaction_count) AS min_transaction,
    MAX(transaction_count) AS max_transaction

FROM (
    SELECT
        customer_id,
        COUNT(transaction_id) AS transaction_count
    FROM tb_transaction
    GROUP BY customer_id
) AS customer_activity;


-- ============================================================
-- 4. CUSTOMER FREQUENCY GROUP
-- ============================================================

WITH customer_frequency AS (

    SELECT
        customer_id,
        COUNT(transaction_id) AS transaction_count
    FROM tb_transaction
    GROUP BY customer_id

)

SELECT
    CASE
        WHEN transaction_count <= 5
            THEN 'Low Frequency'

        WHEN transaction_count <= 20
            THEN 'Medium Frequency'

        WHEN transaction_count <= 50
            THEN 'High Frequency'

        ELSE 'Very High Frequency'
    END AS frequency_group,

    COUNT(*) AS total_customer

FROM customer_frequency

GROUP BY frequency_group

ORDER BY
    CASE frequency_group
        WHEN 'Low Frequency' THEN 1
        WHEN 'Medium Frequency' THEN 2
        WHEN 'High Frequency' THEN 3
        WHEN 'Very High Frequency' THEN 4
    END;


-- ============================================================
-- 5. FREQUENCY VS BUSINESS VALUE
-- ============================================================

WITH customer_frequency AS (

    SELECT
        customer_id,
        COUNT(transaction_id) AS transaction_count
    FROM tb_transaction
    GROUP BY customer_id

)

SELECT

    CASE
        WHEN cf.transaction_count <= 5
            THEN 'Low Frequency'

        WHEN cf.transaction_count <= 20
            THEN 'Medium Frequency'

        WHEN cf.transaction_count <= 50
            THEN 'High Frequency'

        ELSE 'Very High Frequency'
    END AS frequency_group,

    COUNT(DISTINCT c.customer_id) AS total_customer,

    COUNT(t.transaction_id) AS total_transaction,

    ROUND(SUM(t.amount), 2) AS total_transaction_value,

    ROUND(SUM(f.fee_amount), 2) AS total_revenue,

    ROUND(
        SUM(f.fee_amount)
        / COUNT(DISTINCT c.customer_id),
        2
    ) AS avg_revenue_per_customer

FROM customer_frequency cf

JOIN tb_cust c
    ON cf.customer_id = c.customer_id

JOIN tb_transaction t
    ON c.customer_id = t.customer_id

JOIN tb_transaction_fees f
    ON t.transaction_id = f.transaction_id

GROUP BY frequency_group

ORDER BY
    CASE frequency_group
        WHEN 'Low Frequency' THEN 1
        WHEN 'Medium Frequency' THEN 2
        WHEN 'High Frequency' THEN 3
        WHEN 'Very High Frequency' THEN 4
    END;