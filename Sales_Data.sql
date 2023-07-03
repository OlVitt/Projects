-- Cleaning up missing values
SELECT COUNT(*) AS row_count
FROM [dbo].[2019_sales_data] 
WHERE Order_ID IS NULL AND Product is NULL AND Quantity_Ordered IS NULL AND Price_Each IS NULL AND Order_Date IS NULL AND Purchase_Address IS NULL

DELETE FROM dbo.[2019_sales_data]
WHERE Order_ID IS NULL AND Product is NULL AND Quantity_Ordered IS NULL AND Price_Each IS NULL AND Order_Date IS NULL AND Purchase_Address IS NULL

-- TASK 1: What was the best month for sales? How much was earned that month?
SELECT TOP 12
    MONTH(Order_Date) AS Month,
    ROUND(SUM(Quantity_Ordered * Price_Each), 2) AS Earnings
FROM
    dbo.[2019_sales_data]
GROUP BY
    MONTH(Order_Date)
ORDER BY
    Earnings DESC;

-- ANSWER: The best month for sales was December, with $4,613,443.32 

-- TASK 2: What City had the highest number of sales?

--SELECT SUBSTRING(Purchase_Address, CHARINDEX(',', Purchase_Address) +2, CHARINDEX(',', Purchase_Address, CHARINDEX(',', Purchase_Address) +1)+4),
--COUNT(*) AS total_sales
--FROM dbo.[2019_sales_data]
--GROUP BY SUBSTRING(Purchase_Address, CHARINDEX(',', Purchase_Address) +2, CHARINDEX(',', Purchase_Address, CHARINDEX(',', Purchase_Address) +1)+4)
--ORDER BY total_sales DESC;
-- Should've excluded zipcode, but didn't. Works, but includes the zipcode.


WITH AddressSplit AS (
    SELECT 
        CASE 
            WHEN CHARINDEX(',', Purchase_Address) > 0
            THEN SUBSTRING(Purchase_Address, 1, CHARINDEX(',', Purchase_Address) - 1)
            ELSE Purchase_Address
        END AS address,
        CASE 
            WHEN CHARINDEX(',', Purchase_Address) > 0 AND CHARINDEX(',', Purchase_Address, CHARINDEX(',', Purchase_Address) + 1) > 0
            THEN SUBSTRING(Purchase_Address, CHARINDEX(',', Purchase_Address) + 2, CHARINDEX(',', Purchase_Address, CHARINDEX(',', Purchase_Address) + 1) - CHARINDEX(',', Purchase_Address) - 2)
            ELSE ''
        END AS city,
        CASE 
            WHEN CHARINDEX(',', Purchase_Address, CHARINDEX(',', Purchase_Address) + 1) > 0
            THEN SUBSTRING(Purchase_Address, CHARINDEX(',', Purchase_Address, CHARINDEX(',', Purchase_Address) + 1) + 2, 2)
            ELSE ''
        END AS state,
        CASE 
            WHEN LEN(Purchase_Address) >= 5
            THEN RIGHT(Purchase_Address, 5)
            ELSE ''
        END AS zipcode
    FROM
        dbo.[2019_sales_data]
)
SELECT TOP 10 WITH TIES
    CONCAT(city, ', ', state) AS city_state,
    COUNT(*) AS total_sales
FROM
    AddressSplit
GROUP BY
    city,
    state
ORDER BY
    total_sales DESC;


-- ANSWER: The highest number of sales was in San Francisco, CA with 44,732 sales.

-- TASK 3: What time should we display adverstisement to maximize likelihood of customer's buying product?

SELECT
    DATEPART(HOUR, Order_Date) AS hour_of_day,
    COUNT(*) AS purchase_count
FROM
    dbo.[2019_sales_data]
GROUP BY
    DATEPART(HOUR, Order_Date)
ORDER BY
    purchase_count DESC;

-- ANSWER: The best time for ads is between 6 PM and 8 PM with peak time being 7 PM. 
--The second best is lunchtime, from 11 AM to 1 PM, with peak time at 12 PM

-- TASK 4: What products are most often sold together?

SELECT
    s1.Product AS Product1,
    s2.Product AS Product2,
    COUNT(*) AS Frequency
FROM
    dbo.[2019_sales_data] AS s1
JOIN
    dbo.[2019_sales_data] AS s2 ON s1.Order_ID = s2.Order_ID
WHERE
    s1.Product < s2.Product
GROUP BY
    s1.Product,
    s2.Product
ORDER BY
    Frequency DESC;

-- Answer: The most common combination is iPhone + Lightning Charging Cable.
-- The second most common is Google Phone + USB-C Charging Cable.

-- TASK 5: What product sold the most?

SELECT TOP 5
    Product,
    SUM(Quantity_Ordered) AS total_quantity_sold
FROM
    dbo.[2019_sales_data]
GROUP BY
    Product
ORDER BY
    total_quantity_sold DESC

-- Answer: AAA Batteries (4-pack) was sold the most

