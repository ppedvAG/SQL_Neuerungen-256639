
USE [TemporalTables]
GO

-- Erstellen der temporalen Tabelle mit Systemzeit
CREATE TABLE dbo.Customer 
(  
  CustomerId INT IDENTITY(1,1) NOT NULL ,
  CustomerName VARCHAR(100) NOT NULL PRIMARY KEY CLUSTERED, 
  StartDate DATETIME2 GENERATED ALWAYS AS ROW START  NOT NULL,
  EndDate   DATETIME2 GENERATED ALWAYS AS ROW END  NOT NULL,
  PERIOD FOR SYSTEM_TIME (StartDate, EndDate)   
) 
WITH(SYSTEM_VERSIONING= ON (HISTORY_TABLE=dbo.CustomerHistory ) )
GO

-- insert into customer table
INSERT INTO dbo.Customer   (   CustomerName)                   
                     (SELECT  'Sam Union')
               UNION (SELECT  'Fred Dillard')
               UNION (SELECT  'Marry Gordan')
               UNION (SELECT  'Seth Molin')
               UNION (SELECT  'Brian Shah')
               UNION (SELECT  'Lauren Ziller')
GO                

-- Tabelle mit Fremdschlüssel erstellen
CREATE TABLE dbo.CustomerDetail 
(
   CustomerDetailId int
   --folgender Code fügt den Fremdschlüssel mit Cascade-Optionen hinzu
   --Cascade on Update und Delete sorgt dafür,
   --dass Änderungen in der Customer-Tabelle
   --automatisch in der CustomerDetail-Tabelle übernommen werden.
   --Besipiel, wenn der CompanyName in der Customer-Tabelle geändert wird,
   --dann wird diese Änderung automatisch in der CustomerDetail-Tabelle reflektiert.
   --das gilt nicht für andere Spalten, nur für die mit dem Fremdschlüssel.


   ,CustomerName VARCHAR(100) CONSTRAINT FK_CustomerDetail_CustomerName FOREIGN KEY REFERENCES dbo.Customer(CustomerName) 
			ON UPDATE CASCADE
			ON DELETE CASCADE
   ,Customer_DOB Date 
   ,Customer_Address varchar(50)
)
GO

-- insert into cusomerDetail table
INSERT INTO dbo.CustomerDetail   (CustomerDetailId, CustomerName, Customer_DOB, Customer_Address)   
                  (SELECT  101,      'Brian Shah', '30.09.1971', '101 Street 1, IL' )
            UNION (SELECT  102,   'Fred Dillard', '30.10.1972', '202 Street 2, IL' )
            UNION (SELECT  103,   'Lauren Ziller', '30.11.1973', '303 Street 3, IL' )
            UNION (SELECT  104,   'Marry Gordan', '30.12.1974', '404 Street 4, IL' )
            UNION (SELECT  105,   'Sam Union', '30.01.1975', '505 Street 5, IL' )
            UNION (SELECT  106,   'Seth Molin', '30.03.1976', '606 Street 6, IL' )
GO

-- Kontrolle der Daten in 3 Tabellen.
SELECT * FROM dbo.Customer
SELECT * FROM dbo.CustomerHistory
SELECT * FROM dbo.CustomerDetail
GO

--Ändern
DELETE FROM Customer WHERE CustomerName = 'Fred Dillard'
GO

-- Check the data in 3 tables.

SELECT * FROM dbo.Customer
SELECT * FROM dbo.CustomerHistory
SELECT * FROM dbo.CustomerDetail
GO

Update Customer
set CustomerName = 'Sam Henry' where CustomerName = 'Sam Union'

-- Check the data in 3 tables.
SELECT * FROM dbo.Customer
SELECT * FROM dbo.CustomerHistory
SELECT * FROM dbo.CustomerDetail
GO