-- =============================================
-- Author:		DaveBabler
-- Create date: 04/25/2020
-- Description:	This will either add or wipe and update the comments on a table.
-- =============================================
CREATE OR ALTER PROCEDURE DD_AddTableComment 
	-- Add the parameters for the stored procedure here
	@strTableName NVARCHAR(64), 
	@strComment NVARCHAR(360)
AS

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
                    AND [minor_id] = 0
                )
            EXECUTE sp_addextendedproperty @name = N'MS_Description'
                , @value = @vrtComment
                , @level0type = N'SCHEMA'
                , @level0name = N'dbo'
                , @level1type = N'TABLE'
                , @level1name = @strTableName;
        ELSE
            EXECUTE sp_updateextendedproperty @name = N'MS_Description'
                , @value = @vrtComment
                , @level0type = N'SCHEMA'
                , @level0name = N'dbo'
                , @level1type = N'TABLE'
                , @level1name = @strTableName;
    SET NOCOUNT OFF
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
