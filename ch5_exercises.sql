USE TSQL2012;

-- delete null row
SELECT * FROM Sales.Orders
WHERE orderid =11078;

DELETE FROM Sales.Orders
WHERE orderid =11078;


--1-1.
-- I want to return unique empid, orderdate
-- I query all rows from Sales.Orders table
-- for each row I look at the current orderdate
-- and get the max orderdate for the current rows employee.
SELECT DISTINCT O1.empid, O1.orderdate AS maxorderdate
FROM Sales.Orders AS O1
WHERE O1.orderdate = (SELECT MAX(O2.orderdate)
					FROM Sales.Orders AS O2
					WHERE O1.empid = O2.empid);

--more elegant solution
SELECT empid, MAX(orderdate) AS maxorderdate
FROM Sales.Orders
GROUP BY empid;


--1-2.
-- I want to display empid, maxorderdate, orderid and custid
-- I query all rows from derived table T1, returning columns empid, and maxorderdate.
-- I join T1 with Sales.Orders using empid and maxorderdate as the intersection
-- I sort the empid in descending order by empid.
SELECT  T1.empid, T1.maxorderdate, orderid, custid
FROM 

(SELECT DISTINCT O1.empid, O1.orderdate AS maxorderdate
		FROM Sales.Orders AS O1
		WHERE O1.orderdate = (SELECT MAX(O2.orderdate)
		FROM Sales.Orders AS O2
		WHERE O1.empid = O2.empid)
) AS T1

INNER JOIN Sales.Orders AS SO
ON (T1.empid = SO.empid) AND (T1.maxorderdate = SO.orderdate)
ORDER BY empid DESC;

--2-1.
-- I want to display cols orderid, orderdate, custid, empid, and a row number generated by orderidand orderdate sorted by asc.
-- query rows from Sales.Orders table.
SELECT orderid, orderdate, custid, empid, 
(ROW_NUMBER() OVER(ORDER BY orderid ASC, orderdate ASC)) AS row_num
FROM Sales.Orders;

--2-2.
-- I want display orderid, orderdate, custid, empid, and row number
-- So I query all rows from virtual table O1
-- O1 contains cols: orderid, orderdate, custid, empid, and row_num. from sales.orders table
-- filter for row numbers of virtual table between 11 and 20
SELECT O1.orderid, O1.orderdate, O1.custid, O1.empid, O1.row_num
FROM 
(
SELECT orderid, orderdate, custid, empid, 
(ROW_NUMBER() OVER(ORDER BY orderid ASC, orderdate ASC)) AS row_num
FROM Sales.Orders
) AS O1
WHERE (O1.row_num >=11) AND (O1.row_num < = 20);


--Solution: alternative use a CTE 
WITH OrdersRN AS 
(
SELECT orderid, orderdate, custid, empid,
ROW_NuMBER() OVER(ORDER BY orderdate, orderid) AS rownum
FROM Sales.Orders
)
SELECT * FROM OrdersRN WHERE rownum BETWEEN 11 AND 20;


--3.
SELECT * FROM HR.Employees;

-- create an cte 
-- create a base case:
-- i want to display empid, mgrid, firstname, and lastname from HR.Employees table 
-- filter for empid = 9
-- combine all iterations
-- i want to display empid, mgrid, firstname, and lastname from the current table
-- intersect current table instance with HR.Employees table using mgrid of current table and empid of HR.Employees table
-- return all rows from EmpsCTE generated table.
WITH EmpsCTE AS
(
	SELECT empid, mgrid,firstname,lastname
	FROM HR.Employees
	WHERE empid = 9

	UNION ALL

	SELECT C.empid, C.mgrid, C.firstname, C.lastname
	FROM EmpsCTE AS P
	JOIN HR.Employees AS C
	on C.empid = P.mgrid
)
SELECT empid,mgrid, firstname,lastname
FROM EmpsCTE;


--4-1
SELECT TOP(5) * FROM Sales.Orders;
SELECT TOP(5) * FROM Sales.OrderDetails;

