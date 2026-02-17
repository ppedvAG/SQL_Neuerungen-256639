/* =============================================
   Thema:

   Mit RegEx in SQL Server lassen sich komplexe Muster
   in Zeichenketten erkennen, extrahieren oder ersetzen.

   Es gibt dazu mehrere Funktionen, die in SQL Server 2022 eingeführt wurden:

   - REGEXP_LIKE: Überprüft, ob eine Zeichenkette einem regulären Ausdruck entspricht.
   - REGEXP_REPLACE: Ersetzt Teile einer Zeichenkette, die einem regulären Ausdruck entsprechen.
   - REGEXP_COUNT: Zählt, wie oft ein Muster in einer Zeichenkette vorkommt.
   - REGEXP_INSTR: Gibt die Position des ersten Vorkommens eines Musters in einer Zeichenkette zurück.
   - REGEXP_SUBSTR: Extrahiert einen Teil einer Zeichenkette, der einem regulären Ausdruck entspricht.
   - REGEXP_MATCHES: Gibt alle Übereinstimmungen eines regulären Ausdrucks in einer Zeichenkette zurück.
   - REGEXP_SPLIT_TO_TABLE: Teilt eine Zeichenkette anhand eines regulären Ausdrucks und gibt die Teile als Tabelle zurück.
   
   ============================================= */



drop table if exists kunden;
GO
create table Kunden (id int identity, lastname varchar(50), email nvarchar(100))
GO
insert into kunden
select 'Maier', 'maier@aol.com'
UNION ALL
select 'Schmitt', 'schmitt+shop@outlook.de'
UNION ALL
select 'Huber', 'Franz.huber-sql@sql+days.com'
UNION ALL
select 'Rauch','rauch#and&kollege^Kanzlei@ra-kanzelei.oberbayern.de'
UNION ALL
SELECT 'fUZZY', 'Fuzzy..tom@sql..days-de'



SELECT Email
FROM Kunden
WHERE Email LIKE '%@%.%';

--kommt ein @vor? 
SELECT PATINDEX('%[@]%', 'andreasr@ppedv.de');
SELECT CHARINDEX('@', 'andreasr@ppedv.de');--CHARINDEX: keine WIldcard

--folgend dann mind 2 Zeichen, die nicht mit einem erlaubten Sonderzeichen beginnen dürfen und anschliessend einen Punkt haben, dem.........

--oder so

select email from Kunden
where Email like '[A-Za-z][A-Za-z0-9|.+-_][A-Za-z0-9|.+-_][A-Za-z0-9|.+_]%@[A-Za-z][A-Za-z0-9|-_]%.[A-Za-z][A-Za-z]'


-- Liefert nur Zeilen mit RFC-nah gültigen E-Mail-Adressen
--keine sagt, dass es leicht ist
SELECT Email
FROM dbo.Kunden
WHERE REGEXP_LIKE(Email,'@') -- @irgendwo
		and 
	  REGEXP_LIKE(email,'[^@].*@.*[^@]$') --@ weder zu Beginn und noch am Ende 


SELECT Email
FROM dbo.Kunden
WHERE REGEXP_LIKE(
  Email,
  '^(?:[a-z0-9!#$%&''*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&''*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0B\x0C\x0E-\x1F\x21\x23-\x5B\x5D-\x7F]|\\[\x01-\x09\x0B\x0C\x0E-\x7F])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:\d{1,3}\.){3}\d{1,3}|IPv6:[0-9A-Fa-f:.]+)\])$',  'i'
);

--Sonderzeichen entfernen
SELECT 
  Companyname,
  REGEXP_REPLACE(Companyname, '[^A-Za-z0-9 ]', '', 1,0,'i') AS CleanName
FROM Customers;

select productname
, REGEXP_REPLACE(productname,'coffee|tea','Hot Drinks ',1,1,'i')
, REGEXP_COUNT(productname, 'Coffee|Tea')
, REGEXP_INSTR(productname, 'ff')
, REGEXP_SUBSTR(Productname,'\bc+\w*',1,1,'i')
from products 
where productname like '%tea%' or productname like '%coffee%'
or REGEXP_LIKE(Productname, '''')




Select * from
REGEXP_MATCHES('Willkommen bei den SQLDays','(\bSQL+\w*|Will\w*)')--'#([A-Za-z0-9_]+)');

SELECT *
FROM REGEXP_SPLIT_TO_TABLE('the quick brown fox jumps over the lazy dog', '\s+');


SELECT *
FROM REGEXP_SPLIT_TO_TABLE('the quick brown fox jumps over the lazy dog', '\s*');



^: Markiert den Anfang der Zeichenkette.

[^@]: Sucht nach einem Zeichen, das kein @ ist.

.*: Steht für eine beliebige Anzahl (null oder mehr) von beliebigen Zeichen.

@: Sucht das Literal @.

[^@]: Sucht nach einem Zeichen, das kein @ ist.

\w* Wortzeichen Zahlen, Buchstaben |
$: Markiert das Ende der Zeichenkette.
* 0 bis beliebig viele Zeichen
?
\b = Anker. Gibt Position 