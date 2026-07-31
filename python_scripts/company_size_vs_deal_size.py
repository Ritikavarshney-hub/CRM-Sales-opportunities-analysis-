"""Average Won deal size, bucketed by account company size (employee count)."""
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
    CASE WHEN a.employees < 1000 THEN 'Small (<1000)'
         WHEN a.employees BETWEEN 1000 AND 5000 THEN 'Medium (1000-5000)'
         ELSE 'Large (>5000)' END AS company_size,
    ROUND(AVG(sp.close_value), 2) AS avg_deal_size
FROM sales_pipeline sp
JOIN accounts a ON sp.account = a.account
WHERE sp.deal_stage = 'Won'
GROUP BY company_size
ORDER BY FIELD(company_size, 'Small (<1000)', 'Medium (1000-5000)', 'Large (>5000)');
"""

df = pd.read_sql(query, engine)

plt.figure(figsize=(8, 6))
ax = sns.barplot(x="company_size", y="avg_deal_size", data=df, palette="mako")

plt.title("Average Deal Size by Company Size")
plt.xlabel("Company Size (by Employees)")
plt.ylabel("Average Deal Size ($)")

for bar in ax.patches:
    ax.annotate(f"${bar.get_height():,.0f}", (bar.get_x() + bar.get_width() / 2, bar.get_height()),
                ha="center", va="bottom", fontsize=10, xytext=(0, 3), textcoords="offset points")

plt.tight_layout()
plt.savefig(os.path.join(VISUALS_DIR, "company_size_vs_deal_size.png"), dpi=150)
plt.show()
