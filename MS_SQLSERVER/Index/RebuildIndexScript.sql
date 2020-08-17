/**warning
* never
* ever
* ever
* ever
* ever
* ever
* use this on production without first on development and then test your hardest queries on the database before 
* you approve for production --Dave Babler
*/
SELECT OBJECT_NAME(ind.OBJECT_ID) AS TableName
	, ind.name AS IndexName
	, indexstats.index_type_desc AS IndexType
	, indexstats.avg_fragmentation_in_percent
	, 'ALTER INDEX ' + QUOTENAME(ind.name) + ' ON ' + QUOTENAME(object_name(ind.object_id)) + CASE 
		WHEN indexstats.avg_fragmentation_in_percent > 30
			THEN ' REBUILD '
		WHEN indexstats.avg_fragmentation_in_percent >= 5
			THEN 'REORGANIZE'
		ELSE NULL
		END AS [SQLQuery] -- if <5 not required, so no query needed
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) indexstats
INNER JOIN sys.indexes ind
	ON ind.object_id = indexstats.object_id
		AND ind.index_id = indexstats.index_id
WHERE
	--indexstats.avg_fragmentation_in_percent , e.g. >10, you can specify any number in percent 
	ind.Name IS NOT NULL
ORDER BY indexstats.avg_fragmentation_in_percent DESC
