SELECT (LastName || ', ' || FirstName) AS Name
FROM Person.Person
ORDER BY LastName ASC, FirstName ASC;


SELECT 'The order is due on ' || CONVERT(VARCHAR(12), DueDate, 101)
FROM Sales.SalesOrderHeader
WHERE SalesOrderID = 50001;
GO