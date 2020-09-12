--1.
-- USE TSQL2012 database
-- I want to display orderid, orderdate, custid, empid,
-- So I query results from Sales.Orders table
-- I filter the rows for orderdates between 20070601 and 20070701
-- I return the output sorted by orderdate ascending with custid and secondary sort. 
USE TSQL2012;
SELECT orderid, orderdate, custid,empid
FROM Sales.Orders
WHERE orderdate > '20070601' AND orderdate < '20070701' 
ORDER BY orderdate, custid;

--2 
-- use sql2012 table
-- I want to display orderid, orderdate, custid, empid
-- From sales.order table
-- I filter rows for orderdate that is at the end of the month
-- I sort rows by orderdate ASC, and custid secondary ASC 
USE TSQL2012;
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
WHERE orderdate = EOMONTH(orderdate)
ORDER BY orderdate, custid;


-- REPLACE function 68, 96/442
--3
-- I want to display empid, firstname, lastname
-- SO I return rows from HR.Employees table
-- I filter for rows where the lastname contains the letter 'a' more than once.
USE TSQL2012;
SELECT empid, firstname, lastname
FROM HR.Employees
WHERE LEN(lastname) - LEN(REPLACE(lastname, 'a', '')) > 1


--4
-- I want to display orderid, totalvalue
-- So I query results from Sales.OrderDetails table
-- I create unique groups of orderid and totalvalue
-- I order the rows by totalvalue by DESC order.
USE TSQL2012;
SELECT orderid, SUM(qty*unitprice) AS totalvalue
FROM Sales.OrderDetails
GROUP BY orderid
HAVING SUM(qty*unitprice) > 10000
ORDER BY totalvalue DESC;


--5
-- I want to display top 3 results for ship country and average freight
-- So I query results from Sales.ORders table
-- I filter rows for shipped date in 2007
-- I create unique groups of shipcountry and avg freight
-- I sort the rows by highest avg freight cost by descending order
SELECT TOP(3) shipcountry, AVG(freight) as avgfreight
FROM Sales.Orders
WHERE orderdate > '20070101' AND orderdate < '20080101'
GROUP BY shipcountry
ORDER BY avgfreight DESC; 

--6
-- I want to display custid, orderdate, orderid, row number
-- row number is calculated by splitting custid into groups and sorting by orderdate for each cluster of custid
-- I query results from Sales.Orders table
-- I return sorted results by custid and orderdate secondary DESC.
SELECT custid, orderdate, orderid, ROW_NUMBER() OVER(PARTITION BY custid ORDER BY orderdate, orderid)  AS rownums
FROM Sales.Orders
ORDER BY custid, rownums;

--7 
-- I want to display empid, firstname, lastname, titleofcourtesy
-- titleofcourtesy will categorize each rows by gender
-- Then we return the rows from the HR.Employees table
SELECT empid, firstname, lastname, titleofcourtesy,
	CASE titleofcourtesy
		WHEN 'Ms.' THEN N'Female'
		WHEN 'Mrs.' THEN N'Female'
		WHEN 'Mr.' THEN N'Male'
		ELSE 'Unkown'
	END AS gender
FROM HR.Employees;

--8 
-- I want to display custid, region
-- So I query rows from Sales.Customers table
-- I sort rows by region placing NULL markers last
SELECT custid, region
FROM Sales.Customers
ORDER BY 
	CASE 
		WHEN region IS NULL THEN 1
		ELSE 0 
		END, region;
 