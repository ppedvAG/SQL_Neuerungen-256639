/* =============================================
   Thema: Temporale Tabellen erstellen

   Beschreibung: wie versioniere ich DAtensätze?
   ============================================= */

--Temporale Tabelle erstellen

create table dbo.TemporaleKunden
(
	--Spalten der temporalen Tabelle
	--Spalte1 int, Spalte2 int, ...

	--Spalten für die Versionierung
	ValidFrom datetime2 (2) generated always as row start not null,
	ValidTo datetime2 (2) generated always as row end not null,
	period for system_time (ValidFrom, ValidTo)
)
-- Angabe der History-Tabelle und Aktivierung der Versionierung
with (system_Versioning = ON (History_table=dbo.Contactshistory)) 
GO

--Versionen können entweder über die History-Tabelle
-- oder die temporale Tabelle abgefragt werden.

--folgende Optionen gibt es, um Versionen in der temporalen Tabelle 
--zu finden

/*
FOR SYSTEM_TIME kann folgende Optionen verwenden:

AS OF – Zustand zu einem bestimmten Zeitpunkt

FROM ... TO – exklusiv

BETWEEN ... AND – inklusiv

CONTAINED IN – vollständig innerhalb des Zeitraums

ALL – komplette Historie
*/