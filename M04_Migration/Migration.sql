--Servereinstellungen des alten Servers herausfinden
-Logins

--sp Help_revlogin

SELECT 
    'EXEC sp_configure ''' + name + ''', ' + CAST(value_in_use AS NVARCHAR(MAX)) + ';' + 
    CASE WHEN is_dynamic = 1 THEN '' ELSE ' -- Erfordert Neustart!' END
FROM sys.configurations
WHERE name IN (
    'max degree of parallelism', 
    'max server memory (MB)', 
    'min server memory (MB)', 
    'cost threshold for parallelism', 
    'optimize for ad hoc workloads', 
    'remote admin connections', 
    'fill factor (%)'
)
ORDER BY name;

--Veraltete Objekte finden

SELECT instance_name AS 'Feature', cntr_value AS 'Usage_Count'
FROM sys.dm_os_performance_counters
WHERE object_name LIKE '%Deprecated Features%'
AND cntr_value > 0;

--Logins übertragen
sp_help_revlogin;

--Jobs
Job als Skript exportieren

--Hilfreich
https://dbatools.io

--Verwenden des SSMS 22 Migrationsassistenten
https://techcommunity.microsoft.com/t5/sql-server-blog/introducing-the-sql-server-management-studio-22-migration-assistant/ba-p/3662501
https://docs.microsoft.com/en-us/sql/ssms/migration-assistant-overview?view=sql-server-ver16




--Settings einer DB optimieren

USE [IhreDatenbank];
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 8; 
-- Überschreibt den Instanz-Wert nur für diese DB

--Scoped Database Einstellungen prüfen und evtl aktivieren

SELECT name, value, is_value_default 
FROM sys.database_scoped_configurations
ORDER BY name;



--Für KI Integration muss das bisher noch aktiviert werden
ALTER DATABASE SCOPED CONFIGURATION SET PREVIEW_FEATURES = ON;

-- DOP_FEEDBACK und CE_FEEDBACK
-- Prüfen des aktuellen Levels
SELECT name, compatibility_level 
FROM sys.databases WHERE name = 'Northwind';

-- Setzen auf SQL Server 2025 Standard
ALTER DATABASE Northwind SET COMPATIBILITY_LEVEL = 170;

--Aktivieren von :

USE [IhreDatenbank];
GO

-- Degree of Parallelism (DOP) Feedback aktivieren
-- Hilft gegen CPU-Overhead durch zu hohe Parallelisierung
ALTER DATABASE SCOPED CONFIGURATION SET DOP_FEEDBACK = ON;

-- Cardinality Estimator (CE) Feedback aktivieren
-- Korrigiert Fehlannahmen über die Zeilenanzahl in Abfrageplänen
ALTER DATABASE SCOPED CONFIGURATION SET CE_FEEDBACK = ON;

--Prüfen:

SELECT name, value 
FROM sys.database_scoped_configurations
WHERE name IN ('DOP_FEEDBACK', 'CE_FEEDBACK');

--hat es geholfen:
SELECT * FROM sys.query_store_plan_feedback;

--NO_RECOMMENDATION
--FEEDBACK_VALID         Abfrage wurde mehrfach beobachtet und konnt optimierte werden
--VERIFICATION_REGRESSED Optimierung bewirkte das Gegenteil

--Was wurde schlechter: 
SELECT 
    q.query_id,
    t.query_sql_text,
    f.feature_desc,
    f.feedback_data,
    f.state_desc
FROM sys.query_store_plan_feedback f
JOIN sys.query_store_plan p ON f.plan_id = p.plan_id
JOIN sys.query_store_query q ON p.query_id = q.query_id
JOIN sys.query_store_query_text t ON q.query_text_id = t.query_text_id
WHERE f.state_desc = 'VERIFICATION_REGRESSED';
