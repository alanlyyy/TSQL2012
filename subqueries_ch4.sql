-- I want to use TSQL2012 database
USE TSQL2012;

-- Self contained Scalar Subquery 

--maxid is a variable that stores the queried value of finding max orderid from Sales.Orders table
DECLARE @maxid AS INT = (SELECT MAX(orderid) FROM Sales.Orders);

-- I want to display orderid, orderdate, empid, and custid from Sales.Orders table
-- I filter orderid for subquery maxid
SELECT orderid, orderdate, empid, custid
FROM Sales.Orders
WHERE orderid = @maxid;

--instead of using maxid as variable that holds subquery we can pass entire subquery to filter.
SELECT orderid, orderdate, empid, custid
FROM Sales.Orders
WHERE orderid = (SELECT MAX(O.orderid) FROM Sales.Orders AS O);

-- I want to display orderid from Sales.Order table
-- So I query Sales.Order table and filter for empid
-- Where empid = subquery empid from HR.employees table
-- that contains 'B' as first letter of employee lastname

--This query only works because the subquery only returns 1 value,
--if subquery returns multiple values, query fails.
SELECT orderid 
FROM Sales.Orders
WHERE empid = 
(SELECT E.empid FROM HR.Employees AS E
WHERE E.lastname LIKE N'B%');


--When filtering for lastnames that start with D, Query fails because of multiple return values.
SELECT orderid 
FROM Sales.Orders
WHERE empid = 
(SELECT E.empid FROM HR.Employees AS E
WHERE E.lastname LIKE N'D%');

--There are no last names that start with A in HR.Employees table
--when filtering for lastnames that start with A, Query returns empty set.
SELECT orderid 
FROM Sales.Orders
WHERE empid = 
(SELECT E.empid FROM HR.Employees AS E
WHERE E.lastname LIKE N'A%');

--p.131, 159/442

--Multivalued subquery

-- using TSQL data base,
-- I want to display orderid from Sales.Orders table
-- I filter results for empid from Sales.Orders table matching
-- empid from HR.Employees table if last name starts with D.
USE TSQL2012;
SELECT orderid
FROM Sales.Orders
WHERE empid IN 
	(SELECT E.empid 
	FROM HR.Employees AS E
	WHERE E.lastname LIKE N'D%');

-- I want to display custid, orderid, orderdate, empid
-- So I query rows from Sales.Orders table
-- I filter for custid from Sales.Orders table to match
-- the set of custid from Sales.Customers table where country = USA
SELECT custid, orderid, orderdate, empid
FROM Sales.Orders
WHERE custid IN 
		(SELECT C.custid FROM Sales.Customers AS C
		WHERE C.country = N'USA');

-- I want to display custid, companyname from Sales.Customers table
-- I filter for custid from Sales.Customers table
-- not found in the set of custid found in the Sales.Orders table
-- "in other words, return customers who did not place an order."
SELECT custid, companyname
FROM Sales.Customers
WHERE custid NOT IN
(SELECT O.custid
FROM Sales.Orders AS O);

--Using multiple subqueries in a query

-- Create a new tabl called dbo.Orders
-- where orderid is type int and primary key.
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
CREATE TABLE dbo.Orders(orderid INT NOT NULL CONSTRAINT PK_Orders PRIMARY KEY);

--insert data into orderid column
--a copy of orderid from Sales.Orders table that are even
INSERT INTO dbo.Orders(orderid)
	SELECT orderid
	FROM Sales.Orders
	WHERE orderid % 2 = 0;

-- I want to display n from dbo.Nums table
-- I filter for n, if between min orderid from dbo.Orders table (scalar subquery)
-- and max orderid from dbo.Orders table (scalar subquery)
-- and if n is not an orderid found in dbo.Orders table. (multi- subquery)
-- returns all odd numbered orderid between min and max order ids found in orders table.
SELECT n
FROM dbo.Nums
WHERE n BETWEEN (SELECT MIN(O.orderid) FROM dbo.Orders AS O)
				AND (SELECT MAX(O.orderid) FROM dbo.Orders AS O)
AND n NOT IN (SELECT O.orderid FROM dbo.Orders AS O);


--Correlated Subqueries

USE TSQL2012;

-- I want to display custid, orderid, orderdate, empid from Sales.Orders 1 table
-- for each row I filter for orderid = to (MAX orderid for current custid) 
SELECT custid, orderid, orderdate,empid
FROM Sales.Orders AS O1
WHERE orderid = (SELECT MAX(O2.orderid)
				FROM Sales.Orders AS O2
				WHERE O2.custid = O1.custid);

--p.137 165/442