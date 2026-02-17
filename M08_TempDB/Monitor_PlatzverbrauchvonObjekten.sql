USE tempdb;
GO

-- TEIL 2 (KORRIGIERT): Welche Objekte fressen den Platz? (Top 10)
SELECT TOP 10
    [TableName] = t.name,
    [ObjID] = t.object_id,
    [Created] = t.create_date,
    [TotalSizeMB] = CAST((SUM(a.total_pages) * 8.0) / 1024 AS DECIMAL(10,2)),
    [DataSizeMB] = CAST((SUM(a.used_pages) * 8.0) / 1024 AS DECIMAL(10,2)),
    [RowCount] = SUM(p.rows)
FROM sys.tables t
INNER JOIN sys.partitions p ON t.object_id = p.object_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id  -- Hier stand der Fehler
GROUP BY t.name, t.object_id, t.create_date
ORDER BY [TotalSizeMB] DESC;