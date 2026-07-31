"""Monthly Won revenue trend across the full dataset time range."""
import os
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sqlalchemy import text
from db_connection import get_engine

VISUALS_DIR = os.path.join(os.path.dirname(__file__), "..", "visuals")
os.makedirs(VISUALS_DIR, exist_ok=True)

engine = get_engine()

# wrapped in text() so pymysql doesn't try to treat the literal '%Y-%m'
# as a %-style parameter placeholder
query = text("""
SELECT DATE_FORMAT(close_date, '%Y-%m') AS month, ROUND(SUM(close_value), 2) AS monthly_revenue
FROM sales_pipeline
WHERE deal_stage = 'Won'
GROUP BY month
ORDER BY month;
""")

df = pd.read_sql(query, engine)

plt.figure(figsize=(12, 6))
sns.lineplot(x="month", y="monthly_revenue", data=df, marker="o", color="teal")

plt.title("Monthly Revenue Trend (Won Deals)")
plt.xlabel("Month")
plt.ylabel("Revenue ($)")
plt.xticks(rotation=45, ha="right")

plt.tight_layout()
plt.savefig(os.path.join(VISUALS_DIR, "monthly_revenue_trend.png"), dpi=150)
plt.show()
