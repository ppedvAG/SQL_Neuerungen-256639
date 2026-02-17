DROP TABLE IF EXISTS Production.ProductDescriptionEmbeddings;
GO
CREATE TABLE Production.ProductDescriptionEmbeddings
( 
  ProductDescEmbeddingID INT IDENTITY NOT NULL PRIMARY KEY CLUSTERED,
  ProductID INT NOT NULL,
  ProductDescriptionID INT NOT NULL,
  ProductModelID INT NOT NULL,
  CultureID nchar(6) NOT NULL,
  Embedding vector(1536),
  );


INSERT INTO Production.ProductDescriptionEmbeddings
SELECT p.ProductID, pmpdc.ProductDescriptionID, pmpdc.ProductModelID, pmpdc.CultureID, 
AI_GENERATE_EMBEDDINGS(pd.Description USE MODEL OpenAITextEmbedding3Small)
FROM Production.ProductModelProductDescriptionCulture pmpdc
	JOIN Production.Product p
		ON pmpdc.ProductModelID = p.ProductModelID
	JOIN Production.ProductDescription pd
		ON pd.ProductDescriptionID = pmpdc.ProductDescriptionID
ORDER BY p.ProductID;
GO

alter table Production.ProductDescriptionEmbeddings
add EmbOllama vector (1024)

update Production.ProductDescriptionEmbeddings
set EmbOllama=
AI_GENERATE_EMBEDDINGS(pd.Description USE MODEL MixedBreadEmbeddings)
FROM Production.ProductModelProductDescriptionCulture pmpdc
	JOIN Production.Product p
		ON pmpdc.ProductModelID = p.ProductModelID
	JOIN Production.ProductDescription pd
		ON pd.ProductDescriptionID = pmpdc.ProductDescriptionID
ORDER BY p.ProductID	


CREATE VECTOR INDEX product_vector_index 
ON Production.ProductDescriptionEmbeddings (Embedding)
WITH (METRIC = 'cosine', TYPE = 'diskann', MAXDOP = 8);
GO

CREATE VECTOR INDEX product_vector_indexOL 
ON Production.ProductDescriptionEmbeddings (EmbOllama)
WITH (METRIC = 'cosine', TYPE = 'diskann', MAXDOP = 8);
GO

--Proc zum Finden


CREATE OR ALTER procedure [find_relevant_products_vector_search]
	@prompt nvarchar(max), -- NL prompt
	@stock smallint = 500, -- Only show product with stock level of >= 500. User can override
	@top int = 10, -- Only show top 10. User can override
	@min_similarity decimal(19,16) = 0.3 -- Similarity level that user can change but recommend to leave default
AS
IF (@prompt is null) RETURN;

DECLARE @retval int, @vector vector(1536);

SELECT @vector = AI_GENERATE_EMBEDDINGS(@prompt USE MODEL OpenAITextEmbedding3Small);

IF (@retval != 0) RETURN;

SELECT p.Name as ProductName, pd.Description as ProductDescription, p.SafetyStockLevel as StockLevel, s.distance
FROM vector_search(
	table = Production.ProductDescriptionEmbeddings as t,
	column = Embedding,
	similar_to = @vector,
	metric = 'cosine',
	top_n = @top
	) as s
JOIN Production.ProductDescriptionEmbeddings pe
ON t.ProductDescEmbeddingID = pe.ProductDescEmbeddingID
JOIN Production.Product p
ON pe.ProductID = p.ProductID
JOIN Production.ProductDescription pd
ON pd.ProductDescriptionID = pe.ProductDescriptionID
WHERE (1-s.distance) > @min_similarity
AND p.SafetyStockLevel >= @stock
ORDER by s.distance;
GO


--Proc Ollama
CREATE OR ALTER procedure [find_relevant_products_vector_searchOL]
@prompt nvarchar(max), -- NL prompt
@stock smallint = 500, -- Only show product with stock level of >= 500. User can override
@top int = 10, -- Only show top 10. User can override
@min_similarity decimal(19,16) = 0.3 -- Similarity level that user can change but recommend to leave default
AS
IF (@prompt is null) RETURN;

DECLARE @retval int, @vector vector(1024);

SELECT @vector = AI_GENERATE_EMBEDDINGS(@prompt USE MODEL MixedBreadEmbeddings);

IF (@retval != 0) RETURN;

SELECT p.Name as ProductName, pd.Description as ProductDescription, p.SafetyStockLevel as StockLevel,s.distance
FROM vector_search(
	table = Production.ProductDescriptionEmbeddings as t,
	column = EmbOllama,
	similar_to = @vector,
	metric = 'cosine',
	top_n = @top
	) as s
JOIN Production.ProductDescriptionEmbeddings pe
ON t.ProductDescEmbeddingID = pe.ProductDescEmbeddingID
JOIN Production.Product p
ON pe.ProductID = p.ProductID
JOIN Production.ProductDescription pd
ON pd.ProductDescriptionID = pe.ProductDescriptionID
WHERE (1-s.distance) > @min_similarity
AND p.SafetyStockLevel >= @stock
ORDER by s.distance;
GO



---------------------------------------------------------------------
---------------------------------------------------------------------

EXEC find_relevant_products_vector_search
@prompt = N'Show me stuff for extreme outdoor sports',
@stock = 100, 
@top = 20;
GO

EXEC find_relevant_products_vector_searchOL
@prompt = N'Produkte für regen',
@stock = 100, 
@top = 20;
GO


-- Do the same prompt but in Chinese
EXEC find_relevant_products_vector_search
@prompt = N'请向我展示极限户外运动的装备',
@stock = 100,
@top = 20;
GO


EXEC find_relevant_products_vector_search
@prompt = N'Show me Tshirts for men',
@stock = 1,
@top = 20;
GO


EXEC find_relevant_products_vector_searchOL
@prompt = N'Show me Tshirts for men',
@stock = 1,
@top = 20;
GO


