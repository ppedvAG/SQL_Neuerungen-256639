/* =============================================
   Thema:

    DATE_Bucket ist eine Funktion, die in SQL Server 2022 eingeführt wurde 
    und es ermöglicht, Datums- und Uhrzeitwerte in benutzerdefinierte Zeitintervalle 
    zu gruppieren. 
   ============================================= */



-- date_bucket (datepart, interval, date)
-- datepart: Gibt die Zeiteinheit an, z.B. minute, hour, day, etc.
-- interval: Gibt die Länge des Intervalls an, z.B. 15 für 15 Minuten, 1 für 1 Stunde, etc.
-- date: Das Datum, das gruppiert werden soll. Die Funktion 
---- gibt den Startzeitpunkt des Intervalls zurück, in dem das Datum liegt.

create table SensorLog
(
    SensorID int,
    Timestamp datetime,
    SensorValue float
);

-- 1. Tabelle erstellen
CREATE TABLE SensorLog (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Timestamp DATETIME2,
    SensorValue DECIMAL(10, 2)
);

-- 2. Beispieldaten generieren (120 Zeilen = 2 Stunden im Minutentakt)
WITH CTE_Numbers AS (
    SELECT 0 AS n
    UNION ALL
    SELECT n + 1 FROM CTE_Numbers WHERE n < 119
)
INSERT INTO SensorLog (Timestamp, SensorValue)
SELECT 
    DATEADD(minute, n, '2025-05-01 10:00:00'), -- Startzeitpunkt
    ROUND(20 + (RAND(CHECKSUM(NEWID())) * 5), 2) -- Zufallswert zwischen 20.00 und 25.00
FROM CTE_Numbers
OPTION (MAXRECURSION 120);

-- 3. Überprüfung: Die Daten mit DATEBUCKET gruppieren
SELECT 
    DATE_BUCKET(minute, 15, Timestamp) AS BucketStart,
    COUNT(*) AS DatensätzeImBucket,
    AVG(SensorValue) AS DurchschnittsWert
FROM SensorLog
GROUP BY DATE_BUCKET(minute, 15, Timestamp)
ORDER BY BucketStart;



select * from SensorLog order by Timestamp;
SELECT 
    DATE_BUCKET(minute, 15, Timestamp) AS BucketStart,
    AVG(SensorValue) AS Durchschnittswert
FROM SensorLog
GROUP BY DATEBUCKET(minute, 15, Timestamp)
ORDER BY BucketStart;