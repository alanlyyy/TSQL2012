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

--if t1 already exists drop table
IF OBJECT_ID('dbo.T1', 'U') IS NOT NULL DROP TABLE dbo.T1;

--create a table t1
-- with keycol type int as primary key
-- datacol is a string that is not null
CREATE TABLE dbo.T1
(
keycol INT NOT NULL
CONSTRAINT PK_T1 PRIMARY KEY,
datacol VARCHAR(10) NOT NULL
);

USE TSQL2012;
--create a new variable called neworderid which takes the next value of a sequence for current session
DECLARE @neworderid AS INT = NEXT VALUE FOR dbo.SeqOrderIDs;

--insert new seuence value into table and letter a
INSERT INTO dbo.T1(keycol, datacol) VALUES(@neworderid, 'a');

SELECT* FROM dbo.T1;

--insert a new sequence value internally  and inserting row
INSERT INTO dbo.T1(keycol, datacol)
VALUES(NEXT VALUE FOR dbo.SeqOrderIDs, 'b');

SELECT * FROM dbo.T1;


--update all current keycol values in the column by 1
UPDATE dbo.T1
SET keycol = NEXT VALUE FOR dbo.SeqOrderIDs;

SELECT * FROM dbo.T1;

--get current sequeuence orderid value
SELECT current_value
FROM sys.sequences
WHERE OBJECT_ID = OBJECT_ID('dbo.SeqOrderIDs');


--insert keycol, and datacol into dbo.T1
--with data returned from the query
--containing sequential id generated by system, sorted by hiredate, and a string of first letter in each employee first and last name
--extracted from HR.Employees table.
--query all rows from dbo.T1;
INSERT INTO dbo.T1(keycol, datacol)
SELECT 
	NEXT VALUE FOR dbo.SeqOrderIDs OVER(ORDER BY hiredate),
	LEFT (firstname, 1) + LEFT(lastname, 1)
FROM HR.Employees;

SELECT * FROM dbo.T1;



--add a constraint that automatically generates sequential ids when inserting into dbo.T1 table
ALTER TABLE dbo.T1
ADD CONSTRAINT  DFT_T1_keycol
DEFAULT (NEXT VALUE FOR dbo.SeqOrderIDs)
FOR keycol;

--when inserting sequential ids, no need to include keycol
INSERT INTO dbo.T1(datacol) VALUES('c');
SELECT * FROM dbo.T1;



--create a range of sequence values

--create 'first' variable
-- call the function sys.sp_sequence_get_range
-- using the created sequence dbo.SeqOrderIDs
-- with a range of 1-1000 numbers
-- indicate the first value of range is current value of dbo.SeqOrderIDs
DECLARE @first AS SQL_VARIANT;
EXEC sys.sp_sequence_get_range
@sequence_name = N'dbo.SeqOrderIDs',
@range_size		= 1000,
@range_first_value = @first OUTPUT;

SELECT @first;

--delete table dbo.T1 and sequence dbo.SeqOrderIDs
IF OBJECT_ID('dbo.T1', 'U') IS NOT NULL DROP TABLE dbo.T1;
IF OBJECT_ID('dbo.SeqOrderIDs', 'So') IS NOT NULL DROP SEQUENCE dbo.SeqOrderIDs;

--drop dbo.Orders and sbo.Customers if tables already exists
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL DROP TABLE dbo.Customers;

--create table dbo.customers with custid as primary key
CREATE TABLE dbo.Customers
(
custid INT NOT NULL,
companyname		NVARCHAR(40) NOT NULL,
contactname		NVARCHAR(30) NOT NULL,
contacttitle	NVARCHAR(30) NOT NULL,
address			NVARCHAR(60) NOT NULL,
city			NVARCHAR(15) NOT NULL,
region			NVARCHAR(15) NULL,
postalcode		NVARCHAR(10) NULL,
country			NVARCHAR(15) NOT NULL,
phone			NVARCHAR(24) NOT NULL,
fax				NVARCHAR(24) NULL,
CONSTRAINT PK_Customers PRIMARY KEY(custid)
);

