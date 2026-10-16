
-- Bank Customer Churn Analysis
-- Tool: MySQL | Dataset: Kaggle (Shantanu Dhakad)
-- Author: Hemalatha Santhanakrishnan
-- Date: October 2026

-- PART 1: DATABASE & TABLE SETUP

-- Create database
CREATE database IF NOT EXISTS bank_churn;
USE bank_churn;

-- Create customers table
CREATE TABLE customers (
    rownumber        INT,
    customer_id       BIGINT,
    surname           VARCHAR(100),
    credit_score      INT,
    geography         VARCHAR(50),
    gender            VARCHAR(10),
    age               INT,
    tenure            INT,
    balance           DECIMAL(15,2),
    num_of_products   INT,
    has_cr_card       INT,
    is_active_member  INT,
    estimated_salary  DECIMAL(15,2),
    exited            INT
);

-- Create credit segments table
CREATE TABLE credit_segments (
    segment_name    VARCHAR(50),
    min_score       INT,
    max_score       INT,
    risk_level      VARCHAR(20)
);

INSERT INTO credit_segments VALUES
('Poor',      300, 579, 'Very High Risk'),
('Fair',      580, 669, 'High Risk'),
('Good',      670, 739, 'Medium Risk'),
('Very Good', 740, 799, 'Low Risk'),
('Excellent', 800, 850, 'Very Low Risk');

SELECT * FROM credit_segments;


-- PART 2:DATA CLEANING AND VALIDATION 

--Count total rows 
USE bank_churn;
SELECT COUNT(*) FROM customers;
SELECT * FROM customers LIMIT 5;

--Checking for null values 
SELECT  COUNT(*) AS total, 
		COUNT(rownumber) AS rownumber,
		COUNT(customer_id) AS customer_id,
		COUNT(surname) AS surname,
		COUNT(credit_score) AS credit_score,
		COUNT(geography) AS geography,
		COUNT(gender) AS gender,
		COUNT(age) AS age,
		COUNT(tenure) AS tenure,
		COUNT(balance) AS balance ,
		COUNT(num_of_products) AS num_of_products,
		COUNT(has_cr_card) AS has_cr_card,
		COUNT(is_active_member)AS is_active_member,
		COUNT(estimated_salary) AS estimated_salary,
		COUNT(exited) AS exited 
	 FROM customers;
     
--Checking for unique values  
     SELECT DISTINCT geography, gender 
     FROM customers;
     
--Duplicate customer ids
SELECT customer_id, COUNT(*) AS occurences
FROM customers
GROUP BY (customer_id)
HAVING COUNT(*)>1;

--checking for Min and Max values
SELECT MIN(age) AS min_age , MAX(age) AS max_age,
 MIN(credit_score) AS min_creditscr , MAX(credit_score) AS max_creditscr,
 MIN(balance) AS min_balance , MAX(balance) AS max_balance,
 MIN(tenure)  AS min_tenure , MAX(tenure) AS mas_tenure 
FROM customers;


-- PART 3: ANALYSIS QUERIES



-- Q1: Overall Churn Rate
SELECT COUNT(*) AS total_customers, SUM(exited) AS total_churned,
ROUND(SUM(exited)*100.0/COUNT(*)  ,2) AS Overall_churnrate
FROM customers ;

-- Q2: Churn Rate by Country
SELECT COUNT(*) AS Total_customers, SUM(exited) AS total_churned,
ROUND(SUM(exited)*100.0/COUNT(*) , 2)AS Overall_churnrate, geography
FROM customers
GROUP BY geography 
ORDER BY overall_churnrate DESC ;

-- Q3: Churn Rate by Gender
SELECT COUNT(*) AS Total_customers, SUM(exited) AS total_churned,
ROUND(SUM(exited)*100.0/COUNT(*) , 2)AS Overall_churnrate, gender
FROM customers
GROUP BY gender 
ORDER BY overall_churnrate DESC ;

-- Q4: Average Credit Score -- Churned vs Non-Churned
SELECT COUNT(*) AS total_customers , ROUND(AVG(credit_score),2) AS avg_credit_score , exited
FROM customers
GROUP BY exited
ORDER BY exited DESC;


-- Q5: Churn Rate by Age Group
SELECT COUNT(*) AS total_customers, SUM(exited) AS total_churned , 
ROUND(SUM(exited)*100.0/COUNT(*) ,2) AS overall_churnrate, 
       CASE WHEN age <20 THEN 'teens'
       WHEN age BETWEEN 20 AND 29 THEN 'twentys'
       WHEN age BETWEEN 30 AND 39 THEN 'Thirtys'
       WHEN age BETWEEN 40 AND 49 THEN 'Fortys' 
       WHEN age BETWEEN 50 AND 59 THEN 'Fiftys'
       WHEN age >=60 THEN 'Senior_citizen'
       END AS Age_category 
