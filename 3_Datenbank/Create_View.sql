USE Ecommerce;

DROP VIEW IF EXISTS sales_report;

CREATE VIEW sales_report AS
SELECT
	o.Order_ID,
    o.Date,
    c.Age,
    c.Gender,
    city.City_Name,
    pc.Product_Category_Name,
    p.Payment_Method,
    dt.Device_Type,
    o.Unit_Price,
    o.Quantity,
    o.Discount_Amount,
    (o.Unit_Price * o.Quantity - o.Discount_Amount) as Total_Amount,
    o.Session_Duration_Minutes,
    o.Pages_Viewed,
    o.Is_Returning_Customer,
    o.Delivery_Time_Days,
    o.Customer_Rating
FROM Orders o
JOIN Customer c ON o.Customer_ID = c.Customer_ID
JOIN City city ON c.City_id = city.City_id
JOIN Product_Category pc ON o.Product_Category_ID = pc.Product_Category_id
JOIN Payment p ON o.Payment_id = p.Payment_id
JOIN Device_Type dt ON o.Device_Type_id = dt.Device_Type_id;