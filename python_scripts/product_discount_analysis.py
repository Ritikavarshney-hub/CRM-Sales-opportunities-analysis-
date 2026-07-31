"""Average discount (list price vs. actual close value) per product, Won deals only."""
import os
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from db_connection import get_engine

VISUALS_DIR = os.path.join(os.path.dirname(__file__), "..", "visuals")
os.makedirs(VISUALS_DIR, exist_ok=True)

engine = get_engine()

query = """
SELECT p.product,
       ROUND(AVG(p.sales_price - sp.close_value), 2) AS avg_discount
FROM sales_pipeline sp
JOIN products p ON sp.product = p.product
WHERE sp.deal_stage = 'Won'
GROUP BY p.product
ORDER BY avg_discount DESC;
"""

df = pd.read_sql(query, engine)

plt.figure(figsize=(12, 6))
ax = sns.barplot(x="product", y="avg_discount", data=df, palette="rocket")

plt.title("Average Discount vs. List Price by Product (Won Deals)")
plt.xlabel("Product")
plt.ylabel("Average Discount ($)")
plt.xticks(rotation=45, ha="right")

for bar in ax.patches:
    ax.annotate(f"${bar.get_height():,.0f}", (bar.get_x() + bar.get_width() / 2, bar.get_height()),
                ha="center", va="bottom", fontsize=9, xytext=(0, 3), textcoords="offset points")

plt.tight_layout()
plt.savefig(os.path.join(VISUALS_DIR, "product_discount_analysis.png"), dpi=150)
plt.show()
