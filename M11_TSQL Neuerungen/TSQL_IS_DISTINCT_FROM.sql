--Unterschiede in Spalten feststellen

-- Früher musste man mit <> unertsuchen. Allerdings ist ein Vergleich 
-- mit < oder > immer NULL bei NULL Werten. Daher war ein weniger performante
-- Abfrage notwendig


SELECT * FROM orders
WHERE orderdate <> shippeddate 
   OR (orderdate IS NULL AND shippeddate IS NOT NULL)
   OR (orderdate IS NOT NULL AND shippeddate IS NULL);


select * from orders where orderdate is distinct from shippeddate


select * from orders where orderdate is not distinct from shippeddate