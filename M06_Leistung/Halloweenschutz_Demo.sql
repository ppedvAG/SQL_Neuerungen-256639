ALTER DATABASE TESTDB
    SET ACCELERATED_DATABASE_RECOVERY = ON WITH ROLLBACK IMMEDIATE;
ALTER DATABASE TESTDB
    SET COMPATIBILITY_LEVEL = 170;
ALTER DATABASE SCOPED CONFIGURATION
    SET OPTIMIZED_HALLOWEEN_PROTECTION = ON;
GO

/* Validate configuration */
SELECT d.compatibility_level,
       d.is_accelerated_database_recovery_on,
       dsc.name,
       dsc.value
FROM sys.database_scoped_configurations AS dsc
CROSS JOIN sys.databases AS d
WHERE dsc.name = 'OPTIMIZED_HALLOWEEN_PROTECTION'
      AND
      d.name = DB_NAME();
GO

/* Create the test table and add data */
DROP TABLE IF EXISTS dbo.OptimizedHPDemo;

BEGIN TRANSACTION;

SELECT *
INTO dbo.OptimizedHPDemo
FROM Sales.Invoices

ALTER TABLE dbo.OptimizedHPDemo
ADD CONSTRAINT PK_OptimizedHPDemo
PRIMARY KEY CLUSTERED (InvoiceID)
ON USERDATA;

COMMIT;
GO

/* Ensure that Query Store is enabled and is capturing all queries */
ALTER DATABASE WideWorldImporters
    SET QUERY_STORE = ON (OPERATION_MODE = READ_WRITE, QUERY_CAPTURE_MODE = ALL);

/* Empty Query Store to start with a clean slate */
ALTER DATABASE WideWorldImporters
    SET QUERY_STORE CLEAR;
GO

/* Disable optimized Halloween protection as the baseline */
ALTER DATABASE SCOPED CONFIGURATION
    SET OPTIMIZED_HALLOWEEN_PROTECTION = OFF;
GO

/*
Insert data selecting from the same table.
This requires Halloween protection so that 
the same row cannot be selected and inserted repeatedly.
*/
BEGIN TRANSACTION;

INSERT INTO dbo.OptimizedHPDemo
(
InvoiceID, CustomerID, BillToCustomerID, OrderID, DeliveryMethodID, ContactPersonID, AccountsPersonID,
SalespersonPersonID, PackedByPersonID, InvoiceDate, CustomerPurchaseOrderNumber, IsCreditNote, CreditNoteReason,
Comments, DeliveryInstructions, InternalComments, TotalDryItems, TotalChillerItems, DeliveryRun, RunPosition,
ReturnedDeliveryData, ConfirmedDeliveryTime, ConfirmedReceivedBy, LastEditedBy, LastEditedWhen
)
SELECT InvoiceID + 1000000 AS InvoiceID, 
       CustomerID, BillToCustomerID, OrderID, DeliveryMethodID, ContactPersonID, AccountsPersonID,
       SalespersonPersonID, PackedByPersonID, InvoiceDate, CustomerPurchaseOrderNumber, IsCreditNote, CreditNoteReason,
       Comments, DeliveryInstructions, InternalComments, TotalDryItems, TotalChillerItems, DeliveryRun, RunPosition,
       ReturnedDeliveryData, ConfirmedDeliveryTime, ConfirmedReceivedBy, LastEditedBy, LastEditedWhen
FROM dbo.OptimizedHPDemo;

ROLLBACK;
GO

/*
Enable optimized Halloween protection.
Execute the following statement in its own batch.
*/
ALTER DATABASE SCOPED CONFIGURATION 
    SET OPTIMIZED_HALLOWEEN_PROTECTION = ON;
GO

/* Execute the same query again */
BEGIN TRANSACTION;

INSERT INTO dbo.OptimizedHPDemo
(
InvoiceID, CustomerID, BillToCustomerID, OrderID, DeliveryMethodID, ContactPersonID, AccountsPersonID,
SalespersonPersonID, PackedByPersonID, InvoiceDate, CustomerPurchaseOrderNumber, IsCreditNote, CreditNoteReason,
Comments, DeliveryInstructions, InternalComments, TotalDryItems, TotalChillerItems, DeliveryRun, RunPosition,
ReturnedDeliveryData, ConfirmedDeliveryTime, ConfirmedReceivedBy, LastEditedBy, LastEditedWhen
)
SELECT InvoiceID + 1000000 AS InvoiceID, 
       CustomerID, BillToCustomerID, OrderID, DeliveryMethodID, ContactPersonID, AccountsPersonID,
       SalespersonPersonID, PackedByPersonID, InvoiceDate, CustomerPurchaseOrderNumber, IsCreditNote, CreditNoteReason,
       Comments, DeliveryInstructions, InternalComments, TotalDryItems, TotalChillerItems, DeliveryRun, RunPosition,
       ReturnedDeliveryData, ConfirmedDeliveryTime, ConfirmedReceivedBy, LastEditedBy, LastEditedWhen
FROM dbo.OptimizedHPDemo;

ROLLBACK;
GO

/*
Examine query runtime statistics and plans 
for the two executions of the same query.
*/
SELECT q.query_id,
       q.query_hash,
       qt.query_sql_text,
       p.plan_id,
       rs.count_executions,
       rs.avg_tempdb_space_used * 8 / 1024. AS tempdb_space_mb,
       FORMAT(rs.avg_cpu_time / 1000., 'N0') AS avg_cpu_time_ms,
       FORMAT(rs.avg_duration / 1000., 'N0') AS avg_duration_ms,
       TRY_CAST(p.query_plan AS xml) AS xml_query_plan
FROM sys.query_store_runtime_stats AS rs
INNER JOIN sys.query_store_plan AS p
ON rs.plan_id = p.plan_id
INNER JOIN sys.query_store_query AS q
ON p.query_id = q.query_id
INNER JOIN sys.query_store_query_text AS qt
ON q.query_text_id = qt.query_text_id
WHERE q.query_hash = 0xC6ADB023512BBCCC;

/*
For the second execution with optimized Halloween protection:
1. tempdb space usage is zero
2. CPU time and duration are reduced by about 50%
3. The Clustered Index Insert operator in the query plan has 
   the OptimizedHalloweenProtection property set to True
*/