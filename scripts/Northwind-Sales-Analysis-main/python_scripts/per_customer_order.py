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

query=""" SELECT c.company_name
,COUNT (o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
GROUP BY c.company_name
ORDER BY total_orders DESC;"""

df = pd.read_sql_query(query, conn)
plt.figure(figsize=(14, 6))
ax = sns.barplot(x='company_name', y='total_orders', data=df, palette='viridis')

plt.title('Number of Orders per Customer')
plt.xlabel('Customer Name')
plt.ylabel('Total Orders')

plt.xticks(rotation=45, ha='right',fontsize=6)

plt.tight_layout()
plt.show()
