--Assignment Day4 –SQL:  Comprehensive practice

--Answer following questions
--1.	What is View? What are the benefits of using views?
--Solution: View is a virtual table that contains data from one or multiple tables. 
--Views occupy no space except for indexed views. Views can prevent undesired access by providing security as the data that is not of interest to a user can be left out of the view. 
--2.	Can data be modified through views?
--A view can be used in a query that updates data, subject to a few restrictions.
--The actual modification always takes place at the table level. Views cannot be used as a mechanism to override any constraints, rules, or referential integrity defined in the base tables.
--3.	What is stored procedure and what are the benefits of using it?
--A stored procedure is a set of Structured Query Language (SQL) statements with an assigned name.
--Using stored procedure means you can create once, store and call for several times whenever it is required. This supports faster execution. It also reduces network traffic and provides better security to the data.
--4.	What is the difference between view and stored procedure?
--A Stored Procedure:
--(1)Accepts parameters
--(2)Can NOT be used as building block in a larger query
--(3)Can contain several statements, loops, IF ELSE, etc.
--(4)Can perform modifications to one or several tables
--(5)Can NOT be used as the target of an INSERT, UPDATE or DELETE statement.
--A View:
--(1)Does NOT accept parameters
--(2)Can be used as building block in a larger query
--(3)Can contain only one single SELECT query
--(4)Can NOT perform modifications to any table
--(5)But can (sometimes) be used as the target of an INSERT, UPDATE or DELETE statement.
--5.	What is the difference between stored procedure and functions?
--A function has a return type and returns a value.You cannot use a function with Data Manipulation queries. Only Select queries are allowed in functions.A function does not allow output parameters.
--A procedure does not have a return type. But it returns values using the OUT parameters.You can use DML queries such as insert, update, select etc… with procedures.A procedure allows both input and output parameters.
--6.	Can stored procedure return multiple result sets?
--Yes, a stored procedure with more than one select statements can.
--7.	Can stored procedure be executed as part of SELECT Statement? Why?
--No, because stored procedures do not have to return a value. Hence, they cannot be called from inside an SQL statement. 
--8.	What is Trigger? What types of Triggers are there?
--A SQL Server trigger is a piece of procedural code, like a stored procedure which is only executed when a given event happens.
--There are two classes of triggers in SQL Server:Data Definition Language triggers and Data Modification Language triggers. And DML triggers have different types like: FOR or AFTER [INSERT, UPDATE, DELETE], INSTEAD OF [INSERT, UPDATE, DELETE].
--9.	What are the scenarios to use Triggers?
--By using a trigger, you can keep track of the changes on a given table by writing a log record with information about who made the change and what was changed in the table.
--And when you want to enforce business rules, you can use triggers to guaranteed the data consistency.
--10.	What is the difference between Trigger and Stored Procedure?
--Unlike stored procedure, the trigger is only executed when a given event happens.

--Write queries for following scenarios
--Use Northwind database. All questions are based on assumptions described by the Database Diagram sent to you yesterday. When inserting, make up info if necessary. Write query for each step. Do not use IDE. BE CAREFUL WHEN DELETING DATA OR DROPPING TABLE.
USE Northwind
GO
--1.	Lock tables Region, Territories, EmployeeTerritories and Employees. Insert following information into the database. In case of an error, no changes should be made to DB.
--a.	A new region called “Middle Earth”;
--b.	A new territory called “Gondor”, belongs to region “Middle Earth”;
--c.	A new employee “Aragorn King” who's territory is “Gondor”.
BEGIN TRAN
INSERT INTO Region
VALUES (5, 'Middle Earth')
INSERT INTO Territories
VALUES (99000, 'Gondor', 5)
INSERT INTO Employees (LastName, FirstName)
VALUES ('King', 'Aragorn')
INSERT INTO EmployeeTerritories (EmployeeID, TerritoryID)
VALUES (10, 99000)

--2.	Change territory “Gondor” to “Arnor”.
UPDATE Territories SET TerritoryDescription = 'Arnor'
WHERE TerritoryID = 99000

--3.	Delete Region “Middle Earth”. (tip: remove referenced data first) (Caution: do not forget WHERE or you will delete everything.) 
--In case of an error, no changes should be made to DB. Unlock the tables mentioned in question 1.
DELETE FROM Region
WHERE RegionID = 5
ROLLBACK TRAN
GO

--4.	Create a view named “view_product_order_[your_last_name]”, list all products and total ordered quantity for that product.
CREATE VIEW view_product_order_gu 
AS
SELECT a.ProductID, a.ProductName, SUM(b.Quantity) AS Qty
FROM Products a JOIN [Order Details] b ON a.ProductID = b.ProductID
GROUP BY a.ProductID, a.ProductName
GO

