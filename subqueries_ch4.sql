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


-- I want to display orderid, custid, and val, and pct 
-- pct is a percentage calculated from each row of O1.val
-- subquery: get the current O1.custid from the current row, if the current rows O1.custid = O2.custid
-- sum all rows of O2.val that contain the current custid.
-- return results from Sales.OrderValues table
-- sort by custid, orderid ASC
USE TSQL2012;
SELECT orderid, custid, val,
	CAST( 100. *val / (SELECT SUM(O2.val)
						FROM Sales.OrderValues AS O2
						WHERE O2.custid = O1.custid)
			AS NUMERIC(5,2)) AS pct
FROM Sales.OrderValues AS O1
ORDER BY custid, orderid;

--Exists Predicate

-- I want to display custid and companyname from Sales.Customers table
-- I filter for rows where country = Spain
-- and for each row, we check the custid from Sales.Customers table if the custid is in the set of custid from Sales.Orders table.
SELECT custid, companyname
FROM Sales.Customers AS C
WHERE country = N'Spain'
	AND EXISTS 
		(SELECT * FROM Sales.Orders AS O
		WHERE O.custid = C.custid);

-- I want to display custid and companyname from Sales.Customers table
-- I filter for rows where country = Spain
-- and for each row, we check the custid from Sales.Customers table if the custid does NOT exist in the set of custid from Sales.Orders table.
SELECT custid, companyname
FROM Sales.Customers AS C
WHERE country = N'Spain'
	AND NOT EXISTS 
		(SELECT * FROM Sales.Orders AS O
		WHERE O.custid = C.custid);

-- I want to display orderid, orderdate, empid, and custid
-- for each row, I want to display the (max orderid from O2) which is less than the current orderid of the row in O1.
-- So I query all rows from Sales.Orders table.
SELECT orderid, orderdate, empid, custid,
	(SELECT MAX(O2.orderid)
	FROM Sales.Orders AS O2
	WHERE O2.orderid < O1.orderid) AS prevorderid
FROM Sales.Orders AS O1;

-- I want to display orderid, orderdate, empid, and custid
-- for each row, I want to display the (min orderid from O2) which is greater than the "current orderid of the row" in O1.
-- So I query all rows from Sales.Orders table.
SELECT orderid, orderdate, empid, custid,
	(SELECT MIN(O2.orderid)
	FROM Sales.Orders AS O2
	WHERE O2.orderid > O1.orderid) AS next_orderid
FROM Sales.Orders AS O1;


-- Running Aggregates p.141, 169/442
SELECT orderyear, qty
FROM Sales.OrderTotalsByYear;


-- I want to display orderyear qty,
-- and runqty which is a subquery for each row, if the current rows O1.orderyear >= O2.orderyear
-- we get the sum of the qty for the given orderyear
-- I query results from Sales.OrderTotalsByYear
-- I sort by orderyear ASC
USE TSQL2012;
SELECT orderyear, qty,
	(SELECT SUM(O2.qty)
	FROM Sales.OrderTotalsByYear AS O2
	WHERE O2.orderyear <= O1.orderyear) AS runqty
FROM Sales.OrderTotalsByYear AS O1
ORDER BY orderyear;


--Dealing with misbehaving subqueries

-- I want to display custid, companyname from Sales.Customers table
-- I want to filter looking at the custid of each row in Sales.Customers table if custid is found in the Sales.Orders table.
SELECT custid, companyname
FROM Sales.Customers
WHERE custid NOT IN(SELECT O.custid 
					FROM Sales.Orders AS O);
-- running query after adding new row results in a empty set.

-- In the Sales.Orders table with the following columns
-- Insert 1 row with the following values.
INSERT INTO Sales.Orders
(custid, empid, orderdate, requireddate, shippeddate,shipperid,
freight, shipname, shipaddress, shipcity, shipregion,
shippostalcode, shipcountry)
VALUES(NULL, 1, '20090212', '20090212', '20090212', 1, 123.00, N'ABC', N'abc', N'abc', N'ABC', N'ABC',  N'ABC')

--Explicit declaration

-- I want to display custid, companyname from Sales.Customers table
-- I want to filter looking at the custid of each row in Sales.Customers table if custid is not found in the Sales.Orders table, and custid is not null.
SELECT custid, companyname
FROM Sales.Customers
WHERE custid NOT IN(SELECT O.custid 
					FROM Sales.Orders AS O
					WHERE O.custid IS NOT NULL);

--implicit declaration

-- I want to display custid, companyname
-- So I query rows from Sales.Customers table
-- I filter for each row of Sales.Customers, check the current rows custid compared with custid found in Sales.Orders table
-- if custid from Sales.Customers table is not in Sales.Orders return rows.
SELECT custid, companyname
FROM Sales.Customers AS C
WHERE NOT EXISTS
	(SELECT * 
	FROM Sales.Orders AS O
	WHERE O.custid = C.custid);

--eliminate all rows from Sales.ORders table where custid is null.
DELETE FROM Sales.Orders WHERE custid IS NULL;

-- Subsitution errors in subquery column name

--check if myshippers table exist
--remove the table if already exists
IF OBJECT_ID('Sales.Myshippers', 'U') IS NOT NULL
	DROP TABLE Sales.MyShippers;

-- create a table Sales.Myshippers 
-- with columns shipper_id, companyname, phone, shipper_id is set to primary key;
CREATE TABLE Sales.MyShippers
(
shipper_id	INT					NOT NULL,
companyname NVARCHAR(40)		NOT NULL,
phone		NVARCHAR(24)		NOT NULL,
CONSTRAINT PK_Myshippers		PRIMARY KEY(shipper_id)
);

-- for table Sales.Myshippers
-- I want to insert 3 values into the table
INSERT INTO Sales.MyShippers(shipper_id, companyname, phone)
	VALUES ( 1, N'Shipper GVSUA', N'(503) 555 - 0137'),
			(2, N'Shipper ETYNR', N'(425)  555 - 0136'),
			(3, N'Shipper ZHISN', N'(415)  555 - 0138');

-- I want to display shipperid and companyname
-- So I query results from Sales.Myshippers table
-- I look at each row of shipper_id from Sales.Myshippers, 
-- if shipper_id for current row is found in Sales.Orders table for custid 43
-- return the filtered rows

--query is incorrect should return shipper_id 2 and 3 only, shipper_id column does not existing in Sales.Orders table
-- therefore the subquery returns the query of shipper_id from Sales.Myshippers table or outer query
-- Sales.Orders instead has shipperid column.
SELECT shipper_id, companyname
FROM Sales.Myshippers
WHERE shipper_id IN (SELECT shipper_id
					FROM Sales.Orders
					WHERE custid = 43);