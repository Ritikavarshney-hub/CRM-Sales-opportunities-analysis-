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

query1 = """
SELECT CONCAT(e.first_name, ' ', e.last_name) AS employee_name, 
       COUNT(o.order_id) AS total_orders
FROM employees e
JOIN orders o ON e.employee_id = o.employee_id
GROUP BY employee_name
ORDER BY total_orders DESC;
"""

df_orders_handled = pd.read_sql_query(query1, conn)

plt.figure(figsize=(10, 6))
ax = sns.barplot(x='employee_name', y='total_orders', data=df_orders_handled, palette='mako')

plt.title('Employees by Number of Orders Handled')
plt.xlabel('Employee Name')
plt.ylabel('Total Orders')
plt.xticks(rotation=45, ha='right')

for bar in ax.patches:
    height = bar.get_height()
    ax.annotate(f'{int(height)}', (bar.get_x() + bar.get_width() / 2, height),
                textcoords="offset points", xytext=(0, 3),
                ha='center', fontsize=9)

plt.tight_layout()
plt.show()
