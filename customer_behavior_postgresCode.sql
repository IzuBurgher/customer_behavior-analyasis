select * from customer limit 10

-- Q1. What is the total revenue generated from males vs females
select
gender,
sum(purchase_amounts) as revenue
from customer
group by gender

--Q2. Which customers used a discount but still spent more than the average purchase amount?

select
customer_id,
purchase_amounts
from customer
where discount_applied = 'Yes' and purchase_amounts >= (select AVG(purchase_amounts) from customer)

--Q3. which are the top 5 products with the highest average review rating??

select
item_purchased,
ROUND(AVG(review_rating::numeric) ,2) as "Average Product Rating"
from customer
group by item_purchased
order by AVG(review_rating) DESC
limit 5

-- Q4. Compare the average purchase amount between standard and express shipping.

select 
shipping_type, 
round(AVG(purchase_amounts), 2) AS average_purchase
from customer
where shipping_type IN ('Standard', 'Express')
group by shipping_type

--Q5 Do subscribed customers spend more? Compare average spend and total revenue between subscribers and non subscribers

select
subscription_status,
COUNT(customer_id) as total_customers,
round(avg(purchase_amounts),2) as avg_spend,
round(sum(purchase_amounts),2) as total_revenue
from customer
group by subscription_status
order by total_revenue, avg_spend;

--Q6. Which 5 products have the highest percentage of purchases with discounts applied?

select 
item_purchased as products,
round(100 * sum(case when discount_applied = 'Yes' then 1 else 0 end)/count(*),2) as discount_rate
from customer
group by item_purchased
order by discount_rate desc
limit 5

--Q7. Segment customers into New, Returning and royal based on their total number of previous purchases, 
   		--and show the count of each segment
with customer_type as(
select customer_id, 
	previous_purchases, 
case 
	when previous_purchases = 1 then 'New'
	when previous_purchases between 2 and 10 then 'Returning'
	else 'Loyal'
	end as customer_segment
from customer
) 
select 
customer_segment,
count(*) as "Number of Customers"
from customer_type
group by customer_segment

--Q8. What are the top 3 most purchased products within each category? 
WITH item_counts AS (
    SELECT category,
           item_purchased,
           COUNT(customer_id) AS total_orders,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY COUNT(customer_id) DESC) AS item_rank
    FROM customer
    GROUP BY category, item_purchased
)
SELECT item_rank,category, item_purchased, total_orders
FROM item_counts
WHERE item_rank <=3;
 
--Q9. Are customers who are repeat buyers (more than 5 previous purchases) also likely to subscribe?
SELECT subscription_status,
       COUNT(customer_id) AS repeat_buyers
FROM customer
WHERE previous_purchases > 5
GROUP BY subscription_status;

--Q10. What is the revenue contribution of each age group? 
SELECT 
    age_group,
    SUM(purchase_amounts) AS total_revenue
FROM customer
GROUP BY age_group
ORDER BY total_revenue desc;





