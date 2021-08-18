--Assignment Day2 –SQL:  Comprehensive practice

--Answer following questions
--1.	What is a result set?
--A result set is the output of a query. 
--2.	What is the difference between Union and Union All?
--UNION removes duplicate records (where all columns in the results are the same), UNION ALL does not.
--3.	What are the other Set Operators SQL Server has?
--INTERSECT, EXCEPT and UNION, UNION ALL as mentioned in the former question.
--4.	What is the difference between Union and Join?
--Join combines data from tables based on a matched condition, while Union will combine the result set of two or more Select statements.
--5.	What is the difference between INNER JOIN and FULL JOIN?
--INNER JOIN will give the common part of two tables. FULL JOIN will give the common part and also the remaining parts of two tables.
--6.	What is difference between left join and outer join
--Outer join includes left outer join, right outer join and full outer join. Left join is the same as left outer join.
--7.	What is cross join?
--The cross join is used to generate a paired combination of each row of the first table with each row of the second table.
--8.	What is the difference between WHERE clause and HAVING clause?
--Where clause implements in row operations, cannot contain aggregate function. Having clause implements in column operations, can contain aggregate function, and can not be used without group by clause.
--9.	Can there be multiple group by columns?
--Yes, you can have multiple group by columns.


--Write queries for following scenarios
USE AdventureWorks2019
GO

--1.	How many products can you find in the Production.Product table?
SELECT count(ProductID)
FROM Production.Product

--2.	Write a query that retrieves the number of products in the Production.Product table that are included in a subcategory. The rows that have NULL in column ProductSubcategoryID are considered to not be a part of any subcategory.
SELECT count(ProductID)
FROM Production.Product
WHERE ProductSubcategoryID IS NOT NULL

--3.	How many Products reside in each SubCategory? Write a query to display the results with the following titles.
SELECT ProductSubcategoryID, COUNT(ProductID) AS CountedProducts
FROM Production.Product
GROUP BY ProductSubcategoryID
HAVING ProductSubcategoryID IS NOT NULL

--4.	How many products that do not have a product subcategory. 
SELECT count(ProductID)
FROM Production.Product
WHERE ProductSubcategoryID IS NULL

--5.	Write a query to list the sum of products quantity in the Production.ProductInventory table.
SELECT SUM(Quantity) AS QUANTITY_SUM
FROM Production.ProductInventory

--6.	 Write a query to list the sum of products in the Production.ProductInventory table and LocationID set to 40 and limit the result to include just summarized quantities less than 100.
SELECT ProductID, SUM(Quantity) AS TheSum
FROM Production.ProductInventory
WHERE LocationID = 40 
GROUP BY ProductID
HAVING SUM(Quantity) < 100

--7.	Write a query to list the sum of products with the shelf information in the Production.ProductInventory table and LocationID set to 40 and limit the result to include just summarized quantities less than 100
SELECT Shelf, ProductID, SUM(Quantity) AS TheSum
FROM Production.ProductInventory
WHERE LocationID = 40 
GROUP BY Shelf, ProductID
HAVING SUM(Quantity) < 100

--8.	Write the query to list the average quantity for products where column LocationID has the value of 10 from the table Production.ProductInventory table.
SELECT AVG(Quantity) AS TheAvg
FROM Production.ProductInventory
WHERE LocationID = 10 
--if group by ProductID
SELECT ProductID, AVG(Quantity) AS TheAvg
FROM Production.ProductInventory
WHERE LocationID = 10 
GROUP BY ProductID

--9.	Write query  to see the average quantity  of  products by shelf  from the table Production.ProductInventory
SELECT ProductID, Shelf, AVG(Quantity) AS TheAvg
FROM Production.ProductInventory
GROUP BY ProductID, Shelf

--10.	Write query  to see the average quantity  of  products by shelf excluding rows that has the value of N/A in the column Shelf from the table Production.ProductInventory
SELECT ProductID, Shelf, AVG(Quantity) AS TheAvg
FROM Production.ProductInventory
WHERE Shelf != 'N/A'
GROUP BY ProductID, Shelf

--11.	List the members (rows) and average list price in the Production.Product table. This should be grouped independently over the Color and the Class column. Exclude the rows where Color or Class are null.
SELECT Color, Class, COUNT(ProductID) AS TheCount, AVG(ListPrice) AS AvgPrice
FROM Production.Product
WHERE Color IS NOT NULL AND Class IS NOT NULL
GROUP BY Color, Class

--12.	  Write a query that lists the country and province names from person. CountryRegion and person. StateProvince tables. Join them and produce a result set similar to the following. 
SELECT a.Name AS Country, b.Name AS Province
FROM Person.CountryRegion a INNER JOIN Person.StateProvince b on a.CountryRegionCode = b.CountryRegionCode

--13.	Write a query that lists the country and province names from person. CountryRegion and person. StateProvince tables and list the countries filter them by Germany and Canada. Join them and produce a result set similar to the following.
SELECT a.Name AS Country, b.Name AS Province
FROM Person.CountryRegion a INNER JOIN Person.StateProvince b on a.CountryRegionCode = b.CountryRegionCode
WHERE a.Name IN ('Germany', 'Canada')

