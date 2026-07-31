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
SELECT 
    p.product_name,
    COALESCE(SUM(od.quantity), 0) AS demand,
    p.units_in_stock + COALESCE(SUM(od.quantity), 0) AS supply
FROM products p
LEFT JOIN order_details od ON p.product_id = od.product_id
GROUP BY p.product_name, p.units_in_stock
ORDER BY demand DESC
"""

df_supply_demand = pd.read_sql_query(query, conn)

x = df_supply_demand['product_name']
supply = df_supply_demand['supply']
demand = df_supply_demand['demand']

x_axis = range(len(x))
bar_width = 0.4

plt.figure(figsize=(12, 6))
plt.bar(x_axis, supply, width=bar_width, label='Supply (Stock + Demand)', color='lightblue')
plt.bar([i + bar_width for i in x_axis], demand, width=bar_width, label='Demand (Units Sold)', color='coral')

plt.xticks([i + bar_width / 2 for i in x_axis], x, rotation=45, ha='right',fontsize=6)
plt.xlabel('Product Name')
plt.ylabel('Units')
plt.title('Supply vs. Demand: Top 10 Products')
plt.legend()
plt.tight_layout()
plt.show()
