##create table in your danny_diner database

create table sales
(customer_id varchar not null,
order_date date,
product_id int)

insert into sales
(customer_id, order_date, product_id)
    values('A', '2021-01-01', 1),
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
          ('C', '2021-01-07', 3)

create table menu
(product_id int, product_name varchar, price int)

insert into menu
(product_id, product_name, price)
    values(1, 'sushi', 10),
          (2, 'curry', 15),
          (3, 'ramen', 12)

create table members
(customer_id varchar(1), join_date timestamp)

insert into members
(customer_id, join_date)
    values('A', '2021-01-07'),
          ('B', '2021-01-09')

select * from menu
join sales
    on menu.product_id = sales.product_id
right join members
    on sales.customer_id = members.customer_id

##QUESTIONS:
##1. What is the total amount each customer spent at the restaurant?
To get this, we have to join the menu and the sales table.

SELECT DISTINCT customer_id, SUM(price) AS total_amount
FROM sales
RIGHT JOIN menu
	ON sales.product_id = menu.product_id
GROUP BY customer_id
ORDER BY 2 DESC;

##2. How many days has each customer visited the restaurant?

SELECT DISTINCT customer_id, COUNT(order_date) AS times_visited FROM sales
GROUP BY customer_id
ORDER BY 1;

##3. What was the first item from the menu purchased by each customer?

SELECT DISTINCT product_name, customer_id, order_date FROM sales
RIGHT JOIN menu
ON sales.product_id = menu.product_id
ORDER BY 3;

##4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT DISTINCT product_name, COUNT(menu.product_id) AS times_purchased 
FROM sales
RIGHT JOIN menu
	ON sales.product_id = menu.product_id
GROUP BY product_name 
ORDER BY 2 DESC LIMIT 1;

##5. Which item was the most popular for each customer?
SELECT DISTINCT customer_id, COUNT(menu.product_id) AS item_count, 
product_name
FROM sales JOIN menu
    ON sales.product_id = menu.product_id
GROUP BY 1, 3
ORDER BY 2 DESC;

##6. Which item was purchased first by the customer after they became a member? 

WITH CTE AS(SELECT DISTINCT members.customer_id, join_date, order_date, product_name,
            DENSE_RANK() OVER(
            PARTITION BY sales.customer_id
            ORDER BY order_date) AS ranks
FROM members RIGHT JOIN sales
    ON members.customer_id = sales.customer_id
INNER JOIN menu 
    ON sales.product_id = menu.product_id
    WHERE order_date >= join_date)

SELECT customer_id, order_date, product_name
FROM CTE
      WHERE ranks = 1;

##7. Which item was purchased just before the customer became a member?

WITH CTE AS(SELECT DISTINCT members.customer_id, join_date, order_date, product_name,
        DENSE_RANK() OVER(
        PARTITION BY sales.customer_id
        ORDER BY order_date DESC) AS ranks
FROM members JOIN sales
    ON members.customer_id = sales.customer_id
INNER JOIN menu 
    ON sales.product_id = menu.product_id
    WHERE order_date < join_date)

SELECT customer_id, order_date, product_name
 FROM CTE
    WHERE ranks =1;

##8. What is the total items and amount spent for each member before they became a member?

SELECT DISTINCT m.customer_id, COUNT(s.product_id) AS total_item, SUM(price) AS total_amount
FROM members AS m JOIN sales AS s
    ON m.customer_id = s.customer_id
INNER JOIN menu AS me
    ON s.product_id = me.product_id
         WHERE order_date < join_date
    GROUP BY 1;
       
##9. If each $1 spent equates to 10 points and sushi has a 2X points multiplier-how many points would each customer have?
 SOLVE:
The best way to achieve this is using a CASE STATEMENT. However, for sushi, every $1 is 20 points.

WITH CTE AS(SELECT DISTINCT *,
    CASE
        WHEN product_id =1 THEN price * 20
        ELSE price * 10
            END AS points
FROM menu
   ORDER BY 1)
SELECT customer_id, SUM(points) AS total_points
FROM CTE
       JOIN sales 
        ON CTE.product_id = sales.product_id
GROUP BY 1
ORDER BY 2 DESC;

