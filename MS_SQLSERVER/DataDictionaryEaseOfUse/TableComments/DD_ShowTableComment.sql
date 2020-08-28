-- ================================================
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Dave Babler
-- Create date: 08/25/2020
-- Description:	Checks to see if table comments exist
-- Subprocedures: 1. [fn_SuppressOutput]
-- =============================================
CREATE OR ALTER PROCEDURE DD_ShowTableComment 
	@strTableName NVARCHAR(64), 
	@boolOptionalSuccessFlag BIT = NULL OUTPUT, 
	@strOptionalMessageOut NVARCHAR(320) = NULL OUTPUT
	/** The success flag will be used when passing this to other procedures to see if table comments exist.
	 * The optional message out will be used when passing from proc to proc to make things more proceduralized.
	 * --Dave Babler 08/26/2020  */
AS
DECLARE @strMessageOut NVARCHAR(320);
DECLARE @boolSuppressVisualOutput BIT; 

BEGIN TRY
  /**First with procedures that are stand alone/embedded hybrids, determine if we need to suppress output by 
  * populating the data for that variable 
  * --Dave Babler */

	SELECT @boolSuppressVisualOutput = dbo.fn_SuppressOutput();

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
		IF EXISTS (
				/**Check to see if the table has the extened properties on it.
                        *If it does not  will ultimately ask someone to please create 
                        * the comment on the table -- Babler */
				SELECT NULL
				FROM SYS.EXTENDED_PROPERTIES
				WHERE [major_id] = OBJECT_ID(@strTableName)
					AND [name] = N'MS_Description'
					AND [minor_id] = 0
				)
		BEGIN
			WITH tp
			AS (
				SELECT OBJECT_NAME(ep.major_id) AS [epTableName]
					, ep.Value AS [epExtendedProperty]
				FROM sys.extended_properties ep
				WHERE ep.name = N'MS_Description' --sql server							 absurdly complex version of COMMENT
					AND ep.minor_id = 0 --prevents showing column comments
				)
			SELECT TOP 1 @strMessageOut = CAST(tp.epExtendedProperty AS NVARCHAR(320))
			FROM information_schema.tables AS t
			INNER JOIN tp
				ON t.table_name = tp.epTableName
			WHERE TABLE_TYPE = N'BASE TABLE'
				AND tp.epTableName = @strTableName;
			SET @boolOptionalSuccessFlag = 1; --Let any calling procedures know that there is in fact
			SET @strOptionalMessageOut = @strMessageOut;
		END
		ELSE
		BEGIN
			SET @boolOptionalSuccessFlag = 0; --let any proc calling know that there is no table comments yet.
			SET @strMessageOut = @strTableName + N' currently has no comments please use DD_AddTableComment to add comments!';
			SET @strOptionalMessageOut = @strMessageOut;
		END
		IF @boolSuppressVisualOutput = 0
		BEGIN
			SELECT @strTableName AS 'Table Name'
				, @strMessageOut AS 'TableComment';
		END
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
