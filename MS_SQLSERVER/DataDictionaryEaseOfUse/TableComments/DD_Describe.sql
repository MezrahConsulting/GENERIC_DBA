/** This is pretty close to replicating MYSQL's show full columns 
    --Dave Babler*/
DECLARE @strTableName VARCHAR(64);

SET @strTableName = 'DB_EXCEPTION_TANK';
DECLARE @strMessageOut NVARCHAR(320);
BEGIN TRY
	IF EXISTS (
			/**Check to see if the table exists, if it does not we will output an Error Message
        * however since we are not writing anything to the DD we won't go through the whole RAISEEROR 
        * or THROW and CATCH process, a simple output is sufficient. -- Babler
        */
			SELECT 1
			FROM INFORMATION_SCHEMA.TABLES
			WHERE TABLE_NAME = @strTableName
			)
	BEGIN

		/*Common table expression tp will be used in second part of the union statement!*/
		WITH tp
		AS (
			SELECT OBJECT_NAME(ep.major_id) AS [epTableName]
				, ep.Value AS [epExtendedProperty]
			FROM sys.extended_properties ep
			WHERE ep.name = N'MS_Description' --sql server							 absurdly complex version of COMMENT
				AND ep.minor_id = 0 --prevents showing column comments
			)
		SELECT col.COLUMN_NAME AS ColumnName
			, col.ORDINAL_POSITION AS OrdinalPosition
			, col.COLUMN_DEFAULT AS DefaultSetting
			, col.DATA_TYPE AS DataType
			, col.CHARACTER_MAXIMUM_LENGTH AS MaxLength
			, col.DATETIME_PRECISION AS DatePrecision
			, col.NUMERIC_PRECISION AS NumericPrecision
			, CAST(CASE col.IS_NULLABLE
					WHEN 'NO'
						THEN 0
					ELSE 1
					END AS BIT) AS IsNullable
			, COLUMNPROPERTY(OBJECT_ID('[' + col.TABLE_SCHEMA + '].[' + col.TABLE_NAME + ']'), col.COLUMN_NAME, 'IsIdentity') AS IsIdentity
			, COLUMNPROPERTY(OBJECT_ID('[' + col.TABLE_SCHEMA + '].[' + col.TABLE_NAME + ']'), col.COLUMN_NAME, 'IsComputed') AS IsComputed
			, CAST(ISNULL(pk.is_primary_key, 0) AS BIT) AS IsPrimaryKey
			, col.COLLATION_NAME AS CollationName
			, s.value AS Description
		FROM INFORMATION_SCHEMA.COLUMNS AS col
		LEFT JOIN (
			SELECT SCHEMA_NAME(o.schema_id) AS TABLE_SCHEMA
				, o.name AS TABLE_NAME
				, c.name AS COLUMN_NAME
				, i.is_primary_key
			FROM sys.indexes AS i
			INNER JOIN sys.index_columns AS ic
				ON i.object_id = ic.object_id
					AND i.index_id = ic.index_id
			INNER JOIN sys.objects AS o
				ON i.object_id = o.object_id
			LEFT JOIN sys.columns AS c
				ON ic.object_id = c.object_id
					AND c.column_id = ic.column_id
			WHERE i.is_primary_key = 1
			) AS pk
			ON col.TABLE_NAME = pk.TABLE_NAME
				AND col.TABLE_SCHEMA = pk.TABLE_SCHEMA
				AND col.COLUMN_NAME = pk.COLUMN_NAME
		LEFT JOIN sys.extended_properties s
			ON s.major_id = OBJECT_ID(col.TABLE_SCHEMA + '.' + col.TABLE_NAME)
				AND s.minor_id = col.ORDINAL_POSITION
				AND s.name = 'MS_Description'
		WHERE col.TABLE_NAME = @strTableName
			AND col.TABLE_SCHEMA = 'dbo'

		UNION ALL

		SELECT TOP 1 @strTableName
			, NULL
			, NULL
			, NULL
			, NULL
			, NULL
			, NULL
			, NULL
			, NULL
			, NULL
			, NULL
			, 'TABLE COMMENT ROW'
			, CAST(tp.epExtendedProperty AS NVARCHAR(320)) AS TableComment
		FROM information_schema.tables AS t
		INNER JOIN tp
			ON t.table_name = tp.epTableName
		WHERE TABLE_TYPE = N'BASE TABLE'
			AND tp.epTableName = @strTableName
		ORDER BY 2
	END
ELSE 
	BEGIN
		SET @strMessageOut = ' The table you typed in: ' + @strTableName + ' ' + 'is invalid, check spelling, try again? ';

		SELECT @strMessageOut AS 'NON_LOGGED_ERROR_MESSAGE' 
	END 
END TRY 


BEGIN CATCH
	INSERT INTO dbo.DB_EXCEPTION_TANK
	VALUES (
		SUSER_SNAME()
		, ERROR_NUMBER()
		, ERROR_STATE()
		, ERROR_SEVERITY()
		, ERROR_PROCEDURE()
		, ERROR_LINE()
		, ERROR_MESSAGE()
		, GETDATE()
		);
END CATCH;