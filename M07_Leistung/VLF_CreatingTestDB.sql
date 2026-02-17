USE master ;

IF EXISTS ( SELECT  name
            FROM    sys.databases
            WHERE   name = 'TestDB' ) 
    DROP DATABASE TestDB ;
GO

CREATE DATABASE TestDB 
GO

DBCC SQLPERF(LOGSPACE) ;

DBCC loginfo('testdb')

Checkpoint