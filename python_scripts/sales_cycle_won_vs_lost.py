"""Average sales cycle length (days) for Won vs Lost deals."""
import os
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from db_connection import get_engine

VISUALS_DIR = os.path.join(os.path.dirname(__file__), "..", "visuals")
os.makedirs(VISUALS_DIR, exist_ok=True)

engine = get_engine()

query = """
SELECT deal_stage, ROUND(AVG(DATEDIFF(close_date, engage_date)), 2) AS avg_cycle_days
FROM sales_pipeline
WHERE deal_stage IN ('Won', 'Lost')
GROUP BY deal_stage;
"""

df = pd.read_sql(query, engine)

plt.figure(figsize=(8, 6))
ax = sns.barplot(x="deal_stage", y="avg_cycle_days", data=df, palette="flare")

plt.title("Average Sales Cycle Length: Won vs Lost")
plt.xlabel("Deal Stage")
plt.ylabel("Average Days (engage_date to close_date)")

for bar in ax.patches:
    ax.annotate(f"{bar.get_height():.1f} days", (bar.get_x() + bar.get_width() / 2, bar.get_height()),
                ha="center", va="bottom", fontsize=10, xytext=(0, 3), textcoords="offset points")

plt.tight_layout()
plt.savefig(os.path.join(VISUALS_DIR, "sales_cycle_won_vs_lost.png"), dpi=150)
plt.show()
