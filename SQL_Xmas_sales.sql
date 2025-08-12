
-- Dataset name
USE fp20c12
GO
-- Data Exploration: Tables
SELECT * FROM dbo.country
SELECT * FROM dbo.purchase_type
SELECT * FROM dbo.xmas_sales -- Main Dataset -- 41,163 rows

-- 1, Analysis Dimensions
-- Time Dimensions 
        -- Year: Identify year coverage in the dataset using aggregation
           -- SQL functions used: MIN(), MAX(), YEAR()
               SELECT MIN(YEAR(date)) AS min_year, MAX(YEAR(date)) AS max_year FROM dbo.xmas_sales -- year dimention from 2018 - 2022

        -- Month:
        -- SQL functions used: YEAR(), MONTH(), EOMONTH(), COUNT(), GROUP BY
               SELECT YEAR(date) AS [year], MONTH(date) AS [month], EOMONTH(date) AS [end_date_of_month], COUNT(*) AS nb_rows
               FROM dbo.xmas_sales
               GROUP BY YEAR(date), EOMONTH(date), MONTH(date) -- Using group by to find out the months
               ORDER BY [end_date_of_month] -- Dataset includes only Nov, Dec, and Jan. Define "Christmas Year" as Nov–Jan.

        -- Declare January as part of the previous year's Christmas season for analysis.
             --Define custom "Christmas Season" (Nov–Jan)
             -- Logic: Assign January to the previous year's Christmas season
             -- SQL functions used: CASE WHEN, CONCAT(), EOMONTH()
               SELECT 
                     CASE WHEN MONTH(end_date_of_month) = 1 THEN CONCAT([year] - 1, '-', [year]) 
                     ELSE CONCAT([year], '-', [year] + 1) 
                     END AS xmas_season,
                     [month],[year],[end_date_of_month]
               FROM 
               (SELECT YEAR(date) AS [year], MONTH(date) AS [month], EOMONTH(date) AS [end_date_of_month]
               FROM dbo.xmas_sales
               GROUP BY YEAR(date), EOMONTH(date), MONTH(date)
               ) time_dimension
               ORDER BY [xmas_season],[end_date_of_month]

        -- Date name

        -- Hour of the day
               SELECT DATEPART(HOUR, [time]) AS [hour], COUNT(*) AS nb_rows
               FROM dbo.xmas_sales
               GROUP BY DATEPART(HOUR, [time])
               ORDER BY [hour]

        -- Create a reusable view with enriched time features
            -- SQL features used: CREATE OR ALTER VIEW, DATEPART(), CASE WHEN, CONCAT(), EOMONTH()
               CREATE OR ALTER VIEW dbo.v_xmas_sales AS -- Create or Alter view, create cleaner format

               SELECT 
                    CASE WHEN MONTH([date]) = 1 THEN YEAR([date]) - 1 ELSE YEAR([date]) END AS xmas_year,
                         CASE WHEN MONTH([date]) = 1 
                         THEN CONCAT(YEAR([date]) - 1, '-', YEAR([date]) ) 
                         ELSE CONCAT(YEAR([date]) , '-', YEAR([date]) + 1) 
                         END AS xmas_season, 
                   YEAR([date]) AS [year], EOMONTH([date]) AS end_date_of_month, DATEPART(WEEKDAY, [date]) AS [weekday], 
                   CASE DATEPART(WEEKDAY, [date]) -- Weekday are represented by number, Weekday_name are represented by text 
                               WHEN 1 THEN 'Sunday'
                               WHEN 2 THEN 'Monday'
                               WHEN 3 THEN 'Tuesday'
                               WHEN 4 THEN 'Wednesday' 
                               WHEN 5 THEN 'Thursday'
                               WHEN 6 THEN 'Friday' 
                               WHEN 7 THEN 'Saturday'
                        END AS [weekday_name], DATEPART(HOUR, [time]) AS [hour],
               s.* -- Include s.* to retain all original columns from the base table (dbo.xmas_sales)
               FROM dbo.xmas_sales s
               WHERE EOMONTH([date]) <> '2018-01-31'

-- Customer Dimensions: Age_range, gender
-- Product Dimensions: product_category, product_name, product_type
-- Other Dimensions: purchase_type, payment_method, xmas_budget

