import pandas as pd
from pathlib import Path

DATA_DIR = Path("data")

customers = pd.read_csv(DATA_DIR / "tb_cust.csv")
transactions = pd.read_csv(DATA_DIR / "tb_transaction.csv")
products = pd.read_csv(DATA_DIR / "tb_transaction_product.csv")
fees = pd.read_csv(DATA_DIR / "tb_transaction_fees.csv")


# ============================================================
# 1. DATASET SIZE
# ============================================================

print("\n=== DATASET SIZE ===")

print("Customers:", len(customers))
print("Transactions:", len(transactions))
print("Products:", len(products))
print("Fees:", len(fees))


# ============================================================
# 2. MISSING VALUES
# ============================================================

print("\n=== MISSING VALUES ===")

print("\nCustomers:")
print(customers.isnull().sum())

print("\nTransactions:")
print(transactions.isnull().sum())

print("\nProducts:")
print(products.isnull().sum())

print("\nFees:")
print(fees.isnull().sum())


# ============================================================
# 3. DUPLICATE
# ============================================================

print("\n=== DUPLICATES ===")

print("Customer duplicates:",
      customers["customer_id"].duplicated().sum())

print("Transaction duplicates:",
      transactions["transaction_id"].duplicated().sum())

print("Product duplicates:",
      products["transaction_product_id"].duplicated().sum())

print("Fee duplicates:",
      fees["fee_id"].duplicated().sum())


# ============================================================
# 4. CUSTOMER RANGE
# ============================================================

print("\n=== CUSTOMER RANGE ===")

print("Minimum age:", customers["age"].min())
print("Maximum age:", customers["age"].max())

print("\nCustomer segments:")
print(customers["customer_segment"].value_counts())

print("\nCities:")
print(customers["city"].value_counts())


# ============================================================
# 5. TRANSACTION CHECK
# ============================================================

print("\n=== TRANSACTION CHECK ===")

print("Transaction types:")
print(transactions["transaction_type"].value_counts())

print("\nMinimum transaction:",
      transactions["amount"].min())

print("Maximum transaction:",
      transactions["amount"].max())

print("Average transaction:",
      transactions["amount"].mean())


# ============================================================
# 6. REFERENTIAL INTEGRITY
# ============================================================

print("\n=== REFERENTIAL INTEGRITY ===")

invalid_customer = ~transactions["customer_id"].isin(
    customers["customer_id"]
)

invalid_product_transaction = ~products["transaction_id"].isin(
    transactions["transaction_id"]
)

invalid_fee_transaction = ~fees["transaction_id"].isin(
    transactions["transaction_id"]
)

print(
    "Transactions with invalid customer:",
    invalid_customer.sum()
)

print(
    "Products with invalid transaction:",
    invalid_product_transaction.sum()
)

print(
    "Fees with invalid transaction:",
    invalid_fee_transaction.sum()
)


# ============================================================
# 7. FEE VALIDATION
# ============================================================

print("\n=== FEE VALIDATION ===")

merged = transactions.merge(
    fees,
    on="transaction_id",
    how="left"
)

expected_fee = (
    merged["amount"] *
    merged["fee_percentage"] /
    100
).round(2)

fee_difference = (
    expected_fee -
    merged["fee_amount"]
).abs()

print(
    "Fee calculation errors:",
    (fee_difference > 0.01).sum()
)


# ============================================================
# 8. DATE CHECK
# ============================================================

print("\n=== DATE CHECK ===")

transactions["transaction_date"] = pd.to_datetime(
    transactions["transaction_date"]
)

print(
    "Earliest transaction:",
    transactions["transaction_date"].min()
)

print(
    "Latest transaction:",
    transactions["transaction_date"].max()
)


print("\n================================")
print("DATA QUALITY CHECK COMPLETED")
print("================================")