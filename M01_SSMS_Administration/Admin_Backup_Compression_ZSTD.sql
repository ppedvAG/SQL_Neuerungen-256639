/*

ZSTD Kompressionsalgorithmus vs MS_XPRESS

Ab SQL Server 2025 (17.x) Preview ist ein neuer Komprimierungsalgorithmus, 
	ZSTD, für die Sicherungskomprimierung verfügbar. 
	Dieser Algorithmus ist schneller und effektiver als der 
	vorherige MS_XPRESS Algorithmus.

Sie können den ZSTD-Algorithmus für die Sicherungskomprimierung 
auf eine der folgenden Arten verwenden:

Indem Sie die WITH COMPRESSION (ALGORITHM = ZSTD) 
	Option im BACKUP-Befehl Transact-SQL für eine bestimmte Sicherung angeben.
	Durch das Festlegen der Serverkonfigurationsoption 
	für den Sicherungskomprimierungsalgorithmus auf 3. 
	Diese Option legt den Standardmäßigen Sicherungskomprimierungsalgorithmus 
	für alle Sicherungen , die die WITH COMPRESSION Option verwenden, auf ZSTD fest.


0 = Die Sicherungskomprimierung ist deaktiviert, angegeben durch die Standardoption für die Sicherungskomprimierung .
1 = SQL Server verwendet den MS_XPRESS Sicherungskomprimierungsalgorithmus (Standard).
2 = SQL Server verwendet den Intel® QAT-Sicherungskomprimierungsalgorithmus.
3 = SQL Server verwendet den ZSTD-Sicherungskomprimierungsalgorithmus.

*/


SELECT value
FROM sys.configurations
WHERE name = 'backup compression algorithm';
GO


EXECUTE sp_configure 'backup compression algorithm', 2;
RECONFIGURE;



SELECT name, backup_size/compressed_backup_size FROM msdb..backupset;


Backup database ppcompany to disk = 'C:\_DBPreview\backup\ppcompstdINTEL.bak'

set statistics  time on
Backup database ppcompany to disk = 'C:\_DBPreview\backup\ppcompstd.bak'
WITH COMPRESSION (ALGORITHM = MS_XPRESS)
--   CPU time = 282 ms,  elapsed time = 7197 ms.

Backup database ppcompany to disk = 'C:\_DBPreview\backup\ppcompZSTD.bak'
WITH COMPRESSION (ALGORITHM = ZSTD)
--   CPU time = 313 ms,  elapsed time = 3931 ms.