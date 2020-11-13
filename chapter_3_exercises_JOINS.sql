USE TSQL2012;

--1.1

SELECT * FROM dbo.Nums;
SELECT * FROM HR.Employees;

-- I want to display empid, firstname, lastname from HR.Employees table
-- I want to display n from dbo.Nums table
-- So I query all rows and create n x m unique rows between HR.Employees and dbo.Nums
-- I return filtered rows where n <= 5
SELECT E1.empid, E1.firstname,E1.lastname, nums.n
FROM HR.Employees AS E1
	CROSS JOIN dbo.Nums AS nums
WHERE (n < 6);


--1.2
--create a table of june dates 2009-06-12 through 2009-06-16
--combine empid of each Employee with each date in June_date table
--Create n x m copies of empid with june_day 
CREATE TABLE June_date (
	june_day DATE
);
INSERT INTO June_date(june_day)
VALUES(datefromparts('2009','06','12'));
INSERT INTO June_date(june_day)
VALUES(datefromparts('2009','06','13'));
INSERT INTO June_date(june_day)
VALUES(datefromparts('2009','06','14'));
INSERT INTO June_date(june_day)
VALUES(datefromparts('2009','06','15'));
INSERT INTO June_date(june_day)
VALUES(datefromparts('2009','06','16'));

SELECT E.empid, JD.june_day 
FROM HR.Employees AS E
CROSS JOIN June_date as JD
ORDER BY E.empid ASC;


--2
-- I want to display all columns top 5 rows from Sales.Customers,Sales.Orders,Sales.OrderDetails table
USE TSQL2012;
SELECT  * FROM Sales.Customers; --custid here
SELECT  * FROM Sales.Orders; -- custid-orderid here
SELECT  * FROM Sales.OrderDetails; --ordierid-qty located here

SELECT *
FROM Sales.Orders AS SO
WHERE SO.custid = 32;

-- I want to display custid, total number of unique order #, and total quantity ordered
-- So I query all rows from Sales.Customers table
-- I preserve Sales.Customers table and join with Sales.Orders table using custid
-- I preserve the combined table, and join with Sales.Orderdetails using orderid
-- filter from virtual table united states customers only
-- I group by custid so each custid should contain total num orders and total qty ordered.
SELECT CR.custid,COUNT(DISTINCT(SO.orderid)) AS numorders, SUM(SOD.qty) AS totalqty
FROM Sales.Customers AS CR
LEFT JOIN Sales.Orders AS SO
ON CR.custid = SO.custid
LEFT JOIN Sales.OrderDetails AS SOD
ON SO.orderid = SOD.orderid
WHERE CR.country = 'USA'
GROUP BY CR.custid;


--3 Return customers and their orders, including customers who placed no orders.
USE TSQL2012;

--SELECT * FROM Sales.Customers;
SELECT * FROM Sales.Orders;
SELECT * FROM Sales.Orders
WHERE custid = 22 OR custid = 57;

-- I want to display custid companyname from Sales.Customers table
-- I want to display orderid and orderdate from Sales.Orders table
-- I preserve Sales.Customers table and combine with Sales.Orders table, using all custid from Sales.Customers table
-- if custid does not contain a orderid or orderdate output is null
-- sort output in ascending order.
SELECT CR.custid, CR.companyname, SO.orderid, SO.orderdate
FROM Sales.Customers AS CR
LEFT OUTER JOIN Sales.Orders AS SO
ON CR.custid = SO.custid
ORDER BY SO.orderid;

--4 Return customers who did not place any orders

-- I want to display custid and companyname from Sales.Customers table
-- So I query all rows in Sales.Customers table
-- I preserve Sales.customers table and combine with Sales.Orders table using all custids found in Sales.Customers table. 
-- (custid of intersection with Sales.Customers and Sales.Orders and custid that only exist in Sales.Customers table)
-- Find all elements that contain null for orderdate and orderid
-- Sort by orderid in ascending order.
SELECT CR.custid, CR.companyname
FROM Sales.Customers AS CR
LEFT OUTER JOIN Sales.Orders AS SO
ON CR.custid = SO.custid
WHERE SO.orderdate IS NULL OR SO.orderid IS NULL
ORDER BY SO.orderid;

--5 Return customers with orders placed on Feb 12,2007, along with their orders

-- I want to display custid, companyname from Sales.Customers table
-- I want to display orderid and orderdate from Sales.Orders table
-- I query results and preserve Sales.Customers table
-- I combine Sales.Customers table with Sales.Orders table taking the intersection of custid
-- I filter for date 2007-02-12
SELECT CR.custid, CR.companyname, SO.orderid, SO.orderdate
FROM Sales.Customers AS CR
LEFT JOIN Sales.Orders AS SO
ON CR.custid = SO.custid
WHERE SO.orderdate = '20070212';

--6 Return customers with orders placed on 02-12-2007 and orders, customers who didn't place orders on 02-12-2007

-- I want to display custid, company name from Sales.Customers table , orderid and orderdate from Sales.Orders table
-- So I query rows and preserve Sales.Customers table
-- I combined Sales.Customers with Sales.Orders table takin the intersection of custid and if orderdate = '20070212'
-- The output generates a table 
SELECT CR.custid, CR.companyname, SO.orderid, SO.orderdate
FROM Sales.Customers AS CR
LEFT JOIN Sales.Orders AS SO
ON CR.custid = SO.custid AND SO.orderdate = '20070212';

--7 Return all customers and for each return a YES/NO value depending on whether the customer placed an order on 02-12-2007

-- I want to display custid and company name from Sales.Customers table
-- I want to display HasOrderOn20070212 using orderdate from Sales.Orders table
-- I preserve Sales.Customers table and combine with Sales.Orders table taking the intersection of custid and filtering for 20070212
SELECT CR.custid, CR.companyname,
CASE 
	WHEN SO.orderdate = '20070212' THEN 'Yes'
	WHEN SO.orderdate IS NULL THEN 'No'
END AS HasOrderOn20070212
FROM Sales.Customers AS CR
LEFT JOIN Sales.Orders AS SO
ON CR.custid = SO.custid AND SO.orderdate = '20070212';