FROM customers
GROUP BY age_category
ORDER BY Overall_churnrate DESC;


-- Q6: Churn Rate by Number of Products
SELECT COUNT(*) AS total_customers, SUM(exited) AS total_churned , 
ROUND(SUM(exited)*100.0/ COUNT(*) ,2) AS overall_churnrate , num_of_products
FROM customers
GROUP BY num_of_products
ORDER BY overall_churnrate DESC;

-- Q7: Churn Rate -- Active vs Inactive Members
SELECT COUNT(*) AS total_customers, SUM(exited) AS total_churned , 
ROUND(SUM(exited)*100.0/ COUNT(*) ,2) AS overall_churnrate , is_active_member
FROM customers
GROUP BY is_active_member
ORDER BY overall_churnrate DESC;

-- Q8: Churn Rate by Tenure
SELECT COUNT(*) AS total_customers, SUM(exited) AS total_churned , 
ROUND(SUM(exited)*100.0/ COUNT(*) ,2) AS overall_churnrate , tenure
FROM customers
GROUP BY tenure
ORDER BY overall_churnrate DESC;

-- Q9: Number of Customers per Credit Segment (JOIN)
SELECT COUNT(*) AS total_customers, cs.segment_name , cs.risk_level
FROM customers c
JOIN credit_segments cs
ON c.credit_score BETWEEN cs.min_score AND cs.max_score
GROUP BY cs.segment_name, cs.risk_level;

-- Q10: Churn Rate by Credit Segment (JOIN)
SELECT COUNT(*) AS total_customers, SUM(c.exited) AS total_churned , 
ROUND(SUM(c.exited)*100.0/ COUNT(*) ,2) AS overall_churnrate ,cs.segment_name
FROM customers c
JOIN credit_segments cs
ON c.credit_score BETWEEN cs.min_score AND cs.max_score
GROUP BY cs.segment_name;

-- Q11: Average Balance per Risk Level (JOIN)
SELECT ROUND(AVG(c.balance) ,2) AS average_bal, cs.risk_level
FROM customers c
JOIN credit_segments cs
ON c.credit_score BETWEEN cs.min_score AND cs.max_score
GROUP BY cs.risk_level;

-- Q12: High Risk Customers by Country (JOIN)
SELECT COUNT(*) AS total_customers, cs.risk_level , c.geography
FROM customers c
JOIN credit_segments cs
ON c.credit_score BETWEEN cs.min_score AND cs.max_score
WHERE cs.risk_level IN ('High Risk', 'Very High Risk')
GROUP BY c.geography, cs.risk_level;

-- Q13: Country Ranking by Churn Rate (CTE + Window Function)
WITH churn_by_country AS
    (SELECT Count(*) AS total_customers, geography,
    ROUND(SUM(exited)*100.0/ COUNT(*) ,2) AS overall_churnrate
    FROM customers
    GROUP BY geography) 
SELECT total_customers, geography ,
  RANK() OVER (ORDER BY overall_churnrate DESC) AS Ranking_by_churnrate
FROM churn_by_country;


-- Q14: High Risk Inactive Churned Customers by Country (CTE + JOIN)
WITH high_risk_churned AS (SELECT c.geography 
FROM customers c
JOIN credit_segments cs
ON c.credit_score BETWEEN cs.min_score AND cs.max_score
WHERE risk_level In('High Risk', 'Very High Risk') AND is_active_member = 0 AND exited = 1
)
SELECT count(*) AS total_customers , geography 
FROM high_risk_churned 
GROUP BY geography;

-- Q15: Customers with Above Average Balance of Churned Customers (Subquery)
SELECT customer_id, geography , balance , exited 
FROM customers 
WHERE balance > (SELECT ROUND(AVG(balance),2) AS avgbal_churned 
                 FROM customers
                 WHERE exited = 1);

-- Q16: Churn Rate by Balance Category (CASE WHEN)
SELECT COUNT(*) AS total_customers , ROUND(SUM(exited)*100.0/COUNT(*) ,2) AS overall_churnrate,
CASE WHEN balance  =0 THEN 'zero balance' 
WHEN balance BETWEEN 1 AND 50000 THEN 'Low' 
WHEN balance BETWEEN 50001 AND 100000 THEN 'Medium' 
WHEN balance>100000 THEN 'High' 
END AS Balance_categories
FROM customers 
GROUP BY Balance_categories 
ORDER BY overall_churnrate DESC;

-- Q17: Highest Risk female Customer Profile Analysis
SELECT COUNT(*) AS total_customers ,ROUND(SUM(exited)*100.0/COUNT(*) ,2) AS overall_churnrate
FROM customers 
WHERE gender ='female' AND age BETWEEN 50 AND 59 AND is_active_member = 0 AND geography='Germany'
GROUP BY exited;
