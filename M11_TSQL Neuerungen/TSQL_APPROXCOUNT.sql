-- der APPROX_COUNT_DISTINCT 

-- anstatt im Arbeitsspeicher eine HASH Tabelle aufzubauen, um dort Duplikate zu finden
-- Algorithmus (HyperLogLog) basiernd auf stat. Wahrscheinlichkeit
-- schneller und spart CPU 

select APPROX_COUNT_DISTINCT(orderid) from [Order Details]

select count(orderid) from [Order Details]

select count(distinct orderid) from [Order Details]