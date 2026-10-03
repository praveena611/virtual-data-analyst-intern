-- =========================================================
-- Business & Analytics SQL Queries
-- =========================================================

-- 1. Monthly Revenue and Order Volume Trends
SELECT
    DATE_TRUNC('month', o.order_date) AS order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.total_amount) AS gross_revenue,
    ROUND(AVG(oi.total_amount), 2) AS average_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY 1
ORDER BY 1 DESC;

-- 2. Top Performing Product Categories by Revenue
SELECT
    p.category,
    COUNT(oi.order_item_id) AS total_units_sold,
    SUM(oi.total_amount) AS category_revenue,
    ROUND((SUM(oi.total_amount) * 100.0 / SUM(SUM(oi.total_amount)) OVER()), 2) AS revenue_share_pct
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY category_revenue DESC;

-- 3. Customer Segment Performance & Retention
SELECT
    c.segment,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.total_amount), 2) AS segment_revenue,
    ROUND(SUM(oi.total_amount) / NULLIF(COUNT(DISTINCT c.customer_id), 0), 2) AS revenue_per_customer
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.segment
ORDER BY segment_revenue DESC;
