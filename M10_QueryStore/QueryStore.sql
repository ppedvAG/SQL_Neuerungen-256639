--der QueryStore zeichnet nicht jede Abfrage auf
-- unbedeutendes wird ignoeriert, damit die wichtigen 
-- Abfragen schneller gefunden werden können.
--Allerdings aknn man das umsetllen.. und mittlerweile auch 
-- im SSMS 22 

ALTER DATABASE AdentureWorksLT2025 
SET QUERY_STORE (QUERY_CAPTURE_MODE = ALL);

--Man  kann auch nach AI_GENERATE_EMBEDDING suchen, um zu sehen, 
-- ob diese Funktion in den Abfragen verwendet wird.


SELECT * FROM sys.query_store_query_text 
WHERE query_sql_text LIKE '%AI_GENERATE_EMBEDDING%';

--Manchmal muss man den Query Store leeren, 
-- um die neuesten Abfragen zu sehen.
EXEC sp_query_store_flush_db;

SELECT actual_state_desc, readonly_reason 
FROM sys.database_query_store_options;

SELECT TOP 10
    q.query_id,
    qt.query_sql_text,
    CAST(rs.last_execution_time AS datetime2) AS LetzteAusfuehrung,
    rs.count_executions AS AnzahlAufrufe,
    rs.avg_duration / 1000.0 AS Durchschnitt_Gesamt_Dauer_ms,
    -- Wir holen die durchschnittliche Wartezeit aus den Wait Stats
    (SELECT AVG(avg_query_wait_time_ms) 
     FROM sys.query_store_wait_stats ws 
     WHERE ws.plan_id = p.plan_id 
     AND ws.wait_category_desc = 'External_Resource') AS Durchschnitt_Wartezeit_Ollama_ms
FROM sys.query_store_query q
JOIN sys.query_store_query_text qt ON q.query_text_id = qt.query_text_id
JOIN sys.query_store_plan p ON q.query_id = p.query_id
JOIN sys.query_store_runtime_stats rs ON p.plan_id = rs.plan_id
WHERE qt.query_sql_text LIKE '%sp_invoke_external_rest_endpoint%'
  AND qt.query_sql_text NOT LIKE '%sys.query_store_query_text%'
ORDER BY rs.avg_duration DESC;