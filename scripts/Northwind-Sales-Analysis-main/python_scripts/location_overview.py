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
query_city = """
SELECT city, COUNT(*) AS employee_count
FROM employees
GROUP BY city;
"""

df_city = pd.read_sql_query(query_city, conn)

plt.figure(figsize=(10, 6))
ax = sns.barplot(x='city', y='employee_count', data=df_city, palette='flare')

plt.title('Employee Distribution by City')
plt.xlabel('City')
plt.ylabel('Employee Count')
plt.xticks(rotation=45, ha='right')

for bar in ax.patches:
    height = bar.get_height()
    ax.annotate(f'{int(height)}', (bar.get_x() + bar.get_width() / 2, height),
                textcoords="offset points", xytext=(0, 3),
                ha='center', fontsize=9)

plt.tight_layout()
plt.show()
