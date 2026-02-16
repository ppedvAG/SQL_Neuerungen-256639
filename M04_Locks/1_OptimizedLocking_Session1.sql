-----------------------------------------------------------------------
-- LOCK AFTER QUALIFICATION
------------------------------------------------------------------------

--Session1
DROP TABLE IF EXISTS T1
CREATE TABLE t1
(
a int NOT NULL,
b int NULL
);

INSERT INTO t1
VALUES (1,10),(2,20),(3,30);
GO


--Session 1
BEGIN TRANSACTION;
UPDATE t1 SET b = b + 10
WHERE a = 1;

--Session 2 ausführen


--Session 1
Commit


-- Session 2 



--LAQ erkennt.. daher gleichzeitige Änderung an verscbhiedenen Datensätzen 
-- ohne Indizes
DROP TABLE IF EXISTS T3


--------------------------------------------------------------
-- DEMO 3
--------------------------------------------------------------



CREATE TABLE t3
(
a int NOT NULL,
b int NULL
);

INSERT INTO t3 VALUES (1,10),(2,20),(3,30);
GO


--Session 1
BEGIN TRANSACTION;
UPDATE t3
SET b = b + 10
WHERE a = 1;

--Session 2



--Session 1
select * from t3
COMMIT TRANSACTION;


--Session 2
select * from t3
COMMIT TRANSACTION;







rollback


/*

LCK_M_S_XACT_READ – Tritt auf, wenn eine Query auf eine freigegebene Sperre 
    eines XACTwait_resource-Typs wartet, mit der Absicht zu lesen.
LCK_M_S_XACT_MODIFY – Tritt auf, wenn eine Query auf eine freigegebene Sperre 
    eines XACTwait_resource-Typs wartet, mit der Absicht, sie zu ändern.
LCK_M_S_XACT – Tritt auf, wenn eine Query auf eine freigegebene Sperre 
    eines XACTwait_resource-Typs wartet, bei dem die Absicht 
    nicht abgeleitet werden kann. Dieses Szenario ist nicht üblich.

*/