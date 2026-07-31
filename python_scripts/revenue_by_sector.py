"""Total Won revenue by account sector."""
import os
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from db_connection import get_engine

VISUALS_DIR = os.path.join(os.path.dirname(__file__), "..", "visuals")
os.makedirs(VISUALS_DIR, exist_ok=True)

engine = get_engine()

query = """
SELECT a.sector, ROUND(SUM(sp.close_value), 2) AS total_revenue
FROM sales_pipeline sp
JOIN accounts a ON sp.account = a.account
WHERE sp.deal_stage = 'Won'
GROUP BY a.sector
ORDER BY total_revenue DESC;
"""

df = pd.read_sql(query, engine)

plt.figure(figsize=(12, 6))
ax = sns.barplot(x="sector", y="total_revenue", data=df, palette="viridis")

plt.title("Total Revenue by Sector")
plt.xlabel("Sector")
plt.ylabel("Total Revenue ($)")
plt.xticks(rotation=45, ha="right")

for bar in ax.patches:
    ax.annotate(f"${bar.get_height():,.0f}", (bar.get_x() + bar.get_width() / 2, bar.get_height()),
                ha="center", va="bottom", fontsize=9, xytext=(0, 3), textcoords="offset points")

plt.tight_layout()
plt.savefig(os.path.join(VISUALS_DIR, "revenue_by_sector.png"), dpi=150)
plt.show()
