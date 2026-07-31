"""Distribution of all opportunities across the 4 funnel stages."""
import os
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from db_connection import get_engine

VISUALS_DIR = os.path.join(os.path.dirname(__file__), "..", "visuals")
os.makedirs(VISUALS_DIR, exist_ok=True)

engine = get_engine()

query = """
SELECT deal_stage, COUNT(*) AS total_deals
FROM sales_pipeline
GROUP BY deal_stage
ORDER BY FIELD(deal_stage, 'Prospecting', 'Engaging', 'Won', 'Lost');
"""

df = pd.read_sql(query, engine)

plt.figure(figsize=(10, 6))
ax = sns.barplot(x="deal_stage", y="total_deals", data=df, palette="crest")

plt.title("Pipeline Distribution Across Funnel Stages")
plt.xlabel("Deal Stage")
plt.ylabel("Number of Deals")

for bar in ax.patches:
    ax.annotate(f"{int(bar.get_height()):,}", (bar.get_x() + bar.get_width() / 2, bar.get_height()),
                ha="center", va="bottom", fontsize=10, xytext=(0, 3), textcoords="offset points")

plt.tight_layout()
plt.savefig(os.path.join(VISUALS_DIR, "deal_stage_funnel.png"), dpi=150)
plt.show()
