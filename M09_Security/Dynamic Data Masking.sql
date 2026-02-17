
-- Datenbank (erneut) anlegen und wechseln
--Vorsicht .. geht nicht mit Always Encrypted
--berechnete Spalten
--https://docs.microsoft.com/de-de/sql/relational-databases/security/dynamic-data-masking?view=sql-server-ver15

create database DynMask
GO

use Dynmask;
GO


-- Tabelle anlegen 
CREATE TABLE [dbo].[Mitarbeiter]
(
   [ID] INT IDENTITY PRIMARY KEY,
   [Name] NVARCHAR(100) MASKED WITH (FUNCTION = 'partial(2,"-",2)') NULL,
   [Gehalt] DECIMAL(12,2)  MASKED WITH (FUNCTION = 'random(1, 1999)') NOT NULL,
   [Telefon] NVARCHAR(20) MASKED WITH (FUNCTION = 'default()') NULL,
   [EMail] NVARCHAR(100) MASKED WITH (FUNCTION = 'email()') NULL
  -- [GebDatum] NVARCHAR(100) MASKED WITH (FUNCTION = 'datetime(''Y'')') NULL,

);

--Maske zu Spalten später hinizufügen
Alter table dbo.Mitarbeiter
add  Weihnachtsgeld money masked with (FUNCTION = 'random(1, 1999)')  NULL,
	 Religion varchar(50)


Alter table dbo.mitarbeiter
 add [GebDatum] datetime MASKED WITH (FUNCTION = 'datetime("Y")') NULL

ALTER TABLE Mitarbeiter  
ALTER COLUMN Religion ADD MASKED WITH (FUNCTION = 'partial(1,"XXX",0)');


-- Ein paar Daten einfügen
INSERT  [dbo].[Mitarbeiter]
        ( [Name], [Gehalt], [Telefon], [EMail] )
VALUES  ( 'Hugo Drink', 999.9, '1234567', 'Hugo@sql.eu'),
        ( 'James Bond', 12000.0, '234567', 'jbond@dotnetconsulting.eu'),
        ( 'Harry Bo', 9.99, '3456789', 'harry@brexit.eu');

-- Testabfrage
SELECT * FROM [dbo].[Mitarbeiter];

-- Testuser mit Rechten anlegen
CREATE USER [UserOhneUNMASK] WITHOUT LOGIN;
CREATE USER [UserMitUNMASK] WITHOUT LOGIN;

GRANT SELECT, DELETE, UPDATE ON [dbo].[Mitarbeiter] TO [UserOhneUNMASK], [UserMitUNMASK];
--GRANT SELECT, DELETE, UPDATE, INSERT ON [dbo].[MitarbeiterOhneDDM] TO [UserOhneUNMASK], [UserMitUNMASK];
GRANT SHOWPLAN TO [UserOhneUNMASK], [UserMitUNMASK];
GRANT UNMASK TO [UserMitUNMASK];

-- Mit UNMASK-Recht
EXECUTE AS USER = 'UserMitUNMASK'; 
SELECT  CONCAT('Ausführen als: ', USER_NAME());

SELECT * FROM [dbo].[Mitarbeiter];

REVERT; -- Ursprünglicher User

-- Ohne UNMASK-Recht
EXECUTE AS USER = 'UserOhneUNMASK';
SELECT  CONCAT('Ausführen als: ', USER_NAME());

SELECT * FROM [dbo].[Mitarbeiter];

select * from mitarbeiter where gehalt > 11000

REVERT; 


EXECUTE AS USER = 'UserOhneUNMASK';
SELECT  CONCAT('Ausführen als: ', USER_NAME());

-- Filter und Sortierungen funktionen
SELECT * FROM [dbo].[Mitarbeiter] WHERE [Name] like '%Bo%';
SELECT * FROM [dbo].[Mitarbeiter] ORDER BY [Telefon] DESC;
-- Berechnung
SELECT  [Gehalt] - 15000 , * FROM [dbo].[Mitarbeiter] ORDER BY [Gehalt] ASC;

REVERT; -- Ursprünglicher User


-- Ohne UNMASK-Recht Daten ändern? Möglich, wenn UPDATE-Recht vorhanden
EXECUTE AS USER = 'UserOhneUNMASK';
SELECT  CONCAT('Ausführen als: ', USER_NAME());

UPDATE  [dbo].[Mitarbeiter]
SET     [Name] = 'Bugs B.' ,
        [EMail] = 'Bugs@Bunny.de'
WHERE   [ID] = 2;
SELECT * FROM [dbo].[Mitarbeiter];

REVERT; -- Ursprünglicher User


-- Ohne UNMASK-Recht Daten in andere Tabellen kopieren? ..kann man machen..aber..
EXECUTE AS USER = 'UserOhneUNMASK';
SELECT CONCAT ('Ausführen als: ', USER_NAME());

SELECT * INTO #Mitarbeiter FROM [dbo].[Mitarbeiter];

SELECT * FROM #Mitarbeiter;

REVERT; -- Ursprünglicher User

-- Kleine Übersicht über maskierte Spalten in der Datenbank
SELECT  OBJECT_SCHEMA_NAME([tbl].[object_id]) AS [schema_name] ,
        [tbl].[name] AS [table_name] ,
        [c].[name] AS [column_name] ,
        [c].[is_masked] ,
        [c].[masking_function]
FROM    [sys].[masked_columns] AS [c]
        JOIN [sys].[tables] AS [tbl] ON [c].[object_id] = [tbl].[object_id]
WHERE   [c].[is_masked] = 1;



