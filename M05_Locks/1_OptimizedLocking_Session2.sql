--Session 2 

BEGIN TRANSACTION;
UPDATE t1 SET b = b + 10
WHERE a = 2;

--zurück aus Session 1:
commit

-----------------------------------------------
--DEMO 3
-----------------------------------------------
BEGIN TRANSACTION;
UPDATE t3
SET b = b + 10
WHERE a = 1;
--muss warten wg identischen Datensatz

--Zurück aus Session 1

select * from t3
COMMIT TRANSACTION;