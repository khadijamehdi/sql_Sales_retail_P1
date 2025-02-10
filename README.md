# Retail Sales Analysis SQL Project

## Project Overview

**Project Title**: Retail Sales Analysis  
**Level**: Beginner  
**Database**: `retail_sales`

This project is designed to demonstrate SQL skills and techniques typically used by data analysts to explore, clean, and analyze retail sales data. The project involves setting up a retail sales database,cleaning of data, performing exploratory data analysis (EDA), and answering specific business questions through SQL queries. This project is ideal for those who are starting their journey in data analysis and want to build a solid foundation in SQL.

## Objectives

1. **Set up a retail sales database**: Create and populate a retail sales database with the provided sales data.
2. **Data Cleaning**: Identify and remove any records with missing or null values.
3. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `retail_sales`.
- **Table Creation**: A table named `sales_retail_02` is created to store the sales data. The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount.

```sql
CREATE DATABASE retail_sales;

CREATE TABLE Sales_Retail_02
(
    transactions_id INT PRIMARY KEY,
    sale_date DATE,	
    sale_time TIME,
    customer_id INT,	
    gender VARCHAR(10),
    age INT,
    category VARCHAR(35),
    quantity INT,
    price_per_unit FLOAT,	
    cogs FLOAT,
    total_sale FLOAT
);
```

### 2. Data Exploration & Cleaning
- **Check for Duplicates**: Check if there is any duplicates in dataset.
- **Standardized the data**: Check for any spelling errors or wrong data type in dataset.
- **Record Count**: Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.
- **Null Value Check**: Check for any null values in the dataset and delete records with missing data.

```sql

WITH Duplicate_CTEs AS
(
SELECT * ,
ROW_NUMBER() OVER(Partition by  `sales_retail_02`.`transaction_id`,
    `sales_retail_02`.`sale_date`,
    `sales_retail_02`.`sale_time`,
    `sales_retail_02`.`customer_id`,
    `sales_retail_02`.`gender`,
    `sales_retail_02`.`age`,
    `sales_retail_02`.`category`,
    `sales_retail_02`.`quantity`,
    `sales_retail_02`.`price_per_unit`,
    `sales_retail_02`.`cogs`,
    `sales_retail_02`.`total_sales`) as row_num
FROM `retail_sales`.`sales_retail_02`
)
SELECT * FROM Duplicate_CTEs
WHERE row_num >1 ;

SELECT * FROM sales_retail_02;
SELECT DISTINCT gender FROM sales_retail_02; 
SELECT DISTINCT category FROM sales_retail_02;


SELECT COUNT(*) FROM sales_retail_02;
SELECT COUNT(DISTINCT customer_id) FROM sales_retail_02 ;


SELECT * FROM sales_retail_02
WHERE (
 `transaction_id`IS NULL OR
 `sale_date`IS NULL OR
    `sale_time`IS NULL OR
    `customer_id`IS NULL OR
    `gender` IS NULL OR 
    `age`IS NULL OR
    `category`IS NULL OR 
    `quantity`IS NULL OR
    `price_per_unit`IS NULL OR 
    `cogs`IS NULL OR 
    `total_sales`IS NULL
    );

DELETE FROM sales_retail_02
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;
```

### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:
1.**Write a sql query to determine the total sales**:
``` sql
SELECT SUM(total_sales) as `Total Sales`
from sales_retail_02 ;
```

2.**Write sql query to find out unique customers**:
```sql
SELECT COUNT(DISTINCT(customer_id)) as `Total Customers`
FROM sales_retail_02;
```

3.**Write sql query to find out the distinct categories**:
```sql
SELECT DISTINCT(category) as `Category`
FROM sales_retail_02;
```

4.**Write sql query to find which gender shops more**:
```sql
SELECT gender, SUM(total_sales) AS `Sales`
FROM sales_retail_02
GROUP BY gender
ORDER BY `Sales` DESC;
```

5. **Write a SQL query to retrieve all columns for sales made on '2022-11-05**:
```sql
SELECT * FROM sales_retail_02
WHERE sale_date = '2022-11-05';
```
6.**Write a SQL query to find the total sales made on '2022-11-05'**:
```sql
SELECT sale_date,SUM(total_sales) as Sales
FROM sales_retail_02
WHERE sale_date = '2022-11-05';
```

