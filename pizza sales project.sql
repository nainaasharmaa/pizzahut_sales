-- Retrieve the total number of orders placed.
use pizzahut;
select count(order_id) from orders as total_orders;
-- Calculate the total revenue generated from pizza sales.
select round(sum(order_details.quantity * pizzas.price),2) as total_sales from order_details join pizzas on pizzas.pizza_id = order_details.pizza_id;
-- Identify the highest-priced pizza.
SELECT pizza_types.name, pizzas.price
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id ORDER BY pizzas.price DESC LIMIT 1;
-- Identify the most common pizza size ordered.
SELECT pizzas.size,
       COUNT(order_details.order_details_id) AS order_count
FROM pizzas
JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC limit 1;
-- List the top 5 most ordered pizza types along with their quantities.
select pizza_types.name ,sum(order_details.quantity) as quantity from pizza_types join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id join order_details on order_details.pizza_id = pizzas.pizza_id group by pizza_types.name order by quantity desc limit 5;
-- Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.category,sum(order_details.quantity) as quantity from  pizza_types join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id join order_details on order_details.pizza_id = pizzas.pizza_id group by pizza_types.category order by quantity desc limit 5;
-- Determine the distribution of orders by hour of the day.
select hour(time) as hours,count(order_id) from orders group by hours;
-- Join relevant tables to find the category-wise distribution of pizzas.
select category,count(name) from pizza_types group by category;
-- Group the orders by date and calculate the average number of pizzas ordered per day.
select avg(quantity) from (select orders.date , sum(order_details.quantity) as quantity from orders join order_details on orders.order_id=order_details.order_id group by orders.date) as data;
-- Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.name,sum(pizzas.price* order_details.quantity) as revenue from pizza_types join pizzas on pizzas.pizza_type_id=pizzas.pizza_type_id join order_details on order_details.pizza_id=pizzas.pizza_id group by pizza_types.name order by revenue desc limit 3;
-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT
    pizza_types.name,
    ROUND(
        SUM(pizzas.price * order_details.quantity) /
        (
            SELECT SUM(order_details.quantity * pizzas.price)
            FROM order_details
            JOIN pizzas
            ON pizzas.pizza_id = order_details.pizza_id
        ) * 100,
        2
    ) AS revenue
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;
-- Analyze the cumulative revenue generated over time.
SELECT date,
       SUM(revenue) OVER(ORDER BY date) AS cum_revenue
FROM (
    SELECT orders.date,
           SUM(order_details.quantity * pizzas.price) AS revenue
    FROM order_details
    JOIN pizzas
        ON order_details.pizza_id = pizzas.pizza_id
    JOIN orders
        ON orders.order_id = order_details.order_id
    GROUP BY orders.date
) AS sales;
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT category,
       name,
       revenue
FROM (
    SELECT
        pizza_types.category,
        pizza_types.name,
        SUM(order_details.quantity * pizzas.price) AS revenue,
        RANK() OVER (
            PARTITION BY pizza_types.category
            ORDER BY SUM(order_details.quantity * pizzas.price) DESC
        ) AS rank_no
    FROM pizza_types
    JOIN pizzas
        ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    JOIN order_details
        ON pizzas.pizza_id = order_details.pizza_id
    GROUP BY pizza_types.category, pizza_types.name
) AS ranked_pizzas
WHERE rank_no <= 3
ORDER BY category, revenue DESC;