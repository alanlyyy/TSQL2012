
USE TSQL2012;

--I want to display custid from Sales.Customers, C, 91 rows
-- I want to display empid from HR.Employees, E, 9 rows
-- So I query all rows and cross join C and E to get 91x9 rows
SELECT C.custid, E.empid
FROM Sales.Customers AS C
	CROSS JOIN HR.Employees AS E;

-- I want to display E1.empid,firstname,lastname
--I want to display E2.empid,firstname,lastname
-- So I query HR.Employees and CROSS JOIN with HR.Employees
-- Which returns all possible combinations between pair of employees. (m = 9 employees, n = 9 employees) = 81 combinations of employees
SELECT 
	E1.empid, E1.firstname, E1.lastname,
	E2.empid, E2.firstname, E2.lastname
FROM HR.Employees AS E1
	CROSS JOIN HR.Employees AS E2;

-- From the TSQL2012 database
-- Check if dbo.Digits exists, if it exists drop table
-- Create dbo.Digits table 
--Insert 9 rows of nums into dbo.Digits table
-- return all rows from dbo.Digits table
USE TSQL2012;
IF OBJECT_ID('dbo.Digits', 'U') IS NOT NULL DROP TABLE dbo.Digits;
CREATE TABLE dbo.Digits(digit INT NOT NULL PRIMARY KEY);

INSERT INTO dbo.Digits(digit)
	VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9);

--I want to display digit from dbo.Digits tables
SELECT digit FROM dbo.Digits;

-- I want to display digits 1 - 1000  in a single column
-- So I	query from virtual table, cross joined by dbo.Digits x3, m x n x p = 10 * 10 * 10 = 1000 rows
-- D3 represents 100,200,300,etc
-- D2 represemts 10,20,30 etc
-- D1 represents 1,2,3 , etc
SELECT D3.digit * 100 + D2.digit * 10 + D1.digit + 1 AS n
FROM		
			   dbo.Digits AS D1
	CROSS JOIN dbo.Digits AS D2
	CROSS JOIN dbo.Digits AS D3
ORDER BY n;


-- CROSS join creates unique combinations between sets/tables

--INNER JOIN 

-- I want to display empid, firstname, lastname from HR.Employees table
-- I want to display orderid from Sales.Orders table
-- I query for empid, firstname, lastname from HR.employees table
-- I combine HR.employees table with Sales.Orders table using empid as index
SELECT * FROM HR.Employees;
SELECT * FROM Sales.Orders
ORDER BY empid ASC;

USE TSQL2012;
SELECT E.empid, E.firstname, E.lastname, O.orderid
FROM HR.Employees AS E
	JOIN Sales.Orders AS O
		ON E.empid = O.empid;


--INNER JOIN safety, explicitly declaring we have fogotten to join on a condition.
SELECT E.empid, E.firstname, E.lastname, O.orderid
FROM HR.Employees AS E
	JOIN Sales.Orders AS O;

-- Same query as above using SQL-89 syntax, performs a cross join instead of producing an error for the inner join
-- m x n = 9 * 830 = 7470 rows of unique combinations HR.Employees and Sales.Orders, when we want 830 rows.
SELECT E.empid, E.firstname, E.lastname, O.orderid
FROM HR.Employees AS E, Sales.Orders AS O;


-- INNER JOIN EX 1

-- FOR TSQL2012 database
-- Drop Sales.OrderDetailsAudit table has been made
-- Create Sales.OrderDetailsAudit table
-- with the following columns: lsn, orderid, productid, dt, loginname, oldval, newval, PK_OrderDetailsAudit, FK_OrderDetailsAudit_OrderDetails
-- table references back to Sales.OrderDetails with the orderid and productid.
USE TSQL2012;
IF OBJECT_ID('Sales.OrderDetailsAudit', 'U') IS NOT NULL
	DROP TABLE Sales.OrderDetailsAudit;
		
CREATE TABLE Sales.OrderDetailsAudit
(
	lsn				INT NOT NULL IDENTITY,
	orderid			INT NOT NULL,
	productid		INT NOT NULL,
	dt				DATETIME NOT NULL,
	loginname		sysname NOT NULL,
	columnname		sysname NOT NULL,
	oldval			SQL_VARIANT,
	newval			SQL_VARIANT,
	CONSTRAINT		PK_OrderDetailsAudit PRIMARY KEY(lsn),
	CONSTRAINT		FK_OrderDetailsAudit_OrderDetails
		FOREIGN	KEY(orderid, productid)
		REFERENCES Sales.OrderDetails(orderid, productid)
);

