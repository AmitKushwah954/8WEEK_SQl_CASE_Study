Create DATABASE MY_SQL_Case_Studies_2025;

use MY_SQL_Case_Studies_2025;

-- Create sales table
CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

-- Insert data into sales table
INSERT INTO sales (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', 1),
  ('A', '2021-01-01', 2),
  ('A', '2021-01-07', 2),
  ('A', '2021-01-10', 3),
  ('A', '2021-01-11', 3),
  ('A', '2021-01-11', 3),
  ('B', '2021-01-01', 2),
  ('B', '2021-01-02', 2),
  ('B', '2021-01-04', 1),
  ('B', '2021-01-11', 1),
  ('B', '2021-01-16', 3),
  ('B', '2021-02-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-07', 3);

-- Create menu table
CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

-- Insert data into menu table
INSERT INTO menu (product_id, product_name, price)
VALUES
  (1, 'sushi', 10),
  (2, 'curry', 15),
  (3, 'ramen', 12);

-- Create members table
CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

-- Insert data into members table
INSERT INTO members (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

-- 1. What is the total amount each customer spent at the restaurant?

SELECT sales.customer_id, Sum(menu.price) as total_sales FROM sales
inner Join menu
on sales.product_id = menu.product_id
group by customer_id
;


-- 2. How many days has each customer visited the restaurant?

Select customer_id, COUNT(DISTINCT(order_date)) as Number_of_Visit
from sales
group by customer_id
;

-- 3. What was the first item from the menu purchased by each customer?

Select customer_id, product_id, min(order_date) as First_Date FROM sales 
GROUP BY customer_id, product_id
order by customer_id, First_Date;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select menu.product_name , Count(sales.product_id) as Max_Time_ordered
from sales
inner join menu
on sales.product_id = menu.product_id
group by menu.product_name 
order by Max_Time_ordered desc
Limit 1
;

Select customer_id, count(product_id) as Rameen_ordered
from sales
where product_id = 3
GROUP BY customer_id;

-- 5. Which item was the most popular for each customer?
 
Select customer_id, product_id,  count(product_id) as number_of_times_ordered
FROM sales 
Where customer_id = "A"
Group by customer_id, product_id 
Order by product_id Desc
LIMIT 1;

Select customer_id, product_id,  count(product_id) as number_of_times_ordered
FROM sales 
Where customer_id = "B"
Group by customer_id, product_id 
Order by product_id Desc
LIMIT 1;

-- 6. Which item was purchased first by the customer after they became a member?
/*
Select sales.customer_id, sales.order_date, sales.product_id, menu.product_name
FROM sales 
inner join menu
on sales.product_id = menu.product_id
inner join members
on sales.customer_id = members.customer_id
Where sales.order_date >= members.join_date
order by sales.customer_id, sales.order_date
limit 1;
*/


Select sales.customer_id, sales.order_date, sales.product_id, menu.product_name
FROM sales 
inner join menu
on sales.product_id = menu.product_id
Where order_date >= "2021-01-07" and  customer_id = "A"
order by sales.order_date
LIMIT 1;

Select sales.customer_id, sales.order_date, sales.product_id, menu.product_name
FROM sales 
inner join menu
on sales.product_id = menu.product_id
Where order_date >= "2021-01-09" and  customer_id = "B"
order by sales.order_date
LIMIT 1;






-- 7. Which item was purchased just before the customer became a member?

Select sales.customer_id, sales.order_date, sales.product_id, menu.product_name
FROM sales 
inner join menu
on sales.product_id = menu.product_id
Where order_date < "2021-01-09" and  customer_id = "B"
order by order_date desc
LIMIT 1;

Select sales.customer_id, sales.order_date, sales.product_id, menu.product_name
FROM sales 
inner join menu
on sales.product_id = menu.product_id
Where order_date < "2021-01-07" and  customer_id = "A"
order by order_date desc
LIMIT 1;

-- 8. What is the total items and amount spent for each member before they became a member?

Select sales.customer_id, count(sales.product_id) as Total_Number_of_Orders, sum(menu.price) as Order_value
FROM sales
inner join menu
on sales.product_id = menu.product_id
Where order_date < "2021-01-07" and  customer_id = "A"
group by sales.customer_id;


Select sales.customer_id, count(sales.product_id) as Total_Number_of_Orders, sum(menu.price) as Order_value
FROM sales
inner join menu
on sales.product_id = menu.product_id
Where order_date < "2021-01-09" and  customer_id = "B"
group by sales.customer_id;


-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have ?

WITH points_table as (
	SELECT menu.product_id, 
    Case
    when menu.product_id = 1 then menu.price * 2
    else menu.price * 2
    end as Points
    from menu)

select sales.customer_id, sum(points_table.Points) as Total_Points 
from sales
inner join points_table
on sales.product_id = points_table.product_id
group by sales.customer_id; 



/*
SELECT sales.customer_id, 
       SUM(CASE 
             WHEN menu.product_id = 1 THEN menu.price * 2
             ELSE menu.price * 2
           END) AS Total_Points
FROM sales
INNER JOIN menu ON sales.product_id = menu.product_id
GROUP BY sales.customer_id;
*/


/*
The Most Important Question
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items,not just sushi -
how many points do customer A and B have at the end of January?
*/

with new_Points_Table as (
select sales.customer_id, sales.product_id,

case
	When sales.order_date between members.join_date and date_add(members.join_date, interval 7 day) or sales.product_id = 1
    then menu.price * 20
    else menu.price * 10
end as points

from sales
inner join menu
on sales.product_id = menu.product_id
inner join members
on sales.customer_id = members.customer_id
)

select customer_id, sum(points) from new_Points_Table
group by customer_id;




