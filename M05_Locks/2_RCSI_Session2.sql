USE TESTDB;
GO

UPDATE Konto SET Saldo = 200;


-- Kein Warten, da keine Locks!


-- (Commit passiert sofort)