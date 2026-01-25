# ---------- Selecting the Database Using Query -------------
Use pizza_database;

/* End  */

# ---------- Seeing the All tables in Databse ----------
Show tables;
/* End */

/*----------- All Tables ---------- */
SELECT * FROM ORDER_DETAILS;
SELECT * FROM ORDERS;
SELECT * FROM PIZZA_TYPES;
SELECT * FROM PIZZAS; 
/* ---------- End ---------- */

/* Retrieve the total number of orders placed. */
SELECT COUNT(*) AS Total_Orders FROM Orders;


/*  Calculate the total revenue generated from pizza sales. */
SELECT ROUND(SUM(quantity*price),2) AS Total_Revenue
FROM ORDER_DETAILS OD INNER JOIN PIZZAS PZ ON OD.pizza_id = PZ.pizza_id;

/*  Identify the highest-priced pizza. */
 
#        1. Solved by using SubQuery Method.
SELECT PT.name AS Pizza_Name,PT.category AS Pizza_Category,Pz.Price AS Highest_Price
FROM PIZZA_TYPES PT INNER JOIN PIZZAS PZ ON PT.pizza_type_id = PZ.pizza_type_id
WHERE PZ.Price = (SELECT MAX(Price) FROM PIZZAS);

#        2. Without Using SubQuery.
SELECT PT.name AS Pizza_Name,PT.category AS Pizza_Category,Pz.Price AS Highest_Price
FROM PIZZA_TYPES PT INNER JOIN PIZZAS PZ ON PT.pizza_type_id = PZ.pizza_type_id ORDER BY Pz.Price DESC LIMIT 1;


/*   Identify the most common pizza size ordered.    */
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM pizzas
JOIN order_details 
    ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC
LIMIT 1;


/* List the top 5 most ordered pizza types along with their quantities */
SELECT
    pizza_types.name,
    SUM(order_details.quantity) AS quantity
FROM pizza_types
JOIN pizzas
    ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
    ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;


/*  Determine the distribution of orders by hour of the day. */
SELECT
    HOUR(time) AS hour,
    COUNT(order_id) AS order_count
FROM orders
GROUP BY HOUR(time)
ORDER BY hour;

/* Determine the top 3 must ordered pizza types based on revenue. */
SELECT
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM pizza_types
JOIN pizzas
    ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN order_details
    ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

/* Calculate the percentage contribution of each  pizza type to total revenue */
SELECT
    pizza_types.category,
    ROUND(
        SUM(order_details.quantity * pizzas.price) /
        (SELECT SUM(od.quantity * p.price)
         FROM order_details od
         JOIN pizzas p
           ON od.pizza_id = p.pizza_id
        ) * 100, 2
    ) AS revenue_percentage
FROM pizza_types
JOIN pizzas
    ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
    ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue_percentage DESC;

/* Analyse the cumulative revenue generated over time */

SELECT
    date,
    ROUND(SUM(revenue) OVER (ORDER BY date),2) AS cum_revenue
FROM (
    SELECT
        orders.date,
        SUM(order_details.quantity * pizzas.price) AS revenue
    FROM order_details
    JOIN pizzas
        ON order_details.pizza_id = pizzas.pizza_id
    JOIN orders
        ON orders.order_id = order_details.order_id
    GROUP BY orders.date
) AS sales
ORDER BY date;

/* Determine the top 3 most ordered pizza types based on revenue for each pizza category */
 

   # 1. Using Subquery 
SELECT
    Pizza_name,
    ROUND(SUM(revenue),2) AS Total_revenue
FROM (
    SELECT
        pizza_types.name as Pizza_name,
        SUM(order_details.quantity * pizzas.price) AS revenue
    FROM order_details
    JOIN pizzas
        ON order_details.pizza_id = pizzas.pizza_id
    JOIN pizza_types
        ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    GROUP BY pizza_types.name
) AS sales GROUP BY Pizza_name
ORDER BY Total_revenue DESC LIMIT 3;

   #2. Using Windows Function
SELECT Pizza_name,Total_revenue FROM
(SELECT Pizza_name,Total_revenue,DENSE_RANK() OVER(ORDER BY Total_revenue DESC) as Rank_
FROM 
(SELECT pizza_types.name as Pizza_name,
		ROUND(SUM(pizzas.price * order_details.quantity),2) AS Total_revenue
        FROM pizzas 
        INNER JOIN
			 order_details
		ON
			pizzas.pizza_id = order_details.pizza_id
		INNER JOIN
			pizza_types
		ON   pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY Pizza_name) as t1 ) as t2 
WHERE Rank_ <= 3;

/*  Join the necessary tables to find the total quantity of each pizza category ordered.alter */

SELECT
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM pizza_types
JOIN pizzas
    ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
    ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;


/* Join relevant tables to find the category-wise distribution of pizzas.alter */

SELECT category, count(name) as Distribution FROM pizza_types GROUP BY category;

/* Group the orders by the date and calculate the average number of pizzas ordered per day.alter */
SELECT
    ROUND(AVG(daily_quantity), 2) AS avg_pizzas_per_day
FROM (
    SELECT
        orders.date,
        ROUND(SUM(order_details.quantity),2) AS daily_quantity
    FROM orders
    JOIN order_details
        ON orders.order_id = order_details.order_id
    GROUP BY orders.date
) AS order_quantity;





















