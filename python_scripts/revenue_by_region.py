"""Total Won revenue by regional office."""
import os
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from db_connection import get_engine

VISUALS_DIR = os.path.join(os.path.dirname(__file__), "..", "visuals")
os.makedirs(VISUALS_DIR, exist_ok=True)

engine = get_engine()

query = """
SELECT st.regional_office, ROUND(SUM(sp.close_value), 2) AS total_revenue
FROM sales_pipeline sp
JOIN sales_teams st ON sp.sales_agent = st.sales_agent
WHERE sp.deal_stage = 'Won'
GROUP BY st.regional_office
ORDER BY total_revenue DESC;
"""

df = pd.read_sql(query, engine)

plt.figure(figsize=(8, 6))
ax = sns.barplot(x="regional_office", y="total_revenue", data=df, palette="crest")

plt.title("Total Revenue by Regional Office")
plt.xlabel("Regional Office")
plt.ylabel("Total Revenue ($)")

for bar in ax.patches:
    ax.annotate(f"${bar.get_height():,.0f}", (bar.get_x() + bar.get_width() / 2, bar.get_height()),
                ha="center", va="bottom", fontsize=10, xytext=(0, 3), textcoords="offset points")

plt.tight_layout()
plt.savefig(os.path.join(VISUALS_DIR, "revenue_by_region.png"), dpi=150)
plt.show()
