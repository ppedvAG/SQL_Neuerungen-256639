USE Northwind; 
USE [master]
GO

/* =============================================
   Thema: 
   Columnstore sortiert und 
   online ertellen und rebuild

   Beschreibung: 
   Wie erstelle ich einen Clustered
   und non-clustered columnstore Index online
   und wie sortiere ich diesen und optimiere ich 
   ohn zugleich
   ============================================= */


ALTER DATABASE tempdb MODIFY FILE (NAME = N'tempdev', FILEGROWTH = 64 MB, MAXSIZE = UNLIMITED );
ALTER DATABASE tempdb MODIFY FILE (NAME = N'temp2', FILEGROWTH = 64 MB, MAXSIZE = UNLIMITED);
ALTER DATABASE tempdb MODIFY FILE (NAME = N'temp3', FILEGROWTH = 64 MB, MAXSIZE = UNLIMITED);
ALTER DATABASE tempdb MODIFY FILE (NAME = N'temp4', FILEGROWTH = 64 MB, MAXSIZE =UNLIMITED);


USE Northwind;

select * into ku2 from kU


create clustered index CLIX on KU2 (id)

SET STATISTICS IO, TIME ON 

SELECT OrderDate, COUNT(*) AS OrderCount, 
   AVG(DATEDIFF(HH, OrderDate,Getdate())) , 
    SUM(CASE WHEN Freight < 1 THEN 1 ELSE Freight END)  
FROM    dbo.KU2
WHERE   OrderDate >= '1/1/1997' 
    AND OrderDate <= '2/1/1998' 
GROUP BY OrderDate 
ORDER BY OrderDate;

CREATE NONCLUSTERED COLUMNSTORE INDEX NCCI_KU2
ON dbo.KU2 (OrderDate, Freight, ID)

SELECT OrderDate, COUNT(*) AS OrderCount, 
   AVG(DATEDIFF(HH, OrderDate,Getdate())) , 
    SUM(CASE WHEN Freight < 1 THEN 1 ELSE Freight END)  
FROM    dbo.KU2
WHERE   OrderDate >= '1/1/1997' 
    AND OrderDate <= '2/1/1998' 
GROUP BY OrderDate 
ORDER BY OrderDate;

/*
CPU-Zeit = 16 ms, verstrichene Zeit = 24 ms.
"0" wird vom Segment übersprungen.
*/

select * from sys.dm_db_column_store_row_group_physical_stats
select * from sys.dm_db_column_store_row_group_operational_stats


CREATE NONCLUSTERED COLUMNSTORE INDEX NCCI_KU2
ON dbo.KU2 (OrderDate, Freight, ID) 
ORDER  (OrderDate,Freight, ID) 
WITH (DROP_EXISTING = ON,ONLINE = ON, MAXDOP = 8);--MAXDOP=1

CREATE NONCLUSTERED COLUMNSTORE INDEX NCCI_KU2
ON dbo.KU2 (OrderDate, Freight, ID) 
ORDER  (OrderDate,Freight, ID) 
WITH (DROP_EXISTING = ON,ONLINE = ON, MAXDOP = 1);--MAXDOP=1


--Messung:Table 'SalesOrdersBIG'. Segment reads 7, segment skipped 8.

ALTER INDEX NCCI_KU2 ON dbo.KU2 REBUILD;
--Abfrage in zweitem Fenster starten.. läuft und läuft

ALTER INDEX NCCI_KU2 ON dbo.KU2
REBUILD WITH (ONLINE = ON); 

-- Online-Option ermöglicht gleichzeitigen Zugriff
--Abfrage im zweitem Fenster