SELECT * FROM Sales.OrderDetailsAudit;

-- I want to display orderid, productid, and qty from Sales.OrderDetails table
-- I want to display datetime,loginname,oldval,newval from Sales.OrderDetailsAudit table
-- So I query rows from Sales.OrderDetails table 
-- I combine Sales.OrderDetails and Sales.OrderDetailsAudit on orderid and productid
-- Then we filter the output based off Sales.OrderDetailsAudit.columnname = qty
SELECT OD.orderid, OD.productid, OD.qty,
	ODA.dt, ODA.loginname, ODA.oldval, ODA.newval
FROM Sales.OrderDetails AS OD
	JOIN Sales.OrderDetailsAudit AS ODA
		ON OD.orderid = ODA.orderid
		AND OD.productid = ODA.productid
WHERE ODA.columnname = N'qty';

-- EX Non equality join

-- I want to display empid,firstname,lastname
-- So I return rows from HR.Employees table
-- I combine HR.employees with HR.employees on empid to create unique pairs of employees
SELECT 
	E1.empid, E1.firstname, E1.lastname,
	E2.empid, E2.firstname, E2.lastname
FROM HR.Employees AS E1
	JOIN HR.Employees AS E2
	ON E1.empid < E2.empid
ORDER BY E1.empid, E2.empid;

-- I want to disaply empid, firstname, lastname from HR.Employees table 1 and 2
-- So I query all rows from HR.Employees 1 table
-- I combine HR.Employees table 1 with HR.Employees table 2 where empid 1 is less than empid 2 to create unique pairs
-- I Filter rows where empid 1 and 2 < 4
-- Sort empid 1 and 2 by descending order.
SELECT 
	E1.empid, E1.firstname, E1.lastname,
	E2.empid, E2.firstname, E2.lastname
FROM HR.Employees AS E1
	JOIN HR.Employees AS E2
	ON E1.empid < E2.empid
WHERE E1.empid < 4 AND E2.empid <4
ORDER BY E1.empid, E2.empid;


--EX Multijoin example

-- Display all rows and columns from Sales.Customers, Sales.ORders, Sales.OrderDetails
SELECT * FROM Sales.Customers;
SELECT * FROM Sales.Orders;
SELECT * FROM Sales.OrderDetails;

-- I want to display custid, companyname, orderid from Sales.Customers table
-- I want to display productid and qty from Sales.OrderDetails table
-- I return rows from Sales.Customers table
-- I join Sales.Customers table on custid column
-- I join Sales.OrderDetails table to the virtual table on orderid
SELECT 
	C.custid, C.companyname, O.orderid,
	OD.productid, OD.qty

FROM Sales.Customers AS C

	JOIN Sales.Orders AS O
		ON C.custid = O.custid

	JOIN Sales.OrderDetails AS OD
		ON  O.orderid = OD.orderid;

-- Outer joins
-- I want to display all rows from Sales.Customers, Sales.Orders table
-- I want to display custid, companyname from Sales.Customers table, and orderid from Sales.Orders table
-- So I return rows from Sales.Customers table
-- I preserve Sales.Customers table, and combine with orderid from Sales.Orders table using custid as the key. 
SELECT * FROM Sales.Customers;
SELECT * FROM Sales.Orders
ORDER BY custid ASC;
SELECT  C.custid, C.companyname, O.orderid
FROM Sales.Customers AS C
	LEFT OUTER JOIN Sales.Orders AS O
		ON C.custid = O.custid;

-- I want to display custid, companyname from Sales.Customers table, orderid from Sales.ORders table
-- Return all rows from Sales.Customers table
-- Preserve Sales.Customers table and combine with Sales.Orders table on the custid key
-- Filter and return output results for Sales.Orders.orderid thaat are null
SELECT  C.custid, C.companyname, O.orderid
FROM Sales.Customers AS C
	LEFT OUTER JOIN Sales.Orders AS O
		ON C.custid = O.custid
