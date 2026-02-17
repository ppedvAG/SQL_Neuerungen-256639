/*
Security

Sicherheitscache

SQL Server 2025 führt mit dem Sicherheitscache (Security Cache) eine wichtige Optimierung
im Bereich Zugriffsberechtigungen ein. 
Ziel ist es, die Leistung bei der Abfrageausführung zu verbessern
, indem Berechtigungsinformationen zwischengespeichert werden
, anstatt sie bei jeder Abfrage vollständig neu zu berechnen.
Hier ist eine strukturierte Erklärung:

🔐 Was ist der Sicherheitscache?
Der Sicherheitscache speichert Berechtigungen
(z. B. auf Spalten-, Tabellen- oder Schemaebene) für einen Benutzer 
oder eine Anmeldung. Damit entfällt die wiederholte, 
teure Berechnung dieser Rechte bei jeder einzelnen Abfrage. 
Stattdessen kann SQL Server direkt auf zwischengespeicherte 
Berechtigungsergebnisse zugreifen, was besonders bei vielen 
gleichartigen Anfragen zu einer deutlichen Performanceverbesserung führt.

Was bringt der neue Sicherheitscache?
Mit dem Sicherheitscache entfällt ein Großteil der wiederholten Arbeit:

Zwischenspeicherung der Berechtigungsstruktur je Benutzer + Objekt

Schnellere Prüfung durch Lookup im Cache statt vollständiger Berechnung

Reduzierter Aufwand bei mehrfach ausgeführten Abfragen

---------------------------------------------------------------------------

Das Datenbankmodul organisiert eine hierarchische Sammlung von Entitäten
, die als sicherungsfähige Elemente bezeichnet werden
, die mit Berechtigungen gesichert werden können. 
Die bekanntesten sicherungsfähigen Elemente sind Server und Datenbanken
, aber Berechtigungen können auch auf einer feineren Ebene festgelegt werden. 
SQL Server kontrolliert die Aktionen von Benutzern auf Sicherungsobjekte,
indem sichergestellt wird, dass sie über die entsprechenden Berechtigungen verfügen.

Das folgende Diagramm zeigt, dass ein Benutzer, Alice
, eine Anmeldung auf Serverebene hat, und drei verschiedene Benutzer
, die der gleichen Anmeldung bei jeder anderen Datenbank zugeordnet sind.

Diagramm stellt dar, dass Alice eine Anmeldung auf Serverebene haben kann
, und drei verschiedene Benutzer
, die der gleichen Anmeldung in jeder der verschiedenen Datenbanken zugeordnet sind.

GRAFIK


Für SQL Server umfassen die Aufgaben ohne Sicherheitscache Folgendes:

1. Stellen Sie eine Verbindung mit der Instanz her.
2. Führen Sie die Anmeldeüberprüfung aus.
3. Erstellen Sie das Sicherheitskontexttoken und das Anmeldetoken. Details zu diesen Token werden im nächsten Abschnitt erläutert.
4. Stellen Sie eine Verbindung mit der -Datenbank her.
5. Erstellen Sie ein Datenbankbenutzertoken innerhalb der Datenbank.
6. Überprüfen Sie die Mitgliedschaft von Datenbankrollen. Beispielsweise db_datareader, db_datawriter oder db_owner.
7. Überprüfen Sie die Benutzerberechtigungen für alle Spalten, z. B. die Berechtigungen des Benutzers für t1.Column1 und t2.Column1.
8. Überprüft Benutzerberechtigungen für alle Tabellen, wie table1 und table2, und Schemaberechtigungen für Schema1 und Schema2.
9. Überprüft Datenbankberechtigungen.

SQL Server wiederholt den Prozess für jede einzelne Rolle
, zu der der Benutzer gehört. Sobald alle Berechtigungen abgerufen wurden
, führt der Server eine Überprüfung durch, um sicherzustellen
, dass der Benutzer über alle erforderlichen Berechtigungen
in der Kette verfügt und nicht über einen einzigen Verweigerungsfall
in der Kette verfügt. Nach Abschluss der Berechtigungsprüfung beginnt
die Abfrageausführung.



NEU SICHERHEITSCACHE

Der Sicherheitscache speichert Berechtigungen für einen Benutzer 
oder eine Anmeldung für verschiedene sicherungsfähige Objekte 
in einer Datenbank oder einem Server. Einer der Vorteile besteht darin
, dass die Abfrageausführung beschleunigt wird. 
Bevor SQL Server eine Abfrage ausführt, überprüft er
, ob der Benutzer über die erforderlichen Berechtigungen 
für unterschiedliche Datenbanksicherheiten verfügt
, z. B. Berechtigungen auf Schemaebene
, Berechtigungen auf Tabellenebene und Spaltenberechtigungen.

Sicherheitscacheobjekte
Damit der Workflow im vorherigen Abschnitt schneller erläutert wird
, speichert SQL Server viele verschiedene Objekte innerhalb von Sicherheitscaches
zwischen. Einige der zwischengespeicherten Objekte umfassen:

BESCHREIBUNG
SecContextToken	Der serverweite Sicherheitskontext für einen Prinzipal 
	wird in dieser Struktur gespeichert. Sie enthält eine Hashtabelle von 
	Benutzertoken und dient als Ausgangspunkt oder Basis für alle anderen Caches. 
	Enthält Verweise auf das Anmeldetoken, das Benutzertoken, den Überwachungscache 
	und den TokenPerm-Cache. Darüber hinaus fungiert sie als Basistoken 
	für eine Anmeldung auf Serverebene.

LoginToken	Ähnlich wie das Sicherheitskontexttoken. 
	Enthält Details zu Hauptbenutzern auf Serverebene. 
	Das Anmeldetoken enthält verschiedene Elemente wie SID, 
	Anmelde-ID, Anmeldetyp, Anmeldename, isDisabled-Status 
	und Server-feste Rollenmitgliedschaft. Darüber hinaus umfasst 
	sie spezielle Rollen auf Serverebene, z. B. Sysadmin und Sicherheitsadministrator.

UserToken	Diese Struktur bezieht sich auf Prinzipale auf Datenbankebene. 
	Sie enthält Details wie Benutzername, Datenbankrollen, SID, Standardsprache
	, Standardschema, ID, Rollen und Name. Es gibt ein Benutzertoken 
	pro Datenbank für eine Anmeldung.

TokenPerm	Zeichnet alle Berechtigungen für ein sicherungsfähiges 
	Objekt für ein UserToken oder SecContextToken auf.

TokenAudit	Schlüssel ist die Klasse und ID eines sicherungsfähigen Objekts. 
	Der Eintrag ist eine Reihe von Listen, die Überwachungs-IDs 
	für jeden auditierbaren Vorgang für ein Objekt enthalten. 
	Die Serverüberwachung basiert auf Berechtigungsprüfungen, 
	wobei jeder überwachte Vorgang, den ein bestimmter Benutzer 
	für ein bestimmtes Objekt hat, detailliert behandelt wird.

TokenAccessResult	Dieser Cache speichert Abfrageberechtigungsüberprüfungsergebnisse 
	für einzelne Abfragen mit einem Eintrag pro Abfrageplan. 
	Es ist der wichtigste und am häufigsten verwendete Cache, 
	da es das erste Mal während der Abfrageausführung überprüft wird. 
	Um zu verhindern, dass Ad-hoc-Abfragen den Cache überfluten, 
	speichert sie nur Abfrageberechtigungsüberprüfungsergebnisse, 
	wenn die Abfrage dreimal ausgeführt wird.

ObjectPerm	Dadurch werden alle Berechtigungen für ein Objekt 
	in der Datenbank für alle Benutzer innerhalb der Datenbank aufgezeichnet. 
	Der Unterschied zwischen TokenPerm und ObjectPerm besteht darin, 
	dass TokenPerm für einen bestimmten Benutzer ist, während 
	ObjectPerm für alle Benutzer in der Datenbank sein


Abfrageleistung, wenn die Größe von TokenAndPermUserStore wächst
Leistungsprobleme, z. B. hohe CPU-Auslastung und erhöhte Arbeitsspeicherauslastung
, können durch übermäßige Einträge im TokenAndPermUserStore-Cache verursacht werden. 
Sql Server bereinigt standardmäßig nur Einträge in diesem Cache
, wenn der interne Speicherdruck erkannt wird. 
Auf Servern mit viel RAM kann der interne Speicherdruck jedoch nicht häufig auftreten. 
Wenn der Cache wächst, erhöht sich die Zeit, 
die für die Suche nach vorhandenen Einträgen erforderlich ist, um wiederzuverwenden. 
Dieser Cache wird von einem Spinlock verwaltet, 
sodass nur ein Thread die Suche gleichzeitig ausführen kann. 
Folglich kann dieses Verhalten zu einer verringerten Abfrageleistung 
und einer höheren CPU-Auslastung führen.

Zwischenlösung
SQL Server stellt zwei Trace Flags (TF) bereit, 
die zum Festlegen eines Kontingents für den TokenAndPermUserStore-Cache verwendet 
werden können. Standardmäßig gibt es kein Kontingent, 
d. h. der Cache kann eine unbegrenzte Anzahl von Einträgen enthalten.

TF 4618: Beschränkt die Anzahl der Einträge im TokenAndPermUserStore auf 1024.
TF 4618 und TF 4610: Beschränkt die Anzahl der Einträge im TokenAndPermUserStore auf 8192. 
	Wenn der Grenzwert für die niedrige Eingabeanzahl von TF 4618 
	andere Leistungsprobleme verursacht, wird empfohlen, 
	die Trace Flags 4610 und 4618 zusammen zu verwenden. 
	

*/