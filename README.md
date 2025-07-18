# 📊 Retail Sales Analysis SQL Project

## 📌 Project Overview  
In this project, I’ve worked on applying SQL to explore, clean, and analyze retail sales data. It covers everything from setting up the database to performing EDA and writing queries to answer real business-related questions. This has helped me strengthen my SQL basics and understand how data analysis works in practical scenarios — especially useful for anyone just starting out in this field.

## 🎯 Objectives

- 🛠️ **Set up a retail sales database**: Create and populate a retail sales database with the provided sales data.  
- 🧹 **Data Cleaning**: Identify and remove any records with missing or null values.  
- 📈 **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.  
- 💼 **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

## 🗂️ Project Structure

### 1️⃣ Database Setup

- 🗃️ **Database Creation**: The project starts by creating a database named `retail`.  
- 📄 **Table Creation**: A table named `retail_sales` is created to store the sales data. The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount.

```sql
CREATE DATABASE retail;

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
```

### 2️⃣ Handling Missing/Null/Blank Data

📥 I had a CSV file with ~2000 rows that included some missing and inconsistent data like 'NA', blank fields, and commas in numbers. Initially, MySQL was skipping or throwing errors on these rows. I solved it by preprocessing the import using @variables in the LOAD DATA INFILE command, replacing commas, and safely converting blank or non-numeric values to NULL using NULLIF() and REPLACE(). This ensured a complete and clean import of the dataset into MySQL.

```sql
In Order to Include the Missing/Null/Blank Data Value We use this: 
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
```

### 3️⃣ Data Exploration & Cleaning

- 🔢 **Record Count**: Determine the total number of records in the dataset.  
- 👥 **Customer Count**: Find out how many unique customers are in the dataset.  
- 🛍️ **Category Count**: Identify all unique product categories in the dataset.  
- ❌ **Null Value Check**: Check for any null values in the dataset and delete records with missing data.

```sql
SELECT COUNT(*) FROM retail_sales;
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;
SELECT DISTINCT category FROM retail_sales;

SELECT * FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;

DELETE FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;
```

### 4️⃣ Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. 🗓️ **Sales on a specific date**
```sql
SELECT * 
FROM retail_sales
WHERE sale_date = '2022-11-05';
```

2. 👕 **Clothing sales with quantity filter**
```sql
SELECT *
FROM retail_sales
WHERE
	category = 'Clothing'
    AND
    quantity >= 4
    AND
    DATE_FORMAT(sale_date, '%Y-%m') = '2022-11';
```

3. 💰 **Total sales by category**
```sql
SELECT 
	category,
    SUM(total_sale) as net_sale,
    COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category;
```

4. 🧴 **Average age of customers in 'Beauty' category**
```sql
SELECT 
	category,
    ROUND(AVG(age),2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty';
```

5. 📦 **Transactions with sales > 1000**
```sql
SELECT *
FROM retail_sales
WHERE
	total_sale > 1000;
```

6. 👨‍👩‍👧 **Transactions count by gender and category**
```sql
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
```

7. 📆 **Best selling month in each year**
```sql
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
```

8. 🏆 **Top 5 customers by sales**
```sql
SELECT 
	customer_id,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;
```

9. 🔄 **Unique customers by category**
```sql
SELECT 
	    category,
	COUNT(DISTINCT customer_id) AS unique_customer_count
FROM retail_sales
GROUP BY category;
```

10. ⏰ **Shift-wise order count**
```sql
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
```

## 📋 Findings

- 👥 **Customer Demographics**: The dataset includes customers from various age groups, with sales distributed across different categories such as Clothing and Beauty.  
- 💸 **High-Value Transactions**: Several transactions had a total sale amount greater than 1000, indicating premium purchases.  
- 📊 **Sales Trends**: Monthly analysis shows variations in sales, helping identify peak seasons.  
- 🧠 **Customer Insights**: The analysis identifies the top-spending customers and the most popular product categories.

## 📑 Reports

- 🧾 **Sales Summary**: A detailed report summarizing total sales, customer demographics, and category performance.  
- 📉 **Trend Analysis**: Insights into sales trends across different months and shifts.  
- 🔍 **Customer Insights**: Reports on top customers and unique customer counts per category.

## ✅ Conclusion

This project serves as a comprehensive introduction to SQL for data analysts, covering database setup, data cleaning, exploratory data analysis, and business-driven SQL queries. The findings from this project can help drive business decisions by understanding sales patterns, customer behavior, and product performance.

🙌 Thank you for your support, and I look forward to connecting with you!
