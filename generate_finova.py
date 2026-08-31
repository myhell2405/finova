import numpy as np
import pandas as pd
from pathlib import Path

# ============================================================
# CONFIG
# ============================================================

np.random.seed(42)

N_CUSTOMERS = 10_000
N_TRANSACTIONS = 200_000

START_DATE = "2025-01-01"
END_DATE = "2026-06-30"

OUTPUT_DIR = Path("data")
OUTPUT_DIR.mkdir(exist_ok=True)


# ============================================================
# CUSTOMER DATA
# ============================================================

segments = [
    "High School Student",
    "College Student",
    "Office Worker"
]

cities = [
    "Jakarta",
    "Bandung",
    "Surabaya",
    "Medan",
    "Padang",
    "Pekanbaru",
    "Palembang",
    "Semarang",
    "Yogyakarta",
    "Makassar"
]

first_names = [
    "Andi", "Budi", "Citra", "Dina", "Eka",
    "Fajar", "Gita", "Hadi", "Intan", "Joko",
    "Karin", "Lina", "Maya", "Nanda", "Oki",
    "Putri", "Rian", "Salsa", "Tio", "Vina"
]

last_names = [
    "Pratama", "Saputra", "Wijaya", "Permata",
    "Nugraha", "Ramadhan", "Sari", "Putra",
    "Kurniawan", "Lestari"
]

customer_id = np.arange(1, N_CUSTOMERS + 1)

customer_segment = np.random.choice(
    segments,
    size=N_CUSTOMERS,
    p=[0.25, 0.35, 0.40]
)

age = []

for segment in customer_segment:

    if segment == "High School Student":
        age.append(np.random.randint(15, 19))

    elif segment == "College Student":
        age.append(np.random.randint(18, 25))

    else:
        age.append(np.random.randint(22, 36))

age = np.array(age)

customer_name = [
    f"{np.random.choice(first_names)} {np.random.choice(last_names)}"
    for _ in range(N_CUSTOMERS)
]

city = np.random.choice(
    cities,
    size=N_CUSTOMERS,
    p=[
        0.20,
        0.10,
        0.10,
        0.08,
        0.06,
        0.06,
        0.08,
        0.08,
        0.12,
        0.12
    ]
)

registration_date = pd.to_datetime(
    np.random.choice(
        pd.date_range(
            START_DATE,
            END_DATE
        ),
        size=N_CUSTOMERS
    )
)

customers = pd.DataFrame({
    "customer_id": customer_id,
    "customer_name": customer_name,
    "age": age,
    "customer_segment": customer_segment,
    "city": city,
    "registration_date": registration_date
})

customers.to_csv(
    OUTPUT_DIR / "tb_cust.csv",
    index=False
)


# ============================================================
# TRANSACTION DATA
# ============================================================

transaction_ids = np.arange(
    1,
    N_TRANSACTIONS + 1
)

# Customer activity probability
customer_weights = np.random.exponential(
    scale=1.0,
    size=N_CUSTOMERS
)

customer_weights = (
    customer_weights /
    customer_weights.sum()
)

transaction_customer = np.random.choice(
    customer_id,
    size=N_TRANSACTIONS,
    p=customer_weights
)

transaction_dates = pd.to_datetime(
    np.random.choice(
        pd.date_range(
            START_DATE,
            END_DATE,
            freq="h"
        ),
        size=N_TRANSACTIONS
    )
)

transaction_type = np.random.choice(
    [
        "Bank Transfer",
        "Shopping Payment"
    ],
    size=N_TRANSACTIONS,
    p=[0.40, 0.60]
)

amounts = []

for t in transaction_type:

    if t == "Bank Transfer":
        amount = np.random.lognormal(
            mean=np.log(350_000),
            sigma=0.8
        )

    else:
        amount = np.random.lognormal(
            mean=np.log(150_000),
            sigma=0.7
        )

    amounts.append(amount)

amounts = np.round(
    np.clip(amounts, 10_000, 10_000_000),
    2
)

transactions = pd.DataFrame({
    "transaction_id": transaction_ids,
    "customer_id": transaction_customer,
    "transaction_date": transaction_dates,
    "transaction_type": transaction_type,
    "amount": amounts
})

transactions = transactions.sort_values(
    "transaction_date"
).reset_index(drop=True)

transactions.to_csv(
    OUTPUT_DIR / "tb_transaction.csv",
    index=False
)


# ============================================================
# PRODUCT DATA
# ============================================================

products = [
    ("Mobile Top Up", "Digital Goods"),
    ("Electricity Token", "Utilities"),
    ("Internet Package", "Digital Goods"),
    ("Food Delivery", "Food"),
    ("Online Shopping", "E-Commerce"),
    ("Transportation", "Transport"),
    ("Gaming Voucher", "Entertainment"),
    ("Streaming", "Entertainment"),
    ("Bill Payment", "Utilities"),
    ("Education Payment", "Education"),
    ("Marketplace", "E-Commerce"),
    ("Convenience Store", "Retail"),
    ("Restaurant", "Food"),
    ("Ride Hailing", "Transport"),
    ("Digital Subscription", "Entertainment"),
    ("School Payment", "Education"),
    ("University Payment", "Education"),
    ("Healthcare", "Healthcare"),
    ("Travel", "Travel"),
    ("Other", "Other")
]

product_choices = np.random.choice(
    len(products),
    size=N_TRANSACTIONS
)

transaction_products = pd.DataFrame({
    "transaction_product_id": np.arange(
        1,
        N_TRANSACTIONS + 1
    ),
    "transaction_id": transactions["transaction_id"].values,
    "product_name": [
        products[i][0]
        for i in product_choices
    ],
    "product_category": [
        products[i][1]
        for i in product_choices
    ]
})

transaction_products.to_csv(
    OUTPUT_DIR / "tb_transaction_product.csv",
    index=False
)


# ============================================================
# FEE DATA
# ============================================================

fee_percentage = np.where(
    transactions["transaction_type"] == "Bank Transfer",
    0.50,
    1.00
)

fee_amount = np.round(
    transactions["amount"] *
    fee_percentage /
    100,
    2
)

fees = pd.DataFrame({
    "fee_id": np.arange(
        1,
        N_TRANSACTIONS + 1
    ),
    "transaction_id": transactions["transaction_id"].values,
    "fee_percentage": fee_percentage,
    "fee_amount": fee_amount
})

fees.to_csv(
    OUTPUT_DIR / "tb_transaction_fees.csv",
    index=False
)


# ============================================================
# SUMMARY
# ============================================================

print("========================================")
print("FINOVA DATASET GENERATED")
print("========================================")

print(f"Customers    : {len(customers):,}")
print(f"Transactions : {len(transactions):,}")
print(f"Products     : {len(transaction_products):,}")
print(f"Fees         : {len(fees):,}")

print("\nFiles:")

for file in OUTPUT_DIR.glob("*.csv"):
    print(f"- {file}")

print("\nDone!")