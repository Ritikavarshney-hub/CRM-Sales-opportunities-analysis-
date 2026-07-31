"""
Dataset audit for CRM+Sales+Opportunities.

Goal: before designing the MySQL schema, understand each table's shape,
nulls, duplicate keys, cait tegorical values, and cross-table referential
integrity (do foreign-key-like columns in sales_pipeline actually match
rows in accounts / products / sales_teams?).

Run: python scripts/audit_dataset.py
"""
import pandas as pd

pd.set_option("display.max_columns", None)
pd.set_option("display.width", 160)

BASE = r"D:\SQL PROJECT\CRM+Sales+Opportunities"

accounts = pd.read_csv(f"{BASE}\\accounts.csv")
products = pd.read_csv(f"{BASE}\\products.csv")
sales_teams = pd.read_csv(f"{BASE}\\sales_teams.csv")
pipeline = pd.read_csv(f"{BASE}\\sales_pipeline.csv")

tables = {
    "accounts": accounts,
    "products": products,
    "sales_teams": sales_teams,
    "sales_pipeline": pipeline,
}


def section(title):
    print("\n" + "=" * 80)
    print(title)
    print("=" * 80)


# ---------------------------------------------------------------------------
# 1. Per-table shape, dtypes, nulls, sample
# ---------------------------------------------------------------------------
for name, df in tables.items():
    section(f"TABLE: {name}  shape={df.shape}")
    print(df.dtypes)
    print("\n-- null counts --")
    print(df.isnull().sum())
    print("\n-- sample rows --")
    print(df.head(3))

# ---------------------------------------------------------------------------
# 2. Duplicate / primary-key checks
# ---------------------------------------------------------------------------
section("DUPLICATE / KEY CHECKS")
print("accounts: dup account names:", accounts["account"].duplicated().sum())
print("products: dup product names:", products["product"].duplicated().sum())
print("sales_teams: dup sales_agent names:", sales_teams["sales_agent"].duplicated().sum())
print("sales_pipeline: dup opportunity_id:", pipeline["opportunity_id"].duplicated().sum())
print("sales_pipeline: total rows:", len(pipeline))
print("sales_pipeline: distinct opportunity_id:", pipeline["opportunity_id"].nunique())

# ---------------------------------------------------------------------------
# 3. Categorical distinct values (look for typos / inconsistent casing)
# ---------------------------------------------------------------------------
section("CATEGORICAL DISTINCT VALUES")
print("deal_stage:", pipeline["deal_stage"].unique())
print("sector:", sorted(accounts["sector"].dropna().unique()))
print("series:", sorted(products["series"].dropna().unique()))
print("regional_office:", sorted(sales_teams["regional_office"].dropna().unique()))
print("office_location (accounts):", sorted(accounts["office_location"].dropna().unique()))

# ---------------------------------------------------------------------------
# 4. Referential integrity: do pipeline's "foreign keys" actually resolve?
# ---------------------------------------------------------------------------
section("REFERENTIAL INTEGRITY")

missing_accounts = set(pipeline["account"].dropna().unique()) - set(accounts["account"].unique())
print(f"pipeline.account values not found in accounts: {len(missing_accounts)}")
if missing_accounts:
    print(list(missing_accounts)[:10])

missing_products = set(pipeline["product"].dropna().unique()) - set(products["product"].unique())
print(f"pipeline.product values not found in products: {len(missing_products)}")
if missing_products:
    print(list(missing_products)[:10])

missing_agents = set(pipeline["sales_agent"].dropna().unique()) - set(sales_teams["sales_agent"].unique())
print(f"pipeline.sales_agent values not found in sales_teams: {len(missing_agents)}")
if missing_agents:
    print(list(missing_agents)[:10])

missing_managers = set(sales_teams["manager"].dropna().unique()) - set(sales_teams["sales_agent"].unique())
print(f"sales_teams.manager values not present as a sales_agent row: {len(missing_managers)}")
print(list(missing_managers)[:20])

missing_subsidiary_parents = set(accounts["subsidiary_of"].dropna().unique()) - set(accounts["account"].unique())
print(f"accounts.subsidiary_of values not found as an account: {len(missing_subsidiary_parents)}")

# ---------------------------------------------------------------------------
# 5. Nulls / logical edge cases in the fact table
# ---------------------------------------------------------------------------
section("NULLS / EDGE CASES IN PIPELINE")
print("rows with null account:", pipeline["account"].isnull().sum())
print("rows with null engage_date:", pipeline["engage_date"].isnull().sum())
print("rows with null close_date:", pipeline["close_date"].isnull().sum())
print("rows with null close_value:", pipeline["close_value"].isnull().sum())

print("\ndeal_stage counts:")
print(pipeline["deal_stage"].value_counts(dropna=False))

print("\nclose_value stats by deal_stage:")
print(pipeline.groupby("deal_stage")["close_value"].describe())

print("\nrows Won with null close_value:",
      len(pipeline[(pipeline.deal_stage == "Won") & (pipeline.close_value.isnull())]))
print("rows Lost with non-null (non-zero) close_value:",
      len(pipeline[(pipeline.deal_stage == "Lost") & (pipeline.close_value.fillna(0) != 0)]))
print("rows Prospecting with non-null engage_date:",
      len(pipeline[(pipeline.deal_stage == "Prospecting") & (pipeline.engage_date.notnull())]))
print("rows with close_date but no engage_date:",
      len(pipeline[(pipeline.close_date.notnull()) & (pipeline.engage_date.isnull())]))

eng = pd.to_datetime(pipeline["engage_date"], errors="coerce")
cls = pd.to_datetime(pipeline["close_date"], errors="coerce")
print("rows where close_date < engage_date:", int((cls < eng).sum()))

# ---------------------------------------------------------------------------
# 6. Date ranges + derived sales-cycle-length sanity check
# ---------------------------------------------------------------------------
section("DATE RANGES")
print("engage_date min/max:", eng.min(), eng.max())
print("close_date min/max:", cls.min(), cls.max())

sales_cycle_days = (cls - eng).dt.days
closed_mask = pipeline["deal_stage"].isin(["Won", "Lost"])
print("\nsales cycle length in days (Won/Lost only):")
print(sales_cycle_days[closed_mask].describe())

# ---------------------------------------------------------------------------
# 7. Numeric ranges on dimension tables
# ---------------------------------------------------------------------------
section("ACCOUNTS NUMERIC RANGES")
print(accounts[["year_established", "revenue", "employees"]].describe())
print("negative/zero revenue rows:", int((accounts["revenue"] <= 0).sum()))
print("independent companies (null subsidiary_of):",
      accounts["subsidiary_of"].isnull().sum(), "/", len(accounts))

section("PRODUCTS")
print(products)

# ---------------------------------------------------------------------------
# 8. Text quality checks (whitespace, case)
# ---------------------------------------------------------------------------
section("TEXT QUALITY CHECKS")
print("pipeline.sales_agent has leading/trailing whitespace:",
      int((pipeline["sales_agent"] != pipeline["sales_agent"].str.strip()).sum()))
print("sales_pipeline column names:", list(pipeline.columns))
print("accounts column names:", list(accounts.columns))
