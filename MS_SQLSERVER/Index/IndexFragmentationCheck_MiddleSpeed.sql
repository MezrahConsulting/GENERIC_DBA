
USE DATABASE_NAME_HERE
GO

SELECT s.[name] + '.' + t.[name] AS table_name
    , i.NAME AS index_name
    , index_type_desc
    , ROUND(avg_fragmentation_in_percent, 2) AS avg_fragmentation_in_percent
    , record_count AS table_record_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'SAMPLED') ips
    INNER JOIN sys.tables t
        ON t.[object_id] = ips.[object_id]
    INNER JOIN sys.schemas s
        ON t.[schema_id] = s.[schema_id]
    INNER JOIN sys.indexes i
        ON (ips.object_id = i.object_id)
            AND (ips.index_id = i.index_id)
WHERE table_name = 'something'
OR ( table_record_count < 100 AND )
ORDER BY avg_fragmentation_in_percent DESC
