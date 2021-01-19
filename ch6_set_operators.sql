USE TSQL2012;


-- return all rows from HR.Employees (9 rows) 
-- return all rows from Sales.Customers (91 rows)
-- return a total of 100 rows. (contains duplicates)
SELECT country, region, city FROM HR.Employees

UNION ALL


-- return all rows from HR.Employees (9 rows) 
-- return all rows from Sales.Customers (91 rows)
-- return a total of 71 rows. (remove duplicates in combined set)
SELECT country, region, city FROM Sales.Customers;

SELECT country, region, city FROM HR.Employees
UNION
SELECT country, region, city FROM Sales.Customers;

--195, 223/442

USE TSQL2012;
--return distinct row from HR.Employees
--return distinct row from Sales.customers
--return the rows that are in both sets.
SELECT country, region,city FROM HR.Employees

INTERSECT

SELECT country,region,city FROM Sales.Customers;


--return locations that are in Hr.Employees but not in Sales.Customers table
SELECT country, region, city FROM HR.Employees
EXCEPT
SELECT country,region,city FROM Sales.Customers;

--return locations that are in Sales.Customers table but not in Hr.Employees
SELECT country,region,city FROM Sales.Customers
EXCEPT
SELECT country, region, city FROM HR.Employees;


--Intersect has higher precedence than except

-- return locations of suppliers that  are not in HR.employees and Sales.Customers.
SELECT country, region, city FROM Production.Suppliers
EXCEPT
SELECT country, region, city FROM HR.Employees
INTERSECT 
SELECT country, region ,city FROM Sales.Customers;


-- use parenthesis to specify precedence. (parenthesis highest precedence)

--return locations found in Production.Suppliers, but not in employess
--and locations are found in Sales.Customers table.
(SELECT country, region,city FROM Production.Suppliers
EXCEPT 
SELECT country, region, city FROM HR.Employees)
INTERSECT
SELECT country, region, city FROM Sales.Customers;


--I want to display country, and count 
-- query from rows from virtual table, U, which contains all unique rows from HR.Employees
-- and all unique rows from Sales.Customers table
-- cluster the table by country, and location count.
SELECT country, COUNT(*) AS numlocations
FROM (SELECT country, region, city FROM HR.Employees
		UNION
		SELECT country, region, city FROM Sales.Customers) AS U
GROUP BY country;


-- display empid, orderid, and orderdate
-- query from virtual table the oldest orderdate and orderid for empid =3
-- combine current set with next set including duplicates
-- display empid, orderid, and orderdate
-- query from virtual table the oldest orderdate and orderid for empid =5
SELECT empid, orderid, orderdate
FROM (SELECT TOP (2) empid, orderid, orderdate
		FROM Sales.Orders
		WHERE empid =3
		ORDER BY  orderdate DESC, orderid DESC) AS D1

UNION ALL

SELECT empid, orderid, orderdate
FROM (SELECT TOP(2) empid, orderid, orderdate
	 FROM Sales.Orders
	 WHERE empid = 5
	 ORDER BY orderdate DESC, orderid DESC) AS D2;

