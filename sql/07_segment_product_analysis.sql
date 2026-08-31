-- ============================================================
-- FINOVA ANALYTICS
-- 07_segment_product_analysis.sql
-- ============================================================
-- PURPOSE:
-- Menganalisis hubungan antara customer segment dan product.
--
-- ANALYSIS:
-- 1. Segment x Product Transaction
-- 2. Segment x Product Transaction Value
-- 3. Segment x Product Revenue
-- 4. Product preference berdasarkan segment
-- 5. Revenue contribution product dalam masing-masing segment
-- ============================================================


-- ============================================================
-- 1. TRANSACTION BY CUSTOMER SEGMENT AND PRODUCT
-- ============================================================

SELECT
    c.customer_segment,
    p.product_name,
    p.product_category,
    COUNT(t.transaction_id) AS total_transaction
FROM tb_cust c
JOIN tb_transaction t
    ON c.customer_id = t.customer_id
JOIN tb_transaction_product p
    ON t.transaction_id = p.transaction_id
GROUP BY
    c.customer_segment,
    p.product_name,
    p.product_category
ORDER BY
    c.customer_segment,
    total_transaction DESC;


-- ============================================================
-- 2. TRANSACTION VALUE BY SEGMENT AND PRODUCT
-- ============================================================

SELECT
    c.customer_segment,
    p.product_name,
    p.product_category,
    COUNT(t.transaction_id) AS total_transaction,
    ROUND(SUM(t.amount), 2) AS total_transaction_value
FROM tb_cust c
JOIN tb_transaction t
    ON c.customer_id = t.customer_id
JOIN tb_transaction_product p
    ON t.transaction_id = p.transaction_id
GROUP BY
    c.customer_segment,
    p.product_name,
    p.product_category
ORDER BY
    c.customer_segment,
    total_transaction_value DESC;


-- ============================================================
-- 3. REVENUE BY SEGMENT AND PRODUCT
-- ============================================================

SELECT
    c.customer_segment,
    p.product_name,
    p.product_category,
    COUNT(t.transaction_id) AS total_transaction,
    ROUND(SUM(t.amount), 2) AS total_transaction_value,
    ROUND(SUM(f.fee_amount), 2) AS total_revenue
FROM tb_cust c
JOIN tb_transaction t
    ON c.customer_id = t.customer_id
JOIN tb_transaction_product p
    ON t.transaction_id = p.transaction_id
JOIN tb_transaction_fees f
    ON t.transaction_id = f.transaction_id
GROUP BY
    c.customer_segment,
    p.product_name,
    p.product_category
ORDER BY
    c.customer_segment,
    total_revenue DESC;


-- ============================================================
-- 4. TOP 5 PRODUCTS FOR EACH CUSTOMER SEGMENT
-- ============================================================
-- Menggunakan ranking agar kita mengetahui produk unggulan
-- masing-masing segment.

WITH product_segment AS (
    SELECT
        c.customer_segment,
        p.product_name,
        p.product_category,
        COUNT(t.transaction_id) AS total_transaction
    FROM tb_cust c
    JOIN tb_transaction t
        ON c.customer_id = t.customer_id
    JOIN tb_transaction_product p
        ON t.transaction_id = p.transaction_id
    GROUP BY
        c.customer_segment,
        p.product_name,
        p.product_category
),

ranked_product AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY customer_segment
            ORDER BY total_transaction DESC
        ) AS product_rank
    FROM product_segment
)

SELECT
    customer_segment,
    product_rank,
    product_name,
    product_category,
    total_transaction
FROM ranked_product
WHERE product_rank <= 5
ORDER BY
    customer_segment,
    product_rank;


-- ============================================================
-- 5. TOP 5 PRODUCTS BY REVENUE FOR EACH SEGMENT
-- ============================================================

WITH segment_product_revenue AS (
    SELECT
        c.customer_segment,
        p.product_name,
        p.product_category,
        ROUND(SUM(f.fee_amount), 2) AS total_revenue
    FROM tb_cust c
    JOIN tb_transaction t
        ON c.customer_id = t.customer_id
    JOIN tb_transaction_product p
        ON t.transaction_id = p.transaction_id
    JOIN tb_transaction_fees f
        ON t.transaction_id = f.transaction_id
    GROUP BY
        c.customer_segment,
        p.product_name,
        p.product_category
),

ranked_revenue AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY customer_segment
            ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM segment_product_revenue
)

SELECT
    customer_segment,
    revenue_rank,
    product_name,
    product_category,
    total_revenue
FROM ranked_revenue
WHERE revenue_rank <= 5
ORDER BY
    customer_segment,
    revenue_rank;


-- ============================================================
-- 6. REVENUE CONTRIBUTION OF PRODUCTS WITHIN EACH SEGMENT
-- ============================================================

WITH segment_product AS (
    SELECT
        c.customer_segment,
        p.product_name,
        p.product_category,
        SUM(f.fee_amount) AS total_revenue
    FROM tb_cust c
    JOIN tb_transaction t
        ON c.customer_id = t.customer_id
    JOIN tb_transaction_product p
        ON t.transaction_id = p.transaction_id
    JOIN tb_transaction_fees f
        ON t.transaction_id = f.transaction_id
    GROUP BY
        c.customer_segment,
        p.product_name,
        p.product_category
),

segment_total AS (
    SELECT
        customer_segment,
        SUM(total_revenue) AS segment_revenue
    FROM segment_product
    GROUP BY customer_segment
)

SELECT
    sp.customer_segment,
    sp.product_name,
    sp.product_category,
    ROUND(sp.total_revenue, 2) AS total_revenue,
    ROUND(
        sp.total_revenue / st.segment_revenue * 100,
        2
    ) AS revenue_contribution_pct
FROM segment_product sp
JOIN segment_total st
    ON sp.customer_segment = st.customer_segment
ORDER BY
    sp.customer_segment,
    revenue_contribution_pct DESC;