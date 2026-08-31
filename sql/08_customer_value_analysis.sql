-- ============================================================
-- FINOVA ANALYTICS
-- 08_customer_value_analysis.sql
-- ============================================================
-- PURPOSE:
-- Menganalisis customer value dan revenue concentration.
--
-- ANALYSIS:
-- 1. Customer revenue distribution
-- 2. Customer value by segment
-- 3. Top 1% customers
-- 4. Top 5% customers
-- 5. Top 10% customers
-- 6. Revenue concentration
-- 7. Average customer value
-- ============================================================


-- ============================================================
-- 1. CUSTOMER VALUE DISTRIBUTION BY SEGMENT
-- ============================================================

SELECT
    c.customer_segment,
    COUNT(DISTINCT c.customer_id) AS total_customer,
    ROUND(SUM(f.fee_amount), 2) AS total_revenue,
    ROUND(
        SUM(f.fee_amount) / COUNT(DISTINCT c.customer_id),
        2
    ) AS avg_revenue_per_customer,
    ROUND(
        AVG(t.amount),
        2
    ) AS avg_transaction_value
FROM tb_cust c
JOIN tb_transaction t
    ON c.customer_id = t.customer_id
JOIN tb_transaction_fees f
    ON t.transaction_id = f.transaction_id
GROUP BY
    c.customer_segment
ORDER BY
    avg_revenue_per_customer DESC;


-- ============================================================
-- 2. CUSTOMER REVENUE RANKING
-- ============================================================

WITH customer_value AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.customer_segment,
        COUNT(t.transaction_id) AS total_transaction,
        ROUND(SUM(t.amount), 2) AS total_transaction_value,
        ROUND(SUM(f.fee_amount), 2) AS total_revenue
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
    *,
    RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS revenue_rank
FROM customer_value
ORDER BY
    revenue_rank;


-- ============================================================
-- 3. TOP 1% CUSTOMER REVENUE CONTRIBUTION
-- ============================================================

WITH customer_value AS (
    SELECT
        c.customer_id,
        SUM(f.fee_amount) AS total_revenue
    FROM tb_cust c
    JOIN tb_transaction t
        ON c.customer_id = t.customer_id
    JOIN tb_transaction_fees f
        ON t.transaction_id = f.transaction_id
    GROUP BY
        c.customer_id
),

ranked_customer AS (
    SELECT
        *,
        NTILE(100) OVER (
            ORDER BY total_revenue DESC
        ) AS percentile_group
    FROM customer_value
),

summary AS (
    SELECT
        SUM(total_revenue) AS company_revenue,
        SUM(
            CASE
                WHEN percentile_group = 1
                THEN total_revenue
                ELSE 0
            END
        ) AS top_1_percent_revenue
    FROM ranked_customer
)

SELECT
    ROUND(company_revenue, 2) AS company_revenue,
    ROUND(top_1_percent_revenue, 2) AS top_1_percent_revenue,
    ROUND(
        top_1_percent_revenue / company_revenue * 100,
        2
    ) AS top_1_percent_revenue_share
FROM summary;


-- ============================================================
-- 4. TOP 5% CUSTOMER REVENUE CONTRIBUTION
-- ============================================================

WITH customer_value AS (
    SELECT
        c.customer_id,
        SUM(f.fee_amount) AS total_revenue
    FROM tb_cust c
    JOIN tb_transaction t
        ON c.customer_id = t.customer_id
    JOIN tb_transaction_fees f
        ON t.transaction_id = f.transaction_id
    GROUP BY
        c.customer_id
),

ranked_customer AS (
    SELECT
        *,
        NTILE(20) OVER (
            ORDER BY total_revenue DESC
        ) AS percentile_group
    FROM customer_value
),

summary AS (
    SELECT
        SUM(total_revenue) AS company_revenue,
        SUM(
            CASE
                WHEN percentile_group = 1
                THEN total_revenue
                ELSE 0
            END
        ) AS top_5_percent_revenue
    FROM ranked_customer
)

SELECT
    ROUND(company_revenue, 2) AS company_revenue,
    ROUND(top_5_percent_revenue, 2) AS top_5_percent_revenue,
    ROUND(
        top_5_percent_revenue / company_revenue * 100,
        2
    ) AS top_5_percent_revenue_share
FROM summary;


-- ============================================================
-- 5. TOP 10% CUSTOMER REVENUE CONTRIBUTION
-- ============================================================

WITH customer_value AS (
    SELECT
        c.customer_id,
        SUM(f.fee_amount) AS total_revenue
    FROM tb_cust c
    JOIN tb_transaction t
        ON c.customer_id = t.customer_id
    JOIN tb_transaction_fees f
        ON t.transaction_id = f.transaction_id
    GROUP BY
        c.customer_id
),

ranked_customer AS (
    SELECT
        *,
        NTILE(10) OVER (
            ORDER BY total_revenue DESC
        ) AS decile_group
    FROM customer_value
),

summary AS (
    SELECT
        SUM(total_revenue) AS company_revenue,
        SUM(
            CASE
                WHEN decile_group = 1
                THEN total_revenue
                ELSE 0
            END
        ) AS top_10_percent_revenue
    FROM ranked_customer
)

SELECT
    ROUND(company_revenue, 2) AS company_revenue,
    ROUND(top_10_percent_revenue, 2) AS top_10_percent_revenue,
    ROUND(
        top_10_percent_revenue / company_revenue * 100,
        2
    ) AS top_10_percent_revenue_share
FROM summary;


-- ============================================================
-- 6. CUSTOMER REVENUE DISTRIBUTION
-- ============================================================

WITH customer_value AS (
    SELECT
        c.customer_id,
        c.customer_segment,
        SUM(f.fee_amount) AS total_revenue
    FROM tb_cust c
    JOIN tb_transaction t
        ON c.customer_id = t.customer_id
    JOIN tb_transaction_fees f
        ON t.transaction_id = f.transaction_id
    GROUP BY
        c.customer_id,
        c.customer_segment
)

SELECT
    customer_segment,
    COUNT(*) AS active_customer,
    ROUND(MIN(total_revenue), 2) AS min_customer_revenue,
    ROUND(AVG(total_revenue), 2) AS avg_customer_revenue,
    ROUND(MAX(total_revenue), 2) AS max_customer_revenue
FROM customer_value
GROUP BY
    customer_segment
ORDER BY
    avg_customer_revenue DESC;