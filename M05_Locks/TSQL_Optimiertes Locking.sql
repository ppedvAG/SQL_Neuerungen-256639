





/*

Eine Transaktions-ID (TID) ist ein eindeutiger Bezeichner einer Transaktion. 
Jede Zeile wird mit der letzten TID beschriftet, die sie geändert hat. 
Anstelle von potenziell vielen Schlüssel- oder Zeilenbezeichnersperren 
wird eine einzelne Sperre für die TID verwendet. 

Sperrung nach Qualifizierung (Lock After Qualification, LAQ) ist eine Optimierung
, bei der die Prädikate einer Abfrage mithilfe der letzten bestätigten 
Version der Zeile ausgewertet werden, ohne eine Sperre zu erhalten, 
wodurch die Gleichzeitigkeit verbessert wird. 


Beispiel:

Ohne optimierte Sperrung erfordert das Aktualisieren von 1.000 Zeilen 
in einer Tabelle unter Umständen 1.000 exklusive Zeilensperren (X), 
die bis zum Ende der Transaktion aufrechterhalten werden.

Mit der optimierten Sperrung erfordert das Aktualisieren von 
1.000 Zeilen in einer Tabelle auch möglicherweise 1.000 X Zeilensperren. 
Jede Sperre wird jedoch freigegeben, sobald die einzelnen Zeilen aktualisiert wurden
, und lediglich eine TID-Sperre wird bis zum Ende der Transaktion aufrechterhalten. 

Da Sperren schnell freigegeben werden, wird die 
Speicherauslastung der Sperre verringert, und die Sperrenausweitung 
ist viel weniger wahrscheinlich, was die Workload-Nebenläufigkeit verbessert.
*/

--Prüfung der Voraussetzungen
--Optimiertes Sperrverhalten
--STD in Preview deaktiviert

USE TESTDB;
GO 
Alter database TESTDB set accelerated_database_recovery = on
Alter database TESTDB set optimized_locking = on

-- ADR muss aktiv sein
-- optimal: Read Commited Snapshot Isolation aktiviert
ALTER DATABASE TESTDB SET READ_COMMITTED_SNAPSHOT ON WITH NO_WAIT
GO

--Prüfung
SELECT database_id,
       name,
       is_accelerated_database_recovery_on,
       is_read_committed_snapshot_on,
       is_optimized_locking_on
FROM sys.databases
WHERE name = DB_NAME();

/* Is optimized locking is enabled? */
SELECT IsOptimizedLockingOn = DATABASEPROPERTYEX(DB_NAME(), 'IsOptimizedLockingOn');
-----------------------------------------------------------------------

DROP TABLE IF EXISTS t0

CREATE TABLE t0
( a int PRIMARY KEY, b int NULL );

INSERT INTO t0 VALUES (1,10),(2,20),(3,30);
GO


--OHNE OPTIMIZED
USE master;
GO
Alter database TESTDB set optimized_locking = OFF

USE TestDB;
GO

BEGIN TRANSACTION;

UPDATE t0
SET b = b + 10;

SELECT *
FROM sys.dm_tran_locks
WHERE request_session_id = @@SPID
      AND
      resource_type IN ('PAGE','RID','KEY','XACT');

--eine Sperre auf einer Transaction bei optimzed
--4 Sperren (PAGE, KEY) bei off
--Jeder DS wird exklusiv gesperrt --> KEY
--Zusätzlich eine INTENT Sperre auf PAGE Ebene, um anzuzeigen, dass eine Seite gesperrt ist
--und keiner versuchen kann diese zu lesen oder zu schreiben. 
--Man muss eben nicht jede Zeile lesen, um zu wissen, dass Sperren vorliegen
--Der IX PAGE LOCK kann kompatibel mit andere IX PAGE LOCKS anderer Sessions sein.
--Das heißt es drüfen andere Sessions andere Datensätze ändern. 
--Allerdings wäre das Ändern der Tabelle (z.B. DROP TABLE) nicht möglich, 
--da dafür eine SCH-M Sperre benötigt wird, die nicht kompatibel mit IX ist.

rollback

GO

--MIT OPTIMIZED
USE master;
GO
Alter database TESTDB set optimized_locking = ON

USE TestDB;
GO
SELECT IsOptimizedLockingOn = DATABASEPROPERTYEX(DB_NAME(), 'IsOptimizedLockingOn');


BEGIN TRANSACTION;

UPDATE t0
SET b = b + 10;

SELECT *
FROM sys.dm_tran_locks
WHERE request_session_id = @@SPID
      AND
      resource_type IN ('PAGE','RID','KEY','XACT');

--eine Sperre auf einer Transaction bei optimzed

rollback
COMMIT TRANSACTION;
GO

DROP TABLE IF EXISTS t0;

