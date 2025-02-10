-- --------------------------------------------------------------------------------------------------------------------------
                               # IMPORT DATA
-- --------------------------------------------------------------------------------------------------------------------------


SELECT * FROM `sql - retail sales analysis_utf`;
CREATE TABLE Sales_Retail
(
transaction_id INT PRIMARY KEY,
sale_date DATE,
sale_time TIME,
customer_id INT,
gender VARCHAR(10),
age INT,
category VARCHAR(35),
quantity INT,
price_per_unit FLOAT,
cogs FLOAT,
total_sales FLOAT
);
SELECT * FROM sales_retail ;
INSERT INTO Sales_Retail
SELECT * 
FROM `sql - retail sales analysis_utf`;
SELECT COUNT(*) FROM sales_retail;

# firstly i imported the table with table import wizard option 
# 2nd way, create a table and then insert values in it from first imported table
-- ------------------------------------------------------------------------------------------------------------------
# 3rd way, create a table then import data by table wizard option into it


CREATE TABLE Sales_Retail_02
(
transaction_id INT PRIMARY KEY,
sale_date DATE,
sale_time TIME,
customer_id INT,
gender VARCHAR(10),
age INT,
category VARCHAR(35),
quantity INT,
price_per_unit FLOAT,
cogs FLOAT,
total_sales FLOAT
);
SELECT * FROM sales_retail_02;

SELECT COUNT(*) FROM sales_retail_02;

-- --------------------------------------------------------------------------------------------------------------------------
                               # CHECK FOR DUPLICATES
-- --------------------------------------------------------------------------------------------------------------------------
 
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
# no duplicates

-- --------------------------------------------------------------------------------------------------------------------------
                               # STANDARDIZED THE DATA
-- --------------------------------------------------------------------------------------------------------------------------
SELECT * FROM sales_retail_02;
SELECT DISTINCT gender FROM sales_retail_02; # no spelling errors
SELECT DISTINCT category FROM sales_retail_02; 

-- --------------------------------------------------------------------------------------------------------------------------
                               # CHECK FOR NULL VALUES
-- --------------------------------------------------------------------------------------------------------------------------

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
    
SELECT * FROM sales_retail_02
WHERE transaction_id BETWEEN 745 AND 750
;
# 756 , 679, 1225 IS MISSING 

-- --------------------------------------------------------------------------------------------------------------------------
                               # DATA EXPLORATION
-- --------------------------------------------------------------------------------------------------------------------------
SELECT * FROM sales_retail_02;

# How many sales we have ?
SELECT SUM(total_sales) as `Total Sales`
from sales_retail_02 ;

# how many unique customers we have ?
SELECT COUNT(DISTINCT(customer_id)) as `Total Customers`
FROM sales_retail_02;

# how many categories we have ?
SELECT DISTINCT(category) as `Category`
FROM sales_retail_02;

# which gender shops more ?
SELECT gender, SUM(total_sales) AS `Sales`
FROM sales_retail
GROUP BY gender
ORDER BY `Sales` DESC; # females does more shopping

-- My Analysis & Findings
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05

SELECT * FROM sales_retail_02
WHERE sale_date = '2022-11-05';

# total sales on this day
SELECT sale_date,SUM(total_sales) as Sales
FROM sales_retail_02
WHERE sale_date = '2022-11-05'; 

-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022

SELECT * 
FROM sales_retail_02
WHERE (category = 'Clothing') 
AND 
quantity >= 4
AND
(DATE_FORMAT(sale_date, '%Y-%b') = '2022-Nov')
;

-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
SELECT category, SUM(total_sales) AS `Total Sales`, Count(*) as Total_Orders
FROM sales_retail_02
GROUP BY category
;

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

SELECT category, AVG(age) As 'Average Age'
FROM sales_retail_02
WHERE category = 'Beauty'
;

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.

SELECT *
FROM sales_retail_02
WHERE total_sales > 1000
;

-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.

SELECT category,gender,Count(*) AS 'Total Transactions'
FROM sales_retail_02
GROUP BY category,gender
order by 2
;

-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year

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
# July in 2022 and February in 2023 are best selling months


-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
SELECT customer_id AS CUSTOMER , SUM(total_sales) `TOTAL SALES`
FROM sales_retail_02
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5
;

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.

SELECT category,Count(DISTINCT(customer_id))
FROM sales_retail_02
group by 1
;
-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)
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

