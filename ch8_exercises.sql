USE TSQL2012;

IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL DROP TABLE dbo.Customers;

CREATE TABLE dbo.Customers
(
custid INT NOT NULL PRIMARY KEY,
companyname NVARCHAR(40) NOT NULL,
country NVARCHAR(15) NOT NULL,
region NVARCHAR(15) NULL,
city NVARCHAR(15) NOT NULL
);

--1.1
--insert a single row into dbo.Customers
INSERT INTO dbo.Customers
VALUES(100,N'Coho Winery', N'USA', N'WA', N'Redmond');

SELECT * FROM dbo.Customers;


--1.2 -- previously incorrect
--insert into dbo.Customers all customers that made an order
--insert rows from Sales.Customers if custid of given row is also found in Sales.ORders
INSERT INTO dbo.Customers
SELECT SC.custid, SC.companyname, SC.country,SC.region,SC.city 
FROM Sales.Customers AS SC
WHERE SC.custid IN (SELECT SO.custid 
					FROM Sales.Orders AS SO
					WHERE SC.custid = SO.custid);


--drop dbo.Orders if table already exist
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;

SELECT * FROM Sales.Orders;
--1.3 for sql server only can use select into statement

--accept all columns into dbo.Orders table
--queried from Sales.Orders
--filter date between 2006 and 2009 
--create a table and insert rows into dbo.Orders
SELECT *
INTO dbo.Orders
FROM Sales.Orders
WHERE orderdate>= '20060101' AND orderdate < '20090101';

--query for rows outside 2006 and 2009 in dbo.Orders table
SELECT * FROM dbo.Orders
WHERE orderdate < '20060101' OR orderdate > '20090101';


SELECT * FROM dbo.ORDERS
ORDER BY orderdate DESC;

--2
--delete rows from dbo.Orders
--if orderdate is before august 2006
DELETE FROM dbo.Orders
OUTPUT deleted.orderdate,
		deleted.orderid,
		deleted.shipcountry
WHERE orderdate < '20060801';

--3 -- previously incorrect

--book solution
DELETE FROM dbo.Orders
OUTPUT deleted.custid
WHERE EXISTS
(SELECT *
FROM dbo.Customers AS C
WHERE Orders.custid = C.custid
AND C.country = N'Brazil');

SELECT * FROM dbo.ORDERS
ORDER BY shipcountry ASC;


--4. 
SELECT * FROM dbo.Customers;

--update dbo.Customers
--set values of region to none if region is null
--print the output of affected rows
UPDATE dbo.Customers
SET region = '<None>'
OUTPUT 
	deleted.custid, 
	inserted.region AS newregion,
	deleted.region AS oldregion
WHERE region IS NULL;


--5. -- previously incorrect 
SELECT * FROM dbo.Orders
WHERE shipcountry ='UK';

SELECT * FROM dbo.Customers;

--update data in dbo.Orders
--with dbo.Customers table
--if custid match and shipcountry = 'UK'
--update data and print output 
MERGE INTO dbo.Orders AS O
USING dbo.Customers AS C
ON C.custid = O.custid AND C.country ='UK'
WHEN MATCHED THEN 
UPDATE SET
	O.shipcountry = C.country,
	O.shipregion = C.region,
	O.shipcity = C.city
OUTPUT
	deleted.orderid,
	deleted.custid,
	inserted.shipcountry,
	deleted.shipcountry,
	inserted.shipcity,
	deleted.shipcity,
	inserted.shipregion,
	deleted.shipregion;

--delete tables if already exist
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL DROP TABLE dbo.Customers;

--291 , 319/442 solutions.
