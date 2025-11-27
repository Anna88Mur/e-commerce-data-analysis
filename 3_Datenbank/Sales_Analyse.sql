
# Monats Bericht
SELECT
	YEAR(Date) as Year,
    MONTH(Date) as Month,
    Product_Category_Name,
    SUM(Unit_Price * Quantity - Discount_Amount) as Total_Sales,
    COUNT(*) as Order_Count
FROM sales_report
GROUP BY YEAR(Date),  MONTH(Date), Product_Category_Name
ORDER BY YEAR(Date),  MONTH(Date), Total_Sales
;


# Kunden Analyse
SELECT 
	CASE
		WHEN Age < 25 THEN '18-24'
        WHEN Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN Age BETWEEN 35 AND 44 THEN '35-44'
        ELSE '45+'
    END as Age_Group,
    Gender, 
    City_Name,
    AVG(Customer_Rating) as Avg_Rating,
    COUNT(*) as Purchases
FROM sales_report
GROUP BY Age_Group, Gender, City_Name
ORDER BY Avg_Rating DESC;    

# ABC Analyse - Vereinfachte version

SELECT
	Product_Category_Name,
    SUM(Unit_Price * Quantity - Discount_Amount) as Revenue,
    ROUND(SUM(Unit_Price * Quantity - Discount_Amount) / 
          (SELECT SUM(Unit_Price * Quantity - Discount_Amount) FROM sales_report) * 100, 2) as Percentage,
	CASE 
        WHEN SUM(Unit_Price * Quantity - Discount_Amount) / 
             (SELECT SUM(Unit_Price * Quantity - Discount_Amount) FROM sales_report) > 0.05 THEN 'A'
        WHEN SUM(Unit_Price * Quantity - Discount_Amount) / 
             (SELECT SUM(Unit_Price * Quantity - Discount_Amount) FROM sales_report) > 0.02 THEN 'B'
        ELSE 'C'
    END as ABC_Class          
FROM sales_report
GROUP BY Product_Category_Name
ORDER BY Revenue DESC;   

# ABC Analyse - Klassisch (with window function)

WITH category_revenue AS (
SELECT
	Product_Category_Name,
    SUM(Unit_Price * Quantity - Discount_Amount) as Revenue
FROM sales_report
GROUP BY Product_Category_Name
),
revenue_with_cumulative AS (
SELECT 
        *,
        SUM(Revenue) OVER(ORDER BY Revenue DESC) as Cumulative_Revenue,
        (SELECT SUM(Revenue) FROM category_revenue) as Total_Revenue,
        SUM(Revenue) OVER(ORDER BY Revenue DESC) / 
        (SELECT SUM(Revenue) FROM category_revenue) as Cumulative_Share
    FROM category_revenue
)
SELECT 
    Product_Category_Name,
    Revenue,
    Cumulative_Revenue,
    ROUND(Cumulative_Share * 100, 2) as Cumulative_Percentage,
    CASE 
        WHEN Cumulative_Share <= 0.8 THEN 'A'
        WHEN Cumulative_Share <= 0.95 THEN 'B'
        ELSE 'C'
    END as ABC_Category
FROM revenue_with_cumulative
ORDER BY Revenue DESC;

# Customer Satisfaction by City
  SELECT
  AVG(Customer_Rating) as Customer_Rating,
  City_Name
  FROM sales_report
  GROUP BY City_Name
  ORDER BY Customer_Rating DESC;
  
# Customer Satisfaction by Category  
  SELECT
  AVG(Customer_Rating) as Customer_Rating,
  Product_Category_Name
  FROM sales_report
  GROUP BY Product_Category_Name
  ORDER BY Customer_Rating DESC;

# Customer Rating Distribution
SELECT
Customer_Rating, 
COUNT(Order_ID) as Number_of_Orders
FROM sales_report
WHERE City_Name LIKE  "A%"
GROUP BY Customer_Rating
ORDER BY Number_of_Orders DESC;

# Time Series Analysis
SELECT 
CONCAT(EXTRACT(YEAR FROM `Date`), '-', LPAD(EXTRACT(MONTH FROM `Date`), 2, '0')) AS YearMonth,
SUM(Unit_Price * Quantity - Discount_Amount) as Total_Sales,
COUNT(Order_ID) as Number_of_Orders
FROM sales_report 
GROUP BY YearMonth
ORDER BY YearMonth;

# Delivery Time Analysis
SELECT 
Delivery_Time_Days,
COUNT(Delivery_Time_Days) as Frequency
FROM sales_report
GROUP BY Delivery_Time_Days
ORDER BY Delivery_Time_Days;

# Delivery Time Analysis by Rating
SELECT 
Delivery_Time_Days,
AVG(Customer_Rating) AS AVG_Rating
FROM sales_report
GROUP BY Delivery_Time_Days
ORDER BY Delivery_Time_Days;

# Analysis of returning customers by devices
SELECT
Device_Type,
COUNT(*) AS Orders_Count,
SUM(Is_Returning_Customer) AS Returning_Customer,
ROUND(SUM(Is_Returning_Customer)/(SELECT SUM(Is_Returning_Customer) FROM sales_report) * 100, 2) as Percentage
FROM sales_report
GROUP BY Device_Type
ORDER BY Percentage DESC