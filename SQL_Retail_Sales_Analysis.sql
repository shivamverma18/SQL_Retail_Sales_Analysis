DROP DATABASE retail;
CREATE DATABASE retail;
USE retail;

-- Create Table -- 
CREATE TABLE retail_sales (
    transactions_id   INT PRIMARY KEY,
    sale_date         DATE,
    sale_time         TIME,
    customer_id       INT,
    gender            VARCHAR(10),
    age               INT,
    category          VARCHAR(20),
    quantity          INT NULL,
    price_per_unit    FLOAT NULL,
    cogs              FLOAT NULL,
    total_sale        FLOAT NULL
);

-- In Order to Include the Missing/Null/Blank Data Value We use this: (start1:end1)
-- start1

ALTER TABLE retail_sales
MODIFY transactions_id INT,
MODIFY sale_date DATE NULL,
MODIFY sale_time TIME NULL,
MODIFY customer_id INT NULL,
MODIFY gender VARCHAR(10) NULL,
MODIFY age INT NULL,
MODIFY category VARCHAR(20) NULL,
MODIFY quantity INT NULL,
MODIFY price_per_unit FLOAT NULL,
MODIFY cogs FLOAT NULL,
MODIFY total_sale FLOAT NULL;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/SQL_Retail_Sales_Analysis_utf _org_Copy_2.csv'
INTO TABLE retail_sales
FIELDS TERMINATED BY ','  
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@transactions_id, @sale_date, @sale_time, @customer_id, @gender, @age, @category, @quantity, @price_per_unit, @cogs, @total_sale)
SET 
    transactions_id = NULLIF(@transactions_id, ''),
    sale_date = NULLIF(@sale_date, ''),
    sale_time = NULLIF(@sale_time, ''),
    customer_id = NULLIF(@customer_id, ''),
    gender = NULLIF(@gender, ''),
    age = NULLIF(@age, ''),
    category = NULLIF(@category, ''),
    quantity = IF(@quantity REGEXP '^[0-9,.]+$', REPLACE(@quantity, ',', ''), NULL),
    price_per_unit = IF(@price_per_unit REGEXP '^[0-9,.]+$', REPLACE(@price_per_unit, ',', ''), NULL),
    cogs = IF(@cogs REGEXP '^[0-9,.]+$', REPLACE(@cogs, ',', ''), NULL),
    total_sale = IF(@total_sale REGEXP '^[0-9,.]+$', REPLACE(@total_sale, ',', ''), NULL);

SHOW VARIABLES LIKE 'secure_file_priv';

-- end1
 
SELECT * FROM retail_sales;

-- COUNT THE RECORDS -- 
SELECT COUNT(*) FROM 
retail_sales;

-- WILL TELL IF THERE IS ANY NULL VALUE PRESENT IN "transactions_id" TABLE
SELECT * FROM retail_sales 
WHERE transactions_id IS NULL;

-- 
SELECT * FROM retail_sales 
WHERE 
transactions_id IS NULL
OR
sale_date IS NULL
OR
sale_time IS NULL
OR
customer_id IS NULL
OR
gender IS NULL
OR
-- age IS NULL-- 
category IS NULL
OR 
quantity IS NULL
OR
price_per_unit IS NULL
OR
cogs IS NULL
OR
total_sale IS NULL;

SET SQL_SAFE_UPDATES = 0;

DELETE FROM retail_sales
WHERE 
    transactions_id IS NULL
    OR sale_date IS NULL
    OR sale_time IS NULL
    OR customer_id IS NULL
    OR gender IS NULL
    -- OR age IS NULL -- skipped
    OR category IS NULL
    OR quantity IS NULL
    OR price_per_unit IS NULL
    OR cogs IS NULL
    OR total_sale IS NULL;

-- Data Exploration

--  How many sales we have?
SELECT COUNT(*) AS total_sale from retail_sales;

--  How many customers we have?
SELECT COUNT(customer_id) AS total_customers FROM retail_sales;

--  How many unique customers we have?
SELECT COUNT(DISTINCT customer_id) AS total_unique_customers FROM retail_sales;

--  How many categories  we have?
SELECT COUNT(DISTINCT category) AS total_category FROM retail_sales;

-- Names of the category
SELECT DISTINCT Category FROM retail_sales;


-- Data Analysis & Business Key Problem & Answers -- 
-- Q1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
-- Q2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022
-- Q3 Write a SQL query to calculate the total sales (total_sale) for each category
-- Q4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
-- Q5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
-- Q6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
-- Q7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year.
-- Q8 Write a SQL query to find the top 5 customers based on the highest total sales.
-- Q9 Write a SQL query to find the number of unique customers who purchased items from each category.
-- Q10 Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)

-- Q1 Write a SQL query to retrieve all columns for sales made on '2022-11-05

SELECT * 
FROM retail_sales
WHERE sale_date = '2022-11-05';

-- Q2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than or 4 in the month of Nov-2022

SELECT *
FROM retail_sales
WHERE
	category = 'Clothing'
    AND
    quantity >= 4
    AND
    DATE_FORMAT(sale_date, '%Y-%m') = '2022-11';

-- Q3 Write a SQL query to calculate the total sales (total_sale) for each category

SELECT 
	category,
    SUM(total_sale) as net_sale,
    COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category;

-- Q4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

SELECT 
	category,
    ROUND(AVG(age),2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty';

-- IF need the avg age for Beauty as well as Clothing

SELECT 
    category,
    ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
WHERE category IN ('Beauty', 'Clothing')
GROUP BY category;

-- Q5 Write a SQL query to find all transactions where the total_sale is greater than 1000.

SELECT *
FROM retail_sales
WHERE
	total_sale > 1000;
    
-- Q6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.

SELECT 
	category,
    gender,
    COUNT(*) as total_transactions
FROM retail_sales
GROUP 
	BY
    category,
    gender
ORDER BY category;

-- Q7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year.

SELECT 
    year,
    month,
    avg_sale
FROM
(
    SELECT 
        YEAR(sale_date) AS year,
        MONTH(sale_date) AS month,
        ROUND(AVG(total_sale), 2) AS avg_sale,
        RANK() OVER (
            PARTITION BY YEAR(sale_date)
            ORDER BY ROUND(AVG(total_sale), 2) DESC
        ) AS sale_rank
    FROM retail_sales
    GROUP BY YEAR(sale_date), MONTH(sale_date)
) AS table1
WHERE sale_rank = 1;

-- Q8 Write a SQL query to find the top 5 customers based on the highest total sales.

SELECT 
	customer_id,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;

-- Q9 Write a SQL query to find the number of unique customers who purchased items from each category.

SELECT 
	    category,
	COUNT(DISTINCT customer_id) AS unique_customer_count
FROM retail_sales
GROUP BY category;

-- Q10 Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)

WITH hourly_sale
AS
(
SELECT *,
	CASE
		WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN "Afternoon"
        ELSE "Evening"
	END AS shift
FROM retail_sales
)
SELECT 
	shift,
    COUNT(*) AS total_order
FROM hourly_sale
GROUP BY shift;

SELECT EXTRACT(HOUR FROM current_time) AS Time_of_the_moment;

-- Check The Version 

SELECT VERSION();