--5.	Create a stored procedure “sp_product_order_quantity_[your_last_name]” that accept product id as an input and total quantities of order as output parameter.
CREATE PROCEDURE sp_product_order_quantity_gu (
    @product_id INT,
    @product_qty INT OUTPUT
) AS
BEGIN
    SELECT a.ProductID, SUM(b.Quantity) AS Qty
    FROM Products a JOIN [Order Details] b ON a.ProductID = b.ProductID
    WHERE a.ProductID = @product_id
    SELECT @product_qty = SUM(b.Quantity)
END
GO

--7.	Lock tables Region, Territories, EmployeeTerritories and Employees. Create a stored procedure “sp_move_employees_[your_last_name]” that automatically find all employees in territory “Tory”; if more than 0 found, insert a new territory “Stevens Point” of region “North” to the database, and then move those employees to “Stevens Point”.
CREATE PROCEDURE sp_move_employees_gu
AS
BEGIN 
	SELECT c.EmployeeID, c.FirstName, c.LastName, b.TerritoryID, a.TerritoryDescription
	FROM Territories a JOIN EmployeeTerritories b ON a.TerritoryID = b.TerritoryID JOIN Employees c ON b.EmployeeID = c.EmployeeID
	WHERE a.TerritoryDescription = 'Tory'
END
GO
BEGIN TRAN
	EXEC sp_move_employees_gu


--8.	Create a trigger that when there are more than 100 employees in territory “Stevens Point”, move them back to Troy. (After test your code,) remove the trigger. Move those employees back to “Troy”, if any. Unlock the tables.
CREATE TRIGGER move_department
ON Territories a, EmployeeTerritories b, c.EmployeeID
WHERE a.TerritoryID = b.TerritoryID AND b.EmployeeID = c.EmployeeID
FOR INSERT
AS 
BEGIN
	DECLARE @Qty_Steven = SELCET COUNT(*) 
	FROM Territories a JOIN EmployeeTerritories b ON a.TerritoryID = b.TerritoryID JOIN Employees c ON b.EmployeeID = c.EmployeeID
	WHERE a.TerritoryDescription = 'Stevens Point'
	IF @Qty_Steven>100
		UPDATE b.TerritoryID = 48084 WHERE b.TerritoryID = 55555 --SUPPOSE TerritoryID for 'Stevens Point' is 55555
END
ROLLBACK TRAN
GO

--9.	Create 2 new tables “people_your_last_name” “city_your_last_name”. City table has two records: {Id:1, City: Seattle}, {Id:2, City: Green Bay}. People has three records: {id:1, Name: Aaron Rodgers, City: 2}, {id:2, Name: Russell Wilson, City:1}, {Id: 3, Name: Jody Nelson, City:2}. Remove city of Seattle. 
--If there was anyone from Seattle, put them into a new city “Madison”. Create a view “Packers_your_name” lists all people from Green Bay. If any error occurred, no changes should be made to DB. (after test) Drop both tables and view.
CREATE TABLE people_your_last_gu(
	Id INT,
	Name varchar(255), 
	City INT
)
CREATE TABLE city_your_last_gu(
	Id INT, 
	City varchar(255)
)
GO

INSERT INTO city_your_last_gu
VALUES 
	(1, 'Seattle'),
	(2, 'Green Bay');
INSERT INTO people_your_last_gu
VALUES 
	(1, 'Aaron Rodgers', 2),
	(2, 'Russell Wilson', 1),
	(3, 'Jody Nelson', 2);
DELETE FROM city_your_last_gu 
WHERE Id = 1
INSERT INTO city_your_last_gu 
VALUES (1, 'Madison')
GO

CREATE VIEW Packers_your_hang_gu AS
SELECT b.Id, b.Name, a.City 
FROM city_your_last_gu a JOIN people_your_last_gu b ON a.Id = b.City
WHERE a.City = 'Green Bay'
GO

DROP VIEW Packers_your_hang_gu

DROP TABLE people_your_last_gu

DROP TABLE city_your_last_gu
GO
--10.	 Create a stored procedure “sp_birthday_employees_[you_last_name]” that creates a new table “birthday_employees_your_last_name” and fill it with all employees that have a birthday on Feb. 
--(Make a screen shot) drop the table. Employee table should not be affected.
CREATE PROCEDURE sp_birthday_employees_gu
AS
	CREATE TABLE birthday_employees_your_gu(
		EmpId INT,
		LastName varchar(255),
		FirstName varchar(255),
		BirthMonth INT
	)
	SELECT a.EmployeeID, a.LastName, a.FirstName, datepart(mm, a.BirthDate) AS BirthMonth INTO birthday_employees_your_gu
	FROM Employees a
	WHERE datepart(mm, a.BirthDate) = 2

EXEC sp_birthday_employees_gu
DROP TABLE birthday_employees_your_gu
GO

--12.	How do you make sure two tables have the same data?
--SELECT * FROM TABLE1
--EXCEPT 
--SELECT * FROM TABLE2

--SELECT * FROM TABLE2
--EXCEPT 
--SELECT * FROM TABLE1

--IF THEY ALL RETURN NO RESULTS, THEN THE TWO TABLES ARE THE SAME
