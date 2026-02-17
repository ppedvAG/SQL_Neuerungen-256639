-- Umfangreichers Beispiel mit AI_GENERATE CHUNKS

-- Schritt 1 
-- Daten aufbereiten für Embeddings
-- alle Informationen zu einem Produkt in einem Textblock zusammenfassen, 
-- damit die AI mehr Kontext hat, um relevante Embeddings zu generieren.
-- Zur Übersicht in mehereren Teilschritten:

DROP Table if exists  #Produkte


--Schritt 2: alle wichtigen und beschreibenden Informationen sammeln

;WITH XMLNAMESPACES (
    'http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription' AS p1,
    'http://www.w3.org/1999/xhtml' AS html
)
SELECT 
   p.ProductID, 
   p.name AS ProduktName, p.Color, p.ListPrice, p.Size,p.Weight,pmd.culture,
   isnull( pm.CatalogDescription.value('string((/p1:ProductDescription/p1:Summary/html:p)[1])', 'nvarchar(max)'),'-') AS SummaryText,
   isnull(pm.CatalogDescription.value('string((/p1:ProductDescription/p1:Features)[1])', 'nvarchar(max)'),'-') AS FeaturesText
  ,trim(REPLACE(
                TRANSLATE(Description, ',.;-?', '     '), '', '')) as Description   --entfernen alle Sonderzeichen
 , pc2.Name as MainCategory ,pc1.name as Subcategory
INTO #PRODUKTE
FROM SalesLT.product p 
INNER JOIN SalesLT.ProductModel pm 
    ON p.ProductModelID = pm.ProductModelID
INNER JOIN SalesLT.ProductModelProductDescription pmd
    ON pmd.ProductModelID = pm.ProductModelID 
INNER JOIN SalesLT.ProductDescription pd 
    ON pd.ProductDescriptionID = pmd.ProductDescriptionID
INNER JOIN SalesLT.ProductCategory pc1
    ON p.ProductCategoryID = pc1.ProductCategoryID
inner join SalesLT.ProductCategory pc2 
    on pc1.ParentProductCategoryID= pc2.ProductCategoryID

--Ergebnis
select * from #PRODUKTE

select * from ProductDescriptionChunk

-- Nun Embeddings mit Chunk generieren: 
-- Chunks , also die Häppchen für AI können , wenn sie größer werden in mehrere Teile gesplittet werden
-- zB würde nie ein Buch reinpassen. 
-- Viele KI Modelle haben gebrenzte kapazität Tokens von 512 bis 8192
-- Token , das Sprachatom, hat je nachdem eine bestimmte Länge:
-- nomic-embeded-text / gemma3 1 Token = 4 Zeichen  100 Token = 75 Wörter


-- Alle Infos zu einem Textblock zusammenfassen
-- ProduktID muss als einzelen Spalte stehen bleiben, damit wir die Embeddings zuordnen können
-- Wir nutzen CONCAT, um alle Informationen zu einem Textblock zusammenzufassen
-- COALESCE wird verwendet, um sicherzustellen, dass fehlende Werte durch 'unknown'
-- ersetzt werden, damit die AI immer einen Kontext hat, auch wenn einige Informationen fehlen sollten.

select ProductID,
       CONCAT(
            N'Produkt Name: ', COALESCE(ProduktName, 'unknown'),
            N' | Produkt color: ', coalesce (Color, 'unknown'),
            N' | Produkt size: ', coalesce (Size, 'unknown'),
            N' | Produkt weight: ', coalesce (convert(varchar(50),Weight), 'unknown'),
            N' | Produkt Price: ', coalesce (convert(varchar(10),ListPrice), 'unknown'),
            N' | Produkt Summary: ', coalesce (SummaryText, 'unknown'),
            N' | Produkt Culture: ', coalesce (Culture, 'unknown'),
            N' | Produkt Features: ', coalesce (FeaturesText, 'unknown'),
            N' | Produkt Description: ',coalesce (Description, 'unknown'),
            N' | Maincategory: ', coalesce (MainCategory, 'unknown'),
            N' | Subcategory: ', coalesce (Subcategory, 'unknown')
               ) AS TextForEmbedding 
into #Produktdecscription
from #produkte

select * from #Produktdecscription

