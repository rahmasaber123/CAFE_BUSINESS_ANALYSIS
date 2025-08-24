# CAFE_BUSINESS_ANALYSIS
THIS PROJECT GIVE A CLEAR SIGHT ABOUT A CAFE BUSINESS ANALYSIS ANSWERING QUESTIONS USING SQL QUERIES THAT HELP CAFE BUSINESS TO GROW 


## Project Overview

**Project Title** CAFE BUSINESS ANALYSIS  

**Database**: `CAFE_ANALYSIS`

This project demonstrates the implementation of a CAFE BUSINESS ANALYSIS using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library_project](https://github.com/rahmasaber123/CAFE_BUSINESS_ANALYSIS/blob/main/CAFE_PIC.jpeg?raw=true)

## Objectives

1. **Set up the CAFE BUSINESS ANALYSIS Database**: Create and populate the database with tables for Cities, Customers,Products, Sales, status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTE to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/rahmasaber123/CAFE_BUSINESS_ANALYSIS/blob/main/Cafe_schema.png?raw=true)

- **Database Creation**: Created a database named `CAFE_ANALYSIS`.
- **Table Creation**: Created tables for Cities, Customers, Products, Sales. Each table includes relevant columns and relationships.

```sql

DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS city;

-- Import Rules
-- 1st import to city
-- 2nd import to products
-- 3rd import to customers
-- 4th import to sales


CREATE TABLE city
(
	city_id	INT PRIMARY KEY,
	city_name VARCHAR(15),	
	population	BIGINT,
	estimated_rent	FLOAT,
	city_rank INT
);

CREATE TABLE customers
(
	customer_id INT PRIMARY KEY,	
	customer_name VARCHAR(25),	
	city_id INT,
	CONSTRAINT fk_city FOREIGN KEY (city_id) REFERENCES city(city_id)
);


CREATE TABLE products
(
	product_id	INT PRIMARY KEY,
	product_name VARCHAR(35),	
	Price float
);


CREATE TABLE sales
(
	sale_id	INT PRIMARY KEY,
	sale_date	date,
	product_id	INT,
	customer_id	INT,
	total FLOAT,
	rating INT,
	CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES products(product_id),
	CONSTRAINT fk_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id) 
);

-- END of SCHEMAS

```

### BUSINESS ANALYSIS SOLUTIONS

**--How many people in each city are estimated to consume coffee, given that 25% of the population does?**


```sql
select 
city_name,
ROUND((population * 0.25)/1000000 ,2)as coffee_consumers_in_mil
from city;


```
**What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?**

```sql
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
order 



```

**How many units of each coffee product have been sold?**


```sql
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


```

**City Population and Coffee Consumers Provide a list of cities along with their populations and estimated coffee consumers**

```sql
 with city_table as (select city_name,
round((population*0.25)/1000000 ,2)as coffee_consumers
from city)

,  customer_table as
  (
select
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


```


**Top Selling Products by City**


```sql
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


```



- **Customer Segmentation by City How many unique customers are there in each city who have purchased coffee products?**

```sql
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


```






 **Average Sale vs Rent Find each city and their average sale per customer and avg rent per customer**:

```sql
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



```

 **Monthly Sales Growth Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods**:

```sql
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

```


## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into CITIES , CUSTOMERS BEHAVIORS ,COFFEE CONSUMTIONS,REVENUES.
- **Summary Reports**: Aggregated data on high-demand CITIES andCOFFE CONSUMERS performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a CAFE BUSINESS ANALYSIS system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.

## How to Use

1. **Clone the Repository**: Clone this repository to your local machine.
   ```sh
   git clone https://github.com/rahmasaber123/CAFE_BUSINESS_ANALYSIS
   ```

2. **Set Up the Database**: Execute the SQL scripts in the `Schems.sql` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries in the `Cafe_Business_Solutions.sql` file to perform the analysis.
4. **Explore and Modify**: Customize the queries as needed to explore different aspects of the data or answer additional questions.

## Author - RAHMA SABER ABBAS 
