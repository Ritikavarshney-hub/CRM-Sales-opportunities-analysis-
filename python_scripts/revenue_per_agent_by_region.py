"""Revenue-per-agent efficiency ranking by regional office."""
import os
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from db_connection import get_engine

VISUALS_DIR = os.path.join(os.path.dirname(__file__), "..", "visuals")
os.makedirs(VISUALS_DIR, exist_ok=True)

engine = get_engine()

query = """
WITH region_summary AS (
    SELECT st.regional_office,
           COUNT(DISTINCT st.sales_agent) AS total_agents,
           SUM(CASE WHEN sp.deal_stage = 'Won' THEN sp.close_value ELSE 0 END) AS total_revenue
    FROM sales_teams st
    LEFT JOIN sales_pipeline sp ON st.sales_agent = sp.sales_agent
    GROUP BY st.regional_office
)
SELECT regional_office,
       ROUND(total_revenue / total_agents, 2) AS revenue_per_agent
FROM region_summary
ORDER BY revenue_per_agent DESC;
"""

df = pd.read_sql(query, engine)

plt.figure(figsize=(8, 6))
ax = sns.barplot(x="regional_office", y="revenue_per_agent", data=df, palette="flare")

plt.title("Revenue-per-Agent Efficiency by Region")
plt.xlabel("Regional Office")
plt.ylabel("Revenue per Agent ($)")

for bar in ax.patches:
    ax.annotate(f"${bar.get_height():,.0f}", (bar.get_x() + bar.get_width() / 2, bar.get_height()),
                ha="center", va="bottom", fontsize=10, xytext=(0, 3), textcoords="offset points")

plt.tight_layout()
plt.savefig(os.path.join(VISUALS_DIR, "revenue_per_agent_by_region.png"), dpi=150)
plt.show()
