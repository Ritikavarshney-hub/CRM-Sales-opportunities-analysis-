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

query=""" SELECT c.company_name,
SUM(od.unit_price*od.quantity*(1-od.discount))/COUNT(DISTINCT o.order_id) AS avg_order_value
FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
JOIN order_details od ON o.order_id=od.order_id
GROUP BY c.company_name
ORDER BY avg_order_value DESC;

"""

df = pd.read_sql_query(query, conn)
plt.figure(figsize=(14, 6))
ax = sns.barplot(x='company_name', y='avg_order_value', data=df, palette='viridis')

plt.title('average value per Customer')
plt.xlabel('Customer Name')
plt.ylabel('average value')

plt.xticks(rotation=45, ha='right',fontsize=6)

plt.tight_layout()
plt.show()
