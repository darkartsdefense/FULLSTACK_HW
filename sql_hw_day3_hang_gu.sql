--Assignment Day3 –SQL:  Comprehensive practice

--Answer following questions
--1.	In SQL Server, assuming you can find the result by using both joins and subqueries, which one would you prefer to use and why?
--Solution: I would prefer to use joins because it has higher performance usually.
--2.	What is CTE and when to use it?
--Solution: CTE is the common table expressions. It is used to simplify various classes of SQL queries when we can't use a derived table.
--3.	What are Table Variables? What is their scope and where are they created in SQL Server?
--Solution: Table variable is a type of local variable that used to store data temporarily. Its scope is limited to user defined functions or stored procedures.It is created in the memory.
--4.	What is the difference between DELETE and TRUNCATE? Which one will have better performance and why?
--Solution: TRUNCATE always removes all the rows from a table, leaving the table empty and the table structure intact whereas DELETE may remove conditionally if the where clause is used. Truncate is faster compared to delete as it makes less use of the transaction log.
--5.	What is Identity column? How does DELETE and TRUNCATE affect it?
--Solution: Identity column of a table is a column whose value increases automatically. Truncate command resets the identity to its seed value and delete retains the identity.
--6.	What is difference between “delete from table_name” and “truncate table table_name”?
--Solution: Delete is DML, Truncate is DDL.

--Write queries for following scenarios
--All scenarios are based on Database NORTHWND.
USE Northwind
GO

--1.	List all cities that have both Employees and Customers.
SELECT DISTINCT a.City
FROM Employees a JOIN Customers b ON a.City = b.City

--2.	List all cities that have Customers but no Employee.
--a.	Use sub-query
SELECT DISTINCT City 
FROM Customers
WHERE City NOT IN
(SELECT City FROM Employees)
--b.	Do not use sub-query
SELECT DISTINCT a.City
FROM Customers a LEFT JOIN Employees b ON a.City = b.City
WHERE b.City IS NULL

--3.	List all products and their total order quantities throughout all orders.
SELECT a.ProductID, a.ProductName, SUM(b.Quantity) AS The_Quantity
FROM Products a JOIN [Order Details] b ON a.ProductID = b.ProductID
GROUP BY a.ProductID, a.ProductName

--4.	List all Customer Cities and total products ordered by that city.
SELECT c.City, SUM(a.Quantity) AS Total_Sum
FROM [Order Details] a JOIN Orders b ON a.OrderID = b.OrderID JOIN Customers c ON b.CustomerID = c.CustomerID
GROUP BY c.City

--5.	List all Customer Cities that have at least two customers.
--a.	Use union
--Sorry, I don't know how to do it using union.
--b.	Use sub-query and no union
SELECT T.City, T.Customer_Number FROM
(SELECT City, COUNT(CustomerID) AS Customer_Number
FROM Customers
GROUP BY City) T
WHERE T.Customer_Number > 2

--6.	List all Customer Cities that have ordered at least two different kinds of products.
SELECT City, Count(ProductID) AS Product_Number FROM
(SELECT DISTINCT a.ProductID, c.City
FROM [Order Details] a JOIN Orders b ON a.OrderID = b.OrderID JOIN Customers c ON b.CustomerID = c.CustomerID) dt
GROUP BY City
Having Count(ProductID) > 1

--7.	List all Customers who have ordered products, but have the ‘ship city’ on the order different from their own customer cities.
SELECT DISTINCT a.CustomerID, a.ContactName, a.City, b.ShipCity
FROM Customers a JOIN Orders b ON a.CustomerID = b.CustomerID
WHERE a.City != b.ShipCity


--8.	List 5 most popular products, their average price, and the customer city that ordered most quantity of it.
--Solution: I divided this question into three parts,first, list 5 most popular products
SELECT TOP 5 a.ProductID, a.ProductName
FROM Products a JOIN [Order Details] b ON a.ProductID = b.ProductID
GROUP BY a.ProductID, a.ProductName
ORDER BY SUM(b.Quantity) DESC

--Second, calculate the average price of each product in table order details
SELECT ProductID, SUM(EXP(LOG(UnitPrice)+LOG(Quantity)))/SUM(Quantity)
FROM [Order Details] 
GROUP BY ProductID;


