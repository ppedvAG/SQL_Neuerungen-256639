-- 1. Datenbank erstellen und Kompatibilitätsstufe setzen
ALTER DATABASE DB SET COMPATIBILITY_LEVEL = 170;


-- 2. Preview-Features aktivieren
ALTER DATABASE SCOPED CONFIGURATION SET PREVIEW_FEATURES = ON;
GO


CREATE TABLE textchunk (text_id INT IDENTITY(1,1) PRIMARY KEY, text_to_chunk nvarchar(max));
GO

INSERT INTO textchunk (text_to_chunk)
VALUES
('All day long we seemed to dawdle through a country which was full of beauty of every kind. Sometimes we saw little towns or castles on the top of steep hills such as we see in old missals; sometimes we ran by rivers and streams which seemed from the wide stony margin on each side of them to be subject to great floods.'),
('My Friend, Welcome to the Carpathians. I am anxiously expecting you. Sleep well to-night. At three to-morrow the diligence will start for Bukovina; a place on it is kept for you. At the Borgo Pass my carriage will await you and will bring you to me. I trust that your journey from London has been a happy one, and that you will enjoy your stay in my beautiful land. Your friend, DRACULA')
GO



SELECT c.*
FROM textchunk t
CROSS APPLY
   AI_GENERATE_CHUNKS(source = text_to_chunk, chunk_type = FIXED, chunk_size = 150, enable_chunk_set_id = 1) c



