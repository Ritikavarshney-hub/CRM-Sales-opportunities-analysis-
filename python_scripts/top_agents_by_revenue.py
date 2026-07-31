"""Top 10 sales agents by total Won revenue."""
import os
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from db_connection import get_engine

VISUALS_DIR = os.path.join(os.path.dirname(__file__), "..", "visuals")
os.makedirs(VISUALS_DIR, exist_ok=True)

engine = get_engine()

query = """
SELECT sales_agent, ROUND(SUM(close_value), 2) AS total_revenue
FROM sales_pipeline
WHERE deal_stage = 'Won'
GROUP BY sales_agent
ORDER BY total_revenue DESC
LIMIT 10;
"""

df = pd.read_sql(query, engine)

plt.figure(figsize=(12, 6))
ax = sns.barplot(x="sales_agent", y="total_revenue", data=df, palette="viridis")

plt.title("Top 10 Sales Agents by Total Revenue (Won Deals)")
plt.xlabel("Sales Agent")
plt.ylabel("Total Revenue ($)")
plt.xticks(rotation=45, ha="right")

for bar in ax.patches:
    ax.annotate(f"${bar.get_height():,.0f}", (bar.get_x() + bar.get_width() / 2, bar.get_height()),
                ha="center", va="bottom", fontsize=9, xytext=(0, 3), textcoords="offset points")

plt.tight_layout()
plt.savefig(os.path.join(VISUALS_DIR, "top_agents_by_revenue.png"), dpi=150)
plt.show()
