/* 
SQL ZOMATO CASE STUDY - PROJECT NO 1
QUESTIONS 
1. Find customers who have never ordered
2. Average Price/dish
3. Find the top restaurant in terms of the number of orders for a given month
4. restaurants with monthly sales greater than x for 
5. Show all orders with order details for a particular customer in a particular date range
6. Find restaurants with max repeated customers 
7. Month over month revenue growth of swiggy
8. Customer - favorite food

 */

use food;
show tables;
-- import csv files
rename table `zomato-schema - order_details` to order_details;
select * from zom;
drop table zom;
drop table zomato;
-- --------------------------------------------------------------
-- 1. CUSTOMERS WHO NEVER ORDERED
select name from users where user_id not in 
(select user_id from orders);

-- 2. Average Price/dish
select r_id,avg(amount) from orders  group by r_id;
select r_id,r_name from restaurants;

-- select r.r_name,o.r_id,avg(o.amount) avg_amount from orders o inner join restaurants r on r.r_id=o.r_id group by o.r_id,r.r_name;

/*
select * from food ;
select * from menu;
select f_id,avg(price) from menu group by f_id;
select f_id,f_name from food;*/
select f.f_id,f.f_name,round(avg(m.price),1) avg_price from food f inner join menu m on m.f_id=f.f_id group by f.f_id,f.f_name;

-- 3. Find the top restaurant in terms of the number of orders for a given month
show tables;
select * from restaurants;
select * from orders;

select distinct(monthname(date)) from orders;

select r_name,count(r.r_id) count,monthname(o.date) dat from restaurants r 
inner join orders o on r.r_id=o.r_id 
group by dat,r.r_id,r.r_name 
order by count desc limit 3;
-- ---------------------------------
-- 4. restaurants with monthly sales greater than 500 
select * from restaurants;
select * from orders;
select monthname(date) from orders;
select r.r_name,sum(o.amount) ams,monthname(o.date) dat from orders o 
inner join restaurants r on o.r_id=r.r_id 
group by dat,o.amount,r.r_name 
having ams>500;

SELECT r.r_name, max_sales.ams, max_sales.dat
FROM restaurants r
INNER JOIN (
    SELECT o.r_id, SUM(o.amount) as ams, MONTHNAME(o.date) as dat
    FROM orders o
    GROUP BY dat, o.r_id
    HAVING ams > 500
) as max_sales ON r.r_id = max_sales.r_id
INNER JOIN (
    SELECT MAX(ams) as max_ams, dat
    FROM (
        SELECT o.r_id, SUM(o.amount) as ams, MONTHNAME(o.date) as dat
        FROM orders o
        GROUP BY dat, o.r_id
        HAVING ams > 500
    ) as sales
    GROUP BY dat
) as max_month_sales ON max_sales.dat = max_month_sales.dat AND max_sales.ams = max_month_sales.max_ams;
-- -----

-- 5. Show all orders with order details for a particular customer in a particular date range

select * from users;
select * from restaurants;
select * from orders;
select * from order_details;
select * from food;

select * from orders where user_id = (select user_id from users where name = 'Ankit' );

-- how many orders ankit has done between 10th may to 10th june
select o.order_id,r.r_name from orders o 
join
restaurants r 
on r.r_id=o.r_id where user_id = 
(select user_id from users where name = 'Ankit' )
and 
date between '2022-06-10' and '2022-07-10';

-- final query
select o.order_id,r.r_name,f.f_name from orders as o 
join restaurants as r on r.r_id=o.r_id 
join order_details as od on od.order_id = o.order_id
join food as f on f.f_id = od.f_id
where user_id = 
(select user_id from users where name = 'Ankit'/* select name from users; */ )
and 
date between '2022-06-10' and '2022-07-10' /* between these --> select min(date),max(date) from orders; */;

-- 6. find restaurants with max repeated customers
select * from restaurants;
select * from orders;
select * from users;


SELECT r.r_id, r.r_name, u.user_id, u.name, COUNT(*) AS visit_count
FROM restaurants AS r
JOIN orders AS o ON r.r_id = o.r_id
JOIN users AS u ON u.user_id = o.user_id
GROUP BY r.r_id, r.r_name, u.user_id, u.name
HAVING COUNT(*) = (
  SELECT MAX(visit_count)
  FROM (
    SELECT r.r_id, u.user_id, COUNT(*) AS visit_count
    FROM restaurants AS r
    JOIN orders AS o ON r.r_id = o.r_id
    JOIN users AS u ON u.user_id = o.user_id
    GROUP BY r.r_id, u.user_id
  ) AS subquery
  WHERE r.r_id = subquery.r_id
)
ORDER BY r.r_id;

-- 7 month over month revenue growth
select * from order_details;
select sum(amount) from orders where date between '2022-05-01' and '2022-05-31';
select sum(amount),monthname(date) as dat from orders group by dat;

SELECT
    DATE_FORMAT(date, '%Y-%m') AS month,
    SUM(amount) AS revenue,
    LAG(SUM(amount)) OVER (ORDER BY DATE_FORMAT(date, '%Y-%m')) AS previous_revenue,
    (SUM(amount) - LAG(SUM(amount)) OVER (ORDER BY DATE_FORMAT(date, '%Y-%m'))) / LAG(SUM(amount)) OVER (ORDER BY DATE_FORMAT(date, '%Y-%m')) * 100 AS growth_percentage
FROM
    orders
GROUP BY
    DATE_FORMAT(date, '%Y-%m');

-- 8.  customers favourite food
select * from users;
select  * from menu;
select * from food;
select * from orders;
select * from restaurants;
-- how many times they have ordered the food
select user_id,max(r_id) from orders group by user_id;
-- select  from users as u join orders as o on u.user_id=o.user_id;
-- select o.user_id,r.r_id,r.r_name from orders o join restaurants r on r.r_id=o.r_id group by o.user_id,r.r_id ;
select max(r_id) from orders group by user_id;
select * from restaurants where r_id in (select max(r_id) from orders group by user_id);
select * from restaurants;
-- --
with temp as (select o.user_id,od.f_id,count(*) as freequency  from orders o join
order_details od on o.order_id = od.order_id group by o.user_id,od.f_id)

select u.name,f.f_name from temp t1 
join users u on u.user_id=t1.user_id 
join food f on f.f_id=t1.f_id 
where t1.freequency = 
(select max(freequency) from temp t2 where t1.user_id=t2.user_id);
-- ----------------------------------------------------------------------------------------------------------------------------------------------------