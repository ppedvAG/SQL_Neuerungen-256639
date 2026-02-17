/*

sp_executesql


Wenn die konfiguration mit OPTIMIZED_SP_EXECUTESQL Datenbankbereich aktiviert ist
, wird das Kompilierungsverhalten der übermittelten Batches mit sp_executesql 
dem serialisierten Kompilierungsverhalten identisch, das Objekte wie gespeicherte 
Prozeduren und Trigger derzeit verwenden.

Wenn Batches identisch sind (ohne Parameterunterschiede)
, versucht die OPTIMIZED_SP_EXECUTESQL Option, eine Kompilierungssperre 
als Erzwingungsmechanismus abzurufen, um sicherzustellen
, dass der Kompilierungsprozess serialisiert wird. 
Diese Sperre stellt sicher, dass, wenn mehrere Sitzungen gleichzeitig 
aufgerufen sp_executesql werden, diese Sitzungen warten
, während sie versuchen, eine exklusive Kompilierungssperre zu erhalten
, nachdem die erste Sitzung den Kompilierungsprozess gestartet hat. 
Die erste Ausführung der sp_executesql Kompilierung und fügt den 
kompilierten Plan in den Plancache ein. Andere Sitzungen werden abgebrochen
, wenn sie auf die Kompilierungssperre warten und den Plan wiederverwenden
, sobald er verfügbar ist.

Ohne die OPTIMIZED_SP_EXECUTESQL Option werden mehrere Aufrufe identischer Batches
, die parallel über sp_executesql kompiliert ausgeführt werden
, ausgeführt und ihre eigenen Kopien eines kompilierten Plans in den Plancache eingefügt
, wodurch in einigen Fällen Einträge des Plancaches ersetzt oder dupliziert werden.

*/
ALTER DATABASE SCOPED CONFIGURATION SET OPTIMIZED_SP_EXECUTESQL = ON;


EXECUTE sp_executesql N'SELECT * FROM AdventureWorks2022.HumanResources.Employee
    WHERE BusinessEntityID = @level', N'@level TINYINT', @level = 109;


/*
Die Verwendung sp_executesql in diesem Verfahren ist effizienter als EXECUTE die Verwendung der dynamisch erstellten Zeichenfolge, da sie die Verwendung von Parametermarkierungen ermöglicht. Parametermarkierungen machen es wahrscheinlicher, dass die Datenbank-Engine den generierten Abfrageplan wiederverwendet, wodurch zusätzliche Abfragekompilierungen vermieden werden können. Bei EXECUTEjeder Zeichenfolge ist jede INSERT Zeichenfolge eindeutig, da sich die Parameterwerte unterscheiden und am Ende der dynamisch generierten Zeichenfolge angefügt werden. Wenn die Abfrage ausgeführt wird, würde die Abfrage nicht auf eine Weise parametrisiert werden, die die Wiederverwendung des Plans fördert, und muss vor der Ausführung jeder INSERT Anweisung kompiliert werden, wodurch ein separater zwischengespeicherter Eintrag der Abfrage im Plancache hinzugefügt würde.

CREATE TABLE May1998Sales
(
    OrderID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATETIME NULL CHECK (DATEPART(yy, OrderDate) = 1998),
    OrderMonth INT CHECK (OrderMonth = 5),
    DeliveryDate DATETIME NULL,
    CHECK (DATEPART(mm, OrderDate) = OrderMonth)
);


CREATE or alter PROCEDURE InsertSales (
    @PrmOrderID INT,
    @PrmCustomerID INT,
    @PrmOrderDate DATETIME,
    @PrmDeliveryDate DATETIME
)
AS
DECLARE @InsertString AS NVARCHAR (500);
DECLARE @OrderMonth AS INT;
-- Build the INSERT statement.
SET @InsertString = 'INSERT INTO ' +
    /* Build the name of the table. */
    SUBSTRING(DATENAME(mm, @PrmOrderDate), 1, 3)
    + CAST (DATEPART(yy, @PrmOrderDate) AS CHAR (4)) + 'Sales' +
    /* Build a VALUES clause. */
    ' VALUES (@InsOrderID, @InsCustID, @InsOrdDate,'
    + ' @InsOrdMonth, @InsDelDate)';

/* Set the value to use for the order month because
   functions are not allowed in the sp_executesql parameter
   list. */
SET @OrderMonth = DATEPART(mm, @PrmOrderDate);
EXECUTE sp_executesql
    @InsertString, N'@InsOrderID INT, @InsCustID INT, @InsOrdDate DATETIME, @InsOrdMonth INT, @InsDelDate DATETIME',
    @PrmOrderID,
    @PrmCustomerID,
    @PrmOrderDate,
    @OrderMonth,
    @PrmDeliveryDate;
GO