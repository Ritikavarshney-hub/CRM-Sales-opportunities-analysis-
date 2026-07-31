--Employee Who Handled the Most Orders

SELECT CONCAT(e.first_name, ' ', e.last_name) AS employee_name, 
       COUNT(o.order_id) AS total_orders
FROM employees e
JOIN orders o ON e.employee_id = o.employee_id
GROUP BY employee_name
ORDER BY total_orders DESC;

--Revenue Generated per Employee

SELECT CONCAT(e.first_name, ' ', e.last_name) AS employee_name, 
       ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount)), 2) AS total_revenue
FROM employees e
JOIN orders o ON e.employee_id = o.employee_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY employee_name
ORDER BY total_revenue DESC;

--Customers Handled by Each Employee

SELECT CONCAT(e.first_name, ' ', e.last_name) AS employee_name, 
       COUNT(DISTINCT o.customer_id) AS customers_handled
FROM employees e
JOIN orders o ON e.employee_id = o.employee_id
GROUP BY employee_name
ORDER BY customers_handled DESC;

--Employee Location Overview
-- By Region
SELECT region, COUNT(*) AS employee_count
FROM employees
GROUP BY region;

-- By City
SELECT city, COUNT(*) AS employee_count
FROM employees
GROUP BY city;

