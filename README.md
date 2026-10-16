# Bank Customer Churn Analysis

## Project Overview
SQL analysis of bank customer churn patterns using a dataset of 10,000 customers 
from a European bank. The goal is to identify key drivers of churn to help the 
bank improve customer retention.

## Tools Used
- MySQL (MySQL Workbench)
- Dataset: [Bank Customer Churn Prediction](https://www.kaggle.com/datasets/shantanudhakadd/bank-customer-churn-prediction) - Kaggle

## Database Structure
- `customers` - 10,000 rows, 14 columns (demographics, account info, churn status)
- `credit_segments` - 5 rows (credit score ranges mapped to risk levels)

## SQL Skills Demonstrated
- Aggregations (COUNT, SUM, AVG)
- GROUP BY and HAVING
- CASE WHEN for custom categorisation
- JOIN and Range JOIN (BETWEEN)
- Subqueries (WHERE)
- CTEs (WITH clause)
- Window Functions (RANK)

## Key Findings
- Overall churn rate is **20.37%** - higher than industry average
- **Germany** has the highest churn rate at **32.44%** - double France and Spain
- **Female customers** churn at 25.07% vs 16.46% for male customers
- Customers in their **50s** have the highest churn rate at **56.04%**
- Customers with **4 products** churn at 100% - too many products increases churn
- **Inactive members** churn at nearly double the rate of active members (26.85% vs 14.27%)
- Highest risk profile: **German, inactive, female customers aged 50-59** 

## Files
- `bank_churn_analysis.sql` - complete SQL queries (setup, cleaning, analysis)
- `Churn_Modelling.csv` - raw dataset
