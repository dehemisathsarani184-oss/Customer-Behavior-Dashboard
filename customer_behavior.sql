USE customer_behavior;
SHOW TABLES;

Select * from customer limit 20;

SELECT gender,
       SUM(`purchase_amount`) AS revenue
FROM customer
GROUP BY gender;

SELECT customer_id,
       `purchase_amount`
FROM customer
WHERE discount_applied = 'Yes'
  AND `purchase_amount` >= (
        SELECT AVG(`purchase_amount`)
        FROM customer
      );

SELECT item_purchased,
       ROUND(AVG(CAST(review_rating AS DECIMAL(3,2))), 2) AS `Average Product Rating`
FROM customer
GROUP BY item_purchased
ORDER BY AVG(CAST(review_rating AS DECIMAL(3,2))) DESC
LIMIT 5;

ALTER TABLE customer
RENAME COLUMN `purchase_amount` TO purchase_amount;

SELECT 
    shipping_type,
    ROUND(AVG(purchase_amount), 2) AS avg_purchase_amount
FROM 
    customer
WHERE 
    shipping_type IN ('Standard', 'Express')
GROUP BY 
    shipping_type;

SELECT 
    subscription_status,
    COUNT(customer_id) AS total_customers,
    ROUND(AVG(purchase_amount), 2) AS avg_spend,
    ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM 
    customer
GROUP BY 
    subscription_status
ORDER BY 
    total_revenue DESC, 
    avg_spend DESC;

SELECT 
    item_purchased,
    ROUND(
        100 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),2) AS discount_rate
FROM 
    customer
GROUP BY 
    item_purchased
ORDER BY 
    discount_rate DESC
LIMIT 5;

WITH customer_type AS (
    SELECT customer_id,previous_purchases,
        CASE
            WHEN previous_purchases = 1 THEN 'New'
            WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
            ELSE 'Loyal'
        END AS customer_segment
    FROM customer
)
SELECT customer_segment, COUNT(*) AS `Number of Customers`
FROM customer_type
GROUP BY customer_segment;

WITH item_count AS (
    SELECT category,item_purchased,
        COUNT(customer_id) AS total_orders,
        ROW_NUMBER() OVER(PARTITION BY category ORDER BY COUNT(customer_id) DESC) AS item_rank
    FROM customer
    GROUP BY category, item_purchased
)
SELECT item_rank,category,item_purchased,total_orders
FROM item_count
WHERE item_rank <= 3;

SELECT subscription_status,COUNT(customer_id) AS repeat_buyers
FROM customer
WHERE previous_purchases > 5
GROUP BY subscription_status;

SELECT 
    CASE 
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '51+' 
    END AS age_group,
    SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY age_group
ORDER BY total_revenue DESC;

