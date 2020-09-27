SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Dave Babler
-- Create date: 08/26/2020
-- Description:	This recreates and improves upon Oracle's ANSI DESCRIBE table built in data dictionary proc
-- 				This will default to the dbo schema unless specified within the input parameter.
-- Subprocedures: 1. DD_ShowTableComment
-- 				  2. UTL_fn_DelimListToTable  (already exists, used to have diff name)
-- =============================================
CREATE OR ALTER PROCEDURE DD_Describe 
	-- Add the parameters for the stored procedure here
	@str_input_TableName VARCHAR(128) 
	 
AS



DECLARE @strMessageOut NVARCHAR(320)
		, @boolIsTableCommentSet BIT = NULL
		, @strTableComment NVARCHAR(320)
		, @strTableSubComment NVARCHAR(80)--This will be an additional flag warning there is no actual table comment!
		, @strSchemaName NVARCHAR(64)
		, @strTableName NVARCHAR(64)
		, @intSchmeaKey INT = 1  --if needed the schema comes before the delimiter
        , @intTableKey INT = 2 -- and the table after
		, @charDelimiter CHAR(1) = '.' -- can only delimit schmea.TABLE with periods;


BEGIN TRY

	/** First check to see if a schema was specified in the input paramater, schema.table, else default to dbo. -- Babler*/

	IF CHARINDEX(@charDelimiter, @str_input_TableName) > 0
	BEGIN 
		SELECT @strSchemaName = StringValue
		FROM UTL_fn_DelimListToTable(@str_input_TableName, '.')
		WHERE ValueID = @intSchmeaKey;

		SELECT @strTableName = StringValue
		FROM UTL_fn_DelimListToTable(@str_input_TableName, '.')
		WHERE ValueID = @intTableKey;
	END
	ELSE 
	BEGIN 
		/**If no delimiting set default schema of dbo, and table name to what's passed in -- Dave Babler*/
		SET @strSchemaName = 'dbo';
		SET @strTableName = @str_input_TableName;
	END
	PRINT 'Schema: ' + @strSchemaName + ' ' +'Table: ' +@strTableName;

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
		-- we want to suppress results (perhaps this could be proceduralized as well one to make the table one to kill?)
		CREATE TABLE #__suppress_results (col1 INT);

		EXEC DD_ShowTableComment @strTableName
			, @boolIsTableCommentSet OUTPUT
			, @strTableComment OUTPUT;

		IF @boolIsTableCommentSet = 0
		BEGIN
			SET @strTableSubComment = 'RECTIFY MISSING TABLE COMMENT -->';
		END
		ELSE
		BEGIN
			SET @strTableSubComment = 'TABLE COMMENT --> ';
		END
		--it made me put the delimiter here I have NO CLUE why --Babler
		;WITH fkeys
		AS (
			SELECT col.name AS NameofFKColumn
				, schema_name(pk_tab.schema_id) + '.' + pk_tab.name AS ReferencedTable
				, pk_col.name AS PrimaryKeyColumnName
			FROM sys.tables tab
			INNER JOIN sys.columns col
				ON col.object_id = tab.object_id
			LEFT JOIN sys.foreign_key_columns fk_cols
				ON fk_cols.parent_object_id = tab.object_id
					AND fk_cols.parent_column_id = col.column_id
			LEFT JOIN sys.foreign_keys fk
				ON fk.object_id = fk_cols.constraint_object_id
			LEFT JOIN sys.tables pk_tab
				ON pk_tab.object_id = fk_cols.referenced_object_id
			LEFT JOIN sys.columns pk_col
				ON pk_col.column_id = fk_cols.referenced_column_id
					AND pk_col.object_id = fk_cols.referenced_object_id
			WHERE fk.name IS NOT NULL
				AND tab.name = @strTableName
                AND pk_tab.schema_id = SCHEMA_ID(@strSchemaName)
			),
		 pk AS (SELECT SCHEMA_NAME(o.schema_id) AS TABLE_SCHEMA
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
			)
		SELECT col.COLUMN_NAME AS ColumnName
			, col.ORDINAL_POSITION AS OrdinalPosition
			, col.DATA_TYPE AS DataType
			, col.CHARACTER_MAXIMUM_LENGTH AS MaxLength
			, col.NUMERIC_PRECISION AS NumericPrecision
			, col.NUMERIC_SCALE AS NumericScale
			, col.DATETIME_PRECISION AS DatePrecision
			, col.COLUMN_DEFAULT AS DefaultSetting
			, CAST(CASE col.IS_NULLABLE
					WHEN 'NO'
						THEN 0
					ELSE 1
					END AS BIT) AS IsNullable
			, COLUMNPROPERTY(OBJECT_ID('[' + col.TABLE_SCHEMA + '].[' + col.TABLE_NAME + ']'), col.COLUMN_NAME, 'IsComputed') AS 
			IsComputed
			, COLUMNPROPERTY(OBJECT_ID('[' + col.TABLE_SCHEMA + '].[' + col.TABLE_NAME + ']'), col.COLUMN_NAME, 'IsIdentity') AS 
			IsIdentity
			, CAST(ISNULL(pk.is_primary_key, 0) AS BIT) AS IsPrimaryKey
			, 'FK of: ' + fkeys.ReferencedTable + '.' + fkeys.PrimaryKeyColumnName AS ReferencedTablePrimaryKey
			, col.COLLATION_NAME AS CollationName
			, s.value AS Description
		FROM INFORMATION_SCHEMA.COLUMNS AS col
		LEFT JOIN pk
			ON col.TABLE_NAME = pk.TABLE_NAME
				AND col.TABLE_SCHEMA = pk.TABLE_SCHEMA
				AND col.COLUMN_NAME = pk.COLUMN_NAME
		LEFT JOIN sys.extended_properties s
			ON s.major_id = OBJECT_ID(col.TABLE_SCHEMA + '.' + col.TABLE_NAME)
				AND s.minor_id = col.ORDINAL_POSITION
				AND s.name = 'MS_Description'
		LEFT JOIN fkeys AS fkeys
			ON col.COLUMN_NAME = fkeys.NameofFKColumn
		WHERE col.TABLE_NAME = @strTableName
			AND col.TABLE_SCHEMA = @strSchemaName
		
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
			, NULL
			, NULL
			, @strTableSubComment
			, @strTableComment
		ORDER BY 2 
	END
	ELSE
	BEGIN
		SET @strMessageOut = ' The table you typed in: ' + @strTableName + ' ' + 'is invalid, check spelling, try again? ';

		SELECT @strMessageOut AS 'NON_LOGGED_ERROR_MESSAGE'
	END

		DROP TABLE
		IF EXISTS #__suppress_results;
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
