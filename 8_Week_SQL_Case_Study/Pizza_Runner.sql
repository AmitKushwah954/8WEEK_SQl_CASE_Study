
use MY_SQL_Case_Studies_2025;

DROP TABLE IF EXISTS `runners`;
CREATE TABLE `runners` (
  `runner_id` INT,
  `registration_date` DATE
);
INSERT INTO `runners` (`runner_id`, `registration_date`)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS `customer_orders`;
CREATE TABLE `customer_orders` (
  `order_id` INT,
  `customer_id` INT,
  `pizza_id` INT,
  `exclusions` VARCHAR(4),
  `extras` VARCHAR(4),
  `order_time` TIMESTAMP
);
INSERT INTO `customer_orders` (`order_id`, `customer_id`, `pizza_id`, `exclusions`, `extras`, `order_time`)
VALUES
  (1, 101, 1, '', '', '2020-01-01 18:05:02'),
  (2, 101, 1, '', '', '2020-01-01 19:00:52'),
  (3, 102, 1, '', '', '2020-01-02 23:51:23'),
  (3, 102, 2, '', NULL, '2020-01-02 23:51:23'),
  (4, 103, 1, '4', '', '2020-01-04 13:23:46'),
  (4, 103, 1, '4', '', '2020-01-04 13:23:46'),
  (4, 103, 2, '4', '', '2020-01-04 13:23:46'),
  (5, 104, 1, 'null', '1', '2020-01-08 21:00:29'),
  (6, 101, 2, 'null', 'null', '2020-01-08 21:03:13'),
  (7, 105, 2, 'null', '1', '2020-01-08 21:20:29'),
  (8, 102, 1, 'null', 'null', '2020-01-09 23:54:33'),
  (9, 103, 1, '4', '1, 5', '2020-01-10 11:22:59'),
  (10, 104, 1, 'null', 'null', '2020-01-11 18:34:49'),
  (10, 104, 1, '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS `runner_orders`;
CREATE TABLE `runner_orders` (
  `order_id` INT,
  `runner_id` INT,
  `pickup_time` VARCHAR(19),
  `distance` VARCHAR(7),
  `duration` VARCHAR(10),
  `cancellation` VARCHAR(23)
);
INSERT INTO `runner_orders` (`order_id`, `runner_id`, `pickup_time`, `distance`, `duration`, `cancellation`)
VALUES
  (1, 1, '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  (2, 1, '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  (3, 1, '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  (4, 2, '2020-01-04 13:53:03', '23.4', '40', NULL),
  (5, 3, '2020-01-08 21:10:57', '10', '15', NULL),
  (6, 3, NULL, NULL, NULL, 'Restaurant Cancellation'),
  (7, 2, '2020-01-08 21:30:45', '25km', '25mins', NULL),
  (8, 2, '2020-01-10 00:15:02', '23.4 km', '15 minute', NULL),
  (9, 2, NULL, NULL, NULL, 'Customer Cancellation'),
  (10, 1, '2020-01-11 18:50:20', '10km', '10minutes', NULL);


DROP TABLE IF EXISTS `pizza_names`;
CREATE TABLE `pizza_names` (
  `pizza_id` INT,
  `pizza_name` TEXT
);
INSERT INTO `pizza_names` (`pizza_id`, `pizza_name`)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS `pizza_recipes`;
CREATE TABLE `pizza_recipes` (
  `pizza_id` INT,
  `toppings` TEXT
);
INSERT INTO `pizza_recipes` (`pizza_id`, `toppings`)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS `pizza_toppings`;
CREATE TABLE `pizza_toppings` (
  `topping_id` INT,
  `topping_name` TEXT
);
INSERT INTO `pizza_toppings` (`topping_id`, `topping_name`)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');


/* A. Pizza Metrics */

-- 1. How many pizzas were ordered?

select count(pizza_id) as Number_of_Pizza_Ordered
from customer_orders;

-- 2. How many unique customer orders were made?

Select count(distinct(order_id)) as Number_of_Ordered
from customer_orders;

-- 3. How many successful orders were delivered by each runner?

Select runner_id, count(order_id) as No_of_Orders
from runner_orders
where distance <> 0 
group by runner_id;

-- 4. How many of each type of pizza was delivered?

select pn.pizza_name, count(co.pizza_id) as number_of_pizza_ordered
from customer_orders as  co
inner join runner_orders as ro
on co.order_id = ro.order_id
inner join pizza_names as pn
on co.pizza_id = pn.pizza_id
where ro.distance <> 0
group by pn.pizza_name;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

select co.customer_id, pn.pizza_name, count(co.pizza_id) as number_of_pizza_ordered
from customer_orders as  co
inner join pizza_names as pn
on co.pizza_id = pn.pizza_id
group by pn.pizza_name, co.customer_id
order by co.customer_id, pn.pizza_name;

-- 6. What was the maximum number of pizzas delivered in a single order?

select co.order_id, count(co.pizza_id) as number_of_pizza_ordered
from customer_orders as  co
inner join runner_orders as ro
on co.order_id = ro.order_id
where ro.distance <> 0 
group by co.order_id
order by number_of_pizza_ordered desc
limit 1;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

select co.customer_id, count(co.pizza_id) as number_of_pizza_ordered,
sum(case
when co.exclusions <> "" or co.extras <> ""
then  1
else 0 end) as at_least_1_change,
sum(case
when co.exclusions = "" and co.extras = ""
then  1
else 0 end)
as no_changes
from customer_orders as  co
inner join runner_orders as ro
on co.order_id = ro.order_id
where ro.distance <> 0
group by co.customer_id;


-- 8. How many pizzas were delivered that had both exclusions and extras? TBD with Someone used chatgpt code

SELECT 
    COUNT(*) AS pizzas_with_exclusions_and_extras
FROM 
    customer_orders AS co
INNER JOIN 
    runner_orders AS ro
    ON co.order_id = ro.order_id
WHERE 
    ro.pickup_time IS NOT NULL  -- Ensure the order was picked up
    AND (ro.cancellation IS NULL OR ro.cancellation = '') -- No cancellation
    AND ro.distance IS NOT NULL 
    AND ro.distance <> '0'
    AND co.exclusions IS NOT NULL 
    AND co.exclusions <> '' 
    AND co.extras IS NOT NULL 
    AND co.extras <> '';

-- 9. What was the total volume of pizzas ordered for each hour of the day?

select hour(co.order_time) as order_hour, count(co.order_id)
from customer_orders as co
group by co.order_time
order by order_hour;

-- 10. What was the volume of orders for each day of the week?

select dayname(co.order_time) as Weekdayyyy, count(distinct(co.order_id)) as count_of_order
from customer_orders as co
group by Weekdayyyy
order by count_of_order;

/*
B. Runner and Customer Experience
Need to work on data cleaning specially text to int, delimit and all in this exercise and hence left incomplete.
TBD with other classmates
*/

-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01) tbd witrh someone code copies from the chatgpt

select year(ru.registration_date) as Year_, week(ru.registration_date) as Week_, count(*) as runners_signed_up
from runners as ru
group by Year_, Week_
order by Year_, Week_
;

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

with runner_time as (
select ro.runner_id,
timestampdiff(minute, co.order_time, ro.pickup_time) as runner_time
from customer_orders as co
inner join runner_orders as ro
on co.order_id = ro.order_id)

select runner_id, avg(runner_time) from runner_time
group by ro.runner_id;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

with runner_time as (
select co.order_id, co.pizza_id,
timestampdiff(minute, co.order_time, ro.pickup_time) as time_to_cook
from customer_orders as co
inner join runner_orders as ro
on co.order_id = ro.order_id)

select order_id, pizza_id, sum(time_to_cook) from runner_time
group by order_id, pizza_id;

-- 4. What was the average distance travelled for each customer?

select co.customer_id, avg(ro.distance) as distance 
from customer_orders as co
inner join runner_orders as ro
on co.order_id = ro.order_id
group by co.customer_id;

-- 5. What was the difference between the longest and shortest delivery times for all orders?
-- TBD concept was clear but now sure about how to chnage the datatype as the data was in text form

SELECT 
    MAX(CAST(SUBSTRING_INDEX(ro.duration, ' ', 1) AS UNSIGNED)) - MIN(CAST(SUBSTRING_INDEX(ro.duration, ' ', 1) AS UNSIGNED)) AS diff_
FROM 
    runner_orders AS ro
WHERE 
    ro.duration IS NOT NULL AND ro.duration != 'null';

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

select order_id, division(distance,duration) as speed
from runner_orders;

-- 7. What is the successful delivery percentage for each runner?

