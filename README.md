# 🇮🇳 India Credit Card Spending Analytics

> End-to-end data analytics project analyzing 26,052 credit card transactions across India — structured in Excel, queried in SQL, and visualized in Power BI.

---

## 📌 Project Overview

This project analyzes real-world credit card spending behavior across major Indian cities from 2013–2015. The goal was to uncover category-level spending patterns, identify high-value cities and card segments, and track trends over time — the kind of analysis common in financial services and consulting roles.


**Dataset:** [Analyzing Credit Card Spending Habits in India](https://www.kaggle.com/datasets/thedevastator/analyzing-credit-card-spending-habits-in-india) — Kaggle  
**Rows:** 26,052 transactions  
**Fields:** City, Date, Card Type, Expense Category, Gender, Amount

---

## 🛠️ Tools Used

| Layer | Tool | Purpose |
|-------|------|---------|
| Data cleaning | Excel (Power Query) | Standardization, null handling, derived columns |
| Exploration | Excel Pivot Tables | Initial category and city breakdowns |
| Analysis | SQL (MySQL) | Aggregations, YoY trends, window functions |
| Visualization | Power BI | Interactive dashboard |

---

## 📁 Repository Structure

india-credit-card-analytics/
├── data/
│   └── india_cc_sample.csv
├── excel/
│   └── India_CC_Analytics_Dashboard.xlsx
├── sql/
│   └── India_CC_Analytics_SQL.sql
└── README.md

## 🔍 Key Findings

- **Bills dominate spend** at 22.2% of total volume — essential categories (Bills + Grocery + Fuel) account for 55% of all transactions
- **Mumbai and Bengaluru** together represent 26%+ of total national spend
- **Silver cardholders** generate the most transactions despite being the lowest tier — suggesting high everyday usage among mass-market customers
- **Female vs. Male split** is near-even across most categories, with males slightly outspending in Fuel and females leading in Entertainment
- **Q4 seasonality** is visible in both 2014 and 2015 — spending spikes 20–30% in Oct–Dec (festive season)

---

## 🗄️ SQL Highlights

The `/sql` folder contains 10 production-ready queries including:

- Monthly spending by category with % of month
- Top 10 cities by total spend with ranking
- Year-over-year growth by category (2014 vs 2015)
- Rolling 3-month average spend using window functions
- Gender breakdown with female-to-male spend ratio
- High-value transaction outlier detection (top 1%)
- Essential vs. discretionary category split by year

---

## 📊 Excel Workbook Structure

| Sheet | Contents |
|-------|---------|
| `KPI_Summary` | 6 KPI cards + category and gender summary tables |
| `Raw_Data_Cleaned` | Standardized transactions with derived columns |
| `Category_Analysis` | Spend breakdown with visual bars and totals |
| `Monthly_Trends` | MoM change with dynamic Excel formulas |
| `Card_Type_Analysis` | Gold / Platinum / Silver / Signature comparison |
| `City_Analysis` | Top 10 cities ranked with medal tiers |

---

## 💡 Skills Demonstrated

- Data cleaning and standardization (Power Query, pandas)
- Normalized relational schema design (star schema)
- Advanced SQL — CTEs, window functions, CASE statements, subqueries
- Excel financial modeling conventions (formula-driven, no hardcoded values)
- Business storytelling — translating raw data into actionable findings

---

## 👤 Author

**Mandhar Eppakayala**
BBA in Management Information Systems — University of Georgia
[LinkedIn](https://www.linkedin.com/in/mandhar-eppakayala) · [GitHub](https://github.com/emandhar4)
