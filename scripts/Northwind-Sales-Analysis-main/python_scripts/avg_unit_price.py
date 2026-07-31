import psycopg2
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

conn = psycopg2.connect(
    dbname="northwind",
    user="postgres",         
    password="", 
    host="localhost",
    port="5432"
)

query = """
SELECT c.category_name, 
       ROUND(AVG(p.unit_price)::NUMERIC, 2) AS avg_unit_price
FROM categories c
JOIN products p ON c.category_id = p.category_id
GROUP BY c.category_name
ORDER BY avg_unit_price DESC;
"""

df_avg_price = pd.read_sql_query(query, conn)

plt.figure(figsize=(10, 6))
ax = sns.barplot(x='category_name', y='avg_unit_price', data=df_avg_price, palette='mako')

plt.title('Average Unit Price per Category')
plt.xlabel('Category')
plt.ylabel('Average Unit Price ($)')
plt.xticks(rotation=45, ha='right')

for bar in ax.patches:
    ax.annotate(f"${bar.get_height():.2f}", (bar.get_x() + bar.get_width()/2, bar.get_height()), 
                ha='center', va='bottom', fontsize=9, xytext=(0, 3), textcoords='offset points')

plt.tight_layout()
plt.show()
