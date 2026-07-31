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
SELECT p.product_name, 
       ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::NUMERIC, 2) AS total_sales
FROM products p
JOIN order_details od ON p.product_id = od.product_id
GROUP BY p.product_name
ORDER BY total_sales DESC
LIMIT 10;
"""

df_top_products = pd.read_sql_query(query, conn)

plt.figure(figsize=(12, 6))
ax = sns.barplot(x='product_name', y='total_sales', data=df_top_products, palette='viridis')

plt.title('Top 10 Best-Selling Products by Revenue')
plt.xlabel('Product Name')
plt.ylabel('Total Revenue ($)')
plt.xticks(rotation=45, ha='right')

for bar in ax.patches:
    ax.annotate(f"${bar.get_height():,.0f}", (bar.get_x() + bar.get_width()/2, bar.get_height()), 
                ha='center', va='bottom', fontsize=9, xytext=(0, 3), textcoords='offset points')

plt.tight_layout()
plt.show()