--create table dbo.Orders with orderid as primary key, custid as secondary key
CREATE TABLE dbo.Orders
(
orderid INT NOT NULL,
custid INT NULL,
empid INT NOT NULL,
orderdate DATETIME NOT NULL,
requireddate DATETIME NOT NULL,
shippeddate DATETIME NULL,
shipperid INT NOT NULL,
freight MONEY NOT NULL
CONSTRAINT DFT_Orders_freight DEFAULT(0),
shipname NVARCHAR(40) NOT NULL,
shipaddress NVARCHAR(60) NOT NULL,
shipcity NVARCHAR(15) NOT NULL,
shipregion NVARCHAR(15) NULL,
shippostalcode NVARCHAR(10) NULL,
shipcountry NVARCHAR(15) NOT NULL,
CONSTRAINT PK_Orders PRIMARY KEY(orderid),
CONSTRAINT FK_Orders_Customers FOREIGN KEY(custid)
REFERENCES dbo.Customers(custid)
);
GO

--insert all rows and columns from Sales.Customers and Sales.Orders into copy tables.
INSERT INTO dbo.Customers 
SELECT* FROM Sales.Customers;

INSERT INTO dbo.Orders
SELECT * FROM Sales.Orders;

--delete all rows from dbo.Orders where orderdate was prior to Jan 1st 2007
DELETE FROM dbo.Orders
WHERE orderdate < '20070101';

--263 291/442

-- use tsql table
USE TSQL2012;

--delete from virtual table O
-- O is the intersection of dbo.Orders and dbo.Customers on custid key.
-- filter rows where country is USA.
DELETE FROM O
FROM dbo.Orders AS O
JOIN dbo.Customers AS C
ON O.custid = C.custid
WHERE C.country = N'USA';

--delete rows from dbo.Orders
-- if rows in dbo.Orders has a custid in dbo.Customers and country is USA
DELETE FROM dbo.Orders
WHERE EXISTS 
(SELECT * 
FROM dbo.Customers AS C
WHERE Orders.Custid = C.custid
AND C.country = 'USA');

--delete tables if already exists
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL DROP TABLE dbo.Customers;


IF OBJECT_ID('dbo.OrderDetails', 'U') IS NOT NULL DROP TABLE dbo.OrderDetails;
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;


--create dbo.Orders table with orderid as primary key 
CREATE TABLE dbo.Orders
(
orderid			INT			NOT NULL,
custid			INT			NULL,
empid			INT			NOT NULL,
orderdate		DATETIME	NOT NULL,
requireddate	DATETIME	NOT NULL,
shippeddate		DATETIME	NULL,
shipperid		INT			NOT NULL,

freight			MONEY		NOT NULL
CONSTRAINT	DFT_Orders_freight	DEFAULT(0),

shipname		NVARCHAR(40)	NOT NULL,
shipaddress		NVARCHAR(60)	NOT NULL,

shipcity		NVARCHAR(15)	NOT NULL,
shipregion		NVARCHAR(15)	NULL,
shippostalcode	NVARCHAR(10)	NULL,
shipcountry		NVARCHAR(15)	NOT NULL,
CONSTRAINT	PK_Orders PRIMARY KEY(orderid)
);


