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

query="""SELECT c.country , SUM(od.unit_price*od.quantity*(1-od.discount)) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
JOIN order_details od ON o.order_id=od.order_id
GROUP BY c.country
ORDER BY total_spent DESC;"""

df=pd.read_sql(query,conn)

plt.figure(figsize=(10,10))

plt.pie(df['total_spent'],labels=df['country'],autopct='%1.1f%%', startangle=140,pctdistance=0.9,textprops={'fontsize':6},colors=sns.color_palette('pastel'))

plt.title('Revenue Distribution by Country')
plt.show()