--if view already exist delete the view
IF OBJECT_ID('Sales.VEmpOrders') IS NOT NULL
DROP VIEW Sales.VEmpOrders;

-- create a view called Sales.OrderSums
-- return cols empid, year, and total qty

-- query cols: empid and orderdate from Sales.Orders, and qty from Sales.OrderDetails
-- intersect tables on orderid from both tables

--cluster table by empid and order year 

GO 
CREATE VIEW Sales.VEmpOrders
AS

SELECT empid, YEAR(orderdate) AS orderyear, SUM(qty) AS qty
FROM Sales.Orders AS SO
INNER JOIN Sales.OrderDetails AS SOD
ON SOD.orderid = SO.orderid 

GROUP BY empid, YEAR(orderdate)

GO

-- after creating view return output empid and orderyear asc
SELECT * FROM Sales.VEmpOrders
ORDER BY empid ASC, orderyear ASC;



--4.2

-- dispaly columns empid, orderyear, qty from Sales.VEmpOrders table
-- for each orderyear and empid, calculate a Sum qty, 
-- calculated when inner queries orderyear <= outer queries current order year and if inner queries empid = outer queries empid 
-- query all rows from Sales.Vemporder table
--sort by empid and orderyear in ascending order.
SELECT  Cur.empid, Cur.orderyear, Cur.qty, 

(SELECT SUM(O2.qty)
FROM Sales.VEmpOrders AS O2
WHERE (O2.orderyear <= Cur.orderyear) AND (O2.empid = Cur.empid)
) AS runqty

FROM Sales.VEmpOrders AS Cur
ORDER BY empid ASC, orderyear ASC;


--186, p.214,442 

--drop inline tvf if already exists
USE TSQL2012;
IF OBJECT_ID('dbo.GetCustOrders') IS NOT NULL
DROP FUNCTION dbo.GetCustOrders;

--test inline tvf
GO 
CREATE FUNCTION dbo.GetCustOrders
(@cid AS INT) RETURNS TABLE
AS 
RETURN
SELECT orderid,custid, orderdate, requireddate,
shippeddate, shipperid, freight, shipname, shipaddress, shipcity,
shipregion, shippostalcode, shipcountry
FROM Sales.Orders
WHERE custid = @cid;
GO
-- query inline tvf, if custid = 1
SELECT orderid, custid
FROM dbo.GetCustOrders(1) AS O;

--5-1
SELECT * FROM Production.Products;

-- drop dbo.TopProducts if inline table already exists
USE TSQL2012;
IF OBJECT_ID('dbo.TopProducts') IS NOT NULL
DROP FUNCTION dbo.TopProducts;


-- create inline tvf, dbo.TropProducts
-- with parameters supplierid and num orders n
--the table contains the top num orders, all columns from Production.Products
--filter for supplierid = supid
--order by largest unit price
GO 
CREATE FUNCTION dbo.TopProducts
(@supid AS INT, @n AS INT) RETURNS TABLE

AS 
RETURN 
SELECT TOP(@n) productid, productname, supplierid, categoryid, unitprice, discontinued
FROM Production.Products
WHERE supplierid = @supid 
ORDER BY unitprice DESC;
GO

--grab all rows where supid =5 and get top 2 products with highest unit price.
SELECT * FROM dbo.TopProducts(5,2);



--5-2
USE TSQL2012;

-- I want to display columns supplierid, companyname from Production.Products table
-- I want to display columns productid, productname, unitprice from virtual table az
-- for each row in Production.Suppliers table, I apply the supplierid into virtual table az.
-- The virtual table az is a table function that returns top 2 most expensive products for given supplierid.
SELECT PP.supplierid, PP.companyname, az.productid, az.productname, az.unitprice
FROM Production.Suppliers AS PP
CROSS APPLY
	(SELECT productid, productname, supplierid, categoryid, unitprice, discontinued
	FROM dbo.TopProducts(PP.supplierid,2)) AS az;
