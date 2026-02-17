/*

--Verwendung eines Azure OpenAI Modells in SQL Server 2025


KEY: 1conzOy6WZ1iWIjYzfi1QgHIqFT5x5eWI1W9IVfn7mzbBCDg7KahJQQJ99BIACYeBjFXJ3w3AAABACOGTWGT

ENDPOINT
https://aidemo.openai.azure.com/

URI
https://aidemo.openai.azure.com/openai/deployments/text-embedding-3-small/embeddings?api-version=2023-05-15

*/
USE MASTER;
GO

DROP DATABASE IF EXISTS AIAzureDemo
GO

CREATE DATABASE AIAzureDemo
GO

--Der Zugriff auf das Model ist immer verschlüsselt, daher muss ein Master Key erstellt werden, bevor
--eine Database Scoped Credential angelegt werden kann, um die Verbindung zum Azure OpenAI Modell herzustellen.
--Die Database Scoped Credential enthält die Informationen, die SQL Server benötigt, um sich bei Azure OpenAI zu authentifizieren und Zugriff auf das Modell zu erhalten. In diesem Fall verwenden wir die API-Key-Authentifizierung, bei der der API-Schlüssel als geheimes Element in der Credential gespeichert wird.
--Nachdem die Database Scoped Credential erstellt wurde, können wir ein externes Modell registrieren, das auf dem Azure OpenAI Modell basiert. Dabei geben wir die URL des Modells, das API-Format, den Modelltyp, den Modellnamen und die zu verwendende Credential an. In diesem Beispiel registrieren wir ein externes Modell namens "OpenAITextEmbedding3Small", das auf dem "text-embedding-3-small" Modell von Azure OpenAI basiert und für die Generierung von Embeddings verwendet wird.
--Nachdem das externe Modell registriert ist, können wir die Funktion AI_GENERATE_EMBEDDINGS verwenden, um Embeddings für Texte zu generieren. In diesem Beispiel generieren wir ein Embedding für den Text "Das ist ein Text der die Funktion von embedding darstellen soll" unter Verwendung des registrierten Modells "OpenAITextEmbedding3Small".

USE AIAzureDemo
--zuerst Master Key
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'YourStrongPassword!';

-- Create database scoped credential to connect zu Azure Model
CREATE DATABASE SCOPED CREDENTIAL [https://aidemo.openai.azure.com/]
    WITH 
    IDENTITY = 'HTTPEndpointHeaders', 
    secret = '{"api-key":"1conzOy6WZ1iWIjYzfi1QgHIqFT5x5eWI1W9IVfn7mzbBCDg7KahJQQJ99BIACYeBjFXJ3w3AAABACOGTWGT"}';
GO

--korrekt?
select * from sys.database_scoped_credentials

--Externes Model registrieren 
-- Hier registrieren wir ein externes Modell namens "OpenAITextEmbedding3Small", 
-- das auf dem "text-embedding-3-small" Modell von Azure OpenAI basiert und 
-- für die Generierung von Embeddings verwendet wird. 
-- Wir geben die URL des Modells, das API-Format, den Modelltyp, 
-- den Modellnamen und die zu verwendende Credential an. 
-- Die Parameter geben an, dass die generierten Embeddings 1536 Dimensionen haben sollen.

CREATE EXTERNAL MODEL OpenAITextEmbedding3Small
AUTHORIZATION dbo
WITH (
      LOCATION = 'https://aidemo.openai.azure.com/openai/deployments/text-embedding-3-small/embeddings?api-version=2023-05-15',
      API_FORMAT = 'Azure OpenAI',
      MODEL_TYPE = EMBEDDINGS,
      MODEL = 'text-embedding-3-small',
      CREDENTIAL =  [https://aidemo.openai.azure.com/],
      PARAMETERS = '{"Dimensions":1536}'
);

--Kontrolle
select * from sys.external_models

--Mein erster Vektor

select AI_GENERATE_EMBEDDINGS ('Das ist ein Text der die Funtkion von embedding darstellen soll'
USE MODEL OpenAITextEmbedding3Small)


-- Tabelle für Dokumente mit Vektor-Embedding
CREATE TABLE Documents (
    id INT IDENTITY PRIMARY KEY,
    content NVARCHAR(MAX),
    embedding VECTOR(1536)   -- 1536 Dimensionen für Embeddings
);


-- Einfügen eines Beispieldokuments
INSERT INTO Documents (content, embedding)
VALUES ('SQL Server 2025 unterstützt Vektoren für semantische Suche', 
        AI_GENERATE_EMBEDDINGS(N'SQL Server 2025 unterstützt Vektoren für semantische Suche' 
        USE MODEL OpenAITextEmbedding3Small));


--Beispiel mit  AdventureWorks2022

select 
        p.ProductID
    ,    p.name ProduktName
    ,   p.color as Farbe
    ,   pm.Name as Modell
    , pd.Description  as Beschreibung 
INTO Produkte
from   AdventureWorks2022.production.product p 
    inner join      AdventureWorks2022.production.ProductModel pm
on p.ProductModelID=pm.ProductModelID
    inner join      AdventureWorks2022.production.ProductModelProductDescriptionCulture pc
on pc.ProductModelID=pm.ProductModelID
    inner join AdventureWorks2022.production.ProductDescription pd 
on pd.ProductDescriptionID=pc.ProductDescriptionID

--Vaktoren
alter table Produkte add embeddings vector(1536)

--Füllen
update Produkte set embeddings = 
--select 
    AI_GENERATE_EMBEDDINGS(
        CONCAT(
            N'Produkt Name: ', COALESCE(p.produktname, 'unknown'),
            N' | Produkt Farbe: ', coalesce (p.Farbe, 'unknown'),
            N' | Produkt Modell: ', coalesce (p.Modell, 'unknown'),
            N' | Produkt Beschreibung: ',coalesce (p.Beschreibung, 'unknown')
               ) USE MODEL OpenAITextEmbedding3Small 
                            )
 from produkte p


 select * from produkte

 ALTER DATABASE SCOPED CONFIGURATION set PREVIEW_FEATURES = ON

 WITH cte AS (
    SELECT ProductId,ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS NewId
        FROM Produkte
            )
UPDATE cte SET ProductId = NewId;


-- Index zur schnellen Ähnlichkeitssuche
ALTER TABLE dbo.Produkte ADD CONSTRAINT
	PK_Produkte PRIMARY KEY CLUSTERED 	(	ProductID	) 

CREATE VECTOR INDEX vec_idx ON Produkte(embeddings)
WITH (METRIC = 'cosine', TYPE = 'diskann');


DECLARE @SemanticSearchText Nvarchar(max) = 
'I am looking for black shoes for men which i can wear during summer'
 
     
DECLARE @qv VECTOR(1536) = AI_GENERATE_EMBEDDINGS(@SemanticSearchText USE MODEL OpenAITextEmbedding3Small);
 
    SELECT TOP(10) 
      ProduktName, 
      Beschreibung,
      ProductID,
      p.Farbe,
      p.Modell,
      VECTOR_DISTANCE('cosine', @qv, embeddings) AS distance 
    FROM dbo.Produkte p
    
ORDER BY   distance;
