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

query="""SELECT c.company_name , SUM(od.unit_price*od.quantity*(1-od.discount)) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
JOIN order_details od ON o.order_id=od.order_id
GROUP BY c.company_name
ORDER BY total_spent DESC;"""

df=pd.read_sql(query,conn)

plt.figure(figsize=(10,16))
sns.barplot(x='total_spent',y='company_name',data=df,palette='viridis')
plt.title('top 10 customers by revenue')
plt.xlabel('total revenue')
plt.ylabel('customer')
plt.yticks(fontsize=6)
plt.tight_layout()
plt.show()
