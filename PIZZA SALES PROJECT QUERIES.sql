-- Select top 5 rows from the table
	SELECT TOP 5 * FROM  orders;
	SELECT TOP 5 * FROM order_details;
	SELECT TOP 5 * FROM pizzas;
	SELECT TOP 5 * FROM pizza_types;

-- Retrieve the total number of orders 
	SELECT 
		COUNT(*) AS Total_Orders
	FROM 
		orders ;

-- Different type of Categories
	SELECT 
		DISTINCT category 
	FROM 
		pizza_types;

	SELECT 
		DISTINCT name 
	FROM 
		pizza_types;
S

-- Total revenue generated from pizza sales
	SELECT 
		ROUND(SUM(p.price*od.quantity),0) AS total_revenue 
	FROM 
		pizzas AS p
	JOIN 
		order_details AS od 
	ON 
		od.pizza_id=p.pizza_id;

-- Monthly Revenue Breakdown
	SELECT 
		MONTH(o.date) AS month,
		Round(SUM(p.price*od.quantity),0) AS Revenue 
	FROM 
		orders as o
	JOIN
		order_details AS od
	ON 
		o.order_id=od.order_id
	JOIN 
		pizzas AS p
	ON 
		od.pizza_id=p.pizza_id
	GROUP BY 
		MONTH(o.date)
	ORDER BY Revenue Desc;


--  Category-wise Revenue
	SELECT 
		pt.category AS Category_Name,
		Round(SUM(p.price*od.quantity),0) AS Revenue 
	FROM 
		order_details AS od
	JOIN 
		pizzas AS p
	ON 
		od.pizza_id=p.pizza_id
	JOIN 
		pizza_types AS pt
	ON 
		p.pizza_type_id=pt.pizza_type_id
	GROUP BY 
		pt.category
	ORDER BY Revenue Desc;

-- Top 5 Pizzas Based on price
	SELECT 
		TOP 5 pt.name ,pt.category,p.price
	FROM 
		pizza_types AS pt
	JOIN 
		pizzas AS p 
	ON 
		pt.pizza_type_id=p.pizza_type_id 
	ORDER BY 
		p.price DESC;

-- Most common pizza size ordered 
	SELECT 
		 p.size,COUNT(od.order_id) as size_count
	FROM 
		pizzas AS p
	JOIN 
		order_details as od
	ON 
		od.pizza_id=p.pizza_id
	GROUP BY 
		p.size 
	ORDER BY 
		size_count DESC;

-- Top 5 most ordered pizzas 
	SELECT TOP 5 
		pt.name,pt.category,
		SUM(od.quantity) AS sum_of_quantity 
	FROM 
		order_details AS od 
	JOIN 
		pizzas AS P ON od.pizza_id=p.pizza_id
	JOIN 
		pizza_types as pt 
	ON 
		p.pizza_type_id=pt.pizza_type_id
	GROUP BY 
		pt.name,pt.category
	ORDER BY 
		sum_of_quantity DESC;

-- Total quantity of each category ordered.
	SELECT 
		pt.category , sum(od.quantity) as total_quantity
	FROM 
		order_details as od
	JOIN 
		pizzas AS p 
	ON
		p.pizza_id = od.pizza_id
	JOIN
		pizza_types AS pt
	ON 
		pt.pizza_type_id=p.pizza_type_id
	GROUP BY 
		pt.category 
	ORDER BY 
		total_quantity DESC;

-- Distrubution of orders by hour of the day.
	SELECT 
		FORMAT(o.time,'HH') AS Hour,
		sum(od.quantity) AS Orders_Count
	FROM 
		orders as o
	JOIN
		order_details as od
	ON 
		o.order_id=od.order_id
	GROUP BY 
		FORMAT(o.time,'HH')
	ORDER BY Orders_count DESC;

-- Average number of pizza orders per day.
	WITH CTE AS (
		SELECT 
			o.date , SUM(od.quantity) AS TOTAL_ORDERS
		FROM
			orders AS o
		JOIN 
			order_details as od
		ON 
			o.order_id=od.order_id
		GROUP BY 
			o.date
			)
	SELECT AVG(TOTAL_ORDERS) AS average_orders FROM CTE;

-- Top 3 most ordered pizza types based on revenue
	SELECT TOP 3
		pt.name ,sum(od.quantity*p.price) as total_revenue
	FROM
		order_details AS od
	JOIN
		pizzas  AS p
	ON 
		od.pizza_id=p.pizza_id
	JOIN 
		pizza_types AS pt
	ON 
		pt.pizza_type_id=p.pizza_type_id
	GROUP BY 
		pt.name
	ORDER BY
		total_revenue DESC;

-- Calculate the percentage contribution of each pizza type to total revenue
	WITH TotalSales AS (
    SELECT 
        SUM(od.quantity * p.price) AS TotalSalesAmount
    FROM 
        order_details AS od
    JOIN 
        pizzas AS p ON od.pizza_id = p.pizza_id
)

SELECT 
    pt.category,
    SUM(od.quantity * p.price) * 100.0 / 
    (SELECT TotalSalesAmount FROM TotalSales) AS ContributionPercentage
FROM 
    order_details AS od
JOIN 
    pizzas AS p ON od.pizza_id = p.pizza_id
JOIN 
    pizza_types AS pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY 
    pt.category;


-- Calculate cummulative revenue generated over time
	SELECT 
		MONTH(date),SUM(revenue) 
		OVER(ORDER BY date) AS cummulative_sum
	FROM
	(
	SELECT 
		o.date as date, SUM(od.quantity*p.price) as revenue
	FROM 
		orders as o
	JOIN 
		order_details AS od
	ON 
		o.order_id=od.order_id
	JOIN 
		pizzas AS p
	ON
		p.pizza_id=od.pizza_id
		GROUP BY MONTH(o.date),o.date) AS sales
	;

	-- Determine top 3 most ordered pizza types based on revenue for each category
	SELECT * 
	FROM (
		SELECT *, RANK() OVER (
			PARTITION BY category ORDER BY revenue DESC
			) AS rank_num
		FROM (
			SELECT 
				pt.category, 
				pt.name, 
				SUM(od.quantity * p.price) AS revenue
			FROM  
				order_details AS od
			JOIN 
				pizzas AS p ON p.pizza_id = od.pizza_id
			JOIN 
				pizza_types AS pt 
				ON pt.pizza_type_id = p.pizza_type_id
			GROUP BY 
				pt.category, pt.name
		) AS a) AS b 
		WHERE rank_num < 4;


-------------------------------THANK YOU------------------------------


























