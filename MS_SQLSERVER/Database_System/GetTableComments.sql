/**This gets a list of column comments from the um.... unusual way that MSSQLSERVER likes to store them
   --Dave Babler*/
DECLARE @TableName VARCHAR(80);

SET @TableName = 'ASSET_LIABILITY_ASSET_TANK';--you fill in between the quotes!!!

SELECT COLUMN_NAME AS [Output]
	, ORDINAL_POSITION
	, prop.value AS [COLUMN_DESCRIPTION]
FROM INFORMATION_SCHEMA.TABLES AS tbl
INNER JOIN INFORMATION_SCHEMA.COLUMNS AS col
	ON col.TABLE_NAME = tbl.TABLE_NAME
INNER JOIN sys.columns AS sc
	ON sc.object_id = object_id(tbl.table_schema + '.' + tbl.table_name)
		AND sc.NAME = col.COLUMN_NAME
LEFT JOIN sys.extended_properties prop
	ON prop.major_id = sc.object_id
		AND prop.minor_id = sc.column_id
		AND prop.NAME = 'MS_Description'
WHERE col.TABLE_NAME = @TableName
