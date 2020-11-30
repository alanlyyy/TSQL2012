USE TSQL2012;


--1.
--peek at all column names and data format
SELECT * FROM Sales.Orders;

-- I want to display orderid, orderdate, custid, and empid
-- so I query all rows from Sales.Orders table
-- I filter each row for orderdate, where the row equals to the top orderdate (latest orderdate) from Sales.Orders table 
-- The top orderdate is found by searching for custid is not null and the sorted the orderdate is in descending order, (latest date -earliest date)
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
WHERE orderdate = 
			( SELECT TOP(1) orderdate
				FROM Sales.Orders
				WHERE custid IS NOT NULL
				ORDER BY orderdate DESC)
ORDER BY orderid DESC;


--2.
IF OBJECT_ID('dbo.temp_table', 'U') IS NOT NULL
DROP TABLE dbo.temp_table;

--I choose custid and count number of orders
--insert the output into a table dbo.temp_table
--I query rows from Sales.Orders table
--where we aggregate the rows by custid
SELECT custid, COUNT(custid) AS num_orders
INTO dbo.temp_table
FROM Sales.Orders
GROUP BY custid;

--peak at all  rows from temp table
SELECT * FROM dbo.temp_table;

-- I want to see custid, orderid, orderdate, and empid
-- so I query all rows from Sales.Orders table
-- I filter each row where custid is equal to the (largest) num_order
--found in dbo.temp_table sorted by num_orders in descending order.
SELECT custid,orderid, orderdate, empid
FROM Sales.Orders
WHERE custid = (SELECT TOP(1) custid 
				FROM dbo.temp_table
				ORDER BY num_orders DESC);

--drop the temp table after use
IF OBJECT_ID('dbo.temp_table', 'U') IS NOT NULL
DROP TABLE dbo.temp_table;

--page 147, 175/442 exercise 3.