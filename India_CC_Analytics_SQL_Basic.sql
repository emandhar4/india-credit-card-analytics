-- ============================================================
--  INDIA CREDIT CARD ANALYTICS — SQL QUERIES
--  Source: Kaggle — Analyzing Credit Card Spending Habits in India
--  Author: Mandhar Eppakayala | Portfolio Project
-- ============================================================


-- ─────────────────────────────────────────────────────────────
-- 1. DATABASE & TABLE SETUP
-- ─────────────────────────────────────────────────────────────

CREATE DATABASE india_cc_analytics;
USE india_cc_analytics;

CREATE TABLE transactions (
    transaction_id  INT AUTO_INCREMENT PRIMARY KEY,
    city            VARCHAR(100),
    date            DATE,
    card_type       VARCHAR(30),
    expense_type    VARCHAR(50),
    gender          CHAR(1),
    amount          DECIMAL(12,2),
    month           VARCHAR(15),
    year            INT,
    quarter         VARCHAR(5)
);


-- ─────────────────────────────────────────────────────────────
-- 2. EXPLORATORY QUERIES
-- ─────────────────────────────────────────────────────────────

-- How many total transactions are there?
SELECT COUNT(*) AS total_transactions
FROM transactions;

-- What is the total, average, min, and max spend?
SELECT
    SUM(amount)   AS total_spend,
    AVG(amount)   AS avg_transaction,
    MIN(amount)   AS min_transaction,
    MAX(amount)   AS max_transaction
FROM transactions;

-- What years are in the dataset?
SELECT DISTINCT year
FROM transactions
ORDER BY year;


-- ─────────────────────────────────────────────────────────────
-- 3. SPENDING BY CATEGORY
-- ─────────────────────────────────────────────────────────────

-- Total spend and transaction count by expense category
SELECT
    expense_type,
    COUNT(*)            AS transaction_count,
    SUM(amount)         AS total_spend,
    ROUND(AVG(amount), 2) AS avg_transaction
FROM transactions
GROUP BY expense_type
ORDER BY total_spend DESC;


-- ─────────────────────────────────────────────────────────────
-- 4. MONTHLY SPENDING TRENDS
-- ─────────────────────────────────────────────────────────────

-- Total spend by month and year
SELECT
    year,
    month,
    COUNT(*)              AS transaction_count,
    SUM(amount)           AS total_spend,
    ROUND(AVG(amount), 2) AS avg_transaction
FROM transactions
GROUP BY year, month
ORDER BY year, total_spend DESC;

-- Which month had the highest spend overall?
SELECT
    year,
    month,
    SUM(amount) AS total_spend
FROM transactions
GROUP BY year, month
ORDER BY total_spend DESC
LIMIT 5;


-- ─────────────────────────────────────────────────────────────
-- 5. CITY ANALYSIS
-- ─────────────────────────────────────────────────────────────

-- Top 10 cities by total spend
SELECT
    city,
    COUNT(*)              AS transaction_count,
    SUM(amount)           AS total_spend,
    ROUND(AVG(amount), 2) AS avg_transaction
FROM transactions
GROUP BY city
ORDER BY total_spend DESC
LIMIT 10;

-- How many unique cities are in the dataset?
SELECT COUNT(DISTINCT city) AS unique_cities
FROM transactions;


-- ─────────────────────────────────────────────────────────────
-- 6. CARD TYPE ANALYSIS
-- ─────────────────────────────────────────────────────────────

-- Spend breakdown by card type
SELECT
    card_type,
    COUNT(*)              AS transaction_count,
    SUM(amount)           AS total_spend,
    ROUND(AVG(amount), 2) AS avg_transaction
FROM transactions
GROUP BY card_type
ORDER BY total_spend DESC;


-- ─────────────────────────────────────────────────────────────
-- 7. GENDER ANALYSIS
-- ─────────────────────────────────────────────────────────────

-- Total spend by gender
SELECT
    gender,
    COUNT(*)              AS transaction_count,
    SUM(amount)           AS total_spend,
    ROUND(AVG(amount), 2) AS avg_transaction
FROM transactions
GROUP BY gender;

-- Spend by gender broken down by category
SELECT
    expense_type,
    SUM(CASE WHEN gender = 'F' THEN amount ELSE 0 END) AS female_spend,
    SUM(CASE WHEN gender = 'M' THEN amount ELSE 0 END) AS male_spend,
    COUNT(CASE WHEN gender = 'F' THEN 1 END)           AS female_transactions,
    COUNT(CASE WHEN gender = 'M' THEN 1 END)           AS male_transactions
FROM transactions
GROUP BY expense_type
ORDER BY (female_spend + male_spend) DESC;


-- ─────────────────────────────────────────────────────────────
-- 8. YEAR OVER YEAR COMPARISON
-- ─────────────────────────────────────────────────────────────

-- Total spend per year
SELECT
    year,
    COUNT(*)    AS transaction_count,
    SUM(amount) AS total_spend
FROM transactions
GROUP BY year
ORDER BY year;

-- Spend by category for 2014 vs 2015
SELECT
    expense_type,
    SUM(CASE WHEN year = 2014 THEN amount ELSE 0 END) AS spend_2014,
    SUM(CASE WHEN year = 2015 THEN amount ELSE 0 END) AS spend_2015
FROM transactions
WHERE year IN (2014, 2015)
GROUP BY expense_type
ORDER BY spend_2014 DESC;


-- ─────────────────────────────────────────────────────────────
-- 9. QUARTERLY TRENDS
-- ─────────────────────────────────────────────────────────────

-- Spend by quarter
SELECT
    year,
    quarter,
    COUNT(*)              AS transaction_count,
    SUM(amount)           AS total_spend,
    ROUND(AVG(amount), 2) AS avg_transaction
FROM transactions
GROUP BY year, quarter
ORDER BY year, quarter;


-- ─────────────────────────────────────────────────────────────
-- 10. FILTERS & SPECIFIC LOOKUPS
-- ─────────────────────────────────────────────────────────────

-- Show all transactions over 500,000 INR
SELECT *
FROM transactions
WHERE amount > 500000
ORDER BY amount DESC;

-- Show spend for a specific city (example: Mumbai)
SELECT
    expense_type,
    COUNT(*)    AS transaction_count,
    SUM(amount) AS total_spend
FROM transactions
WHERE city LIKE '%Mumbai%'
GROUP BY expense_type
ORDER BY total_spend DESC;

-- Show Platinum card transactions in 2015
SELECT *
FROM transactions
WHERE card_type = 'Platinum'
  AND year = 2015
ORDER BY amount DESC
LIMIT 20;