-- 2, Which product sell best each year? In which channels?
-- Best selling product by year
     -- Product sell the most 
        -- Identify the best-selling product by quantity for each year using RANK() to select the top-ranked item per year.
        -- SQL features used: CTEs, SUM(), CAST(), GROUP BY, RANK() window function, ORDER BY
     WITH ProductSales AS (
           SELECT 
             YEAR(date) AS [year], 
             product_name,
             SUM(CAST(quantity AS FLOAT)) AS Total_Units_Sold
           FROM dbo.xmas_sales
           GROUP BY YEAR(date), product_name
     ), -- using CTE to group sales data by year, product_name, caculate total unit sold
    BestProducts AS (
        SELECT *,
        RANK() OVER (PARTITION BY Year ORDER BY Total_Units_Sold DESC) AS Product_Rank
    FROM ProductSales
     ) -- using CTE to rank product
    SELECT *
    FROM BestProducts
    WHERE Product_Rank = 1
    ORDER BY [year] DESC; 

    -- Product earns the most: 2022:JBL, 2021:Harry Potter Puzzle, 2020: LEGO, 2019: Barbie Doll, 2018: Hot Wheels Car Set
        -- Identify the top product by total sales revenue per year by aggregating total_sales and applying RANK() for ranking.
        -- SQL features used: CTEs, SUM(), CAST(), ROUND(), GROUP BY, RANK() window function

    WITH ProductSales AS (
           SELECT 
             YEAR(date) AS [year], 
             product_name,
             ROUND(SUM(CAST(total_sales AS FLOAT)), 2) AS Total_Sales -- round up 
           FROM dbo.xmas_sales
           GROUP BY YEAR(date), product_name
     ), 
    BestProductsBySales AS (
        SELECT *,
        RANK() OVER (PARTITION BY Year ORDER BY Total_Sales DESC) AS Product_Rank -- desc data because the highest number will be ranked 1st
    FROM ProductSales
     ) 
    SELECT *
    FROM BestProductsBySales
    WHERE Product_Rank = 1
    ORDER BY [year] DESC;

    -- Product contributes the most margin - Same as BestProductBySales
       -- Determine the product contributing the highest total profit each year by summing profit and ranking within each year.
       -- SQL features used: CTEs, SUM(), CAST(), ROUND(), GROUP BY, RANK() window function

    WITH ProductSales AS (
           SELECT 
             YEAR(date) AS [year], 
             product_name,
             ROUND(SUM(CAST(profit AS FLOAT)), 2) AS Profit -- round up 
           FROM dbo.xmas_sales
           GROUP BY YEAR(date), product_name
     ), 
    BestProductsByProfit AS (
        SELECT *,
        RANK() OVER (PARTITION BY Year ORDER BY Profit DESC) AS Product_Rank -- desc data because the highest number will be ranked 1st
    FROM ProductSales
     ) 
    SELECT *
    FROM BestProductsByProfit
    WHERE Product_Rank = 1
    ORDER BY [year] DESC;

-- In which channel => best purchase type/ channel are in-store for all 5 years
   -- Analyze which channel (purchase_type) the top-selling product was sold in for each year based on total revenue.
   -- SQL features used: CTEs, SUM(), CAST(), ROUND(), GROUP BY (including purchase_type), RANK() window function

   WITH ProductSales AS (
           SELECT 
             YEAR(date) AS [year], 
             product_name,purchase_type,
             ROUND(SUM(CAST(total_sales AS FLOAT)), 2) AS Total_Sales -- round up 
           FROM dbo.xmas_sales
           GROUP BY YEAR(date), product_name, purchase_type
     ), 
    BestProductsBySales AS (
        SELECT *,
        RANK() OVER (PARTITION BY Year ORDER BY Total_Sales DESC) AS Product_Rank -- desc data because the highest number will be ranked 1st
    FROM ProductSales
     ) 
    SELECT *
    FROM BestProductsBySales
    WHERE Product_Rank = 1
    ORDER BY [year] DESC;


