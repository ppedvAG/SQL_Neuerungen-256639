use TemporalTables
GO


--Anlegen einer temporalen Tabelle
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

--Einfügen von Daten
insert into Contacts 
(Lastname,Firstname,Birthday, Phone, email) 
select 'Kent', 'Clark','3.4.2010', '089-3303003', 'clarkk@krypton.universe' 

insert into Contacts 
(Lastname,Firstname,Birthday, Phone, email) 
select 'Wayne', 'Bruce','3.4.2012', '08677-3303003', 'brucew@gotham.city' 

select * from contacts

--Und nun die Änderungen, die zu einer Versionierung der Datensätze führt 
WAITFOR DELAY '00:00:02'
update contacts set email = 'wer@earth.de' where cid = 1 
update contacts set Phone = 'w3434' where cid = 1 
update contacts set Lastname = 'Wayne' where cid = 1 

WAITFOR DELAY '00:00:02'

update contacts set email = 'asas@earth.de' where cid = 1 
update contacts set Phone = 'w34sasaa34' where cid = 2 
update contacts set Lastname = 'Smith' where cid = 1 

--Result
select * from contacts 
select * from ContactsHistory 


--nach Version suchen

select * from contactshistory 
where 
    Startdatum >= '2026-02-16 12:32:42.9271155' 
    and 
    Enddatum <= '2026-02-16 12:34:02.0561587'  

--Noch besser mit SYSTEM_TIME
--SYSTEM_TIME Optionen:
-- AS OF – Zustand zu einem bestimmten Zeitpunkt
-- FROM ... TO – exklusiv
-- BETWEEN ... AND – inklusiv
-- CONTAINED IN – vollständig innerhalb des Zeitraums
-- ALL – komplette Historie

 select * from contacts 
    FOR SYSTEM_TIME BETWEEN '2026-02-16 12:32:42.9271155' AND '2026-02-16 12:34:02.0561587' 
    where cid =1 
 select * from contacts 
    FOR SYSTEM_TIME FROM '2026-02-03 11:22:08.8997518' TO '2026-02-03 11:22:19.3665463' 
    where cid =1
select * from contacts 
    FOR SYSTEM_TIME AS OF '2026-02-03 11:22:19.3665463' 
    where cid =1 

 select * from contacts 
    FOR SYSTEM_TIME All
    where cid =1 


--Was passiert , wenn man eine Spalte hinzufügt/löscht/ändert?
--Was wenn..
Alter Table contacts	add spx int
Alter Table contacts	add spy int

select * from contactshistory


update contacts set Firstname= 'Chris', spx=2 where cid = 1
update contacts set Firstname= 'Diana', spy=3 where cid = 2
update contacts set Firstname= 'Chris', spx=5 where cid = 5
update contacts set Firstname= 'Diana', spy=3 where cid = 5

Alter table contacts drop column spy

select * from contactshistory


--nope--das geht nicht
delete from Contactshistory where StartDatum <= '2026-02-03 11:22:19.3741577'


--Also:
--Spalten hinzufügen ist erlaubt und 
--in der Versionstabelle wird diese Spalte ebenso hinzugefügt

--werden Spalten gelöscht, sind diese in der Versionstabelle ebenso gelöscht

--Historientabellen können nicht direkt verändert werden
--ausser die Versionierung wurde deaktiviert




