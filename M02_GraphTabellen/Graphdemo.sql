/* =============================================
   Thema: Graphtabellen

   Beschreibung: mit Hilfe von Node und Edge Tabellen
                werden Graphen modelliert

    Node Tabellen werden mit dem Zusatz AS NODE
    erstellt 

    Edge Tabellen werden mit dem Zusatz AS EDGE
    erstellt

    Edgetabellen enthalten keine eigenen
    Primärschlüssel, sondern verweisen auf die
    Knoten (Nodes) über spezielle Spalten
    $from_id und $to_id
    in denen die internen Ids der Knoten
    gespeichert werden.

    Edge Tabellen können beliebige Eigenschaften 
    von Beziehungen zwischen Knoten speichern.

    Edge Tabellen besitzten einen Index auf den Spalten
    $from_id und $to_id. 

    Beispiel: Soziale Netzwerke

   ============================================= */

create database Graphdb
GO

--A---->B
--B<----A

use graphdb
go
drop table if exists person
drop table  if exists friendof

CREATE TABLE Person (
  ID INTEGER PRIMARY KEY,
  name VARCHAR(100)
) AS NODE;


CREATE TABLE friendOf AS EDGE;


INSERT INTO Person VALUES (1,'Stefan');
INSERT INTO Person VALUES (2,'Daniel');
INSERT INTO Person VALUES (3,'John');
INSERT INTO Person VALUES (4,'Mary');
INSERT INTO Person VALUES (5,'Jacob');
INSERT INTO Person VALUES (6,'Julie');
INSERT INTO Person VALUES (7,'Alice');
INSERT INTO Person VALUES (8,'Hans');
INSERT INTO Person VALUES (9,'Max');
INSERT INTO Person VALUES (10,'Susi');


INSERT INTO friendof 
VALUES 
((SELECT $node_id FROM Person WHERE ID = 2), 
 (SELECT $node_id FROM Person WHERE ID = 1));

INSERT INTO friendof 
VALUES 
((SELECT $node_id FROM Person WHERE ID = 3), 
 (SELECT $node_id FROM Person WHERE ID = 2));

INSERT INTO friendof 
VALUES 
((SELECT $node_id FROM Person WHERE ID = 4), 
 (SELECT $node_id FROM Person WHERE ID = 3));


INSERT INTO friendof 
VALUES 
((SELECT $node_id FROM Person WHERE ID = 3), 
 (SELECT $node_id FROM Person WHERE ID = 4));

INSERT INTO friendof 
VALUES 
((SELECT $node_id FROM Person WHERE ID = 5), 
 (SELECT $node_id FROM Person WHERE ID = 4));


INSERT INTO friendof 
VALUES 
((SELECT $node_id FROM Person WHERE ID = 4), 
 (SELECT $node_id FROM Person WHERE ID = 7));

 
INSERT INTO friendof 
VALUES 
((SELECT $node_id FROM Person WHERE ID = 8), 
 (SELECT $node_id FROM Person WHERE ID = 7));



INSERT INTO friendof 
VALUES 
((SELECT $node_id FROM Person WHERE ID = 10), 
 (SELECT $node_id FROM Person WHERE ID = 4));

INSERT INTO friendof 
VALUES 
((SELECT $node_id FROM Person WHERE ID = 10), 
 (SELECT $node_id FROM Person WHERE ID = 8));



  INSERT INTO friendof 
VALUES 
((SELECT $node_id FROM Person WHERE ID = 7), 
 (SELECT $node_id FROM Person WHERE ID = 3));


 select * from friendOf

 --Query auf die Beziehungen

 --Welche direkten Freunde hat John
 --Abfrage in 1ter Linie
SELECT p1.name, p2.name
FROM 
	Person p1, friendof, person p2
WHERE 
	MATCH (p1-(friendof)->p2)
AND p1.name = 'John';

-- Wen kennt Mary
SELECT person.name, p2.name
FROM Person, friendof, person p2
WHERE MATCH (Person-(friendof)->p2)
AND Person.name = 'Mary';

--und wen kennt Jacob in 2ter Linie
 SELECT p1.name, p3.name
FROM Person p1, friendof fo, person p2, friendof fo2, person p3
WHERE MATCH (p1-(fo)->p2-(fo2)->p3)
AND p1.name = 'Jacob';


--Beziehung sind immer einseitig gerichtet
--Daher muss in Edgetabellen die Gegegenrichtung definiert sein, 
--wenn die Beziehung in beide Richtungen gelten soll


--Wen! kennt Mary?
select p1.name, p2.name
from person p1, person p2 , friendof fo, friendof fo2
where match(p1-(fo)->p2-(fo2)->p1) and p1.name = 'mary'

--Wer! kennt Mary?
select p1.name, p2.name
from person p1, person p2 , friendof fo, friendof fo2
where match(p1-(fo)->p2<-(fo2)-p1) and p2.name = 'mary'

