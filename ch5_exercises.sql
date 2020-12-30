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

-- query from virtual table temp with cols: empid and orderdate from Sales.Orders, and qty from Sales.OrderDetails
-- intersect tables on orderid from both tables

--cluster table by empid and order year 

GO 
CREATE VIEW Sales.VEmpOrders
AS

SELECT temp.empid, YEAR(temp.orderdate) AS orderyear, SUM(temp.qty) AS qty
FROM 

(
SELECT SO.empid, SO.orderdate, SOD.qty
FROM Sales.Orders AS SO
INNER JOIN Sales.OrderDetails AS SOD
ON SOD.orderid = SO.orderid 
) AS temp

GROUP BY empid, YEAR(temp.orderdate)

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