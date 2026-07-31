"""Win rate per manager's team."""
import os
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from db_connection import get_engine

VISUALS_DIR = os.path.join(os.path.dirname(__file__), "..", "visuals")
os.makedirs(VISUALS_DIR, exist_ok=True)

engine = get_engine()

query = """
SELECT st.manager,
       ROUND(100.0 * SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END)
           / NULLIF(SUM(CASE WHEN sp.deal_stage IN ('Won','Lost') THEN 1 ELSE 0 END), 0), 2) AS win_rate
FROM sales_pipeline sp
JOIN sales_teams st ON sp.sales_agent = st.sales_agent
GROUP BY st.manager
ORDER BY win_rate DESC;
"""

df = pd.read_sql(query, engine)

plt.figure(figsize=(12, 6))
ax = sns.barplot(x="manager", y="win_rate", data=df, palette="mako")

plt.title("Win Rate by Manager's Team")
plt.xlabel("Manager")
plt.ylabel("Win Rate (%)")
plt.xticks(rotation=45, ha="right")

for bar in ax.patches:
    ax.annotate(f"{bar.get_height():.1f}%", (bar.get_x() + bar.get_width() / 2, bar.get_height()),
                ha="center", va="bottom", fontsize=9, xytext=(0, 3), textcoords="offset points")

plt.tight_layout()
plt.savefig(os.path.join(VISUALS_DIR, "win_rate_by_manager.png"), dpi=150)
plt.show()