-- 3, Who are our most profitable customer segments during Christmas? (age, gender, country)
  -- SQL functions used:
      -- CTEs (Common Table Expressions) for modular, readable query structure
      -- Aggregation with SUM() and type conversion using CAST()
      -- ROUND() to format numeric output
      -- RANK() window function to assign rankings based on sales performance

    -- Age: Top 1: 1 - 11 years old
    WITH CustomerDemo AS (
    SELECT 
        customer_age_range,
        ROUND(SUM(CAST(total_sales AS FLOAT)), 2) AS Total_Sales
    FROM dbo.xmas_sales
    GROUP BY customer_age_range
    ),
    TargetDemo AS (
    SELECT *,
        RANK() OVER (ORDER BY Total_Sales DESC) AS Product_Rank
    FROM CustomerDemo
    )
    SELECT *
    FROM TargetDemo
    WHERE Product_Rank = 1;


    -- Gender: Female
    WITH CustomerDemo AS (
    SELECT 
        gender,
        ROUND(SUM(CAST(total_sales AS FLOAT)), 2) AS Total_Sales
    FROM dbo.xmas_sales
    GROUP BY gender
    ),
    TargetDemo AS (
    SELECT *,
        RANK() OVER (ORDER BY Total_Sales DESC) AS Product_Rank 
    FROM CustomerDemo
    )
    SELECT *
    FROM TargetDemo
    WHERE Product_Rank = 1;

    -- Country (Top 3 Country: Sweeden, Netherlands, Germany)
    WITH CustomerDemo AS(
           SELECT 
              country,
              ROUND(SUM(CAST(total_sales AS FLOAT)), 2) AS Total_Sales
           FROM dbo.xmas_sales
           GROUP BY country
    ), -- Using CTE to create a group w countries
    TargetDemo AS(
          SELECT *,
             RANK() OVER (ORDER BY Total_Sales DESC) AS Product_Rank -- rank
          FROM CustomerDemo
    )
    SELECT *
    FROM TargetDemo
    WHERE Product_Rank = 1;
    
   

-- 4, When is the peak spending period leading up to Christmas? USing visualization tools on PowerBI
    SELECT 
    date,YEAR(date) AS [year], MONTH(date) AS [month],
    SUM(total_sales) AS Total_Sales,
    SUM(profit) AS Total_Profit
    FROM dbo.xmas_sales
    GROUP BY date, YEAR(date), MONTH(date)
 

-- 5, Which cities or countries underperformed or overperformed?
      -- Analyze which cities or countries are underperforming based on total sales and profit compared to the city-level average.
      -- SQL features used: CTEs, SUM(), COUNT(), AVG(), CROSS JOIN, GROUP BY (country, city), conditional filtering (WHERE) 
      
-- Underperformed cities
-- Step 1: Aggregate data by country & city
WITH CityPerformance AS (
    SELECT 
        country,
        city,
        SUM(total_sales) AS Total_Sales,
        SUM(profit) AS Total_Profit,
        COUNT(*) AS Nb_of_orders
    FROM dbo.xmas_sales
    GROUP BY country, city
),

-- Step 2: Calculate average total sales/profit across all cities
AverageCityPerformance AS (
    SELECT 
        AVG(Total_Sales) AS Avg_Sales,
        AVG(Total_Profit) AS Avg_Profit
    FROM CityPerformance
)

-- Step 3: Compare each city to the city-level average
SELECT 
    c.country,
    c.city,
    c.Total_Sales,
    c.Total_Profit,
    c.Nb_of_orders
FROM CityPerformance c
CROSS JOIN AverageCityPerformance a -- Use cross join to compare every city to a single summary row without a matching key. 
WHERE c.Total_Sales < a.Avg_Sales OR c.Total_Profit < a.Avg_Profit
ORDER BY c.Total_Sales ASC, c.Total_Profit ASC; -- from lowest

-- Overperformed cities
WITH CityPerformance AS (
    SELECT 
        country,
        city,
        SUM(total_sales) AS Total_Sales,
        SUM(profit) AS Total_Profit,
        COUNT(*) AS Nb_of_orders
    FROM dbo.xmas_sales
    GROUP BY country, city
),
AverageCityPerformance AS (
    SELECT 
        AVG(Total_Sales) AS Avg_Sales,
        AVG(Total_Profit) AS Avg_Profit
    FROM CityPerformance
)
SELECT 
    c.country,
    c.city,
    c.Total_Sales,
    c.Total_Profit,
    c.Nb_of_orders
FROM CityPerformance c
CROSS JOIN AverageCityPerformance a -- Use cross join to compare every city to a single summary row without a matching key. 
WHERE c.Total_Sales > a.Avg_Sales OR c.Total_Sales = a.Avg_Sales OR c.Total_Profit < a.Avg_Profit OR c.Total_Profit = a.Avg_Profit
ORDER BY c.Total_Sales DESC, c.Total_Profit DESC; -- from highest


