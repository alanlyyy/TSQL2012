USE TSQL2012;

-- get employeeid, orderyear, count of orders from Sales.Orders table
--where custid = 71
-- group employeeid and order year together
--
SELECT empid, YEAR(orderdate) AS orderyear, COUNT(*) AS numorders
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR(orderdate)
HAVING COUNT(*) > 1
ORDER BY empid, orderyear;

--practice
--Query all results from Sales.Orders table with a weight less than 10 lbs
SELECT orderid,shipname, freight AS weightt 
FROM Sales.Orders
WHERE freight < 10;

--query all results from Sales.Orders table.
SELECT * FROM Sales.Orders;

--query all rows in Sales.Orders table but display orderid, custid, empid, orderdate, and freight
SELECT orderid, custid, empid, orderdate, freight
FROM Sales.Orders;


--query all rows from Sales.Orders table and filter results with custid = 71
--display orderid, empid, orderdate, and freight 
SELECT orderid, empid, orderdate, freight FROM Sales.Orders
WHERE custid = 71;

--I want to return empid and orderyear
--so I query all rows from Sales.Orders table
-- I filter the rows where custid = 71
-- I then group empid and orderyear to make unique groups of empid and orderyear pairs
SELECT empid, YEAR(orderdate) as orderyear
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR(orderdate);


--GROUP BY 
--Can only use aggregate functions COUNT,SUM,AVG,MIN, and MAX if GROUP BY statement is used to create distinct rows.

--I want to display empid, year, total freight, and total number of orders
--So I query all results from Sales.Orders table
--I want to filter custid = 71 from the rows
--and then GROUP BY empid and year to create unique empid and year groupings
SELECT
	empid,
	YEAR(orderdate),
	SUM(freight) AS totalfreight,
	COUNT(*) AS numorders
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR(orderdate);

-- From the tsql database
-- I want to display empid , year and count of distinct customers
-- So I query all rows from the Sales.Orders table
-- Then I want to display unique groups of empid, year, and the count of unique custid
USE TSQL2012;
SELECT 
	empid,
	YEAR(orderdate) AS orderyear,
	COUNT(DISTINCT custid) AS numcusts
FROM Sales.Orders
GROUP BY empid, YEAR(orderdate);



--I want to display empid, orderyear
--So I query all rows from Sales.Orders table
--I want to filter results where custid = 71
--Then I create distinct pairs of empid, and order year
--I return the results with a count  > 1
SELECT
	empid,
	YEAR(orderdate) AS orderyear
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR(orderdate)
HAVING COUNT( *) > 1;

-- I want to display orderid and orderyear
-- So I query all rows from Sales.Orders table
SELECT orderid orderyear
FROM Sales.Orders;
--Query only returns one row with orderid renamed as orderyear because of missing comma between orderid and orderyear 


-- I want to display empid , orderyear, and numorders
-- So I query all rows from Sales.Orders table
-- I filter rows with custid = 71
-- I create unique/distinct groups of empid and orderyear
-- I filter the set unique pairs of empid and orderyear having numorders > 1
SELECT empid, YEAR(orderdate) AS orderyear, COUNT(*) AS numorders
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR(orderdate)
HAVING COUNT(*) > 1;


--example showing the select statement returns duplicate rows

--I want to display empid and orderyear
--So I query all rows from Sales.Orders table
--Lastly , I Filter the rows where custid = 71
SELECT 
	empid,
	YEAR(orderdate) AS orderyear
FROM Sales.Orders
WHERE custid = 71;


-- example query using distinct to remove duplicate rows

--I want to display unique rows for empid and orderyear
--so I query all results from the Sales.Orders table
--I filter the rows where custid = 71
SELECT DISTINCT
	empid,
	YEAR(orderdate) AS orderyear
FROM Sales.Orders
WHERE custid = 71;

--return/display all rows from Sales.Shippers table
SELECT * 
FROM Sales.Shippers;




-- Only use Alias in select statements for display as column header
-- SELECT is the last statement to be ran.
USE TSQL2012
--Query will fail because you can't refer to the column alisas that was created in the same select clause
SELECT 
	orderid,
	YEAR(orderdate) AS orderyear,
	orderyear + 1 AS nextyear
FROM Sales.Orders;

--Query works because we are not using an alias 
SELECT 
	orderid,
	YEAR(orderdate) AS orderyear,
	YEAR(orderdate) AS nextyear
FROM Sales.Orders;


--Using the TSQL2012 table
-- I want to display empid, orderyear, and numoders
-- I query all results from Sales.Orders
-- From all the results, I filter the rows with custid = 71
-- I used the filtered rows to create unique pairs of empid and orderyear
-- I filter the unique pairs if numorders > 1
-- I display results sorted by empid and orderyear


USE TSQL2012;

