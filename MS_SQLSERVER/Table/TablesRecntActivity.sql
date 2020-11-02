SELECT tbl.name
	, ius.last_user_update
	, ius.user_updates
	, ius.last_user_seek
	, ius.last_user_scan
	, ius.last_user_lookup
	, ius.user_seeks
	, ius.user_scans
	, ius.user_lookups
FROM sys.dm_db_index_usage_stats ius
INNER JOIN sys.tables tbl
	ON (tbl.OBJECT_ID = ius.OBJECT_ID)
WHERE ius.database_id = DB_ID()
