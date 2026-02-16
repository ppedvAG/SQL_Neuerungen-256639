------------------------------------------------------
-- Aktualisierbare Ledgertabellen 
-- mit Systemversionierung erstellen und verwenden
-------------------------------------------------------
Use TemporalTables;
GO

drop table if exists balance;
GO

--Erstellen der Ledgertabelle mit Systemversionierung
--und Aktivierung von Ledger-Funktionalität

Create table  dbo.Kontoauszug
(
   Spalte1 int,
   Spalte2 int, ---...
   --Versionierungsspalten
    [ValidFrom] DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL,
    [ValidTo] DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
) WITH 
(
 SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.KontoauszugHistory),
 LEDGER = ON --  Aktivierung der Ledger-Funktionalität
);

------------------------------------------------------------------------

--Beispiel mit Kundensalden

CREATE TABLE dbo.[Kontoauszug]
(
    [KundeNr] INT NOT NULL PRIMARY KEY CLUSTERED,
    [Nachname] VARCHAR (50) NOT NULL,
    [Vorname] VARCHAR (50) NOT NULL,
    [Betrag] DECIMAL (10,2) NOT NULL
)
WITH 
(
 SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.[KontoauszugsHistory]),
 LEDGER = ON
);

--Welche Tabellen und Sichten gibts es zu dieser Tabelle?

SELECT 
ts.[name] + '.' + t.[name] AS [ledger_table_name]
, hs.[name] + '.' + h.[name] AS [history_table_name]
, vs.[name] + '.' + v.[name] AS [ledger_view_name]
FROM sys.tables AS t
JOIN sys.tables AS h ON (h.[object_id] = t.[history_table_id])
JOIN sys.views v ON (v.[object_id] = t.[ledger_view_id])
JOIN sys.schemas ts ON (ts.[schema_id] = t.[schema_id])
JOIN sys.schemas hs ON (hs.[schema_id] = h.[schema_id])
JOIN sys.schemas vs ON (vs.[schema_id] = v.[schema_id])
WHERE t.[name] = 'Kontoauszug';



INSERT INTO dbo.Kontoauszug
VALUES (1, 'Jones', 'Nick', 50);


INSERT INTO dbo.Kontoauszug
VALUES (2, 'Smith', 'Tom', 30);


INSERT INTO dbo.Kontoauszug
VALUES (3, 'Smith', 'John', 500),
(4, 'Smith', 'Joe', 30),
(5, 'Michaels', 'Mary', 200);



SELECT [KundeNr]
   ,[Nachname],[Vorname]
   ,[Betrag]
   ,[ledger_start_transaction_id]
   ,[ledger_end_transaction_id]
   ,[ledger_start_sequence_number]
   ,[ledger_end_sequence_number]
 FROM dbo.Kontoauszug;



UPDATE dbo.Kontoauszug SET Betrag = 100
WHERE [KundeNr] = 1;


--Verlauf darstellen

SELECT
 t.[commit_time] AS [CommitTime] 
 , t.[principal_name] AS [UserName]
 , l.[KundeNr]
 , l.[Nachname]
 , l.[Vorname]
 , l.[Betrag]
 , l.[ledger_operation_type_desc] AS Operation,l.ledger_transaction_id, l.ledger_sequence_number
 FROM dbo.Kontoauszug_ledger l
 JOIN sys.database_ledger_transactions t
 ON t.transaction_id = l.ledger_transaction_id
 ORDER BY t.commit_time DESC;



 

