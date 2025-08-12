# SQL_Xmas_Sales

# 🎄 Christmas Sales Analysis (2018–2022)

**Author:** Harmony Pham  
**Role:** Business Analyst  
**Tools Used:** SQL (CTEs, Window Functions, Aggregations), Power BI  
**Focus Areas:** Time-based analysis, product performance, customer segmentation, revenue growth

---

## 1️⃣ Background and Overview

This project analyzes five years of Christmas season sales data to uncover trends in product performance, customer behavior, and regional growth. The goal is to deliver actionable insights for marketing strategy and campaign planning.

The analysis defines the "Christmas Season" as **November to January**, with **January reassigned to the previous year** to reflect actual shopping behavior.

---

## 2️⃣ Data Structure Overview

The dataset `dbo.xmas_sales` includes transactional records for holiday purchases across multiple countries. A reusable SQL view `v_xmas_sales` was created to enrich time-based features and streamline analysis.

### 📁 Key Dimensions

| Dimension Type     | Attributes Included                                      |
|--------------------|----------------------------------------------------------|
| Time               | Date, Time, Hour, Weekday, Month, Year, Xmas Season      |
| Customer           | Age Range, Gender, Country                               |
| Product            | Product Name, Category, Type                             |
| Transaction        | Quantity, Total Sales, Profit, Purchase Type, Payment Method, Xmas Budget |

> The enriched view `v_xmas_sales` includes calculated fields such as `xmas_year`, `xmas_season`, `weekday_name`, and `hour` for deeper time-based analysis.

---

## 3️⃣ Executive Summaries

**Seasonal Coverage:** 2018–2022  
**Peak Shopping Hours:** 12 PM–6 PM  
**Top Products:** JBL, LEGO, Barbie  
**Most Profitable Segment:** Females aged 1–11  
**Top Growth Markets (2021):** Belgium, Netherlands, Austria, UK, Italy  
**Peak Spending Period:** December 10–20  
**Revenue Growth:** Consistent YoY increase, peaking at +20.9% in 2020–2021

---

## 4️⃣ Insights Deep Dive

### 🕒 Time Dimensions
- Defined "Christmas Year" using SQL logic to group Nov–Jan
- Created enriched view `v_xmas_sales` with weekday names, hours, and season logic
- Identified peak shopping hours: 12 PM–6 PM

### 🧸 Product Performance

| Year | Best-Selling Product | Top Revenue Product | Highest Profit Product |
|------|----------------------|---------------------|------------------------|
| 2022 | JBL Speaker          | JBL Speaker         | JBL Speaker            |
| 2021 | Harry Potter Puzzle  | Harry Potter Puzzle | Harry Potter Puzzle    |
| 2020 | LEGO Set             | LEGO Set            | LEGO Set               |
| 2019 | Barbie Doll          | Barbie Doll         | Barbie Doll            |
| 2018 | Hot Wheels Car Set   | Hot Wheels Car Set  | Hot Wheels Car Set     |

### 🛍️ Channel Analysis
- In-store purchases consistently outperformed online channels across all five years

### 👥 Customer Segmentation

| Segment        | Top Performer |
|----------------|----------------|
| Age Range      | 1–11 years old |
| Gender         | Female         |
| Top Countries  | Sweden, Netherlands, Germany |

### 💰 Revenue Growth by Season

| Christmas Season | Revenue ($M) | YoY Growth (%) |
|------------------|--------------|----------------|
| 2019–2020        | 12.34        | +13.5%         |
| 2020–2021        | 14.92        | +20.9%         |
| 2021–2022        | 16.78        | +12.5%         |

### 🌍 Top Growth Markets (2021 YoY)

| Country        | YoY Growth (%) |
|----------------|----------------|
| Belgium        | +51.2%         |
| Netherlands    | +43.1%         |
| Austria        | +39.4%         |
| United Kingdom | +37.9%         |
| Italy          | +35.4%         |

### 📅 Peak Spending Period
- December 10–20 consistently shows the highest spike in both sales and profit

---

## 5️⃣ Recommendations

1. **Target High-Growth Regions:** Expand campaigns in Belgium, Netherlands, Austria, UK, and Italy
2. **Maximize In-Store Momentum:** Invest in experiential retail and exclusive bundles
3. **Capitalize on Peak Shopping Window:** Launch promotions between Dec 10–20 during peak hours
4. **Feature Proven Holiday Winners:** Prioritize JBL, LEGO, Barbie, and similar high-performing products
5. **Refine Reporting and Planning:** Use enriched time views and “Christmas Year” logic in dashboards

---

## 6️⃣ Contact & Credit

**Author:** Harmony Pham  
**LinkedIn:** [Connect with me](https://www.linkedin.com/in/harmony-pham-362193235/)  
**GitHub Portfolio:** [Visit my profile](https://github.com/)  

For collaboration, feedback, or portfolio reviews, feel free to reach out!

