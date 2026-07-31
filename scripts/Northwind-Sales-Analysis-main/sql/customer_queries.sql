-- customer queries

--top customers

SELECT c.company_name , SUM(od.unit_price*od.quantity*(1-od.discount)) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
JOIN order_details od ON o.order_id=od.order_id
GROUP BY c.company_name
ORDER BY total_spent DESC;


--Revenue by country change only select and group by

SELECT c.country , SUM(od.unit_price*od.quantity*(1-od.discount)) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
JOIN order_details od ON o.order_id=od.order_id
GROUP BY c.country
ORDER BY total_spent DESC;

--number of orders per customer
SELECT c.company_name
COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
GROUP BY c.company_name
ORDER BY total_orders DESC;


--average value per customer
SELECT c.company_name 
SUM(od.unit_price*od.quantity*(1-od.discount))/COUNT(DISTINCT o.order_id) AS avg_order_value
FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
JOIN order_details od ON o.order_id=od.order_id
GROUP BY c.company_name
ORDER BY avg_order_value DESC;




