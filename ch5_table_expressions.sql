USE TSQL2012;

-- I want display all columns
-- So I query all rows from "virtual table"
-- the "virtual table" contains custid and companyname from Sales.Customers filtering for USA customers
SELECT*
FROM (SELECT custid, companyname
		FROM Sales.Customers 
		WHERE country = N'USA') AS USA_Custs;


-- error query since group by runs before select, orderyear variable is not seen
SELECT 
	YEAR(orderdate) AS orderyear,
	COUNT (DISTINCT custid) AS numcusts
FROM Sales.Orders
GROUP BY orderyear;

-- solution 1
SELECT 
	YEAR(orderdate) AS orderyear,
	COUNT (DISTINCT custid) AS numcusts
FROM Sales.Orders
GROUP BY YEAR(orderdate);

--solution 2 using table expressions

--table expressions used in the FROM clause allows us to use the declared variables
--in the SELECT and GROUP BY clause, "orderyear".

-- I want to display orderyear, unique custid
-- So I query all rows from "virtual table"
-- returning columns orderyear, and custid from Sales.Orders table
-- I count total custid for each orderyear.
SELECT orderyear, COUNT(DISTINCT custid) AS numcusts

FROM (SELECT YEAR(orderdate) AS orderyear, custid		
		FROM Sales.Orders) AS D

GROUP BY orderyear;

