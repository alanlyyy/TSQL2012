USE TSQL2012;

-- I want display all columns
-- So I query all rows from "virtual table"
-- the "virtual table" contains custid and companyname from Sales.Customers filtering for USA customers
SELECT*
FROM (SELECT custid, companyname
		FROM Sales.Customers 
		WHERE country = N'USA') AS USA_Custs;


-- error query since group by runs before select, orderyear variable is not seen
SELECT 
	YEAR(orderdate) AS orderyear,
	COUNT (DISTINCT custid) AS numcusts
FROM Sales.Orders
GROUP BY orderyear;

-- solution 1
SELECT 
	YEAR(orderdate) AS orderyear,
	COUNT (DISTINCT custid) AS numcusts
FROM Sales.Orders
GROUP BY YEAR(orderdate);

--solution 2 using table expressions

--table expressions used in the FROM clause allows us to use the declared variables
--in the SELECT and GROUP BY clause, "orderyear".

-- I want to display orderyear, unique custid
-- So I query all rows from "virtual table"
-- returning columns orderyear, and custid from Sales.Orders table
-- I count total custid for each orderyear.
SELECT orderyear, COUNT(DISTINCT custid) AS numcusts

FROM (SELECT YEAR(orderdate) AS orderyear, custid		
		FROM Sales.Orders) AS D

GROUP BY orderyear;

USE TSQL2012;
--create a local variable called empid
DECLARE @empid AS INT =3;

-- i want to display orderyear and count of unique custid
--I query rows from virtual table
--where virtual table returns orderyear, custid queried from Sales.Orders table filtering for empid = local variable empid =3.
-- I aggregate table by orderyear, where each orderyear has a total count.
SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
FROM (SELECT YEAR(orderdate) AS orderyear, custid
		FROM Sales.Orders
		WHERE empid = @empid) AS D
GROUP BY orderyear;

-- i want to display orderyear, numcusts variables derived from inner table
-- so i query from virtual table 1
-- the virtual table 1 returns orderyear,count of unique ids from virtual table 2
-- virtual table 2 returns year of the orderdate, and custid from Sales.Orders table
-- we aggregate results from virtual table 1 by orderyear
-- we filter the rows returned by virtual table 1, if the count of unique custid for orderyear > 70
SELECT orderyear, numcusts
FROM (SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
		FROM (SELECT  YEAR(orderdate) AS orderyear, custid
				FROM Sales.Orders) AS D1
		GROUP BY orderyear) AS D2
WHERE numcusts > 70;


-- same query as above but more simpler without nested query table expressions.
SELECT YEAR(orderdate) AS orderyear, COUNT (DISTINCT custid) AS numcusts
FROM Sales.Orders
GROUP BY YEAR(orderdate)
HAVING COUNT(DISTINCT custid) > 70;

USE TSQL2012;
--I want to display orderyear, numcusts from Cur virtual table
--I want to display numcusts from Prv virtual table
--I want to display growth which is a function of Cur - Prv table
--I query rows from virtual table Cur, for columns orderyear ,numcusts
--which queries from Sales.Orders table,and aggregates orderyear displaying count of unique custid for each order year.
--I preserve Cur table and combine with Prv table:
--Prv table returns orderyear, numcusts queried from Sales.Orders table, and we aggregate orderyear, displaying orderyear and total unique counts of custid
--We join Cur and Prv table for current orderyear.
SELECT Cur.orderyear,
	Cur.numcusts AS curnumcust, Prv.numcusts AS prvnumcusts,
	Cur.numcusts - Prv.numcusts AS growth
FROM (SELECT YEAR(orderdate) AS orderyear,
		COUNT (DISTINCT custid)  AS numcusts
		FROM Sales.Orders
		GROUP BY YEAR(orderdate) ) AS Cur

LEFT OUTER JOIN
	(SELECT YEAR(orderdate) AS orderyear,
		COUNT(DISTINCT custid)AS numcusts
		FROM Sales.Orders
		GROUP BY YEAR(orderdate)) AS Prv
ON Cur.orderyear = Prv.orderyear+1;


--Cmmon table expressions

--Create a virtual table called USACusts
--where we return columns custid, companyname
--querying rows from Sales.Customers table
-- filtering for countries in the USA
WITH USACusts AS
(
SELECT custid, companyname
FROM Sales.Customers
WHERE country= N'USA'
)
SELECT * FROM USACusts;


