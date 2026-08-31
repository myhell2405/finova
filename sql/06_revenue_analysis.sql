-- ============================================================
-- FINOVA DATA ANALYSIS
-- 06 - REVENUE ANALYSIS
-- ============================================================
-- Tujuan:
-- Menganalisis revenue Finova berdasarkan transaction,
-- customer segment, dan periode waktu.
-- ============================================================


-- ============================================================
-- 1. OVERALL REVENUE
-- ============================================================

SELECT
    COUNT(t.transaction_id) AS total_transaction,

    ROUND(SUM(t.amount), 2) AS total_transaction_value,

    ROUND(SUM(f.fee_amount), 2) AS total_revenue,

    ROUND(
        SUM(f.fee_amount)
        / COUNT(t.transaction_id),
        2
    ) AS avg_revenue_per_transaction

FROM tb_transaction t

JOIN tb_transaction_fees f
    ON t.transaction_id = f.transaction_id;


-- ============================================================
-- 2. REVENUE PER CUSTOMER SEGMENT
-- ============================================================

SELECT

    c.customer_segment,

    COUNT(t.transaction_id) AS total_transaction,

    ROUND(SUM(t.amount), 2) AS total_transaction_value,

    ROUND(SUM(f.fee_amount), 2) AS total_revenue,

    ROUND(
        SUM(f.fee_amount)
        / COUNT(DISTINCT c.customer_id),
        2
    ) AS avg_revenue_per_customer

FROM tb_cust c

JOIN tb_transaction t
    ON c.customer_id = t.customer_id

JOIN tb_transaction_fees f
    ON t.transaction_id = f.transaction_id

GROUP BY c.customer_segment

ORDER BY total_revenue DESC;


-- ============================================================
-- 3. CUSTOMER REVENUE CONTRIBUTION
-- ============================================================

SELECT

    c.customer_id,
    c.customer_name,
    c.customer_segment,

    COUNT(t.transaction_id) AS total_transaction,

    ROUND(SUM(t.amount), 2) AS total_transaction_value,

    ROUND(SUM(f.fee_amount), 2) AS total_revenue,

    ROUND(
        SUM(f.fee_amount)
        / COUNT(t.transaction_id),
        2
    ) AS avg_revenue_per_transaction

FROM tb_cust c

JOIN tb_transaction t
    ON c.customer_id = t.customer_id

JOIN tb_transaction_fees f
    ON t.transaction_id = f.transaction_id

GROUP BY
    c.customer_id,
    c.customer_name,
    c.customer_segment

ORDER BY total_revenue DESC

LIMIT 10;


-- ============================================================
-- 4. MONTHLY REVENUE
-- ============================================================

SELECT

    DATE_FORMAT(t.transaction_date, '%Y-%m') AS transaction_month,

    COUNT(t.transaction_id) AS total_transaction,

    ROUND(SUM(t.amount), 2) AS total_transaction_value,

    ROUND(SUM(f.fee_amount), 2) AS total_revenue

FROM tb_transaction t

JOIN tb_transaction_fees f
    ON t.transaction_id = f.transaction_id

GROUP BY transaction_month

ORDER BY transaction_month ASC;


-- ============================================================
-- 5. MONTHLY REVENUE GROWTH
-- ============================================================

WITH monthly_revenue AS (

    SELECT

        DATE_FORMAT(t.transaction_date, '%Y-%m') AS transaction_month,

        ROUND(SUM(f.fee_amount), 2) AS total_revenue

    FROM tb_transaction t

    JOIN tb_transaction_fees f
        ON t.transaction_id = f.transaction_id

    GROUP BY transaction_month

)

SELECT

    transaction_month,

    total_revenue,

    LAG(total_revenue)
        OVER (
            ORDER BY transaction_month
        ) AS previous_month_revenue,

    ROUND(
        (
            total_revenue
            - LAG(total_revenue)
                OVER (
                    ORDER BY transaction_month
                )
        )
        /
        LAG(total_revenue)
            OVER (
                ORDER BY transaction_month
            )
        * 100,
        2
    ) AS revenue_growth_pct

FROM monthly_revenue

ORDER BY transaction_month ASC;


-- ============================================================
-- 6. REVENUE PER TRANSACTION
-- ============================================================

SELECT

    ROUND(
        SUM(f.fee_amount)
        / COUNT(t.transaction_id),
        2
    ) AS avg_revenue_per_transaction

FROM tb_transaction t

JOIN tb_transaction_fees f
    ON t.transaction_id = f.transaction_id;


-- ============================================================
-- 7. REVENUE CONTRIBUTION BY PRODUCT CATEGORY
-- ============================================================

SELECT

    p.product_category,

    COUNT(t.transaction_id) AS total_transaction,

    ROUND(SUM(t.amount), 2) AS total_transaction_value,

    ROUND(SUM(f.fee_amount), 2) AS total_revenue

FROM tb_transaction_product p

JOIN tb_transaction t
    ON p.transaction_id = t.transaction_id

JOIN tb_transaction_fees f
    ON t.transaction_id = f.transaction_id

GROUP BY p.product_category

ORDER BY total_revenue DESC;