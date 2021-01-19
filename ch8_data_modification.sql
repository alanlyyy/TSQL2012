USE TSQL2012;

--delete dbo.Orders if already exist
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;

-- create dbo.Orders table
CREATE TABLE dbo.Orders
(
orderid INT NOT NULL
CONSTRAINT PK_Orders PRIMARY KEY,
orderdate DATE NOT NULL
CONSTRAINT DFT_orderdate DEFAULT(SYSDATETIME()),
empid INT NOT NULL,
custid VARCHAR(10) NOT NULL
)

--insert a single row into orders table.
INSERT INTO dbo.Orders(orderid, orderdate,empid, custid)
VALUES(10001, '20090212',3, 'A');

INSERT INTO dbo.Orders(orderid, empid, custid)
VALUES(10002, 5, 'B');

SELECT * FROM dbo.Orders;

--insert multiple rows into dbo.Orders in the following order: orderid, orderdate, empid, and custid
INSERT INTO dbo.Orders
(orderid, orderdate, empid, custid)
VALUES 
(10003, '20090213',4 , 'B'),
(10004, '20090214',1 , 'A'),
(10005, '20090213',1 , 'C'),
(10006, '20090215',3 , 'C');


-- return all columns from virtual table O
--virtual table O contains cols: orderid, orderdate, empid, and custid
SELECT * 
FROM ( VALUES
		(10003, '20090213', 4, 'B'),
		(10004, '20090214',1 , 'A'),
		(10005, '20090213',1 , 'C'),
		(10006, '20090215',3 , 'C') ) AS O(orderid,orderdate,empid, custid);


-- insert into dbo.Orders in following order: orderid,orderdate,empid,custid
-- values are equal to all rows returned from select statement Sales.Orders 
--where country is equal to uk.
USE TSQL2012;
INSERT INTO dbo.Orders(orderid, orderdate, empid, custid)
SELECT orderid, orderdate, empid, custid
FROM Sales.Orders
WHERE shipcountry = 'UK';

--p249, 277/442 (INSERT SELECT STATEment)


-- insert 4 rows into dbo.Orders table
INSERT INTO dbo.Orders(orderid, orderdate, empid, custid)
SELECT 10007, '20090215', 2 , 'B' UNION ALL
SELECT 10008, '20090215', 1 , 'C' UNION ALL
SELECT 10009, '20090216', 2 , 'C' UNION ALL
SELECT 10010, '20090216', 3 , 'A';


USE TSQL2012;
--drop stored procedure if already exists
IF OBJECT_ID('Sales.usp_getorders', 'P') IS NOT NULL
DROP PROC Sales.usp_getorders;


--create stored procedure which takes an input country of upto 40 characters
--return columns orderid, orderdate, empid, custid from Sales.Orders
--if the shipcountry = input country
GO
CREATE PROC Sales.usp_getorders
@country AS NVARCHAR(40)
AS

SELECT orderid, orderdate, empid, custid
FROM Sales.Orders
WHERE shipcountry = @country;
GO

--run the stored procedure with parameter France
EXEC Sales.usp_getorders @country = 'France';

--insert rows into dbo.Orders table
--rows are from stored procedure, Sales.usp_getorders with the parameter 'France'
INSERT INTO dbo.Orders(orderid, orderdate, empid, custid)
EXEC Sales.usp_getorders @country = 'France';

SELECT * FROM dbo.Orders;

--delete dbo.Orders if already exist
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;

-- return columns: orderid, orderdate, empid, and custid from Sales.Orders table
-- insert into dbo.Orders
SELECT orderid, orderdate, empid, custid
INTO dbo.Orders
FROM Sales.Orders;

--delete dbo.Locations if already exist
IF OBJECT_ID('dbo.Locations', 'U') IS NOT NULL DROP TABLE dbo.Locations;

--create a new table called dbo.Locations,
-- insert country, region, city from Sales.Customers table
--exclude rows with the same country, region, and city from HR.employees table
SELECT country, region, city
INTO dbo.Locations
FROM Sales.Customers

EXCEPT

SELECT country, region, city
FROM HR.Employees

SELECT * FROM dbo.Locations;

--252 p.280/442
USE TSQL2012;

--delete dbo.T1 if table already exists
IF OBJECT_ID('dbo.T1', 'U') IS NOT NULL DROP TABLE dbo.T1;

--create table dbo.T1 
-- keycol is a system created primary key starting at 1, and increments 1 for each new object.
--datacol is a string that starts with alphabetical characters
CREATE TABLE dbo.T1
(
keycol INT	NOT NULL IDENTITY(1,1)
	CONSTRAINT PK_T1 PRIMARY KEY,
datacol VARCHAR(10) NOT NULL
	CONSTRAINT CHK_T1_datacol CHECK(datacol LIKE '[A-Za-z]%')
);

--insert data into table, keycol is neglected because keycol is a system defined value
INSERT INTO dbo.T1(datacol) VALUES('AAAAA');
INSERT INTO dbo.T1(datacol) VALUES('CCCCC');
INSERT INTO dbo.T1(datacol) VALUES('BBBBB');

--since data is not alphabetical, insertion fails.
INSERT INTO dbo.T1(datacol) VALUES('12323');


SELECT * FROM dbo.T1;

--query keycol from dbo.T1 implicitly
SELECT $identity FROM dbo.T1;


--insert new row into dbo.T1;
-- extract newly generated key from dbo.T1
-- return the newly generated key
DECLARE @new_key AS INT;
INSERT INTO dbo.T1(datacol) VALUES('AAAAA');
SET @new_key = SCOPE_IDENTITY();
SELECT @new_key AS new_key;

--in a new seesion, check the current identity key in keycol for dbo.T1
--IDENT_CURRENT checks dbo.T1 regardless of the session.
SELECT 
	SCOPE_IDENTITY() AS [SCOPE_IDENTITY],
	@@identity AS [@@identity],
	IDENT_CURRENT('dbo.T1') AS [IDENT_CURRENT];

--insert a new row into T1with value of 5 in keycol
SET IDENTITY_INSERT dbo.T1 ON;
INSERT INTO dbo.T1(keycol,datacol) VALUES(4,'FFFFF');
SET IDENTITY_INSERT dbo.T1 OFF;

SELECT * from dbo.T1;

--create a sequence starting value of 1, with max value of 2^32 (max num for int)
--default increment by 1
CREATE SEQUENCE dbo.SeqOrderIDs AS INT
MINVALUE 1
CYCLE;

--alter current sequence to prevent cycling.
ALTER SEQUENCE dbo.SeqOrderIDs
NO CYCLE;

--generate a new sequence value 
SELECT NEXT VALUE FOR dbo.SeqOrderIDs;

--259 p. 287/442