--qty has a default constraint of 0
--discount has default constraint of 0
--primary key is orderid and productid
--foreign key is orderid from dbo.Orders table (foreign key prevents actions to destroy links between the 2 tables and prevents invalid data to be inserted into foreign key column
CREATE TABLE dbo.OrderDetails
(
orderid INT NOT NULL,
productid INT  NOT NULL,

unitprice MONEY	NOT NULL
CONSTRAINT DFT_OrderDetails_unitprice DEFAULT(0),

qty		SMALLINT	NOT NULL
CONSTRAINT DFT_OrderDetails_qty DEFAULT(1),

discount NUMERIC(4,3) NOT NULL
CONSTRAINT DFT_OrderDetails_discount DEFAULT(0),


CONSTRAINT PK_OrderDetails PRIMARY KEY(orderid, productid),

CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY(orderid) 
REFERENCES dbo.Orders(orderid),

CONSTRAINT CHK_discount CHECK (discount BETWEEN 0 AND 1),

CONSTRAINT CHK_qty CHECK(qty > 0),
CONSTRAINT CHK_unitprice CHECK(unitprice > = 0)
);
GO

--copy all rows from Sales.Orders into dbo.Orders
--copy all rows from Sales.OrderDetails into dbo.OrdersDetails
INSERT INTO dbo.Orders SELECT * FROM Sales.Orders;
INSERT INTO dbo.OrderDetails SELECT * FROM Sales.OrderDetails;

SELECT * FROM dbo.OrderDetails;
SELECT * FROM dbo.Orders;

USE TSQL2012;
--in dbo.Orderdetails table
--add 0.05 to discount
-- for all rows with productid = 51
UPDATE dbo.OrderDetails
SET discount = discount +0.05 --could also change to discount += 0.05
WHERE productid = 51;

-- update virtual table OD (update clause is last to execute)
-- OD is the intersection of dbo.OrderDetails and dbo.Orders using orderid as a key (from clause is first to execute)
-- filter rows from virtual table where custid equal to 1 (WHERE clause is 2nd to execute)
UPDATE OD
SET discount +=0.05
FROM dbo.OrderDetails AS OD
JOIN dbo.Orders AS O
ON OD.orderid = O.orderid
WHERE O.custid = 1;

-- subquery version of above code

--update rows in orderDetails table
-- if row is found in set returned from subquery
-- rows in dbo.Orders with an orderid found in OrderDetails and orders custid = 1
UPDATE dbo.OrderDetails
	SET discount += 0.05

WHERE EXISTS

(SELECT * FROM dbo.Orders AS O
WHERE O.orderid = OrderDetails.orderid
AND O.custid = 1);


--267, 295/442
USE TSQL2012;

IF OBJECT_ID('dbo.Sequences', 'U') IS NOT NULL DROP TABLE dbo.Sequences;

--create a table called dbo.Sequences
--columns id, as primary key, and val
CREATE TABLE dbo.Sequences
(
id VARCHAR(10) NOT NULL
CONSTRAINT PK_Sequences PRIMARY KEY(id),
val INT NOT NULL
);

--insert first element into table with val 0
INSERT INTO dbo.Sequences VALUES('SEQ1', 0);

--create variable nextval
--update val of current row by 1 and store in the table
DECLARE @nextval AS INT;
UPDATE dbo.Sequences
SET @nextval = val +=1
WHERE id = 'SEQ1';

SELECT* FROM dbo.Sequences;

IF OBJECT_ID('dbo.Sequences', 'U') IS NOT NULL DROP TABLE dbo.Sequences;

--275, 303/442

--query rows from dbo.OrderDetails
--combine rows using the intersection with dbo.Orders using orderid
--filter the rows for custid = 1
--update discount for the returned rows from query with custid 1
UPDATE OD
SET discount +=0.05
FROM dbo.OrderDetails AS OD
JOIN dbo.Orders AS O
ON OD.orderid = O.orderid
WHERE O.custid = 1;



USE TSQL2012;

-- similar to code above -- except we create CTE to test query before actually updating dbo.OrderDetails
-- create a table expression called C
-- query all rows from dbo.OrderDetails 
-- find intersection with dbo.Orders using orderid as the key
-- return columns custid, orderid, productid, discount, and new discount
-- filter rows for custid = 1
-- Update CTE table created with new discount replacing old discount.
WITH C AS
(
SELECT custid, OD.orderid,
productid, discount, discount + 0.05 AS newdiscount
FROM dbo.OrderDetails AS OD
JOIN dbo.Orders AS O
ON OD.orderid = O.orderid
WHERE O.custid = 1
)
UPDATE C 
SET discount = newdiscount;


--same query as above except we use derived table expression instead of CTE for testing the query
UPDATE D
SET discount = newdiscount
FROM (SELECT custid, OD.orderid, productid,
		discount, discount +0.05 AS newdiscount
		FROM dbo.OrderDetails AS OD
		JOIN dbo.Orders AS O
		ON OD.orderid = O.orderid
		WHERE O.custid = 1) AS D;

SELECT * FROM dbo.OrderDetails
WHERE productid = 28;

--delete dbo.T1 if alraedy exists
--create a table called dbo.T1 with 2 columns, col1 and col2
--insert 3 rows into dbo.T1 with only values in col1
IF OBJECT_ID('dbo.T1', 'U') IS NOT NULL DROP TABLE dbo.T1;
CREATE TABLE dbo.T1(col1 INT, col2 INT);
GO

INSERT INTO dbo.T1(col1) VALUES(10),(20),(30);

SELECT * FROM dbo.T1;

--query fails, cannot use row number window function in a update/set clause
--window functions can only be used is select or order by clause.
UPDATE dbo.T1 
SET col2 = ROW_NUMBER() OVER(ORDER BY col1);

--create a CTE 
--return col1, col2, and a row number generated looking at indices of col1
--query from dbo.T1 table.
--update cte by seeting col2 = rownumber
WITH C AS 
( 
SELECT col1, col2, ROW_NUMBER() OVER (ORDER BY col1) AS rownum
FROM dbo.T1
)
UPDATE C
SET col2 = rownum;

--277, 305/442

--if dbo.OrderDetails or dbo.Orders alraedy exist drop table
IF OBJECT_ID('dbo.OrderDetails', 'U') IS NOT NULL DROP TABLE dbo.OrderDetails;
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;

--create a new table called dbo.Orders
--freight has a default value of 0
--orderid is the primary key.
CREATE TABLE dbo.Orders
(
orderid INT NOT NULL,
custid INT NULL,
empid INT NOT NULL,
orderdate DATETIME NOT NULL,
requireddate DATETIME NOT NULL,
shippeddate DATETIME NULL,
shipperid INT NOT NULL,
freight MONEY NOT NULL
CONSTRAINT DFT_Orders_freight DEFAULT(0),
shipname NVARCHAR(40) NOT NULL,
shipaddress NVARCHAR(60) NOT NULL,
shipcity NVARCHAR(15) NOT NULL,
shipregion NVARCHAR(15) NULL,
shippostalcode NVARCHAR(10) NULL,
shipcountry NVARCHAR(15) NOT NULL,
CONSTRAINT PK_Orders PRIMARY KEY(orderid)
);
GO

--insert all rows from Sales.Orders into dbo.Orders.
INSERT INTO dbo.Orders SELECT * FROM Sales.Orders;

--delete 50 rows  orders table
--user cannot control what gets deleted, sql server determines which 50 rows to delete.
DELETE  TOP(50) FROM dbo.Orders;

--update top 50 rows of dbo.Orders
--by adding 10 to freight
-- cannot control which rows are modified.
UPDATE TOP(50) dbo.Orders
SET freight +=10.00;


--to control modifications using top/ offset fetch ==> use a CTE

--create a CTE
--query top 50 rows from dbo.ORders in ascending order(smallest -largest)
--Delete 50 rows from dbo.Orders
WITH C AS
(
SELECT TOP(50) *
FROM dbo.Orders
ORDER BY orderid
)
DELETE FROM C;


--create a cte 
--query top 50 rows from dbo.Orders
--sort by descending order (largest to smallest)
--add 10 to freight for queried rows from dbo.Orders
WITH C AS
(
SELECT TOP(50) *
FROM dbo.Orders
ORDER BY orderid DESC
)
UPDATE C
SET freight += 10;

--drop dbo.T1 if table already exists
IF OBJECT_ID('dbo.T1', 'U') IS NOT NULL DROP TABLE dbo.T1;

--create table dbo.T1
--keycol is primary key with system generated key identity, which starts at 1.
CREATE TABLE dbo.T1
(
keycol  INT				NOT NULL IDENTITY(1,1) CONSTRAINT PK_T1 PRIMARY KEY,
datacol NVARCHAR(40)	NOT NULL
);

--p.281, 309/442

USE TSQL2012;

--insert into table dbo.T1 a single datacol expicitly
--print output of the rows affected, that will be inserted into dbo.T1
--insert a single row with column last name from Hr.Employees table
--filter for USA
INSERT INTO dbo.T1(datacol)
OUTPUT inserted.keycol, inserted.datacol
SELECT lastname
FROM HR.Employees
WHERE country  = N'USA';


--create a table variable called new rows, with keycol and datacol
DECLARE @NewRows TABLE(keycol INT, datacol NVARCHAR(40));

--return last names queried from Hr.Employees where rows contains UK
--insert data into dbo.T1
--print affected rows
--and insert output into table variable NewRows;
INSERT INTO dbo.T1(datacol)
OUTPUT inserted.keycol, inserted.datacol
INTO @NewRows 
SELECT lastname
FROM HR.Employees
WHERE country = N'UK';

SELECT * FROM @NewRows;


--drop dbo.Orders if table already exists
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;

--create a new dbo.Orders table
CREATE TABLE dbo.Orders
(
orderid INT NOT NULL,
custid INT NULL,
empid INT NOT NULL,
orderdate DATETIME NOT NULL,
requireddate DATETIME NOT NULL,
shippeddate DATETIME NULL,
shipperid INT NOT NULL,
freight MONEY NOT NULL
CONSTRAINT DFT_Orders_freight DEFAULT(0),
shipname NVARCHAR(40) NOT NULL,
shipaddress NVARCHAR(60) NOT NULL,
shipcity NVARCHAR(15) NOT NULL,
shipregion NVARCHAR(15) NULL,
shippostalcode NVARCHAR(10) NULL,
shipcountry NVARCHAR(15) NOT NULL,
CONSTRAINT PK_Orders PRIMARY KEY(orderid)
);
GO

-- return all rows and columns from Sales.Orders
-- insert data into dbo.Orders
INSERT INTO dbo.Orders 
SELECT * FROM Sales.Orders;

--remove rows from dbo.Orders
--print the deleted output
--if rows contain data before 2008.
DELETE FROM dbo.Orders
	OUTPUT 
		deleted.orderid,
		deleted.orderdate,
		deleted.empid,
		deleted.custid
WHERE orderdate < '20080101';


--if dbo.OrderDetails already exist delete the table
IF OBJECT_ID('dbo.OrderDetails', 'U') IS NOT NULL DROP TABLE dbo.OrderDetails;

--create a new table called dbo.OrderDetails
CREATE TABLE dbo.OrderDetails
(
orderid INT NOT NULL,
productid INT NOT NULL,
unitprice MONEY NOT NULL
CONSTRAINT DFT_OrderDetails_unitprice DEFAULT(0),
qty SMALLINT NOT NULL
CONSTRAINT DFT_OrderDetails_qty DEFAULT(1),
discount NUMERIC(4, 3) NOT NULL
CONSTRAINT DFT_OrderDetails_discount DEFAULT(0),
CONSTRAINT PK_OrderDetails PRIMARY KEY(orderid, productid),
CONSTRAINT CHK_discount CHECK (discount BETWEEN 0 AND 1),
CONSTRAINT CHK_qty CHECK (qty > 0),
CONSTRAINT CHK_unitprice CHECK (unitprice >= 0)
);
GO

--insert all data from Sales.OrderDetails into dbo.OrderDetails
INSERT INTO dbo.OrderDetails SELECT * FROM Sales.OrderDetails;

--query rows from dbo.OrderDetails
--for rows with productid = 51
--add 5% to the discount
--print the productid of the insert rows
--print the old discount
--print the new discount
UPDATE dbo.OrderDetails
SET discount +=0.05
OUTPUT 
inserted.productid,
deleted.discount AS olddiscount,
inserted.discount AS newdiscount
WHERE productid = 51;





---------------------------------- Merge with Output example------------------------------------------------
------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL DROP TABLE dbo.Customers;
GO
CREATE TABLE dbo.Customers
(
custid INT NOT NULL,
companyname VARCHAR(25) NOT NULL,
phone VARCHAR(20) NOT NULL,
address VARCHAR(50) NOT NULL,
CONSTRAINT PK_Customers PRIMARY KEY(custid)
);

INSERT INTO dbo.Customers(custid, companyname, phone, address)
VALUES
(1, 'cust 1', '(111) 111-1111', 'address 1'),
(2, 'cust 2', '(222) 222-2222', 'address 2'),
(3, 'cust 3', '(333) 333-3333', 'address 3'),
(4, 'cust 4', '(444) 444-4444', 'address 4'),
(5, 'cust 5', '(555) 555-5555', 'address 5');
IF OBJECT_ID('dbo.CustomersStage', 'U') IS NOT NULL DROP TABLE dbo.
CustomersStage;
GO
CREATE TABLE dbo.CustomersStage
(
custid INT NOT NULL,
companyname VARCHAR(25) NOT NULL,
phone VARCHAR(20) NOT NULL,
address VARCHAR(50) NOT NULL,
CONSTRAINT PK_CustomersStage PRIMARY KEY(custid)
);
INSERT INTO dbo.CustomersStage(custid, companyname, phone, address)
VALUES
(2, 'AAAAA', '(222) 222-2222', 'address 2'),
(3, 'cust 3', '(333) 333-3333', 'address 3'),
(5, 'BBBBB', 'CCCCC', 'DDDDD'),
(6, 'cust 6 (new)', '(666) 666-6666', 'address 6'),
(7, 'cust 7 (new)', '(777) 777-7777', 'address 7');


--merge dbo.Customers and dbo.CustomersStage using custid as key
--if keys match update dbo.Customers companyname, phone, and address 
--if keys do not exist inserts dbo.CustomerStage row into dbo.Customers
--print the output of the query, for deleted and inserted rows.
MERGE INTO dbo.Customers AS TGT
USING dbo.CustomersStage AS SRC
	ON TGT.custid = SRC.custid
WHEN MATCHED THEN
UPDATE SET
	TGT.companyname = SRC.companyname,
	TGT.phone = SRC.phone,
	TGT.address = SRC.address
WHEN NOT MATCHED THEN
	INSERT (custid, companyname, phone, address)
	VALUES (SRC.custid, SRC.companyname, SRC.phone, SRC.address)
OUTPUT $action AS theaction, inserted.custid,
deleted.companyname AS oldcompanyname,
inserted.companyname AS newcompanyname,
deleted.phone AS oldphone,
inserted.phone AS newphone,
deleted.address AS oldaddress,
inserted.address AS newaddress;


--drop dbo.ProductsAudit and dbo.Products if table already exist
IF OBJECT_ID('dbo.ProductsAudit', 'U') IS NOT NULL DROP TABLE dbo.ProductsAudit;
IF OBJECT_ID('dbo.Products', 'U') IS NOT NULL DROP TABLE dbo.Products;

--create dbo.Products table
--primary key is productid, 
--unitprice default value =0
--discontinued price = 0
--unitprice has a constraint grater than 0
CREATE TABLE dbo.Products
(
productid INT NOT NULL,
productname NVARCHAR(40) NOT NULL,
supplierid INT NOT NULL,
categoryid INT NOT NULL,
unitprice MONEY NOT NULL
CONSTRAINT DFT_Products_unitprice DEFAULT(0),
discontinued BIT NOT NULL
CONSTRAINT DFT_Products_discontinued DEFAULT(0),
CONSTRAINT PK_Products PRIMARY KEY(productid),
CONSTRAINT CHK_Products_unitprice CHECK(unitprice >= 0)
);


INSERT INTO dbo.Products SELECT * FROM Production.Products;
CREATE TABLE dbo.ProductsAudit
(
LSN INT NOT NULL IDENTITY PRIMARY KEY,
TS DATETIME NOT NULL DEFAULT(CURRENT_TIMESTAMP),
productid INT NOT NULL,
colname SYSNAME NOT NULL,
oldval SQL_VARIANT NOT NULL,
newval SQL_VARIANT NOT NULL
);

--insert a row explicitly into dbo.ProductsAudit
--productid, unitprice, oldval and newval from result set 
--For result set, rows in dbo.Products multiply current unitprice by 1.15 if suppierid = 1
--return modified rows productid, and old and new unitprice
--filter the result set where oldval < 20 and newval >=20
INSERT INTO dbo.ProductsAudit(productid, colname, oldval,newval)
SELECT productid, N'unitprice', oldval, newval
FROM (UPDATE dbo.Products
		SET unitprice *=1.15
		OUTPUT 
			inserted.productid,
			deleted.unitprice AS oldval,
			inserted.unitprice AS newval
		WHERE supplierid = 1) AS D
WHERE oldval < 20 AND newval >=20;


SELECT * FROM ProductsAudit;


--p.287, 315/442

--drop tables if they already exist
IF OBJECT_ID('dbo.OrderDetails', 'U') IS NOT NULL DROP TABLE dbo.OrderDetails;
IF OBJECT_ID('dbo.ProductsAudit', 'U') IS NOT NULL DROP TABLE dbo.ProductsAudit;
IF OBJECT_ID('dbo.Products', 'U') IS NOT NULL DROP TABLE dbo.Products;
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL DROP TABLE dbo.Customers;
IF OBJECT_ID('dbo.T1', 'U') IS NOT NULL DROP TABLE dbo.T1;
IF OBJECT_ID('dbo.Sequences', 'U') IS NOT NULL DROP TABLE dbo.Sequences;
IF OBJECT_ID('dbo.CustomersStage', 'U') IS NOT NULL DROP TABLE dbo.CustomersStage;

