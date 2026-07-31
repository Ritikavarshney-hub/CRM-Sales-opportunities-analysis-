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

query3 = """
SELECT CONCAT(e.first_name, ' ', e.last_name) AS employee_name, 
       COUNT(DISTINCT o.customer_id) AS customers_handled
FROM employees e
JOIN orders o ON e.employee_id = o.employee_id
GROUP BY employee_name
ORDER BY customers_handled DESC;
"""

df_customers = pd.read_sql_query(query3, conn)

plt.figure(figsize=(10, 6))
ax = sns.barplot(x='employee_name', y='customers_handled', data=df_customers, palette='rocket')

plt.title('Customers Handled by Each Employee')
plt.xlabel('Employee Name')
plt.ylabel('Number of Customers')
plt.xticks(rotation=45, ha='right')

for bar in ax.patches:
    height = bar.get_height()
    ax.annotate(f'{int(height)}', (bar.get_x() + bar.get_width() / 2, height),
                textcoords="offset points", xytext=(0, 3),
                ha='center', fontsize=9)

plt.tight_layout()
plt.show()
