create database pizza_sales_analysis;
use pizza_sales_analysis;
create table orders(
ord_id int not null,
ord_date date not null,
time time not null,
primary key(order_id));

create table ord_details(
ord_details_id int not null,
ord_id int not null,
pizza_id text not null,
quantity int not null,
primary key(ord_details_id));


-- 1 Rterive the total number of order placed
select count(ord_id) as total_order_placed from orders
 as total_orders;

-- 2 -- Calculate the total revenue generated from pizza sales.
select round(sum(o.quantity*p.price),2) as total_revenue
from order_details as o join
pizzas as p on p.pizza_id=o.pizza_id; 


-- 3 -- Identiy the highest-price pizza.
 select pi.price,p.name as highest_price_pizza
 from pizza_types as p
 join pizzas as pi 
 on p.pizza_type_id=pi.pizza_type_id 
 order by pi.price desc
 limit 1;
 
 -- 4 
-- Identify the most common pizza size ordered 
SELECT 
    pizzas.size, COUNT(ord_details.ord_details_id) as order_count
FROM
    pizzas
        JOIN
    ord_details ON pizzas.pizza_id = ord_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

-- 5 
-- list the top 5 most ordered pizza types along with theier quantities
select pizza_types.name,
sum(ord_details.quantity) as quantity
 from pizza_types join pizzas
 on pizza_types.pizza_type_id=pizzas.pizza_type_id
 join ord_details on
 ord_details.pizza_id=pizzas.pizza_id
 group by pizza_types.name order by quantity desc limit 5;
 
 -- 6.Join the necessary tables to find the total quantity of each pizza ordered
select pt.category,sum(ord_details.quantity) as total_quantity
from pizza_types as pt
join pizzas
on pt.pizza_type_id=pizzas.pizza_type_id
join ord_details
on ord_details.pizza_id=pizzas.pizza_id
group by pt.category order by total_quantity desc;
 
 -- 7-- determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hours, COUNT(ord_id) AS order_count
FROM
    orders
GROUP BY HOUR(time);

-- 8-- join relevant tables to find the category-wise distribution of pizzas
select category,count(name) as distribution from pizza_types
group by category;

-- 9 -- Group the orders by date and calculate the avergae number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 0) as average_ordered_pizza_perday
FROM
    (SELECT 
        orders.ord_Date, SUM(ord_details.quantity) AS quantity
    FROM
        orders
    JOIN ord_details ON ord.order_id = ord_details.order_id
    GROUP BY orders.ord_date) AS ord_quantity; 
    
-- 10. 
-- Determine the top 3 category pizza types based on revenue
select pt.category as most_ordered_pizzas ,sum(pizzas.price) as revenue
from pizzas join pizza_types as pt
on pizzas.pizza_type_id=pt.pizza_type_id
group by pt.category order by revenue desc limit 3; 

-- 11.
-- .Calculate the percentage contribution of each pizza type to the total revenue.
select pizza_types.category,
round(sum(order_details.quantity*pizzas.price)/(select 
round(sum(order_details.quantity*pizzas.price),2) as total_sales
from order_details
join pizzas
on pizzas.pizza_id=ord_details.pizza_id)*100,2)as revenue
from pizza_types join pizzas on
pizza_types.pizza_type_id=pizzas.pizza_type_id
join ord_details on ord_details.pizza_id=pizzas.pizza_id
group by pizza_types.category order by revenue desc;


-- 12 -- Analyze the cumulative revenue generated over time.
select order_date,
sum(revenue) over (order by order_date)as cum_revenue
from
(select orders.order_date,
sum(order_details.quantity*pizzas.price)as revenue 
from order_details join pizzas
on order_details.pizza_id=pizzas.pizza_id
join orders 
on orders.order_id=order_details.order_id
group by orders.order_date) as sales;


-- 13 -- Determine the top 3 most orderd pizza types  baesd on revenue for each pizza categroy
select name,revenue from
(select category,name,revenue,
rank() over (partition by category order by revenue desc)as rn
from 
(select pizza_types.category,pizza_types.name,
sum((order_details.quantity)*pizzas.price)as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category,pizza_types.name) as a) as b
where rn<= 3;
