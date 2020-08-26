	-- Add the parameters for the stored procedure here
	
DECLARE    @strTableName NVARCHAR(64), 
	@strComment NVARCHAR(360);

/**Note: vrt is for Variant, which is the absurd way SQL Server stores it's Strings in the data dictionary
* supposedly for 'security' --Dave Babler*/

DECLARE @vrtComment SQL_Variant;

SET @vrtComment = CAST(@strComment AS SQL_Variant);
BEGIN TRY 
	SET NOCOUNT ON;
    		IF NOT EXISTS (
				SELECT NULL
				FROM SYS.EXTENDED_PROPERTIES
				WHERE [major_id] = OBJECT_ID(@strTableName)
					AND [name] = N'MS_Description'
					AND [minor_id] = (
						SELECT [column_id]
						FROM SYS.COLUMNS
						WHERE [name] = @strColumnName
							AND [object_id] = OBJECT_ID(@strTableName)
						)
				)
			EXECUTE sp_addextendedproperty @name = N'MS_Description'
				, @value = @vrtComment
				, @level0type = N'SCHEMA'
				, @level0name = N'dbo'
				, @level1type = N'TABLE'
				, @level1name = @strTableName
				, @level2type = N'COLUMN'
				, @level2name = @strColumnName;
		ELSE
			EXECUTE sp_updateextendedproperty @name = N'MS_Description'
				, @value = @vrtComment
				, @level0type = N'SCHEMA'
				, @level0name = N'dbo'
				, @level1type = N'TABLE'
				, @level1name = @strTableName
				, @level2type = N'COLUMN'
				, @level2name = @strColumnName;
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
