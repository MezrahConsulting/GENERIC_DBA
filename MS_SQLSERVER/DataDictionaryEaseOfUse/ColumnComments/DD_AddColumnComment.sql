SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Dave Babler
-- Create date: 08/26/2020
-- Description:	This makes adding comments to columns in SQLServer far more accessible than before.
-- =============================================
CREATE
	OR

ALTER PROCEDURE DD_AddColumnComment
	-- Add the parameters for the stored procedure here
	@strTableName NVARCHAR(64)
	, @strColumnName NVARCHAR(64)
	, @strComment NVARCHAR(360)
AS
/**Note: vrt is for Variant, which is the absurd way SQL Server stores it's Strings in the data dictionary
* supposedly for 'security' --Dave Babler*/
DECLARE @vrtComment SQL_VARIANT;
DECLARE @strErrorMessage VARCHAR(MAX);
DECLARE @boolCatchFlag BIT = 0;

SET @vrtComment = CAST(@strComment AS SQL_VARIANT);

BEGIN TRY
	SET NOCOUNT ON;

	IF NOT EXISTS (
			/**Check to see if the column or table actually exists -- Babler*/
			SELECT 1
			FROM INFORMATION_SCHEMA.COLUMNS
			WHERE TABLE_NAME = @strTableName
				AND COLUMN_NAME = @strColumnName
			)
	BEGIN
		--if it does not exist raise error and send to the exception tank
		SET @boolCatchFlag = 1;
		SET @strErrorMessage = 'Attempt to add comment on column ' + @strColumnName + ' of ' + @strTableName + ';however, either ' + 
			@strColumnName + ' or ' + @strTableName + ' does not exist, check spelling, try again?';

		RAISERROR (
				@strErrorMessage
				, 11
				, 1
				);
	END
	ELSE
	BEGIN
		IF NOT EXISTS (
				/**Here we have to first check to see if a MS_Description Exists
                * If the MS_Description does not exist will will use the ADD procedure to add the comment
                * If the MS_Description tag does exist then we will use the UPDATE procedure to add the comment
                * Normally it's just a simple matter of ALTER TABLE/ALTER COLUMN ADD COMMENT, literally every other system
                * however, Microsoft Has decided to use this sort of registry style of documentation 
                * -- Dave Babler 2020-08-26*/
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
	END
END TRY

BEGIN CATCH
	IF @boolCatchFlag = 1
	BEGIN
		INSERT INTO dbo.DB_EXCEPTION_TANK (
			UserName
			, ErrorState
			, ErrorSeverity
			, ErrorProcedure
			, ErrorMessage
			, ErrorDateTime
			)
		VALUES (
			SUSER_SNAME()
			, ERROR_STATE()
			, ERROR_SEVERITY()
			, ERROR_PROCEDURE()
			, ERROR_MESSAGE()
			, GETDATE()
			);
	END
	ELSE
	BEGIN
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
	END

	PRINT 
		'Please check the DB_EXCEPTION_TANK an error has been raised. 
		The query between the lines below will likely get you what you need.

		_____________________________


		WITH mxe
		AS (
			SELECT MAX(ErrorID) AS MaxError
			FROM DB_EXCEPTION_TANK
			)
		SELECT ErrorID
			, UserName
			, ErrorNumber
			, ErrorState
			, ErrorLine
			, ErrorProcedure
			, ErrorMessage
			, ErrorDateTime
		FROM DB_EXCEPTION_TANK et
		INNER JOIN mxe
			ON et.ErrorID = mxe.MaxError

		_____________________________

'
END CATCH;
