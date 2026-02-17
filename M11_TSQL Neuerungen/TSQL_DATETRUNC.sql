/* =============================================
   Thema:

   DATETRUNC() function
   DAte_trunc kannt in SQL Server 2025 verwendet werden, 
   um ein Datum auf die angegebene Genauigkeit zu kürzen. 
   Es unterstützt verschiedene Zeitintervalltypen wie 
   Jahr, Quartal, Monat, Woche, Tag, Stunde, 
   Minute, Sekunde, Millisekunde und Mikrosekunde.

   ============================================= */

DECLARE @d datetime2 = '2021-12-08 11:30:15.1234567';
SELECT 'Year', DATETRUNC(year, @d);
SELECT 'Quarter', DATETRUNC(quarter, @d);
SELECT 'Month', DATETRUNC(month, @d);
SELECT 'Week', DATETRUNC(week, @d); -- Using the default DATEFIRST setting value of 7 (U.S. English)
SELECT 'Iso_week', DATETRUNC(iso_week, @d);
SELECT 'DayOfYear', DATETRUNC(dayofyear, @d);
SELECT 'Day', DATETRUNC(day, @d);
SELECT 'Hour', DATETRUNC(hour, @d);
SELECT 'Minute', DATETRUNC(minute, @d);
SELECT 'Second', DATETRUNC(second, @d);
SELECT 'Millisecond', DATETRUNC(millisecond, @d);
SELECT 'Microsecond', DATETRUNC(microsecond, @d);