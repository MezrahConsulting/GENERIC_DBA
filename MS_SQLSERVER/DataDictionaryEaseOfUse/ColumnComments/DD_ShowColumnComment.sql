SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Dave Babler
-- Create date: 08/26/2020
-- Description:	This procedure makes viewing comments on a single column much more accessible.
-- =============================================
CREATE PROCEDURE DD_ShowColumnComment 
	-- Add the parameters for the stored procedure here
	@strTableName NVARCHAR(64)
	, @strColumnName NVARCHAR(64)
AS


DECLARE @strMessageOut NVARCHAR(320);

BEGIN TRY

    IF EXISTS (
            /**Check to see if the column or table actually exists -- Babler*/
            SELECT 1
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_NAME = @strTableName
                AND COLUMN_NAME = @strColumnName
        )
        BEGIN 
            IF EXISTS (
                /**Check to see if the column has the extened properties on it.
                 *If it does not  will ultimately ask someone to please create 
                 * the comment on the column -- Babler */
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
            BEGIN
                SELECT TOP 1 @strMessageOut = CAST(ep.value AS  NVARCHAR(320))
                FROM sys.extended_properties ep
                INNER JOIN sys.all_objects ob
                    ON ep.major_id = ob.object_id
                INNER JOIN sys.tables AS st
                    ON ob.object_id = st.object_id
                INNER JOIN sys.columns AS c	
                    ON ep.major_id = c.object_id
                        AND ep.minor_id = c.column_id
                WHERE st.name = @strTableName
                    AND c.name = @strColumnName
            END
            ELSE
            BEGIN
                SET @strMessageOut = @strTableName + ' ' + @strColumnName + 
                    N' currently has no comments please use DD_AddColumnComment to add a comment!';
            END

            SELECT @strColumnName AS 'ColumnName'
                , @strMessageOut AS 'TableComment';
        END
    ELSE 
        BEGIN
         SET @strMessageOut = 'Either the column you typed in: ' + @strColumnName + ' or, '
                            + ' the table you typed in: ' + @strTableName + ' '
                            + 'is invalid, check spelling, try again? ';
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
