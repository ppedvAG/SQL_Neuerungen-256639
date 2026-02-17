--Ledger Tabellen

--Alle durch eine Transaktion in einer Ledgertabelle geänderten Zeilen 
--werden kryptografisch mit einem SHA-256-Hash versehen.
--Dabei wird eine Merkle-Baumdatenstruktur verwendet, 
--die einen Stammhash generiert, 
--der alle Zeilen in der Transaktion repräsentiert.
--Die von der Datenbank 
--verarbeiteten Transaktionen werden über eine
--Merkle-Baumdatenstruktur gemeinsam
--mit einem SHA-256-Hash versehen. Das Ergebnis ist 
--ein Stammhash, der einen -Block bildet. 
--Der Block wird dann mithilfe seines Stammhashes 
--zusammen mit dem Stammhash des vorherigen Blocks 
--als Eingabe für die Hashfunktion mit SHA-256 gehasht. 



--und jetzt alle mit eigenen Worten wiederholen

CREATE TABLE ZutrittsLog
(
    LogID INT PRIMARY KEY,
    Zeitstempel DATETIME,
    MitarbeiterID INT,
    Ereignis VARCHAR(50)
)
WITH
(
    LEDGER = ON (APPEND_ONLY = ON) -- Explizit "Nur Anfügen"
);

select * from dbo.ZutrittsLog_ledger

--------------------------------------------
--Beispiel Kreditkartenutzung
--------------------------------------------

--Erstellen der Tabelle mit Ledger-Eigenschaft Append_only
CREATE TABLE dbo.[KeyCardEvents]
   (
      [EmployeeID] INT NOT NULL,
      [AccessOperationDescription] NVARCHAR (1024) NOT NULL,
      [Timestamp] Datetime2 NOT NULL
   )
   WITH (LEDGER = ON (APPEND_ONLY = ON));
   GO

--Einträge hinzufügen

INSERT INTO dbo.[KeyCardEvents]
VALUES ('43869', 'Building42', '2020-05-02T19:58:47.1234567');

INSERT INTO dbo.[KeyCardEvents]
VALUES ('84489', 'Automat', '2021-05-02T19:58:47.1234567');

INSERT INTO dbo.[KeyCardEvents]
VALUES ('43869', 'Schalter', '2021-06-02T19:58:47.1234567');

--geht nicht
update KeyCardEvents
set employeeid = 10000 where AccessOperationDescription= ' Building42'

--Blick in die View

Select * from keyCardEvents_ledger

--Unterschied zwischen einzelner Transaktion und mehreren

--1 Transaktion
INSERT INTO dbo.[KeyCardEvents]
VALUES ('01010', 'Konto', '2021-07-02T19:58:47.1234567');

--1 Transaktionv -mebhr Einträge
INSERT INTO dbo.[KeyCardEvents]
VALUES ('01010', 'Konto', '2021-07-02T19:58:47.1234567'),
    ('01011', 'Konto', '2021-08-02T19:58:47.1234567');

Select * from keyCardEvents_ledger
--der letzte INSERT mit 1 Transaktion und
--mehreren Einträgen hat nur 1 ledger_start_transaction_id
--Die Reihenfolge beginnt bei 0
--und jede weitere Insert innerhalb der Transaktion wird um 1 erhöht.

--------------------------------------
--Abrufen zusätzlicher Informationen
--------------------------------------

--Zusätzliche Spalten in der Ledgertabelle
--die auch in der Sicht wieder zu finden sind

SELECT *
     ,[ledger_start_transaction_id]
     ,[ledger_start_sequence_number]
FROM dbo.[KeyCardEvents];
Select * from KeyCardEvents_Ledger

-- Weitere Information zu den Ledgertabellen:
-- Wer hat wann das Statement ausgeführt

select * from sys.database_ledger_transactions;


--Übersicht mit Hilfer der View und Join
SELECT
 t.[commit_time] AS [CommitTime] 
 , t.[principal_name] AS [UserName]
 , l.[EmployeeID]
 , l.[AccessOperationDescription]
 , l.[Timestamp]
 , l.[ledger_operation_type_desc] AS Operation
 FROM dbo.[KeyCardEvents_Ledger] l
 JOIN sys.database_ledger_transactions t
 ON t.transaction_id = l.ledger_transaction_id
 ORDER BY t.commit_time DESC;