SELECT 
	empid,
	YEAR(orderdate) AS orderyear,
	COUNT(*) AS numorders
FROM Sales.Orders
Where custid = 71
GROUP BY empid, YEAR(orderdate)
HAVING COUNT(*) > 1
ORDER BY empid, orderyear;

--ORDER BY is the only phrase in which you can refer to column aliases created in the SELECT phase.
--ORDER BY is processed after the SELECT phrase.

--I want to display empid , firstname, lastname, country
--So I return all rows from HR.Employees table
--Lastly, I'll sort the data by hiredate descending
SELECT 
	empid, 
	firstname, 
	lastname, 
	country
FROM HR.Employees
ORDER BY hiredate DESC;

--EX BAD QUERY
--if distinct is used, you are restricted in using ORDER BY to elements that appear from the SELECT list.
SELECT DISTINCT country
FROM HR.Employees;
ORDER BY empid;


-- I want to display the first 5 rows for orderid, orderdate, custid, empid
-- So I return all rows from Sales.Orders table
-- For the returned rows, I want to sort the results by orderdate in descending order.
SELECT TOP (5) orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC;

-- I want to display the first 1% of all rows containing orderid, orderdate, custid, and empid
-- So I query first 1% of all rows from the Sales.Orders table
-- I sort the first 1% of all rows by orderdate descending order.
SELECT TOP (1) PERCENT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC;

--ORDER BY sorting with a tie breaker

-- I want to display the top 5 rows with orderid, orderdate, custid, and empid
-- So I query results from Sales.Orders table
-- I sort the ouput in descending order by orderdate, and if multiple dates match I sort by empid.
SELECT TOP (5) orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC, orderid DESC;

-- I want to display top 5 rows, and rows with the same orderdate as the top 5 rows, containing orderid, orderdate, custid, and empid
-- So I query the Sales.Orders table
-- I sort the output by orderdate in descending order
USE TSQL2012;
SELECT TOP (5) WITH TIES orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC;

-- ORDER BY example using OFFSET - FETCH to skip OFFSET rows and return filtered FETCH rows

-- I want to display orderid, orderdate,custid, and empid
-- So I query from Sales.Orders table
-- I sort by orderdate, and secondary sort with orderid
-- I skip the first 50 rows and filter the next 25 rows ordered by orderdate and orderid
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate, orderid
OFFSET 50 ROWS FETCH NEXT 25 ROWS ONLY;


--Window function expression example using ROW_NUMBER

-- Display orderid, custid, val, and rownum
-- rownum is defined by spliting custid into groups and sorting by val, providing each row a unique id specific to the group
-- We query from Sales.OrderValues table
-- We display results sorted by custid and secondary sort by val.
SELECT orderid, custid, val,
	ROW_NUMBER() OVER(PARTITION BY custid
						ORDER BY val) AS rownum
FROM Sales.OrderValues
ORDER BY custid, val;


-- logical process order for clauses in SQL
-- FROM
-- WHERE
--GROUP BY
--HAVING
-- SELECT
--	Expressions
--	DISTINCT
-- ORDER BY
--	TOP/ OFFSET-FETCH

--Predicates and Operators examples

-- Normally used with WHERE, HAVING, CHECK constraints

--1) IN predicate

-- I want to display orderid, empid, and orderdate
-- So I query all results from Sales.Orders table
-- Then I filter the rows by orderid if orderid== 10248,10249, 10250
SELECT orderid, empid, orderdate
FROM Sales.Orders
WHERE orderid IN(10248,10249,10250)

-- 2) BETWEEN predicate

-- I want to display orderid, empid, and orderdate
-- SO i query all results from Sales.Orders table
-- Then I filter the rows for  10300 < orderid < 10310
SELECT orderid, empid, orderdate
FROM Sales.Orders
WHERE orderid BETWEEN 10300 AND 10310;

--3) LIKE predicate

-- I want to display empid, firstname, and lastname
-- So I query all results from HR.Employees table
-- Then I filter by lastnames that start with D.
SELECT empid, firstname, lastname
FROM HR.Employees
WHERE lastname LIKE N'D%';

-- I want to display orderid, empid, and orderdate
-- So I query all rows from Sales.Orders table
-- Then I filter the rows by orderdate which is greater than 20080101.
SELECT orderid, empid, orderdate
FROM Sales.Orders
WHERE orderdate >= '20080101';


-- I want to display orderid, empid and orderdate
-- So I query all results from Sales.Orders table
-- Then I filter by orderdate >= 20080101 and empid == 1,3,5
SELECT orderid, empid, orderdate
FROM Sales.Orders
WHERE orderdate >= '20080101'
	AND empid IN(1,3,5);

