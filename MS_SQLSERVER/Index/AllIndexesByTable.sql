--Display all indexes along with key columns, included columns and index type
DECLARE @TempTable AS TABLE (
	SchemaName VARCHAR(100)
	, ObjectID INT
	, TableName VARCHAR(100)
	, IndexID INT
	, IndexName VARCHAR(100)
	, ColumnID INT
	, column_index_id INT
	, ColumnNames VARCHAR(500)
	, IncludeColumns VARCHAR(500)
	, NumberOfColumns INT
	, IndexType VARCHAR(20)
	, LastColRecord INT
	);

WITH CTE_Indexes (
	SchemaName
	, ObjectID
	, TableName
	, IndexID
	, IndexName
	, ColumnID
	, column_index_id
	, ColumnNames
	, IncludeColumns
	, NumberOfColumns
	, IndexType
	)
AS (
	SELECT s.name
		, t.object_id
		, t.name
		, i.index_id
		, i.name
		, c.column_id
		, ic.index_column_id
		, CASE ic.is_included_column
			WHEN 0
				THEN CAST(c.name AS VARCHAR(5000))
			ELSE ''
			END
		, CASE ic.is_included_column
			WHEN 1
				THEN CAST(c.name AS VARCHAR(5000))
			ELSE ''
			END
		, 1
		, i.type_desc
	FROM sys.schemas AS s
	INNER JOIN sys.tables AS t
		ON s.schema_id = t.schema_id
	INNER JOIN sys.indexes AS i
		ON i.object_id = t.object_id
	INNER JOIN sys.index_columns AS ic
		ON ic.index_id = i.index_id
			AND ic.object_id = i.object_id
	INNER JOIN sys.columns AS c
		ON c.column_id = ic.column_id
			AND c.object_id = ic.object_id
			AND ic.index_column_id = 1
	
	UNION ALL
	
	SELECT s.name
		, t.object_id
		, t.name
		, i.index_id
		, i.name
		, c.column_id
		, ic.index_column_id
		, CASE ic.is_included_column
			WHEN 0
				THEN CAST(cte.ColumnNames + ', ' + c.name AS VARCHAR(5000))
			ELSE cte.ColumnNames
			END
		, CASE 
			WHEN ic.is_included_column = 1
				AND cte.IncludeColumns != ''
				THEN CAST(cte.IncludeColumns + ', ' + c.name AS VARCHAR(5000))
			WHEN ic.is_included_column = 1
				AND cte.IncludeColumns = ''
				THEN CAST(c.name AS VARCHAR(5000))
			ELSE ''
			END
		, cte.NumberOfColumns + 1
		, i.type_desc
	FROM sys.schemas AS s
	INNER JOIN sys.tables AS t
		ON s.schema_id = t.schema_id
	INNER JOIN sys.indexes AS i
		ON i.object_id = t.object_id
	INNER JOIN sys.index_columns AS ic
		ON ic.index_id = i.index_id
			AND ic.object_id = i.object_id
	INNER JOIN sys.columns AS c
		ON c.column_id = ic.column_id
			AND c.object_id = ic.object_id
	INNER JOIN CTE_Indexes cte
		ON cte.Column_index_ID + 1 = ic.index_column_id
			--JOIN CTE_Indexes cte ON cte.ColumnID + 1 = ic.index_column_id  
			AND cte.IndexID = i.index_id
			AND cte.ObjectID = ic.object_id
	)
INSERT INTO @TempTable
SELECT *
	, RANK() OVER (
		PARTITION BY ObjectID
		, IndexID ORDER BY NumberOfColumns DESC
		) AS LastRecord
FROM CTE_Indexes AS cte;

SELECT SchemaName
	, TableName
	, IndexName
	, ColumnNames
	, IncludeColumns
	, IndexType
FROM @TempTable
WHERE LastColRecord = 1
ORDER BY objectid
	, TableName
	, indexid
	, IndexName;


	---- alternative way




SELECT i.[name] AS index_name
	, substring(column_names, 1, len(column_names) - 1) AS [columns]
	, CASE 
		WHEN i.[type] = 1
			THEN 'Clustered index'
		WHEN i.[type] = 2
			THEN 'Nonclustered unique index'
		WHEN i.[type] = 3
			THEN 'XML index'
		WHEN i.[type] = 4
			THEN 'Spatial index'
		WHEN i.[type] = 5
			THEN 'Clustered columnstore index'
		WHEN i.[type] = 6
			THEN 'Nonclustered columnstore index'
		WHEN i.[type] = 7
			THEN 'Nonclustered hash index'
		END AS index_type
	, CASE 
		WHEN i.is_unique = 1
			THEN 'Unique'
		ELSE 'Not unique'
		END AS [unique]
	, schema_name(t.schema_id) + '.' + t.[name] AS table_view
	, CASE 
		WHEN t.[type] = 'U'
			THEN 'Table'
		WHEN t.[type] = 'V'
			THEN 'View'
		END AS [object_type]
FROM sys.objects t
INNER JOIN sys.indexes i
	ON t.object_id = i.object_id
CROSS APPLY (
	SELECT col.[name] + ', '
	FROM sys.index_columns ic
	INNER JOIN sys.columns col
		ON ic.object_id = col.object_id
			AND ic.column_id = col.column_id
	WHERE ic.object_id = t.object_id
		AND ic.index_id = i.index_id
	ORDER BY key_ordinal
	FOR XML path('')
	) D(column_names)
WHERE t.is_ms_shipped <> 1
	AND index_id > 0
ORDER BY i.[name];
