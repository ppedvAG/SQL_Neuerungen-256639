--RCSI_ Session1

USE TESTDB;
GO


BEGIN TRAN


SELECT Saldo FROM Konto;

--Session 2 ausführen

SELECT Saldo FROM Konto;

--geänderter Wert