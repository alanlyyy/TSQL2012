--Alter employee tables by adding a primary key
-- ALTER TABLE dbo.Employees
--	ADD CONSTRAINT PK_Employees
-- PRIMARY KEY(empid);

--alter employee table by adding a unique key
--ALTER TABLE dbo.Employees
--	ADD CONSTRAINT UNQ_Employees_ssn
--	UNIQUE(ssn);

--Create a table called Orders with a primary key defined on the orderid column
USE TSQL2012;

IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL
	DROP TABLE dbo.Orders;

CREATE TABLE dbo.Orders
(
	orderid INT NOT NULL,
	empid INT NOT NULL,
	custid VARCHAR(10) NOT NULL,
	orderts DATETIME2 NOT NULL,
	qty INT NOT NULL,
	CONSTRAINT PK_Orders
	PRIMARY KEY(orderid)
);

--restrict values supported by the empid column in the orders table to the value that exists in the empid column in the employee table.
ALTER TABLE dbo.Orders
	ADD CONSTRAINT FK_ORDERS_EMPLOYEES
	FOREIGN KEY(empid)
	REFERENCES dbo.Employees(empid);

--restrict values supported by mgrid column in the employees table to the values that exist in the empid column of the same table.
ALTER TABLE dbo.Employees
	ADD CONSTRAINT FK_EMPLOYEES_EMPLOYEES
	FOREIGN KEY(mgrid)
	REFERENCES dbo.Employees(empid);

--add a constraint to employee salary > 0
ALTER TABLE dbo.Employees
	ADD CONSTRAINT CHK_Employees_salary
	CHECK(salary > 0.00);

--default value to enter into the database if there is missing data for timestamp
ALTER TABLE dbo.Orders
	ADD CONSTRAINT DFT_Orders_orderts
	DEFAULT(SYSDATETIME()) FOR orderts;

--drop dbo.orders and dbo.employees table
DROP TABLE dbo.Orders, dbo.Employees;