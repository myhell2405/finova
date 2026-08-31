-- ============================================================
-- FINOVA DATA ANALYSIS
-- 01 - DATA VALIDATION
-- ============================================================
-- Tujuan:
-- Memastikan kualitas dan konsistensi data sebelum analisis.
-- ============================================================


-- ============================================================
-- 1. JUMLAH DATA PADA SETIAP TABEL
-- ============================================================

SELECT 'tb_cust' AS table_name, COUNT(*) AS total_rows
FROM tb_cust

UNION ALL

SELECT 'tb_transaction', COUNT(*)
FROM tb_transaction

UNION ALL

SELECT 'tb_transaction_product', COUNT(*)
FROM tb_transaction_product

UNION ALL

SELECT 'tb_transaction_fees', COUNT(*)
FROM tb_transaction_fees;


-- ============================================================
-- 2. CEK CUSTOMER ID DUPLIKAT
-- ============================================================

SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM tb_cust
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 3. CEK TRANSACTION ID DUPLIKAT
-- ============================================================

SELECT
    transaction_id,
    COUNT(*) AS duplicate_count
FROM tb_transaction
GROUP BY transaction_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 4. CEK TRANSACTION YANG TIDAK MEMILIKI CUSTOMER
-- ============================================================

SELECT
    COUNT(*) AS orphan_transaction
FROM tb_transaction t
LEFT JOIN tb_cust c
    ON t.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- ============================================================
-- 5. CEK PRODUCT YANG TIDAK MEMILIKI TRANSACTION
-- ============================================================

SELECT
    COUNT(*) AS orphan_product
FROM tb_transaction_product p
LEFT JOIN tb_transaction t
    ON p.transaction_id = t.transaction_id
WHERE t.transaction_id IS NULL;


-- ============================================================
-- 6. CEK FEE YANG TIDAK MEMILIKI TRANSACTION
-- ============================================================

SELECT
    COUNT(*) AS orphan_fee
FROM tb_transaction_fees f
LEFT JOIN tb_transaction t
    ON f.transaction_id = t.transaction_id
WHERE t.transaction_id IS NULL;


-- ============================================================
-- 7. CEK NULL PADA DATA CUSTOMER
-- ============================================================

SELECT
    SUM(customer_id IS NULL) AS null_customer_id,
    SUM(customer_name IS NULL) AS null_customer_name,
    SUM(customer_segment IS NULL) AS null_customer_segment
FROM tb_cust;


-- ============================================================
-- 8. CEK NULL PADA DATA TRANSACTION
-- ============================================================

SELECT
    SUM(transaction_id IS NULL) AS null_transaction_id,
    SUM(customer_id IS NULL) AS null_customer_id,
    SUM(amount IS NULL) AS null_amount
FROM tb_transaction;


-- ============================================================
-- 9. CEK NILAI TRANSACTION NEGATIF / NOL
-- ============================================================

SELECT
    COUNT(*) AS invalid_amount
FROM tb_transaction
WHERE amount <= 0;


-- ============================================================
-- 10. CEK FEE NEGATIF / NOL
-- ============================================================

SELECT
    COUNT(*) AS invalid_fee
FROM tb_transaction_fees
WHERE fee_amount <= 0;


-- ============================================================
-- 11. CEK SEGMENT CUSTOMER
-- ============================================================

SELECT
    customer_segment,
    COUNT(*) AS total_customer
FROM tb_cust
GROUP BY customer_segment
ORDER BY total_customer DESC;


-- ============================================================
-- 12. CEK RANGE TRANSACTION
-- ============================================================

SELECT
    COUNT(*) AS total_transaction,
    ROUND(AVG(amount), 2) AS avg_transaction,
    ROUND(MIN(amount), 2) AS min_transaction,
    ROUND(MAX(amount), 2) AS max_transaction
FROM tb_transaction;


-- ============================================================
-- 13. CEK RANGE FEE
-- ============================================================

SELECT
    COUNT(*) AS total_fee,
    ROUND(AVG(fee_amount), 2) AS avg_fee,
    ROUND(MIN(fee_amount), 2) AS min_fee,
    ROUND(MAX(fee_amount), 2) AS max_fee
FROM tb_transaction_fees;