--Mit Hilfe von STRING_AGG lassen sich Pfade als Strings darstellen
--Beispiel ohne Graphen

select string_agg(lastname,'; ') from northwind..employees

--Das folgende Statement zeigt alle Freunde von Hans
--unabhängig von der Distanz

SELECT
   Person1.name AS PersonName, 
   STRING_AGG(Person2.name, '->') WITHIN GROUP (GRAPH PATH) AS Friends
FROM
   Person AS Person1,
   friendOf FOR PATH AS fo,
   Person FOR PATH  AS Person2
WHERE MATCH(SHORTEST_PATH(Person1(-(fo)->Person2)+))--Distanz egal
AND Person1.name = 'Hans'


--Nachfolgende Statement zeigt alle Freunde von Hans, die in einer Distanz
--von 1 bis 4 hops entfernt sind
SELECT
   Person1.name AS PersonName, 
   STRING_AGG(Person2.name, '->') WITHIN GROUP (GRAPH PATH) AS Friends
FROM
   Person AS Person1,
   friendOf FOR PATH AS fo,
   Person FOR PATH  AS Person2
WHERE MATCH(SHORTEST_PATH(Person1(-(fo)->Person2){1,4})) --Distanz bestimmen
AND Person1.name = 'Hans'


--Dies folgende Statement zeigt alle kürzesten Wege von Hans zu John
SELECT PersonName, Friends
FROM (  
 SELECT
       Person1.name AS PersonName, 
       STRING_AGG(Person2.name, '->') WITHIN GROUP (GRAPH PATH) AS Friends,
       LAST_VALUE(Person2.name) WITHIN GROUP (GRAPH PATH) AS LastNode
   FROM
       Person AS Person1,
       friendOf FOR PATH AS fo, --muss für die Siche entlang der Kanten/Pfade angegeben werden 
       Person FOR PATH  AS Person2
   WHERE MATCH(SHORTEST_PATH(Person1(-(fo)->Person2)+))
   AND Person1.name = 'Hans'
) AS Q
WHERE Q.LastNode = 'John'



---kürzesten Wege zu allen vernetzten Freunden
SELECT
   Person1.name AS PersonName, 
   STRING_AGG(Person2.name, '->') WITHIN GROUP (GRAPH PATH) AS Friends
FROM
   Person AS Person1,
   friendOf FOR PATH AS fo,
   Person FOR PATH  AS Person2
WHERE MATCH(SHORTEST_PATH(Person1(-(fo)->Person2)+))
AND Person1.name = 'Hans'

--Übung
---kürzesten Wege zu Stefan
SELECT PersonName, Friends, levels
FROM (  
   SELECT
       Person1.name AS PersonName, 
       STRING_AGG(Person2.name, '->') WITHIN GROUP (GRAPH PATH) AS Friends,
       LAST_VALUE(Person2.name) WITHIN GROUP (GRAPH PATH) AS LastNode,
       COUNT(Person2.name) WITHIN GROUP (GRAPH PATH) AS levels
   FROM
       Person AS Person1,
       friendOf FOR PATH AS fo,
       Person FOR PATH  AS Person2
   WHERE MATCH(SHORTEST_PATH(Person1(-(fo)->Person2)+))
   AND Person1.name = 'Hans'
   	) AS Q
WHERE Q.LastNode = 'Stefan'

--alle Freunde von Jacob in ? ter Linie, mit Hilfe einer Unterabfrage
-- gefiltert nach der Anzahl der hops/levels
SELECT PersonName, Friends
FROM (
    SELECT
        Person1.name AS PersonName, 
        STRING_AGG(Person2.name, '->') WITHIN GROUP (GRAPH PATH) AS Friends,
        COUNT(Person2.name) WITHIN GROUP (GRAPH PATH) AS levels
    FROM
        Person AS Person1,
        friendOf FOR PATH AS fo,
        Person FOR PATH  AS Person2
    WHERE MATCH(SHORTEST_PATH(Person1(-(fo)->Person2){1,3}))
    AND Person1.name = 'Jacob'
) Q
WHERE Q.levels = 2



--Kilometer als Eigenschaft in der Node Tabelle Person
alter table person add Distanz int

update Person set Distanz = id % 3
update Person set Distanz = 5 where Distanz = 0

select * from person

--Wie weit entfernt sind die Freunde von Jacob in 1 bis 3ter Linie
SELECT PersonName, Friends, Distanz
FROM (
    SELECT
        Person1.name AS PersonName, 
        STRING_AGG(Person2.name, '->') WITHIN GROUP (GRAPH PATH) AS Friends,
        sum(Person2.Distanz) WITHIN GROUP (GRAPH PATH) AS Distanz
    FROM
        Person AS Person1,
        friendOf FOR PATH AS fo,
        Person FOR PATH  AS Person2
    WHERE MATCH(SHORTEST_PATH(Person1(-(fo)->Person2){1,3}))
    AND Person1.name = 'Jacob'
) Q
WHERE Q.Distanz >1



