-- ============================================================
--  INDIA CREDIT CARD ANALYTICS — SQL SCRIPTS
--  Source: Kaggle — Analyzing Credit Card Spending Habits in India
--  Author: Mandhar Eppakayala | Portfolio Project
-- ============================================================


-- ─────────────────────────────────────────────────────────────
-- 1. DATABASE SETUP & NORMALIZED SCHEMA
-- ─────────────────────────────────────────────────────────────

CREATE DATABASE IF NOT EXISTS india_cc_analytics;
USE india_cc_analytics;

-- Dimension: Categories
CREATE TABLE dim_category (
    category_id   INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    category_group VARCHAR(50)   -- e.g. 'Essential', 'Discretionary'
);

-- Dimension: Card Types
CREATE TABLE dim_card_type (
    card_type_id  INT AUTO_INCREMENT PRIMARY KEY,
    card_type     VARCHAR(30) NOT NULL UNIQUE,
    tier_rank     INT          -- 1=Signature, 2=Platinum, 3=Gold, 4=Silver
);

-- Dimension: Cities
CREATE TABLE dim_city (
    city_id       INT AUTO_INCREMENT PRIMARY KEY,
    city_name     VARCHAR(100) NOT NULL,
    state         VARCHAR(100),
    country       VARCHAR(50) DEFAULT 'India'
);

-- Dimension: Date
CREATE TABLE dim_date (
    date_key      DATE PRIMARY KEY,
    day           INT,
    month_num     INT,
    month_name    VARCHAR(15),
    quarter       VARCHAR(5),
    year          INT,
    is_weekend    BOOLEAN
);

-- Fact: Transactions
CREATE TABLE fact_transactions (
    transaction_id  INT AUTO_INCREMENT PRIMARY KEY,
    date_key        DATE         NOT NULL,
    city_id         INT          NOT NULL,
    card_type_id    INT          NOT NULL,
    category_id     INT          NOT NULL,
    gender          CHAR(1)      CHECK (gender IN ('M', 'F')),
    amount          DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (date_key)     REFERENCES dim_date(date_key),
    FOREIGN KEY (city_id)      REFERENCES dim_city(city_id),
    FOREIGN KEY (card_type_id) REFERENCES dim_card_type(card_type_id),
    FOREIGN KEY (category_id)  REFERENCES dim_category(category_id),
    INDEX idx_date (date_key),
    INDEX idx_city (city_id),
    INDEX idx_category (category_id)
);


-- ─────────────────────────────────────────────────────────────
-- 2. SEED DIMENSION TABLES
-- ─────────────────────────────────────────────────────────────

INSERT INTO dim_category (category_name, category_group) VALUES
    ('Bills',         'Essential'),
    ('Grocery',       'Essential'),
    ('Fuel',          'Essential'),
    ('Food',          'Discretionary'),
    ('Travel',        'Discretionary'),
    ('Entertainment', 'Discretionary');

INSERT INTO dim_card_type (card_type, tier_rank) VALUES
    ('Signature', 1),
    ('Platinum',  2),
    ('Gold',      3),
    ('Silver',    4);


-- ─────────────────────────────────────────────────────────────
-- 3. ANALYTICAL QUERIES
-- ─────────────────────────────────────────────────────────────

-- ── Q1: Monthly Spending by Category ────────────────────────
SELECT
    d.year,
    d.month_name,
    d.month_num,
    c.category_name,
    COUNT(*)                          AS transaction_count,
    SUM(f.amount)                     AS total_spend,
    ROUND(AVG(f.amount), 2)           AS avg_transaction,
    ROUND(SUM(f.amount)
          / SUM(SUM(f.amount)) OVER (PARTITION BY d.year, d.month_num)
          * 100, 2)                   AS pct_of_month
FROM fact_transactions  f
JOIN dim_date           d ON f.date_key     = d.date_key
JOIN dim_category       c ON f.category_id  = c.category_id
GROUP BY d.year, d.month_num, d.month_name, c.category_name
ORDER BY d.year, d.month_num, total_spend DESC;


-- ── Q2: Top 10 Cities by Spend ───────────────────────────────
SELECT
    ci.city_name,
    COUNT(*)                AS transaction_count,
    SUM(f.amount)           AS total_spend,
    ROUND(AVG(f.amount), 2) AS avg_transaction,
    ROUND(SUM(f.amount) /
          (SELECT SUM(amount) FROM fact_transactions) * 100, 2) AS pct_of_total,
    RANK() OVER (ORDER BY SUM(f.amount) DESC) AS spend_rank
FROM fact_transactions f
JOIN dim_city          ci ON f.city_id = ci.city_id
GROUP BY ci.city_name
ORDER BY total_spend DESC
LIMIT 10;


-- ── Q3: Card Type Performance ────────────────────────────────
SELECT
    ct.card_type,
    ct.tier_rank,
    COUNT(*)                           AS transaction_count,
    SUM(f.amount)                      AS total_spend,
    ROUND(AVG(f.amount), 2)            AS avg_transaction,
    MIN(f.amount)                      AS min_transaction,
    MAX(f.amount)                      AS max_transaction,
    ROUND(STDDEV(f.amount), 2)         AS spend_std_dev,
    ROUND(SUM(f.amount) /
          SUM(SUM(f.amount)) OVER ()
          * 100, 2)                    AS pct_of_portfolio
FROM fact_transactions f
JOIN dim_card_type     ct ON f.card_type_id = ct.card_type_id
GROUP BY ct.card_type, ct.tier_rank
ORDER BY ct.tier_rank;