-- Acces the TSQL2012 database
-- I want to display orderid, productid, qty, unitprice, discount, and val
-- So I query all results from Sales.OrderDetails table
USE TSQL2012;
SELECT orderid, productid, qty, unitprice, discount,
	qty * unitprice * ( 1 - discount) AS val
FROM Sales.OrderDetails;

-- I want to display orderid, custid, empid, and orderdate
-- So I query all results from Sales.Orders table
-- Then I filter the rows for custid =1 and empid == 1,3,5 OR custid = 85 and empid = 2,4,6
SELECT orderid, custid, empid, orderdate
FROM Sales.Orders
WHERE
	(custid = 1 
		AND empid IN(1,3,5))
	OR

	(custid = 85
		AND empid IN (2,4,6));


-- Use CASE statement

--EX1 - Simple form CASE statement
-- I want to display productid, productname, categoryid, and categoryname
-- so I query all results from Production.Products table
-- For each row, take the categoryid column from 1-8 and create a categoryname for the row.
-- Display results.
SELECT productid, productname, categoryid,
	CASE categoryid
		WHEN 1 THEN 'Beverages'
		WHEN 2 THEN 'Condiments'
		WHEN 3 THEN 'Confections'
		WHEN 4 THEN 'Dairy Products'
		WHEN 5 THEN 'Grains/Cereals'
		WHEN 6 THEN 'Meat/Poultry'
		WHEN 7 THEN 'Produce'
		WHEN 8 THEN 'Seafood'
		ELSE 'Unknown Category'
	END AS categoryname
FROM Production.Products;

--EX2 - Searched CASE form
-- I want to display orderid, custid, val, and value category
-- valuecategory will be generated using the a CASE statement comparing scalars to val column
-- Then I query all results from Sales.OrderValues table
SELECT orderid, custid, val,
	CASE
		WHEN val < 1000.00						THEN 'Less than	1000'
		WHEN val BETWEEN 1000.00 AND 3000.00	THEN 'Between 1000 and 3000'
		WHEN val > 3000.00						THEN 'More than 3000'
		ELSE 'Unknown'
	END AS valuecategory 
FROM Sales.OrderValues;

--NULL Values

--Display custid, country, region, and city
--So query Sales.Customers table
--Filter for rows with 'WA' string under region
--- 3 results should pop up
SELECT custid, country, region, city
FROM Sales.Customers
WHERE region = N'WA';

-- Display custid, country, region, city
-- Query Sales.Customers table
-- Filter rows without "WA" string for the region column
-- 28 results are returned, 88 - 28 rows contain NULL values for regions.
SELECT custid, country, region, city
FROM Sales.Customers
WHERE region <> N'WA';


-- Display region and count of all rows
-- Query Sales.Customers table
-- Create unique pairs between region and num_rows
-- 60 NULL values found.
SELECT region, COUNT(*) AS num_rows
FROM Sales.Customers
GROUP BY region;


-- Use TSQL Database
-- Display custid, country, region, and city
-- Query all rows from Sales.Customers table
-- filter for rows where region = null
USE TSQL2012;
SELECT custid, country, region, city
FROM Sales.Customers
WHERE region IS NULL;

-- Display rows where region attribute is not WA

-- Display custid, country, region, and city
-- Query from Sales.Customers table
-- Filter and return rows where region !=NA or region is null
SELECT custid, country, region, city
FROM Sales.Customers
WHERE region <> N'WA'
	OR region IS NULL;

-- All expressions in the SELECT list are evaluated at the same point in time.
-- Therefore you cannot refer back to an alias in a query.
SELECT 
	orderid,
	YEAR(orderdate) AS orderyear,
	orderyear + 1 AS nextyear
FROM Sales.Orders;

-- Collations - gathering metadata of a variable type:

--display name and description
--query from system collations table
SELECT name, description
FROM sys.fn_helpcollations();

-- For an case insensitive system when filtering rows we can extract both cases of an object
-- Returns lastname = 'Davis' despite lower case filter
SELECT empid, firstname,lastname
FROM HR.Employees
WHERE lastname = N'davis';

-- Adding a COLLATE to add a constraint based on META DATA, "case sensitive", Returns lastname = None,
SELECT empid, firstname, lastname
FROM HR.Employees
WHERE lastname COLLATE Latin1_General_CS_AS = N'davis';


--String concatenation

--[+] operator to combine firstname and lastname to create fullname

-- Display empid and fullname
-- Query all results from HR.Employees table
USE TSQL2012;
SELECT empid, firstname + N' ' + lastname AS fullname
FROM HR.Employees;


-- concatenation with a NULL results to NULL

-- Display custid, country, region, city, and location
-- So query all results from Sales.Customers table
SELECT custid, country, region, city,
	(country + N',' + region + N',' + city) AS location
FROM Sales.Customers;