-- 6, How do Christmas Budgets affect customer purchasing behavior? 
     -- Analyze whether customer Christmas budgets impact purchasing behavior by comparing average unit price and quantity across budget groups.
     -- SQL features used: GROUP BY, COUNT(), AVG()
      SELECT xmas_budget,
        COUNT(*) AS Total_Orders,
        AVG(unit_price) AS Unit_Price,
        AVG (quantity) AS Quantity
      FROM dbo.xmas_sales
      GROUP BY xmas_budget
      -- Resuts are similar accross budget types => Budget type does not affect purchasing behaviors

-- 7, Which purchase channels are gaining or losing traction overtime?
    -- Aggregate monthly sales and quantity data per channel to monitor trends in channel usage.
    -- SQL features used: GROUP BY (with YEAR() and MONTH()), SUM() for totals, CAST() to ensure numeric operations, ROUND() for readable financial outputs
     SELECT
         YEAR(date) AS [year],MONTH(date) AS [month],
         purchase_type,
         SUM(CAST(quantity AS FLOAT)) AS Total_Units_Sold,
         ROUND(SUM(CAST(total_sales AS FLOAT)), 2) AS Total_Sales
     FROM dbo.xmas_sales
     GROUP BY purchase_type, YEAR(date), MONTH(date)
     ORDER BY purchase_type

-- 8, Are there opportunities for gender-based targeting? No, since the re are little to no differences between the two group
   -- Use CTE to aggregate and rank total sales per gender to assess distribution patterns.
   -- SQL features used: CTEs for modular structure, SUM() for aggregation, CAST() and ROUND() for precision, GROUP BY for segmentation, RANK() for comparative ranking
    
    WITH CustomerDemo AS (
    SELECT 
        gender,
        ROUND(SUM(CAST(total_sales AS FLOAT)), 2) AS Total_Sales
    FROM dbo.xmas_sales
    GROUP BY gender
    ),
    TargetDemo AS (
    SELECT *,
        RANK() OVER (ORDER BY Total_Sales DESC) AS Product_Rank 
    FROM CustomerDemo
    )
    SELECT *
    FROM TargetDemo

-- 9, What is the percentage growth of revenue for each Christmas season?
    -- Calculate annual growth rates by comparing total sales for each Christmas season to the previous year's season.
    -- SQL features used: CTEs for aggregation, SUM() for total revenue, ROUND() for readable formatting, self-JOIN for year-over-year comparison
; WITH s AS(
   SELECT xmas_year, xmas_season, SUM(total_sales) AS sales
   FROM dbo.v_xmas_sales
   GROUP BY xmas_year, xmas_season
)
SELECT s.xmas_year, s.xmas_season,
   ROUND(s.sales / POWER(10,6), 2) AS sales, ROUND(prev.sales / POWER(10,6), 2) AS sales_prev_season,
   ROUND(1.0 *(s.sales - prev.sales)/prev.sales, 3) AS growth_yoy
FROM s
JOIN s prev ON s.xmas_year = prev.xmas_year + 1

-- 10. What are top 5 countries with highest YoY increase in total sales in 2021? - Belgium, Neitherlands, Austria, United Kingdom, Italy
     -- Identify the five countries with the largest year-over-year increase in total sales for 2021 by comparing revenue to 2020.
     -- SQL features used: CTEs for aggregation, SUM() for sales and quantity, ROUND() for readable output, self-JOIN for YoY comparison, TOP for limiting results, ORDER BY for ranking by growth
;WITH s AS (
    SELECT 
        YEAR(date) AS year,
        country,
        SUM(quantity) AS total_quantity,
        SUM(total_sales) AS sales
    FROM xmas_sales
    GROUP BY YEAR(date), country
),
m AS (
    SELECT 
        s.country,
        s.year,
        ROUND(s.sales / POWER(10, 6), 2) AS sales,
        ROUND(prev.sales / POWER(10, 6), 2) AS sales_prev_season,
        ROUND(1.0 * (s.sales - prev.sales) / prev.sales, 3) AS growth_yoy
    FROM s
    JOIN s prev ON s.country = prev.country AND s.year = prev.year + 1
    WHERE s.year = 2021 
)
SELECT TOP 5 *
FROM m
ORDER BY growth_yoy DESC
