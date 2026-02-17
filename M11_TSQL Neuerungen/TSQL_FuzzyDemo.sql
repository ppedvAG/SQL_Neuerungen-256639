/* =============================================
   Thema:

   Fuzzy Logik und String-Ähnlichkeit in SQL Server

   Die beiden Funktionen EDIT_DISTANCE und 
   JARO_WINKLER_SIMILARITY sind nützlich, um die 
   Ähnlichkeit zwischen zwei Zeichenketten zu bewerten.

   Der Unterschied zwischen beiden Funktionen liegt
   in der Art und Weise, wie die Ähnlichkeit berechnet wird:
   
- EDIT_DISTANCE: Berechnet die minimale Anzahl von 
	 Operationen (Einfügen, Löschen, Ersetzen), die 
	 erforderlich sind, um eine Zeichenkette in eine 
	 andere zu transformieren. Je kleiner der Wert, 
	 desto ähnlicher sind die beiden Zeichenketten.

- JARO_WINKLER_SIMILARITY: Berechnet die Ähnlichkeit
	 zwischen zwei Zeichenketten basierend auf der Anzahl
	 und der Reihenfolge der übereinstimmenden Zeichen.
	 Der Wert liegt zwischen 0 und 1, wobei 1 bedeutet,
	 dass die Zeichenketten identisch sind, und 0 bedeutet,
	 dass sie völlig unterschiedlich sind.

   ============================================= */

SELECT EDIT_DISTANCE('kitten', 'sitting') AS EditDistance;

SELECT EDIT_DISTANCE('ALKI', 'ALFKI') 

--Warum 3 ?
--k statt s, i entfernen, , e statt i, g entfernen
--k durch s ersetzen  sitten
--e durch i ersetzen sittin
--g hinzufügen sitting

--Wie ähnlich?

SELECT EDIT_DISTANCE_SIMILARITY('kitten', 'sitting') AS EditDistance;

SELECT EDIT_DISTANCE_SIMILARITY('Hallo', 'Hello') AS EditDistance;
SELECT EDIT_DISTANCE_SIMILARITY('Hallo', 'Halli') AS EditDistance;

SELECT EDIT_DISTANCE_SIMILARITY('Maier', 'Meier') AS EditDistance;
SELECT EDIT_DISTANCE_SIMILARITY('Mayer', 'Meier') AS EditDistance;



SELECT JARO_WINKLER_SIMILARITY('kitten', 'sitting') AS EditDistance;

SELECT JARO_WINKLER_SIMILARITY('Hallo', 'Hello') ,
	   JARO_WINKLER_SIMILARITY('Hallo', 'Halli') ,
	   EDIT_DISTANCE_SIMILARITY('Mayer', 'Meier'),
	   EDIT_DISTANCE('ALKI', 'ALFKI') 


SELECT JARO_WINKLER_SIMILARITY('Hallo', 'Halli') AS EditDistance;

SELECT JARO_WINKLER_DISTANCE('Hallo', 'Hello') AS EditDistance;

SELECT JARO_WINKLER_DISTANCE('ALKI', 'ALFKI') AS EditDistance;





