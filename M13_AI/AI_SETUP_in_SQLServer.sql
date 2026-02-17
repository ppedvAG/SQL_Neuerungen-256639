-- AI Setup für lokale LLM (ollama) in SQL Server 2025

--  REST Endpoint aktivieren
-- der REST Enpoint ermöglicht es, SQL Server über HTTP-Anfragen zu erreichen, 
--  was besonders nützlich für die Integration mit Webanwendungen und APIs ist.
-- der REST Endpoint wird global aktiviert.
use Northwind;

EXECUTE sp_configure 'external rest endpoint enabled', 1;
GO

RECONFIGURE WITH OVERRIDE;
GO

--Prüfung , ob der REST Endpoint aktiviert ist
EXECUTE sp_configure 'external rest endpoint enabled';

--Erstellen eines EXTERNAL MODELS pro Datenbank
-- bestehen in der DB bereits Modelle

select * from sys.external_models
drop external ..


USE Northwind;

CREATE EXTERNAL MODEL ollama
WITH (
LOCATION = 'https://localhost:11435/api/embed',
API_FORMAT = 'Ollama',
MODEL_TYPE = EMBEDDINGS,
MODEL = 'nomic-embed-text'
);

CREATE EXTERNAL MODEL ollama2
WITH (
LOCATION = 'https://localhost:11435/api/embed',
API_FORMAT = 'Ollama',
MODEL_TYPE = EMBEDDINGS,
MODEL = 'mxbai-embed-large'
);

--TESTEN DES MODELLS
select AI_GENERATE_EMBEDDINGS(N'test text' USE MODEL ollama);

--
--TRACE Flags for vector Search
-- Turn on Trace Flags for Vector Search
DBCC TRACEON (466, 474, 13981, -1) 
GO

-- Check trace flags status
DBCC TraceStatus
GO

