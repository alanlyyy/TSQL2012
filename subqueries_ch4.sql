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