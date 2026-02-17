/* =============================================
   Thema:

   Mit SQL 2025 wurde Json als nativer Datentyp eingeführt. 
   Das bedeutet, dass SQL Server jetzt echte JSON-Daten 
   speichern und validieren kann, anstatt sie nur als Text 
   zu behandeln. 
   
   In diesem Demo-Skript zeige ich die Unterschiede zwischen 
   der bisherigen Handhabung von JSON in SQL Server (bis 2022) 
   und den neuen Möglichkeiten ab SQL 2025.
   ============================================= */

USE TESTDB
GO
--SQL 2016 keine Fehlermeldung
--SQL 2022 --Error

-- Tabelle mit JSON-Daten in einer NVARCHAR-Spalte
CREATE TABLE Orders (
    Id INT PRIMARY KEY,
    OrderData NVARCHAR(MAX) -- enthält JSON, aber SQL Server weiß es nicht!
);

-- Einfügen von JSON (SQL prüft nicht, ob das gültig ist!)
INSERT INTO Orders (Id, OrderData)
VALUES (1, N'{"Customer":"Alice","Amount":99.5}'),
       (2, N'INVALID JSON DATA');

-- Auslesen eines Werts aus JSON
SELECT 
    Id,
    JSON_VALUE(OrderData, '$.Customer') AS CustomerName 
FROM Orders
where ID = 1

-- In einzelne Zeilen zerlegen
SELECT 
    Id,    [Key],
    Value 
FROM Orders
CROSS APPLY OPENJSON(OrderData) --gibt Key-Value Paare zurück
where ID = 1;

--ab SQL 2022: ISJSON Funktion prüft, ob der Inhalt gültiges JSON ist
CREATE TABLE TestJSON (
    ID INT IDENTITY PRIMARY KEY,
    JSONData NVARCHAR(MAX)
);

INSERT INTO TestJSON (JSONData) VALUES
('{"name": "Alice", "age": 30}'),          -- Gültiges JSON
('{"name": "Bob", "city": "Berlin"}'),     -- Gültiges JSON
('Invalid JSON'),                          -- Ungültig
('{"key": "value"'),                       -- Ungültig (fehlende schließende Klammer)
('{"array": [1, 2, 3]}');                  -- Gültiges JSON

SELECT 
    ID,    JSONData,
    ISJSON(JSONData) AS IsValidJSON
FROM TestJSON;

SELECT 
    ID,    JSONData,
    ISJSON(JSONData) AS IsValidJSON,
    CASE 
        WHEN ISJSON(JSONData) = 1 
        THEN JSON_VALUE(JSONData, '$.name') 
        ELSE 'Invalid' 
    END AS Name
FROM TestJSON;

---Typenprüfung
drop table if exists TestJSONTypes;
GO

CREATE TABLE TestJSONTypes 
(
    ID INT IDENTITY PRIMARY KEY,
    Description NVARCHAR(100),
    JSONData NVARCHAR(MAX)
);



INSERT INTO TestJSONTypes (Description, JSONData) VALUES
-- SCALAR Werte
('String scalar', '"Hello World"'),
('Number scalar', '42'),
('Boolean scalar', 'true'),
('Null scalar', 'null'),

-- ARRAY Werte
('Simple array', '[1, 2, 3, 4]'),
('String array', '["apple", "banana", "cherry"]'),
('Mixed array', '[1, "two", true, null]'),
('Nested array', '[1, [2, 3], 4]'),

-- OBJECT Werte
('Simple object', '{"name": "Alice", "age": 30}'),
('Nested object', '{"person": {"name": "Bob", "address": {"city": "Berlin"}}}'),
('Object with array', '{"users": ["Alice", "Bob", "Charlie"]}'),

-- VALUE (beliebiger gültiger JSON-Wert)
('String value', '"A string"'),
('Number value', '123.45'),
('Object value', '{"key": "value"}'),
('Array value', '[1, 2, 3]'),

