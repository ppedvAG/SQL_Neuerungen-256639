Create database TemporalTables
GO

Use TemporalTables
GO


--Erstellen einer temporalen Tabelle
Create table contacts  
( 
Cid int identity primary key, 
Lastname varchar(50), 
Firstname varchar(50), 
Birthday date, 
Phone varchar(50), 
email varchar(50), 
StartDatum datetime2 Generated always as row start not null, 
EndDatum datetime2 Generated always as row end not null, 
Period for system_time (StartDatum, EndDatum) --Großschreibung/Kleinschreibung
) 
with (system_Versioning = ON (History_table=dbo.Contactshistory)) 
GO


--Aktivieren der Versionierung bei bestehenden Tabellen
CREATE TABLE Demo2 
( 
SP1 int identity primary key, 
SP2 int, 
--Versionsspalten müssen vorhanden sein
StartFrom datetime2 not null, EndTo datetime2 not null
); 

--Aktivierung der PERIOD 

ALTER TABLE demo2 
ADD PERIOD FOR SYSTEM_TIME(StartFrom,EndTo) 

--Aktivierung des SYSTEM_VERSIONING 

ALTER TABLE demo2
SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.demohistory, DATA_CONSISTENCY_CHECK = ON)) 


--Aktivieren der Versionierung bei bestehenden Tabellen
--falls Datumsspalten für Versionierung nich  nicht vorhanden sind
CREATE TABLE Demo3 
( 
SP1 int identity primary key, SP2 int 
) 
 
--Hinzufügen der Versionsspalten mit den notwendigen Eigenschaften
ALTER TABLE demo3 
ADD PERIOD FOR SYSTEM_TIME (StartFrom, EndTo), 
StartFrom datetime2 GENERATED ALWAYS AS ROW START NOT NULL DEFAULT GETUTCDATE(), 
EndTo datetime2 GENERATED ALWAYS AS ROW END NOT NULL DEFAULT CONVERT(DATETIME2,'9999.12.31'); 
     
--Aktivierung des SYSTEM_VERSIONING
ALTER TABLE demo3 
SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.demo3history, DATA_CONSISTENCY_CHECK = ON)) 



--Deaktivieren der Versionierung
Alter Table contacts 
set (system_versioning=off)
--> Historientabelle bleibt bestehen
--> Tabelle ist jetzt wieder normal manipulierbar
--> Löschen der History-Tabelle, falls gewünscht

--Reaktivieren der Versionierung
ALTER TABLE contacts
SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.contactshistory, DATA_CONSISTENCY_CHECK = ON)) 

--Erst wenn Versionierung deaktiviert ist, kann die Tabelle gelöscht werden
drop table contacts

---Löschen der Historientabellen und Versionstabellen
Alter Table contacts 
set (system_versioning=off)
GO

drop table contactshistory
GO

drop table contacts

Alter Table Demo2
set (system_versioning=off)
GO

Alter Table Demo3
set (system_versioning=off)
GO

DROP TABLE Demo2
GO

DROP TABLE Demo3
GO

DROP TABLE demohistory
GO

DROP TaBLE demo3history
GO
