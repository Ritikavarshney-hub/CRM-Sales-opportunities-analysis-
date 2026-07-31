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

query2 = """
SELECT CONCAT(e.first_name, ' ', e.last_name) AS employee_name, 
       SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_revenue
FROM employees e
JOIN orders o ON e.employee_id = o.employee_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY employee_name
ORDER BY total_revenue DESC;
"""

df_revenue = pd.read_sql_query(query2, conn)

plt.figure(figsize=(10, 6))
ax = sns.barplot(x='employee_name', y='total_revenue', data=df_revenue, palette='crest')

plt.title('Revenue Generated per Employee')
plt.xlabel('Employee Name')
plt.ylabel('Total Revenue ($)')
plt.xticks(rotation=45, ha='right')

for bar in ax.patches:
    height = bar.get_height()
    ax.annotate(f'${height:,.0f}', (bar.get_x() + bar.get_width() / 2, height),
                textcoords="offset points", xytext=(0, 3),
                ha='center', fontsize=9)

plt.tight_layout()
plt.show()
