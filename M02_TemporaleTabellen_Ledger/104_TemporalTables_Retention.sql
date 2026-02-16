--AB SQL 2017--Retention

--Ab SQL 2017 können die Versionen automatisch gelöscht werden, 
--die älter als ein bestimmter Zeitraum sind.
--Die einheiten können Tage, Wochen, Monate oder Jahre sein.

CREATE TABLE TestTemporal(
Id INT CONSTRAINT PK_ID PRIMARY KEY,
CustomerName VARCHAR(50),
StartDate DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL, 
EndDate DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL,
PERIOD FOR SYSTEM_TIME (StartDate, EndDate)
)
WITH (SYSTEM_VERSIONING = ON 
         (HISTORY_TABLE = dbo.TestTemporalHistory, 
            History_retention_period = 2 DAYS --Days, Week, Month, Year --  <-----
          )
      ) 
GO

SELECT is_temporal_history_retention_enabled, NAME FROM sys.databases
GO;

--Kann man die Retention Zeit auch nachträglich ändern oder hinzufügen?

Alter TABLE TestTemporal
SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.TestTemporalHistory, 
            History_retention_period = 3 DAYS))
GO

--Nachträglich hinzufügen zu einer bestehenden Temporal Table

Alter TABLE Contacts
SET (SYSTEM_VERSIONING = ON(History_retention_period = 3 DAYS))
GO