--nun wird das Feld TextforEmbedding in chunks geteilt--
--Um die Chunks zusammengehörig zu machen, wird der Parameter overlap verwendet.
-- overlap sorgt dafür, dass sich die Chunks um eine bestimmte Anzahl von Zeichen überschneiden.
drop table if exists ProductDescriptionChunk

Select 
pd.ProductID, c.chunk, c.chunk_set_id as ChunkId --welche Zeilen gehören zueinander
--into ProductDescriptionChunk
FROM #Produktdecscription pd
CROSS APPLY AI_GENERATE_CHUNKS(source=TextForEmbedding, chunk_type=FIXED, chunk_size=250,OVERLAP = 30 ,enable_chunk_set_id=1) AS c
order by 1

-- Embeddings Spalte hinzufügen mit Vector Datentyp
alter table ProductDescriptionChunk 
    add 
            embedding vector(768),
            PDCID int identity(1,1) primary key clustered

-- select * from productdescriptionchunk

--externes Model vorhanden?
select * from sys.external_models
--drop external model ollama


CREATE EXTERNAL MODEL ollama
WITH (
LOCATION = 'https://localhost:11435/api/embed',
API_FORMAT = 'Ollama',
MODEL_TYPE = EMBEDDINGS,
MODEL = 'nomic-embed-text')

UPDATE ProductDescriptionChunk
SET [embedding] = AI_GENERATE_EMBEDDINGS(chunk USE MODEL ollama)

--dauert etwas :-)


-- Vector Index zur schnellen Ähnlichkeitssuche
-- setzt einen Vektorindex auf der Embeddings-Spalte 
-- der ProductDescriptionChunk-Tabelle, um die Suche zu beschleunigen.
-- Voraussetzung ist ein Primary Key auf der Tabelle, 
-- damit der Vektorindex erstellt werden kann.

CREATE VECTOR INDEX vec_idx ON ProductDescriptionChunk(embedding)
WITH (METRIC = 'cosine', TYPE = 'diskann');

declare @search_text nvarchar(max) = 'I am looking for shorts for men in black'
declare @search_vector vector(768) = AI_GENERATE_EMBEDDINGS(@search_text USE MODEL ollama);
SELECT TOP(10)
pc.ProductID,p.name , p.Color, p.Size, p.Weight, p.ListPrice,pc1.name ,
vector_distance('cosine', @search_vector, pc.embedding) AS distance
FROM ProductDescriptionChunk pc inner join SalesLT.product p on pc.ProductID = p.ProductID
inner join salesLT.ProductCategory pc1 on p.ProductCategoryID = pc1.ProductCategoryID
where VECTOR_DISTANCE('cosine', @search_vector, pc.embedding) < 0.4 --nur Ergebnisse mit einer Distanz von unter 0.3 anzeigen
ORDER BY distance;

select * from #PRODUKTE


--Test mit mxbai-emebeded large

alter table ProductDescriptionChunk 
    add 
            embedding2 vector(1024)

CREATE EXTERNAL MODEL ollama2
WITH (
LOCATION = 'https://localhost:11435/api/embed',
API_FORMAT = 'Ollama',
MODEL_TYPE = EMBEDDINGS,
MODEL = 'mxbai-embed-large')

drop index if exists vec_idx on ProductDescriptionChunk

--hier gehts weiter..
UPDATE ProductDescriptionChunk
SET [embedding2] = AI_GENERATE_EMBEDDINGS(chunk USE MODEL ollama2)

create vector index vec_idx2 on ProductDescriptionChunk(embedding2)
WITH (METRIC = 'cosine', TYPE = 'diskann');

declare @search_text nvarchar(max) = 'I am looking black shorts for women'
declare @search_vector vector(1024) = AI_GENERATE_EMBEDDINGS(@search_text USE MODEL ollama2);
SELECT distinct TOP(10) 
pc.ProductID,p.name , p.Color, p.Size, p.Weight, p.ListPrice,pc1.name ,
vector_distance('cosine', @search_vector, pc.embedding2) AS distance
FROM ProductDescriptionChunk pc inner join SalesLT.product p on pc.ProductID = p.ProductID
inner join salesLT.ProductCategory pc1 on p.ProductCategoryID = pc1.ProductCategoryID
where VECTOR_DISTANCE('cosine', @search_vector, pc.embedding2) < 0.4 --nur Ergebnisse mit einer Distanz von unter 0.3 anzeigen
ORDER BY distance;