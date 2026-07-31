import psycopg2
import pandas as pd
import matplotlib.pyplot as plt


conn = psycopg2.connect(
    dbname="northwind",
    user="postgres",         
    password="", 
    host="localhost",
    port="5432"
)

query = """
SELECT c.category_name, 
       ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::NUMERIC, 2) AS total_revenue
FROM categories c
JOIN products p ON c.category_id = p.category_id
JOIN order_details od ON p.product_id = od.product_id
GROUP BY c.category_name
ORDER BY total_revenue DESC;
"""

df_categories = pd.read_sql_query(query, conn)

plt.figure(figsize=(7, 7))
plt.pie(df_categories['total_revenue'], 
        labels=df_categories['category_name'], 
        autopct='%1.1f%%', 
        startangle=140, 
        textprops={'fontsize': 9})

plt.title('Top Product Categories by Revenue')
plt.tight_layout()
plt.show()