--inline version
--create a virtual table c
--for virtual table: return columns year of orderdate and custid from Sales.Orders table
--Display orderyear, count of unique custid
--query rows from virtual table C.
--Aggregate count of unique custid by orderyear.
WITH C AS 
(
SELECT YEAR(orderdate) AS orderyear, custid
FROM Sales.Orders
)
SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
FROM C 
GROUP BY orderyear; 


--external version
WITH C(orderyear, custid) AS
(
SELECT YEAR(orderdate), custid
FROM Sales.Orders
)
SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
FROM C
GROUP BY orderyear;

--p.165, 193/442

USE TSQL2012;

-- create a variable empid with value of int ,3
--C is a virtual table, that contains the columns orderyear, and custid 
--rows from Sales.Orders table, filter for rows with empid = 3
--I want to display orderyear, Count of unique custid,
--query from virtual table C
--display results by orderyear and total counts of unique custid for each year.
DECLARE @empid AS INT = 3;

WITH C AS
(
SELECT YEAR(orderdate) AS orderyear, custid
FROM Sales.Orders
WHERE empid = @empid
)
SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
FROM C 
GROUP BY orderyear;


-- declaring multiple CTE tables for query.

-- C1 is a virtual table with columns orderyear and custid
--extract rows from Sales.Orders table
-- C2 is a virtual table with columns orderyear and numcusts(count of unique customers)
-- querying rows from virtual table C1, displaying orderyear and ----- total counts of customers/orderyear
-- I want to display orderyear, and num custs
-- query rows from virtual table C2
-- filter for rows where count of unique custs > 70.
WITH C1 AS 
(
	SELECT YEAR(orderdate) AS orderyear, custid
	FROM Sales.Orders
),
C2 AS
(
	SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
	FROM C1 
	GROUP BY orderyear
)
SELECT orderyear, numcusts
FROM C2
WHERE numcusts > 70;


-- Using multiple instances of CTE tables.

--create a virtual table called yearly count, with the columns: orderyear, numcusts
--rows queried from Sales.Orders table
--Aggregate to display orderyear and total count of unique customer id/orderyear.
--I want to display orderyear, current number of customers, prev year number of customers
--and the growth of num customers in 1 year.
-- So I query all rows from virtual table YearlyCount
-- preserving yearlycount instance Cur and joining Yearly count instance Prv
-- on current years orderyear and previous years order year.
WITH YearlyCount AS 
(
SELECT YEAR(orderdate) AS orderyear,
COUNT(DISTINCT custid) AS numcusts
FROM Sales.Orders
GROUP BY YEAR(orderdate)
)
SELECT Cur.orderyear, 
		Cur.numcusts AS curnumcusts,
		Prv.numcusts AS prvnumcusts,
		Cur.numcusts - Prv.numcusts AS growth
FROM YearlyCount AS Cur
LEFT OUTER JOIN  YearlyCount AS Prv
ON  Cur.orderyear = Prv.orderyear+1;

--p.167 195/442


-- recursive CTE

--Union All combines the result set of 2 or more SELECT statements and allows duplicate values.
USE TSQL2012;

--Create virutal table EmpsCTE

-- generate anchor member:
-- --------------------------------------------
-- return columns empid, mgrid, firstname, and last name 
-- query from HR.Employees table
-- filter for rows where empid = 2

-- using the anchor member from the previous set:
-- --------------------------------------------
-- Take the current set of data and combine with next set.
-- return columns empid, mgrid, firstname, and lastname from virtual table EmpsCTE
-- joining Employees table with EmptsCTE table using key mgrid = empid
-- EmpsCTE resultant grows for each invocation of join statement. When the resultant select statement returns empty set, recursion is finished.
-- return columns empid, mgrid, firstname, lastname from EmpsCTE resulting set.
WITH EmpsCTE AS
(
SELECT empid, mgrid, firstname, lastname
FROM HR.Employees 
WHERE empid =2

UNION ALL

SELECT C.empid, C.mgrid, C.firstname, C.lastname
FROM EmpsCTE AS P
JOIN HR.Employees AS C
ON C.mgrid = P.empid
)
SELECT empid, mgrid, firstname,lastname
FROM EmpsCTE;

--169, (197,442)