-- Display custid, country, region, city, and location
-- If row-region is NULL replace with ',' (treat as empty space_)
-- So query all results from Sales.Customers table
SELECT custid, country, region, city,
	(country + COALESCE(N',' + region, N'') + N',' + city) AS location
FROM Sales.Customers;

-- I want to display custid, country, region, city, and location
-- location is the concatenation of country and region and city, if region is NULL replaced with empty string.
-- query from sales.customers table
SELECT custid, country, region, city,
	CONCAT(country, N',' + region, N',' + city) AS location
FROM Sales.Customers;

-- Substring function - extracts a substring from a string 
-- Extract abc from abcde.
SELECT SUBSTRING('abcde', 1,3);
SELECT LEFT('abcde',3);

--Extract cde from 'abcde'
SELECT RIGHT('abcde', 3);

--returns 5 chars
SELECT LEN(N'abcde') ;

-- returns 10 bytes
SELECT DATALENGTH(N'abcde')

-- CHARINDEX returns the position of the first argument, substring within the second argument string.
--Display position of ' ' in the string
--returns output 6
SELECT CHARINDEX(' ','Itzik Ben-Gan');

-- PATINDEX returns position of the first occurence of a pattern within a string.
--returns output 5
SELECT PATINDEX('%[0-9]%', 'abcd123efgh');

--REPLACE, replaces all occurences of substring1 with substring2
--returns '1:a 2:b'
SELECT REPLACE('1-a 2-b', '-', ':');

--I want to display empid, lastname, and number of occurences of e
--numoccur_of_e replaces all e with null and creates a substring, get the new length, and substract from old length.
--Query all results from HR.Employees table.
SELECT empid, lastname,
	LEN(lastname) - LEN( REPLACE(lastname, 'e', '') ) AS numoccur_of_e
FROM HR.Employees;

-- REPLICATE function replicates a string a requested number of times
-- Returns 'abcabcabc'
SELECT REPLICATE('abc', 3);

-- I want to display supplierid, and strsupplierid
-- strsupplierid = '000000000' + 'supplierid' 
-- Query all results from Production.Suppliers table
SELECT supplierid,
	RIGHT(REPLICATE('0', 9) + CAST(supplierid AS VARCHAR(10)), 10) AS strsupplierid
FROM Production.Suppliers;

-- STUFF allows you to remove a substring from a string and insert a new substring instead.
-- returns xabcz
SELECT STUFF('xyz' , 2, 1, 'abc');

-- return upper case version of string
SELECT UPPER('Itzik Ben- GAN');

-- display lower case version of string.
SELECT LOWER('Itzik Ben- GAN');

--RTRIM and LTRIM returns input string with leading and trailing spaces removed

--display abc
--	remove leading spaces, then remove trailing spaces.
SELECT RTRIM(LTRIM('      abc  '));

--FORMAT allows  format of an input value as a character based on Microsoft .NET format string
--return 0000001759
SELECT FORMAT(1759, '000000000');

-- LIKE Predicate - checks whether a character string matches a specific pattern
-- % wildcard represents a string of any size, including an empty string

-- Display empid and lastname
-- So I query all rows from HR.Employees table
-- I filter rows with lastnames that start with a 'D'
SELECT empid, lastname
FROM HR.Employees
WHERE lastname LIKE N'D%';

-- The _ wildcard  represents a single character. Query returns employees where the second character in the last name is e.

-- I want to display empid and lastname
-- so I query all results from HR.Employees table
-- I filter the rows where in lastname the second character is 'e'
SELECT empid, lastname
FROM HR.Employees
WHERE lastname LIKE N'_e%';

-- [ ] represents a single character that must be one of the characters specified in  [ ]


--EX1 [ABC] leter must be A,B, or C.

-- I want to display empid and lastname
-- So I query all results from HR.Employees table
-- So I filter rows where lastname contains A, B, or C
SELECT empid, lastname
FROM HR.Employees
WHERE lastname LIKE N'[ABC]%';

--EX2 [A - E] represents character must be a letter within A through E

-- I want to display empid and lastname
-- So I query all results from HR.Employees table
-- So I filter rows where the first character of lastname is between A-E 
SELECT empid, lastname
FROM HR.Employees
WHERE lastname LIKE N'[A-E]%' ;

--EX3 [^A-E] represents character is not letters A - E
-- I want to display empid and lastname
-- So I query all results from HR.Employees table
-- So I filter rows where the first character of lastname is not between A-E 
SELECT empid, lastname
FROM HR.Employees
WHERE lastname LIKE N'[^A-E]%' ;


-- Example of how language of database settings can affect date formatting.

SET LANGUAGE British;
SELECT CAST('02/12/2007' AS DATETIME);

SET LANGUAGE us_english;
SELECT CAST('02/12/2007' AS DATETIME);