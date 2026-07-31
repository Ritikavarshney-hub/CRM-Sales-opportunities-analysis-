"""Total Won revenue by product series (GTX/GTK/MG)."""
import os
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from db_connection import get_engine

VISUALS_DIR = os.path.join(os.path.dirname(__file__), "..", "visuals")
os.makedirs(VISUALS_DIR, exist_ok=True)

engine = get_engine()

query = """
SELECT p.series, ROUND(SUM(sp.close_value), 2) AS total_revenue
FROM sales_pipeline sp
JOIN products p ON sp.product = p.product
WHERE sp.deal_stage = 'Won'
GROUP BY p.series
ORDER BY total_revenue DESC;
"""

df = pd.read_sql(query, engine)

plt.figure(figsize=(8, 6))
ax = sns.barplot(x="series", y="total_revenue", data=df, palette="viridis")

plt.title("Total Revenue by Product Series")
plt.xlabel("Product Series")
plt.ylabel("Total Revenue ($)")

for bar in ax.patches:
    ax.annotate(f"${bar.get_height():,.0f}", (bar.get_x() + bar.get_width() / 2, bar.get_height()),
                ha="center", va="bottom", fontsize=10, xytext=(0, 3), textcoords="offset points")

plt.tight_layout()
plt.savefig(os.path.join(VISUALS_DIR, "revenue_by_product_series.png"), dpi=150)
plt.show()
