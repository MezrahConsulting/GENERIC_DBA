SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Dave Babler
-- Create date: 08/26/2020
-- Description:	This makes adding comments to columns in SQLServer far more accessible than before.
-- =============================================
CREATE OR ALTER PROCEDURE DD_AddColumnComment 
    -- Add the parameters for the stored procedure here
    @strTableName NVARCHAR(64), 
    @strColumnName NVARCHAR(64),
    @strComment NVARCHAR(360)
AS

/**Note: vrt is for Variant, which is the absurd way SQL Server stores it's Strings in the data dictionary
* supposedly for 'security' --Dave Babler*/
DECLARE @vrtComment SQL_VARIANT;

SET @vrtComment = CAST(@strComment AS SQL_VARIANT);

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
