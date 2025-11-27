#Database erstellen
DROP DATABASE IF EXISTS Ecommerce;
CREATE DATABASE Ecommerce;
USE Ecommerce;

#Die Tabelle erstellen

DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS City;
DROP TABLE IF EXISTS Product_Category;
DROP TABLE IF EXISTS Payment;
DROP TABLE IF EXISTS Device_Type;



CREATE TABLE `Customer`(
    `Customer_ID` INT PRIMARY KEY,
    `External_Customer_Code` VARCHAR(255) NOT NULL,
    `Age` INT NOT NULL,
    `Gender` VARCHAR(255) NOT NULL,
    `City_id` INT NOT NULL
);
CREATE TABLE `Orders`(
    `Order_ID` INT PRIMARY KEY,
    `Order_Line_ID` VARCHAR(255) NULL,
    `Customer_ID` INT NOT NULL,
    `Date` DATE NOT NULL,
    `Product_Category_ID` INT NOT NULL,
    `Unit_Price` DECIMAL(8, 2) NOT NULL,
    `Quantity` INT NOT NULL,
    `Discount_Amount` DECIMAL(8, 2) NOT NULL,
    `Payment_id` INT NOT NULL,
    `Device_Type_id` INT NOT NULL,
    `Session_Duration_Minutes` INT NOT NULL,
    `Pages_Viewed` INT NOT NULL,
    `Is_Returning_Customer` BOOLEAN NOT NULL,
    `Delivery_Time_Days` INT NOT NULL,
    `Customer_Rating` INT NOT NULL
);
CREATE TABLE `City`(
    `City_id` INT PRIMARY KEY,
    `City_Name` VARCHAR(255) NOT NULL
);
CREATE TABLE `Product_Category`(
    `Product_Category_id` INT PRIMARY KEY,
    `Product_Category_Name` VARCHAR(255) NOT NULL
);
CREATE TABLE `Payment`(
    `Payment_id` INT PRIMARY KEY,
    `Payment_Method` VARCHAR(255) NOT NULL
);
CREATE TABLE `Device_Type`(
    `Device_Type_id` INT PRIMARY KEY,
    `Device_Type` VARCHAR(255) NOT NULL
);
ALTER TABLE
    `Orders` ADD CONSTRAINT `orders_product_category_id_foreign` FOREIGN KEY(`Product_Category_ID`) REFERENCES `Product_Category`(`Product_Category_id`);
ALTER TABLE
    `Customer` ADD CONSTRAINT `customer_city_id_foreign` FOREIGN KEY(`City_id`) REFERENCES `City`(`City_id`);
ALTER TABLE
    `Orders` ADD CONSTRAINT `orders_device_type_id_foreign` FOREIGN KEY(`Device_Type_id`) REFERENCES `Device_Type`(`Device_Type_id`);
ALTER TABLE
    `Orders` ADD CONSTRAINT `orders_customer_id_foreign` FOREIGN KEY(`Customer_ID`) REFERENCES `Customer`(`Customer_ID`);
ALTER TABLE
    `Orders` ADD CONSTRAINT `orders_payment_id_foreign` FOREIGN KEY(`Payment_id`) REFERENCES `Payment`(`Payment_id`);
    
#Das Hochladen von CSV-Dateien

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/City.csv'
INTO TABLE City
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(City_id, City_Name);  


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Customer.csv'
INTO TABLE Customer
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(Customer_ID, External_Customer_Code,Age,Gender,City_id);  

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Product_Category.csv'
INTO TABLE Product_Category
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(Product_Category_id, Product_Category_Name);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Payment.csv'
INTO TABLE Payment
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(Payment_id, Payment_Method);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Device_Type.csv'
INTO TABLE Device_Type
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(Device_Type_id, Device_Type);  


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Orders.csv'
INTO TABLE Orders
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(Order_ID, Order_Line_ID, Customer_ID, @Date, Product_Category_ID, @Unit_Price, Quantity, @Discount_Amount, Payment_id, Device_Type_id, Session_Duration_Minutes, Pages_Viewed, @Is_Returning_Customer,Delivery_Time_Days, Customer_Rating) 
SET Date = STR_TO_DATE(@Date, '%d.%m.%Y'),
Unit_Price = REPLACE(@Unit_Price, ',', '.'),
    Discount_Amount = REPLACE(@Discount_Amount, ',', '.'),
    Is_Returning_Customer = CASE 
        WHEN @Is_Returning_Customer = 'WAHR' THEN 1 
        ELSE 0 
    END;
    

