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

USE TSQL2012;
SELECT * FROM Sales.Orders;
SELECT * FROM HR.Employees;

-- I want to display empid, firstname, lastname
-- so I query rows from HR.Employees table
-- I filter each rows empid, if the empid is not found with an orderdate >=20080501 from Sales.Orders table.
SELECT empid, firstname,lastname 
FROM HR.Employees
WHERE empid NOT IN (SELECT SO.empid
				FROM Sales.Orders AS SO
				WHERE SO.orderdate >= '20080501');

--4.
USE TSQL2012;
SELECT * FROM Sales.Customers;
SELECT * FROM HR.Employees;

-- I want to display unique countries
-- so i query all rows from Sales.Customers table
-- I look at each row of Sales.Customers.country and filter for country not found in HR.Employees
SELECT DISTINCT C.country
FROM Sales.Customers AS C
WHERE C.country NOT IN (SELECT H.country 
						FROM HR.Employees AS H)

--5.
-- I want to display custid, orderid, orderdate, empid
-- I query all rows from Sales.Orders table
-- I filter each row of  O1.orderdate if O1.orderdate is (O2.orderdate, latest date = top(1), sorted by desc) for the current rows custid
-- Sort by custid ASC.
USE TSQL2012;
SELECT O1.custid,O1.orderid, O1.orderdate,O1.empid
FROM Sales.Orders AS O1
WHERE O1.orderdate = (SELECT TOP(1) O2.orderdate
					FROM Sales.Orders AS O2
					WHERE O2.custid = O1.custid
					ORDER BY O2.orderdate DESC)
ORDER BY O1.custid;
					
--6.
USE TSQL2012;
SELECT * FROM Sales.Customers;
SELECT * FROM Sales.Orders;

-- I want to display custid, and companyname
-- So i query all rows from Sales.Customers table
-- I look at each row of custid, accept custid if contains an orderdate in 2007
-- AND if custid does not contain an orderdate in 2008.
-- order by ascending
SELECT C.custid, C.companyname
FROM Sales.Customers AS C
WHERE				custid  IN (SELECT O.custid 
							FROM Sales.Orders AS O
							WHERE YEAR(O.orderdate) = '2007')

			AND 
					custid NOT IN(SELECT O2.custid
								FROM Sales.Orders AS O2
								WHERE YEAR(O2.orderdate) = '2008')
				
ORDER BY C.custid;

--7.
SELECT * FROM Sales.Customers;
SELECT * FROM Sales.Orders;
SELECT * FROM Sales.OrderDetails;


-- I want to display custid, companyname
-- So I query rows from Sales.Customers table, 
-- I filter rows of custid for custid that contains and orderid that contains a productid of 12
SELECT O1.custid, O1.companyname
FROM Sales.Customers AS O1
WHERE O1.custid IN (SELECT O2.custid 
					FROM Sales.Orders AS O2
					WHERE O2.orderid IN (SELECT O3.orderid
										FROM Sales.OrderDetails AS O3
										WHERE O3.productid = 12))

--8.
SELECT * FROM Sales.CustOrders
ORDER BY custid ASC;

-- I want to display custid, ordermonth, and qty
-- runqty is the sum of the qty for each current rows custid (C2.custid and C.custid), up to the current rows order month (C2.ordermonth = C.ordermonth)
-- We query rows from Sales.CustORders table.
-- sort the table by custid ascending order.
SELECT C.custid, C.ordermonth,C.qty,
		(SELECT SUM(C2.qty)
		FROM Sales.CustOrders AS C2
		WHERE C2.ordermonth <= C.ordermonth AND C2.custid = C.custid) AS runqty
FROM Sales.CustOrders AS C
ORDER BY custid ASC;

--solutions 152, 180/442