-- ── Q4: Gender Spend Analysis by Category ───────────────────
SELECT
    c.category_name,
    SUM(CASE WHEN f.gender = 'F' THEN f.amount ELSE 0 END)  AS female_spend,
    SUM(CASE WHEN f.gender = 'M' THEN f.amount ELSE 0 END)  AS male_spend,
    COUNT(CASE WHEN f.gender = 'F' THEN 1 END)              AS female_txns,
    COUNT(CASE WHEN f.gender = 'M' THEN 1 END)              AS male_txns,
    ROUND(
        SUM(CASE WHEN f.gender = 'F' THEN f.amount ELSE 0 END) /
        NULLIF(SUM(CASE WHEN f.gender = 'M' THEN f.amount ELSE 0 END), 0),
    2)                                                        AS female_to_male_ratio
FROM fact_transactions f
JOIN dim_category      c ON f.category_id = c.category_id
GROUP BY c.category_name
ORDER BY (female_spend + male_spend) DESC;


-- ── Q5: Year-over-Year Growth ────────────────────────────────
WITH yearly_spend AS (
    SELECT
        d.year,
        c.category_name,
        SUM(f.amount) AS total_spend
    FROM fact_transactions f
    JOIN dim_date     d ON f.date_key    = d.date_key
    JOIN dim_category c ON f.category_id = c.category_id
    WHERE d.year IN (2014, 2015)
    GROUP BY d.year, c.category_name
)
SELECT
    curr.category_name,
    prev.total_spend  AS spend_2014,
    curr.total_spend  AS spend_2015,
    curr.total_spend - prev.total_spend           AS yoy_change,
    ROUND((curr.total_spend - prev.total_spend)
          / prev.total_spend * 100, 2)            AS yoy_pct_change
FROM yearly_spend curr
JOIN yearly_spend prev
  ON curr.category_name = prev.category_name
 AND curr.year = 2015
 AND prev.year = 2014
ORDER BY yoy_pct_change DESC;


-- ── Q6: Biggest Spending Months ──────────────────────────────
SELECT
    d.year,
    d.month_name,
    SUM(f.amount)                                        AS total_spend,
    COUNT(*)                                             AS transaction_count,
    ROUND(AVG(f.amount), 2)                              AS avg_transaction,
    RANK() OVER (ORDER BY SUM(f.amount) DESC)            AS spend_rank,
    RANK() OVER (PARTITION BY d.year
                 ORDER BY SUM(f.amount) DESC)            AS rank_within_year
FROM fact_transactions f
JOIN dim_date          d ON f.date_key = d.date_key
GROUP BY d.year, d.month_num, d.month_name
ORDER BY total_spend DESC
LIMIT 12;


-- ── Q7: Rolling 3-Month Average Spend ───────────────────────
WITH monthly_totals AS (
    SELECT
        d.year,
        d.month_num,
        d.month_name,
        SUM(f.amount) AS monthly_spend
    FROM fact_transactions f
    JOIN dim_date d ON f.date_key = d.date_key
    GROUP BY d.year, d.month_num, d.month_name
)
SELECT
    year,
    month_name,
    monthly_spend,
    ROUND(AVG(monthly_spend) OVER (
        ORDER BY year, month_num
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2)  AS rolling_3mo_avg,
    ROUND(monthly_spend - LAG(monthly_spend)
          OVER (ORDER BY year, month_num), 2) AS mom_change
FROM monthly_totals
ORDER BY year, month_num;


-- ── Q8: Essential vs Discretionary Split ────────────────────
SELECT
    d.year,
    c.category_group,
    SUM(f.amount)                      AS total_spend,
    COUNT(*)                           AS transaction_count,
    ROUND(SUM(f.amount) /
          SUM(SUM(f.amount)) OVER (PARTITION BY d.year)
          * 100, 2)                    AS pct_of_year
FROM fact_transactions f
JOIN dim_date          d ON f.date_key    = d.date_key
JOIN dim_category      c ON f.category_id = c.category_id
GROUP BY d.year, c.category_group
ORDER BY d.year, c.category_group;


-- ── Q9: High-Value Transaction Outliers (top 1%) ─────────────
WITH percentiles AS (
    SELECT PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY amount) AS p99
    FROM fact_transactions
)
SELECT
    f.transaction_id,
    d.date_key,
    ci.city_name,
    ct.card_type,
    c.category_name,
    f.gender,
    f.amount,
    ROUND(f.amount / (SELECT AVG(amount) FROM fact_transactions), 2) AS times_avg
FROM fact_transactions f
JOIN dim_date     d  ON f.date_key    = d.date_key
JOIN dim_city     ci ON f.city_id     = ci.city_id
JOIN dim_card_type ct ON f.card_type_id = ct.card_type_id
JOIN dim_category  c ON f.category_id  = c.category_id
CROSS JOIN percentiles p
WHERE f.amount >= p.p99
ORDER BY f.amount DESC
LIMIT 50;


-- ── Q10: Weekend vs Weekday Spend Patterns ───────────────────
SELECT
    CASE WHEN d.is_weekend THEN 'Weekend' ELSE 'Weekday' END AS day_type,
    c.category_name,
    COUNT(*)                                                   AS transaction_count,
    SUM(f.amount)                                              AS total_spend,
    ROUND(AVG(f.amount), 2)                                    AS avg_transaction
FROM fact_transactions f
JOIN dim_date     d ON f.date_key    = d.date_key
JOIN dim_category c ON f.category_id = c.category_id
GROUP BY d.is_weekend, c.category_name
ORDER BY day_type, total_spend DESC;
