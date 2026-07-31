--Top 10 Best-Selling Products by Revenue
SELECT p.product_name, 
       ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount)), 2) AS total_sales
FROM products p
JOIN order_details od ON p.product_id = od.product_id
GROUP BY p.product_name
ORDER BY total_sales DESC
LIMIT 10;

--Top Product Categories by Revenue
SELECT c.category_name, 
       ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount)), 2) AS total_revenue
FROM categories c
JOIN products p ON c.category_id = p.category_id
JOIN order_details od ON p.product_id = od.product_id
GROUP BY c.category_name
ORDER BY total_revenue DESC;

--Average Unit Price per Category
SELECT c.category_name, 
       ROUND(AVG(p.unit_price), 2) AS avg_unit_price
FROM categories c
JOIN products p ON c.category_id = p.category_id
GROUP BY c.category_name
ORDER BY avg_unit_price DESC;

--Product Stock vs. Sales Comparison
SELECT p.product_name,
       p.units_in_stock,
       COALESCE(SUM(od.quantity), 0) AS total_units_sold
FROM products p
LEFT JOIN order_details od ON p.product_id = od.product_id
GROUP BY p.product_name, p.units_in_stock
ORDER BY total_units_sold DESC;