7. **Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022**:
```sql
SELECT * 
FROM sales_retail_02
WHERE (category = 'Clothing') 
AND 
quantity >= 4
AND
(DATE_FORMAT(sale_date, '%Y-%b') = '2022-Nov')
;
```

8. **Write a SQL query to calculate the total sales (total_sale) for each category.**:
```sql
SELECT category, SUM(total_sales) AS `Total Sales`, Count(*) as Total_Orders
FROM sales_retail_02
GROUP BY category;
```

9. **Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.**:
```sql
SELECT category, AVG(age) As 'Average Age'
FROM sales_retail_02
WHERE category = 'Beauty'
;
```

10. **Write a SQL query to find all transactions where the total_sale is greater than 1000.**:
```sql
SELECT *
FROM sales_retail_02
WHERE total_sales > 1000;
```

11. **Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.**:
```sql
SELECT category,gender,Count(*) AS 'Total Transactions'
FROM sales_retail_02
GROUP BY category,gender
order by 2;
```

12. **Write a SQL query to calculate the average sale for each month. Find out best selling month in each year**:
```sql
WITH Best_Selling_Month AS
(
SELECT date_format(sale_date,'%Y') 'Year',date_format(sale_date,'%M') 'Month' ,round(AVG(total_sales)) 'Average Sales',
RANK() OVER(PARTITION BY date_format(sale_date,'%Y') ORDER BY round(AVG(total_sales)) desc) AS `rank`
FROM sales_retail_02
GROUP BY 1,2
)
SELECT `Year`, `Month`, `Average Sales`
FROM Best_Selling_Month
WHERE `rank` = 1
; 
```

13. **Write a SQL query to find the top 5 customers based on the highest total sales**:
```sql
SELECT customer_id AS CUSTOMER , SUM(total_sales) `TOTAL SALES`
FROM sales_retail_02
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5
;
```

14. **Write a SQL query to find the number of unique customers who purchased items from each category.**:
```sql
SELECT category,Count(DISTINCT(customer_id))
FROM sales_retail_02
group by 1
;
```

15. **Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)**:
```sql
WITH Shifts AS 
(
SELECT *,
	CASE
		WHEN  EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
		WHEN  EXTRACT(HOUR FROM sale_time)  BETWEEN 12 AND 17 THEN 'AfterNoon'
		ELSE 'Evening'
	END as Shift
FROM sales_retail_02
)
SELECT Shift , COUNT(*) AS `Total Orders`
FROM Shifts
GROUP BY Shift
;
```

## Findings

- **Customer Demographics**: The dataset includes customers from various age groups, with sales distributed across different categories such as Clothing and Beauty.
- **High-Value Transactions**: Several transactions had a total sale amount greater than 1000, indicating premium purchases.
- **Sales Trends**: Monthly analysis shows variations in sales, helping identify peak seasons.
- **Customer Insights**: The analysis identifies the top-spending customers and the most popular product categories.

## Reports

- **Sales Summary**: A detailed report summarizing total sales, customer demographics, and category performance.
- **Trend Analysis**: Insights into sales trends across different months and shifts.
- **Customer Insights**: Reports on top customers and unique customer counts per category.

## Conclusion

This project serves as a comprehensive introduction to SQL for data analysts, covering database setup, data cleaning, exploratory data analysis, and business-driven SQL queries. The findings from this project can help drive business decisions by understanding sales patterns, customer behavior, and product performance.

## How to Use

1. **Clone the Repository**: Clone this project repository from GitHub.
2. **Run the Queries**: Use the SQL queries provided in the `Project 03 (SALES).sql` file to perform your analysis.
3. **Explore and Modify**: Feel free to modify the queries to explore different aspects of the dataset or answer additional business questions.

## Author - Khadija Mehdi

This project is part of my portfolio, showcasing the MySQL skills essential for data analyst roles.
### Stay Updated and Join the Community

- **LinkedIn**: [Connect with me professionally](https://www.linkedin.com/in/1khadijamehdi/)

Thank you for your support, and I look forward to connecting with you!
