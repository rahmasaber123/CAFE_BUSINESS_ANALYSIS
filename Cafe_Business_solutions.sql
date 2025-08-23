SELECT * FROM SALES;
SELECT * FROM PRODUCTS;
SELECT * FROM CITY;
SELECT * FROM CUSTOMERS;
-- BUSINESS ANALYSIS QUESTIONS


--Coffee Consumers Count
--How many people in each city are estimated to consume coffee, given that 25% of the population does?

select 
city_name,
ROUND((population * 0.25)/1000000 ,2)as coffee_consumers_in_mil
from city;

-- Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
select
ct.city_name,
sum(total) as total_revenue

from sales s
join 
customers c
on s.customer_id= c.customer_id
join city ct
on ct.city_id =c.city_id
where 
extract(year from s.sale_date)=2023
and
extract(quarter from s.sale_date) =4
group by 1
order by 2 desc
;

-- Sales Count for Each Product
-- How many units of each coffee product have been sold?
select
product_name,
count(distinct s.sale_id) as total_units_per_product
from sales s
right join products p
on 
p.product_id=s.product_id
group by 1
order by 2 desc;
-- Average Sales Amount per City
-- What is the average sales amount per customer in each city?
select
ct.city_name,
count(distinct c.customer_id) as total_customers,
sum(s.total) as revenue,
round (sum(s.total) :: numeric /count(distinct c.customer_id)::numeric ,2)as avg_sales_per_customer
from sales s
join customers c on
c.customer_id=s.customer_id
join city ct
on c.city_id= ct.city_id
group by 1
order by 2 desc 


-- City Population and Coffee Consumers
-- Provide a list of cities along with their populations and estimated coffee consumers.
-- return city name ,total customers and estimate coffee consumers
 with city_table as (select city_name,
round((population*0.25)/1000000 ,2)as coffee_consumers
from city)

,  customer_table as
(select

ct.city_name,
count(distinct c.customer_id) as total_customers
from sales s
join customers c
on c.customer_id =s.customer_id
join city ct
on ct.city_id=ct.city_id 
group by 1)
 select
 customer_table.city_name,
 customer_table.total_customers,
 city_table.coffee_consumers
 from customer_table 
 join city_table on
 customer_table.city_name =city_table.city_name



 

-- Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?
select* from
(select 
ct.city_name,
p.product_name,
count(sale_id) as total_orders ,
dense_rank() over (partition by ct.city_name order by count(sale_id) desc) as ranks
from sales s
join products p on
s.product_id=p.product_id
join customers c on
c.customer_id = s.customer_id 
join city ct
on ct.city_id = c.city_id
group by 1,2
) as table_1
where ranks<=3



-- Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?
select 
ct.city_name,
count(distinct c.customer_id) as total_unique_customers
from sales s
join customers c
on c.customer_id= s.customer_id
join city ct on
ct.city_id= c.city_id
where 
s.product_id in(1,2,3,4,5,6,7,8,9,10,11,12,13,14)
group by 1
order by 2

-- Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer
with city_sales as(
select
ct.city_name,
sum(s.total) as revenue,
count(distinct c.customer_id) as unique_cust,
ROUND
(sum(s.total)::numeric/count(distinct c.customer_id)::numeric,2) as AVRAGE_SALES_PER_C

from sales s
join customers c
on c.customer_id = s.customer_id
join city ct on
ct.city_id= c.city_id
group by 1),

city_rent as(
select
city_name, 
estimated_rent
from city)

select 
cs.city_name, 
cr.estimated_rent,
cs.unique_cust,
cs.AVRAGE_SALES_PER_C ,
round(estimated_rent ::numeric/unique_cust ::numeric,2)as avrage_rent
from city_sales cs
join city_rent cr
on cs.city_name=cr.city_name



-- Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).
with month_rate as
(select 
ct.city_name,
extract(month from sale_date) as month_sales,
extract(year from sale_date) as year_sales,
sum(s.total) as total_sales

from sales s
join customers c on 
c.customer_id =s.customer_id
join city ct on 
ct.city_id=c.city_id
group by 1,2,3
order by 1,3,2)
,
growth_ratio
as
(
select 
city_name ,
month_sales,
year_sales,
total_sales as cr_month_sales,
lag(total_sales ,1) over(partition by city_name order by year_sales, month_sales desc) as previous_month_sales
from month_rate)
select 

city_name ,
month_sales,
year_sales, 
cr_month_sales,


round((cr_month_sales-previous_month_sales)::numeric/previous_month_sales::numeric*100,2) as growth_ratio
from growth_ratio;

-- Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer

with city_sales as(
select
ct.city_name,
sum(s.total) as revenue,
count(distinct c.customer_id) as unique_cust,
ROUND
(sum(s.total)::numeric/count(distinct c.customer_id)::numeric,2) as AVRAGE_SALES_PER_C

from sales s
join customers c
on c.customer_id = s.customer_id
join city ct on
ct.city_id= c.city_id
group by 1),

city_rent as(
select
city_name, 
estimated_rent,
round((population*.25)/1000000,2) as estmated_coffee_consumers_millions

from city)

select 
cs.city_name, 
cr.estimated_rent as total_rent,
estmated_coffee_consumers_millions,
cs.unique_cust,
cs.AVRAGE_SALES_PER_C ,
round(estimated_rent ::numeric/unique_cust ::numeric,2)as avrage_rent
from city_sales cs
join city_rent cr
on cs.city_name=cr.city_name
order by 2desc
limit 3;

