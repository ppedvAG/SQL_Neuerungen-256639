--opitmierter Halloweenschutz

/*

Ein klassisches Beispiel, in dem das Halloween-Problem auftritt
, ist ein Update auf eine Spalte, die zugleich 
in einem (Nicht-Clustered-)Index als Suchkriterium dient 
und deren Wert verändert wird. 
Dadurch kann eine aktualisierte Zeile während des Scan-Vorgangs 
erneut in den Bereich fallen und somit mehrfach verarbeitet werden.



voraussetzung: ADR

Spart Speicher und IO (da kein tempdb-Spool nötig ist).

Verringert die Abfrage-Latenz deutlich.

Reduziert die Komplexität von Ausführungsplänen.


nicht bei #tabellen und Columnstore

*/
ALTER DATABASE Aventureworks2022 SET ACCELERATED_DATABASE_RECOVERY = ON WITH ROLLBACK IMMEDIATE;
ALTER DATABASE Aventureworks2022 SET COMPATIBILITY_LEVEL = 170;
ALTER DATABASE SCOPED CONFIGURATION SET OPTIMIZED_HALLOWEEN_PROTECTION = ON;

--oder per Abfrage
-- OPTION (USE HINT('ENABLE_OPTIMIZED_HALLOWEEN_PROTECTION'))


---

UPDATE humanresources.employee 
SET VacationHours = VacationHours +5
WHERE VacationHours < 10


update sales.SalesOrderDetail set unitprice = UnitPrice+0.1
where unitprice < 2


update sales.SalesOrderDetail set unitprice = UnitPrice+0.1
where unitprice < 2
OPTION (USE HINT('ENABLE_OPTIMIZED_HALLOWEEN_PROTECTION'))