-- Ungültige JSON-Formate
('Invalid JSON', 'Invalid JSON'),
('Missing comma', '{"name": "John" "age": 30}'),
('Unclosed array', '[1, 2, 3'),
('Unclosed object', '{"name": "John"'),
('Trailing comma', '{"name": "John",}');


SELECT 
    ID,    Description,    JSONData,
    ISJSON(JSONData) AS IsValidJSON
FROM TestJSONTypes;

--ISJSON prüft nicht nur, ob es sich um gültiges JSON handelt, 
--sondern auch, ob es sich um ein bestimmtes JSON-Format handelt 
--(OBJECT, ARRAY, VALUE, SCALAR).
-- Das ermöglicht eine genauere Validierung und Verarbeitung der Daten.
SELECT 
    ID,    Description,    JSONData,
    ISJSON(JSONData) AS IsValidJSON,
    ISJSON(JSONData, OBJECT) AS IsObject,
    ISJSON(JSONData, ARRAY) AS IsArray,
    ISJSON(JSONData, VALUE) AS IsValue,
    ISJSON(JSONData, SCALAR) AS IsScalar
FROM TestJSONTypes
WHERE ISJSON(JSONData) = 1;


--Folgende Abfrage zeigt
-- wie man die verschiedenen JSON-Formate abfragen kann
-- SCALAR Werte können direkt mit JSON_VALUE abgefragt werden,
-- ARRAY Werte können mit JSON_QUERY abgefragt werden,
-- OBJECT Werte können mit JSON_VALUE oder JSON_QUERY abgefragt werden, je nachdem
-- was benötigt wird.
--

SELECT 
    ID,    Description,    JSONData,
    ISJSON(JSONData) AS IsValidJSON,
    CASE 
        WHEN ISJSON(JSONData, SCALAR) = 1 
        THEN JSON_VALUE(JSONData, '$') 
        ELSE NULL 
    END AS ScalarValue,
    CASE 
        WHEN ISJSON(JSONData, ARRAY) = 1 
        THEN JSON_QUERY(JSONData, '$') 
        ELSE NULL 
    END AS ArrayValue,
    CASE 
        WHEN ISJSON(JSONData, OBJECT) = 1 
        THEN JSON_VALUE(JSONData, '$.name') 
        ELSE NULL 
    END AS NameFromObject
FROM TestJSONTypes
WHERE ISJSON(JSONData) = 1;


---SQL 2025: Echter JSON-Datentyp
-- Ab SQL 2025 gibt es einen nativen JSON-Datentyp, 
--der die Validierung von JSON-Daten direkt auf Spaltenebene ermöglicht.
-- Das bedeutet, dass ungültige JSON-Daten nicht mehr gespeichert werden können.
-- Außerdem können JSON-Daten effizienter gespeichert und abgefragt werden,
-- da SQL Server jetzt weiß, dass es sich um JSON handelt und 
--entsprechende Optimierungen vornehmen kann.


-- Neue Tabelle mit echtem JSON-Datentyp
CREATE TABLE Orders2025 (
    Id INT PRIMARY KEY,
    OrderData JSON
);

-- Gültiges JSON wird akzeptiert
INSERT INTO Orders2025 (Id, OrderData)
VALUES (1, '{"Customer":"Alice","Amount":99.5}');

-- Ungültiges JSON wird abgelehnt!
INSERT INTO Orders2025 (Id, OrderData)
VALUES (2, 'INVALID JSON DATA'); 
-- -> Fehler: Ungültiges JSON

-- Auslesen ist genauso möglich wie bisher:
SELECT 
    Id,
    JSON_VALUE(OrderData, '$.Customer') AS CustomerName
FROM Orders2025;

-- Neuer, direkter Index auf JSON-Pfad:
CREATE JSON INDEX IX_Orders_CustomerName
ON Orders2025 (OrderData)

DROP  INDEX IX_Orders_CustomerName ON Orders2025;

--auch auf Pfade möglich

CREATE JSON INDEX jIX_Orders_CustomerName
    ON Orders2025 (Orderdata)
    FOR ('$.customer') WITH (FILLFACTOR = 80);

