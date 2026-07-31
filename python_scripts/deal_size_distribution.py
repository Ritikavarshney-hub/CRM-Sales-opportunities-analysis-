"""Distribution of Won deals across small/medium/large size buckets."""
import os
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from db_connection import get_engine

VISUALS_DIR = os.path.join(os.path.dirname(__file__), "..", "visuals")
os.makedirs(VISUALS_DIR, exist_ok=True)

engine = get_engine()

query = """
SELECT
    CASE WHEN close_value < 5000 THEN 'Small'
         WHEN close_value BETWEEN 5000 AND 10000 THEN 'Medium'
         ELSE 'Large' END AS deal_size,
    COUNT(*) AS total_deals
FROM sales_pipeline
WHERE deal_stage = 'Won'
GROUP BY deal_size
ORDER BY FIELD(deal_size, 'Small', 'Medium', 'Large');
"""

df = pd.read_sql(query, engine)

plt.figure(figsize=(8, 6))
ax = sns.barplot(x="deal_size", y="total_deals", data=df, palette="viridis")

plt.title("Won Deal Count by Size Bucket")
plt.xlabel("Deal Size Bucket")
plt.ylabel("Number of Deals")

for bar in ax.patches:
    ax.annotate(f"{int(bar.get_height()):,}", (bar.get_x() + bar.get_width() / 2, bar.get_height()),
                ha="center", va="bottom", fontsize=10, xytext=(0, 3), textcoords="offset points")

plt.tight_layout()
plt.savefig(os.path.join(VISUALS_DIR, "deal_size_distribution.png"), dpi=150)
plt.show()
