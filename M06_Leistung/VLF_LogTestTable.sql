USE TestDB ;
GO
IF OBJECT_ID('dbo.LogTest', 'U') IS NOT NULL 
    DROP TABLE dbo.LogTest ;
--===== AUTHOR: Jeff Moden
--===== Create and populate 1,000,000 row test table.
-- "SomeID" has range of 1 to 1000000 unique numbers
-- "SomeInt" has range of 1 to 50000 non-unique numbers
-- "SomeLetters2";"AA"-"ZZ" non-unique 2-char strings
-- "SomeMoney"; 0.0000 to 99.9999 non-unique numbers
-- "SomeDate" ; >=01/01/2000 and <01/01/2010 non-unique
-- "SomeHex12"; 12 random hex characters (ie, 0-9,A-F) 

BEGIN TRAN
SELECT TOP 1000000
        SomeID = IDENTITY( INT,1,1 ),
        SomeInt = ABS(CHECKSUM(NEWID())) % 50000 + 1 ,
        SomeLetters2 = CHAR(ABS(CHECKSUM(NEWID())) % 26 + 65)
        + CHAR(ABS(CHECKSUM(NEWID())) % 26 + 65) ,
        SomeMoney = CAST(ABS(CHECKSUM(NEWID())) % 10000 / 100.0 AS MONEY) ,
        SomeDate = CAST(RAND(CHECKSUM(NEWID())) * 3653.0 + 36524.0 AS DATETIME) ,
        SomeHex12 = RIGHT(NEWID(), 12)
INTO    dbo.LogTest
FROM    sys.all_columns ac1
        CROSS JOIN sys.all_columns ac2 ;

DBCC SQLPERF(LOGSPACE) ;

SELECT @@TRANCOUNT
ROLLBACK
