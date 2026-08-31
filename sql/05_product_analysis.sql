-- ============================================================
-- FINOVA DATA ANALYSIS
-- 05 - PRODUCT ANALYSIS
-- ============================================================
-- Tujuan:
-- Mengetahui produk yang paling banyak digunakan serta
-- kontribusi transaction value dan revenue setiap produk.
-- ============================================================


-- ============================================================
-- 1. PRODUCT TRANSACTION COUNT
-- ============================================================

SELECT
    product_name,
    product_category,
    COUNT(*) AS total_transaction

FROM tb_transaction_product

GROUP BY
    product_name,
    product_category

ORDER BY total_transaction DESC;


-- ============================================================
-- 2. PRODUCT PERFORMANCE
-- ============================================================

SELECT

    p.product_name,
    p.product_category,

    COUNT(t.transaction_id) AS total_transaction,

    ROUND(SUM(t.amount), 2) AS total_transaction_value,

    ROUND(SUM(f.fee_amount), 2) AS total_revenue

FROM tb_transaction_product p

JOIN tb_transaction t
    ON p.transaction_id = t.transaction_id

JOIN tb_transaction_fees f
    ON t.transaction_id = f.transaction_id

GROUP BY
    p.product_name,
    p.product_category

ORDER BY total_revenue DESC;


-- ============================================================
-- 3. TOP PRODUCT BERDASARKAN TRANSACTION
-- ============================================================

SELECT

    p.product_name,
    p.product_category,

    COUNT(t.transaction_id) AS total_transaction,

    ROUND(SUM(t.amount), 2) AS total_transaction_value,

    ROUND(SUM(f.fee_amount), 2) AS total_revenue

FROM tb_transaction_product p

JOIN tb_transaction t
    ON p.transaction_id = t.transaction_id

JOIN tb_transaction_fees f
    ON t.transaction_id = f.transaction_id

GROUP BY
    p.product_name,
    p.product_category

ORDER BY total_transaction DESC

LIMIT 10;


-- ============================================================
-- 4. TOP PRODUCT BERDASARKAN TRANSACTION VALUE
-- ============================================================

SELECT

    p.product_name,
    p.product_category,

    COUNT(t.transaction_id) AS total_transaction,

    ROUND(SUM(t.amount), 2) AS total_transaction_value,

    ROUND(SUM(f.fee_amount), 2) AS total_revenue

FROM tb_transaction_product p

JOIN tb_transaction t
    ON p.transaction_id = t.transaction_id

JOIN tb_transaction_fees f
    ON t.transaction_id = f.transaction_id

GROUP BY
    p.product_name,
    p.product_category

ORDER BY total_transaction_value DESC

LIMIT 10;


-- ============================================================
-- 5. TOP PRODUCT BERDASARKAN REVENUE
-- ============================================================

SELECT

    p.product_name,
    p.product_category,

    COUNT(t.transaction_id) AS total_transaction,

    ROUND(SUM(t.amount), 2) AS total_transaction_value,

    ROUND(SUM(f.fee_amount), 2) AS total_revenue

FROM tb_transaction_product p

JOIN tb_transaction t
    ON p.transaction_id = t.transaction_id

JOIN tb_transaction_fees f
    ON t.transaction_id = f.transaction_id

GROUP BY
    p.product_name,
    p.product_category

ORDER BY total_revenue DESC

LIMIT 10;


-- ============================================================
-- 6. PRODUCT CATEGORY PERFORMANCE
-- ============================================================

SELECT

    p.product_category,

    COUNT(t.transaction_id) AS total_transaction,

    ROUND(SUM(t.amount), 2) AS total_transaction_value,

    ROUND(SUM(f.fee_amount), 2) AS total_revenue,

    ROUND(
        SUM(f.fee_amount)
        / COUNT(t.transaction_id),
        2
    ) AS avg_revenue_per_transaction

FROM tb_transaction_product p

JOIN tb_transaction t
    ON p.transaction_id = t.transaction_id

JOIN tb_transaction_fees f
    ON t.transaction_id = f.transaction_id

GROUP BY p.product_category

ORDER BY total_revenue DESC;