--Using Northwind Database: (Use aliases for all the Joins)
USE Northwind
GO

--14.	List all Products that has been sold at least once in last 25 years.
SELECT DISTINCT a.ProductID, a.ProductName
FROM Products a INNER JOIN [Order Details] b ON a.ProductID = b.ProductID INNER JOIN Orders c ON b.OrderID = c.OrderID
WHERE c.OrderDate > '1996-08-17'

--15.	List top 5 locations (Zip Code) where the products sold most.
SELECT TOP 5 ShipPostalCode, COUNT(ShipPostalCode) AS THE_COUNT
FROM Orders
GROUP BY ShipPostalCode
ORDER BY COUNT(ShipPostalCode) DESC

--16.	List top 5 locations (Zip Code) where the products sold most in last 25 years.
SELECT TOP 5 ShipPostalCode, COUNT(ShipPostalCode) AS THE_COUNT
FROM Orders
WHERE OrderDate > '1996-08-17'
GROUP BY ShipPostalCode
ORDER BY COUNT(ShipPostalCode) DESC

--17.	 List all city names and number of customers in that city.     
SELECT City, count(CustomerID) as Customer_Number
FROM Customers
Group by City

--18.	List city names which have more than 2 customers, and number of customers in that city 
SELECT City, count(CustomerID) as Customer_Number
FROM Customers
Group by City
HAVING count(CustomerID) > 2

--19.	List the names of customers who placed orders after 1/1/98 with order date.
SELECT a.ContactName, b.OrderDate
FROM Customers a INNER JOIN Orders b ON a.CustomerID = b.CustomerID
WHERE b.OrderDate > '1998-01-01'

--20.	List the names of all customers with most recent order dates 
SELECT a.ContactName, MAX(b.OrderDate)
FROM Customers a INNER JOIN Orders b ON a.CustomerID = b.CustomerID
GROUP BY a.ContactName

--21.	Display the names of all customers  along with the  count of products they bought 
SELECT a.ContactName, SUM(c.Quantity) AS The_count
FROM Customers a JOIN Orders b ON a.CustomerID = b.CustomerID JOIN [Order Details] c ON b.OrderID = c.OrderID
GROUP BY a.ContactName

--22.	Display the customer ids who bought more than 100 Products with count of products.
SELECT a.CustomerID, SUM(c.Quantity) AS The_count
FROM Customers a JOIN Orders b ON a.CustomerID = b.CustomerID JOIN [Order Details] c ON b.OrderID = c.OrderID
GROUP BY a.CustomerID
HAVING SUM(c.Quantity) > 100

--23.	List all of the possible ways that suppliers can ship their products. Display the results as below
SELECT DISTINCT a.CompanyName AS [Supplier Company Name], e.CompanyName AS [Shipping Company Name]
FROM Suppliers a INNER JOIN Products b on a.SupplierID = b.SupplierID INNER JOIN [Order Details] c ON b.ProductID = c.ProductID
INNER JOIN Orders d On c.OrderID = d.OrderID INNER JOIN Shippers e ON d.ShipVia = e.ShipperID
ORDER BY a.CompanyName

--24.	Display the products order each day. Show Order date and Product Name.
SELECT c.OrderDate, a.ProductName
FROM Products a JOIN [Order Details] b ON a.ProductID = b.ProductID JOIN Orders c ON b.OrderID = c.OrderID
ORDER BY c.OrderDate

--25.	Displays pairs of employees who have the same job title.
SELECT o1.FirstName + ' ' + o1.LastName AS Employee1_Name, o2.FirstName + ' ' + o2.LastName AS Employee2_Name, o1.Title AS Job_Title
FROM Employees o1 INNER JOIN Employees o2 ON o1.Title = o2.Title
WHERE o1.EmployeeID != o2.EmployeeID

--26.	Display all the Managers who have more than 2 employees reporting to them.
SELECT o2.EmployeeID, o2.Title, (o2.LastName + ' ' + o2.FirstName) AS Name, COUNT(o1.EmployeeID) AS Reporting_Number
FROM Employees o1 INNER JOIN Employees o2 ON o1.ReportsTo = o2.EmployeeID
GROUP BY o2.EmployeeID, o2.Title, (o2.LastName + ' ' + o2.FirstName)
HAVING  COUNT(o1.EmployeeID) > 2

--27.	Display the customers and suppliers by city. The results should have the following columns
SELECT a.City, a.CompanyName AS Name, a.ContactName AS [Contact Name], a.Relationship AS Type
FROM [Customer and Suppliers by City] a
ORDER BY a.City

--28.   Please write a query to inner join these two tables and write down the result of this query.
SELECT T1.F1 AS T1_Column, T2.F2 AS T2_Column
FROM T1 INNER JOIN T2 ON T1.F1 = T2.F2
--The result would be as follows
T1_Column T2_Column
2	      2
3         3

--29.   Based on above two table, Please write a query to left outer join these two tables and write down the result of this query.
SELECT T1.F1 AS T1_Column, T2.F2 AS T2_Column
FROM T1 LEFT JOIN T2 ON T1.F1 = T2.F2
--The result would be as follows
T1_Column T2_Column
1	      NULL
2	      2
3         3
