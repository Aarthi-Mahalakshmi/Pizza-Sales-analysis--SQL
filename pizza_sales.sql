Create database Pizza_sales
Use Pizza_sales
Select * from [dbo].[pizzas]
Select * from [dbo].[orders]
Select * from [dbo].[order_details]
Select * from [dbo].[pizza_types]


--Retrieve the total number of orders placed.
select COUNT(order_id)as total_orders from orders

--Calculate the total revenue generated from pizza sales.                    
Select round(sum(p.price * O.quantity),2) as total_revenue
from pizzas P 
JOIN 
order_details O
ON P.pizza_id=O.pizza_id

--Identify the highest-priced pizza.
Select TOP 1 p.price,pt.name
from pizzas p
join 
pizza_types pt
on p.pizza_type_id=pt.pizza_type_id
order by p.price desc

--Identify the most common pizza size ordered.
select p.size, COUNT(o.order_details_id) as order_count
from pizzas p
join
order_details o
on 
p.pizza_id=o.pizza_id
group by p.size
order by order_count desc


--List the top 5 most ordered pizza types along with their quantities.
  select TOP 5 pt.name, SUM(o.quantity) as quantity
  from pizza_types pt join pizzas p
  on pt.pizza_type_id =p.pizza_type_id
  join order_details o 
  on o.pizza_id= p.pizza_id
  group by pt.name
  order by quantity desc

  --Join the necessary tables to find the total quantity 
  --of each pizza category ordered.
  select pt.category, SUM(o.quantity) as quantity
  from pizza_types pt join pizzas p
  on pt.pizza_type_id =p.pizza_type_id
  join order_details o 
  on o.pizza_id= p.pizza_id
  group by pt.category
  order by quantity desc

-- Determine the distribution of orders by hour of the day.
select datepart(hour,time) as order_hour , 
count(order_id) as order_count from orders
group by datepart(hour,time)
order by order_hour


--Join relevant tables to find the category-wise distribution of pizzas.
select category , 
COUNT(name) as distribution_of_category from pizza_types
group by category  

--Group the orders by date and 
--calculate the average number of pizzas ordered per day.
Select avg(quantity) as avg_no_of_pizzas from
(select o.date, sum(od.quantity) as quantity
from orders o join order_details od
on o.order_id=od.order_id
group by o.date) as order_quantity

--Determine the top 3 most ordered pizza types based on revenue.
Select top 3 pt.name , 
round(sum(p.price * O.quantity),2) as revenue
from pizzas P JOIN order_details O
ON P.pizza_id=O.pizza_id
join pizza_types pt 
on P.pizza_type_id=PT.pizza_type_id
group by pt.name
order by revenue desc

--Calculate the percentage contribution of each pizza type to total revenue.
 select pt.category,
 (SUM(p.price * o.quantity) * 100.0 / (SELECT SUM(p.price * o.quantity) 
  FROM pizzas p JOIN order_details o ON p.pizza_id = o.pizza_id)) 
  AS revenue_percentage
 from pizzas p join order_details o
 on p.pizza_id=o.pizza_id
 join pizza_types pt
 on p.pizza_type_id=pt.pizza_type_id
 group by pt.category
 order by revenue_percentage desc

 -- Analyze the cumulative revenue generated over time.
 select date,
 sum(revenue) over(order by date) as cum_revenue
 from
 (Select orders.date,
 sum(od.quantity * p.price) as revenue
 from order_details od join pizzas p
 on od.pizza_id = p.pizza_id
 join orders 
 on orders.order_id = od.order_id
 group by orders.date) as sales

 -- Determine the top 3 most ordered pizza types 
 --based on revenue for each pizza category.
 select category,name, revenue from 
 (select category, name , revenue,
 rank() over(partition by category order by revenue desc) 
 as rn from
 (select pt.category ,pt.name,
 sum(od.quantity * p.price) as revenue
 from pizza_types pt join pizzas p
 on pt.pizza_type_id=p.pizza_type_id
 join order_details od
 on od.pizza_id=p.pizza_id
 group by pt.category, pt.name) as a)as b
 where rn <= 3
 order by category,rn

 






