--String_Split 

--String_agg

SELECT * FROM STRING_SPLIT('Lorem ipsum dolor sit amet.', ' ');

-- SQL Server 2022+
SELECT * FROM STRING_SPLIT('Lorem ipsum dolor sit amet.', ' ', 1);

Select String_AGG(Categoryname,',') as KAT from categories

-- Der Vorteil gegenüber +
-- Es werden  NULL Werte ignoriert. Am Ende steht kein Trennzeichen
-- Mtit Hilfe von WITHIN GROUP lassen sich die Ergebnisse sortieren


Select String_AGG(Categoryname,', ') WITHIN GROUP (ORDER BY Categoryname) as KAT from categories