WHERE O.orderid IS NULL;


-- use tsql table
-- I want to display orderdate
-- orderdate is # of days, n-1, from 20060101
-- we query from dbo.Nums table
-- filter and return results where date is between 20060101 and 20081231
--sort by date ascending
USE TSQL2012;
SELECT DATEADD(day, n-1, '20060101') AS orderdate
FROM dbo.Nums
WHERE n <= DATEDIFF(day, '20060101', '20081231') + 1
ORDER BY orderdate;

-- I want to display orderdate, AGG functtion
-- orderid, custid, and empid from Sales.orders table
-- So I query results from dbo.Nums table
-- I preserve dbo.Nums and I combine Sales.orders table with dbo.Nums
-- using the DATEADD orderdate, 20060101 to Nums.n-1 days = O.orderdate as the key
-- I return rows only between 20060101 and 20081231
-- sorted by ascending order.
SELECT DATEADD(day, Nums.n -1, '20060101') AS orderdate,
	O.orderid, O.custid, O.empid
FROM dbo.Nums
	LEFT OUTER JOIN Sales.Orders AS O
		ON DATEADD(day, Nums.n - 1, '20060101') = O.orderdate
WHERE Nums.n <= DATEDIFF(day, '20060101', '20081231') + 1
ORDER BY orderdate;
--(orderdates that do not appear in the Sales.Orders table appear Null.

-- Multiple Joins


USE TSQL2012;
SELECT * FROM  Sales.Orders;
SELECT * FROM Sales.Customers;
-- I want to display custid, companyname from Sales.Customers table
-- I want to display orderid, orderdate from Sales.Orders table
-- So I query results from Sales.Customers table
-- I preserve Sales.Customers table and combine Sales.Orders table with Sales.Customers
-- combining on custid, if a custid does not exist from Sales.Orders in Sales.Customers,
-- then a new column is created with custid being null.
-- filter results using orderdate from Sales.Orders table.
-- sort by custid
SELECT C.custid, C.companyname, O.orderid, O.orderdate
FROM Sales.Customers AS C
	LEFT OUTER JOIN Sales.Orders AS O
		ON C.custid = O.custid
WHERE O.orderdate <= '20070101'
ORDER by C.custid ASC;

--I want to display custid from Sales.customers table
--Display orderid from Sales.Orders table
--Display productid and qty from Sales.OrderDetails table
--So I query all rows from Sales.Customers table
--I preserve Sales.Customers and combines Sales.Orders with Sales.Customers on custid
--to create a virtual table
-- I perform an inner join to combine the virtual table with Sales.OrderDetails on orderid
-- I return only overlapping rows that contain the same orderid in both tables.
SELECT C.custid, O.orderid, OD.productid, OD.qty
FROM Sales.Customers AS C
	LEFT OUTER JOIN Sales.Orders AS O
		ON C.custid = O.custid
	JOIN Sales.OrderDetails AS OD
		ON O.orderid = OD.orderid;
--problem with this query is that performing a outer join then inner join,
--"outer rows"are dropped from the inner join.
SELECT C.custid, O.orderid, OD.productid, OD.qty
FROM Sales.Customers AS C
	LEFT OUTER JOIN Sales.Orders AS O
		ON C.custid = O.custid
	LEFT OUTER JOIN Sales.OrderDetails AS OD
		ON O.orderid = OD.orderid;

-- I want to display custid from Sales.Customers table
--I want to display orderid from Sales.Orders table
-- I want to display productid and qty from Sales.OrderDetails table
-- So I query all rows from Sales.Customers table
-- I create a virtual table and preserve Sales.Customers and combine Sales.Orders with 
-- Sales.Customers using custid
-- I preserve the virtual table and combine Sales.OrderDetails with the virtual table with orderid.
SELECT C.custid, O.orderid, OD.productid, OD.qty
FROM Sales.Customers AS C
	LEFT OUTER JOIN Sales.Orders AS O
		ON C.custid = O.custid
	LEFT OUTER JOIN  Sales.OrderDetails AS OD
		ON O.orderid = OD.orderid;
-- using the 2 outer joins we preserved the null values from the first join.
-- using outer join and then inner join dropped the null values from the outer join.