--Third, find the customer city that ordered most quantity of a certain product (for example with id 60) in table order details
SELECT TOP 1 c.City AS Top_City, a.ProductID AS ProductID, SUM(a.Quantity) AS Quantity
FROM [Order Details] a JOIN Orders b ON a.OrderID = b.OrderID JOIN Customers c ON b.CustomerID = c.CustomerID
WHERE a.ProductID = 60
GROUP BY c.City, ProductID
ORDER BY Quantity DESC

--Then, we can list 5 most popular products with their average price by combining the first part of code and second part of code.
SELECT OD.ProductID, T.ProductName, SUM(EXP(LOG(UnitPrice)+LOG(Quantity)))/SUM(Quantity) AS AvgPrice
FROM [Order Details] OD
JOIN
(
SELECT TOP 5 a.ProductID AS ProductID, a.ProductName AS ProductName
FROM Products a JOIN [Order Details] b ON a.ProductID = b.ProductID
GROUP BY a.ProductID, a.ProductName
ORDER BY SUM(b.Quantity) DESC
) T
ON OD.ProductID = T.ProductID
GROUP BY OD.ProductID, T.ProductName
ORDER BY AvgPrice DESC

--But I have met some problems to combine the code of the third part. Don't know how to do it.

--9.	List all cities that have never ordered something but we have employees there.
--a.	Use sub-query
SELECT City
FROM Employees
WHERE City NOT IN
(Select b.City
FROM Orders a JOIN Customers b ON a.CustomerID = b.CustomerID)
--b.	Do not use sub-query
WITH CityWithOrder
AS
(
Select b.City
FROM Orders a JOIN Customers b ON a.CustomerID = b.CustomerID
)
SELECT a.City AS City_No_Order
FROM Employees a LEFT JOIN CityWithOrder b ON a.City = b.city 
WHERE b.City IS NULL

--10.	List one city, if exists, that is the city from where the employee sold most orders (not the product quantity) is, and also the city of most total quantity of products ordered from. (tip: join  sub-query)
SELECT a.City, a.Order_Number, b.Quantity_Number
FROM 
(SELECT TOP 1 c.City, COUNT(a.OrderID) AS Order_Number
FROM [Order Details] a JOIN Orders b ON a.OrderID = b.OrderID JOIN Customers c ON b.CustomerID = c.CustomerID
GROUP BY c.City
ORDER BY COUNT(a.OrderID) DESC) a
INNER JOIN
(SELECT TOP 1 c.City, SUM(a.Quantity) AS Quantity_Number
FROM [Order Details] a JOIN Orders b ON a.OrderID = b.OrderID JOIN Customers c ON b.CustomerID = c.CustomerID
GROUP BY c.City
ORDER BY SUM(a.Quantity) DESC) b
ON a.City = b.City

--11. How do you remove the duplicates record of a table?
--Solution: Select distinct * from tbl

--12. Sample table to be used for solutions below- Employee (empid integer, mgrid integer, deptid integer, salary money) Dept (deptid integer, deptname varchar(20))
--Find employees who do not manage anybody.
SELECT empid, mgrid, depid, salary
FROM Empolyee 
WHERE mgrid IS NULL

--13. Find departments that have maximum number of employees. (solution should consider scenario having more than 1 departments that have maximum number of employees). 
--Result should only have - deptname, count of employees sorted by deptname.
--Solution: Use RANK function and derived table
SELECT dt1.deptname, dt1.Emp_number FROM
(SELECT a.deptname, COUNT(b.empid) AS Emp_number, RANK() OVER(ORDER BY COUNT(b.empid) DESC) RNK
FROM Dept a INNER JOIN Employee b ON a.deptid = b.deptid
GROUP BY a.deptname
ORDER BY COUNT(b.empid)) dt1
WHERE dt1.RNK = 1

--14. Find top 3 employees (salary based) in every department. Result should have deptname, empid, salary sorted by deptname and then employee with high to low salary.
--Solution: Use RANK function, PARTITION function and derived table
SELECT e.deptname, e.empid, e.salary
FROM Employee e JOIN 
(SELECT a.empid, a.salary, a.deptid, RANK() OVER(PARTITION BY a.deptid ORDER BY a.salary DESC) AS RNK 
FROM Employee a JOIN Dept b ON a.deptid = b.deptid
GROUP BY a.empid, a.deptid) dt ON e.empid = dt.empid
WHERE dt.RNK <= 3