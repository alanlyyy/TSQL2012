USE TSQL2012;


--1. create virtual table of 10 integers
SELECT 1 AS n
UNION ALL 
SELECT 2
UNION ALL 
SELECT 3
UNION ALL 
SELECT 4
UNION ALL 
SELECT 5
UNION ALL 
SELECT 6
UNION ALL 
SELECT 7
UNION ALL 
SELECT 8
UNION ALL 
SELECT 9
UNION ALL 
SELECT 10;

--2. 
SELECT TOP(5) * FROM Sales.Orders;

-- display custid and empid pairs
-- query from sales.orders table
-- filter for month = 1 and year =2008

-- filter custid and empid pairs from sales.orders table
-- if month = 2 and orderdate =2008

--sort by custid, and empid ascending.
SELECT custid, empid 
FROM Sales.Orders
WHERE MONTH(orderdate) = 1 AND YEAR(orderdate) = 2008

EXCEPT

SELECT custid, empid 
FROM Sales.Orders
WHERE MONTH(orderdate) = 2 AND YEAR(orderdate) = 2008

ORDER BY custid,empid;

--3.

-- return set custid empid pair from Sales.Orders table
-- if month = jan, year = 2008
-- return set custid empid pair from Sales.ORders table
-- if month = feb and year =2008
-- find the empid,custid pairs that are found in both sets.
SELECT custid, empid 
FROM Sales.Orders
WHERE MONTH(orderdate) = 1 AND YEAR(orderdate) = 2008

INTERSECT

SELECT custid, empid 
FROM Sales.Orders
WHERE MONTH(orderdate) = 2 AND YEAR(orderdate) = 2008

ORDER BY custid,empid;


--4
-- set 1 , custid empid pairs with month =1 and year =2008
-- set 2, custid, empid pairs with month =2 and year =2008
-- if custid and empid pair is found in set 1 and set 2, return the resultant set
-- set 3, custid empid pairs with  year 2007
-- for custd and empid pair in set 3 is not found in resultant set, remove and return new resultant set.
SELECT custid, empid 
FROM Sales.Orders
WHERE MONTH(orderdate) = 1 AND YEAR(orderdate) = 2008

INTERSECT

SELECT custid, empid 
FROM Sales.Orders
WHERE MONTH(orderdate) = 2 AND YEAR(orderdate) = 2008

EXCEPT

SELECT custid, empid 
FROM Sales.Orders
WHERE YEAR(orderdate) = 2007

ORDER BY custid,empid;

--5

-- create a virtual table temptable:
-- set 1: row number from 1-9 and row numbers to order country, region and city from HR.Employees table
-- combine all rows with 
-- set2: row numbers calculated using ordering of country,region, city from Production.Suppliers table with a offset of 10 from HR.Employees table
-- query country, region, city
-- query from virtual table country, region, and city
-- order by user_value or primary ordering key in ascending order.
USE TSQL2012;
WITH temptable
AS
(
SELECT ROW_NUMBER() OVER (ORDER BY country, region, city) AS user_value,
ROW_NUMBER()
OVER(PARTITION BY country, region, city
ORDER BY (SELECT 0)) AS rownum,
country, region, city
FROM HR.Employees

UNION ALL

SELECT (ROW_NUMBER() OVER (ORDER BY country, region, city) + (SELECT COUNT(*) FROM HR.Employees)) AS user_value,
ROW_NUMBER() OVER(PARTITION BY country, region, city ORDER BY (SELECT 0)) AS rownum,
country, region, city
FROM Production.Suppliers
)
SELECT country,region, city
FROM temptable
ORDER BY user_value ASC;


--alternative
SELECT country, region, city
FROM (SELECT 1 AS sortcol, country, region, city
		FROM  HR.Employees

		UNION ALL

		SELECT 2, country, region, city
		FROM Production.Suppliers) AS D
ORDER BY sortcol, country, region,city;