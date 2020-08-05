-- ================================================
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Dave Babler
-- Create date: 08/26/2020
-- Description:	This shows two colums so you can visually check JOIN compatibility (and for other things)
-- Subprocedures: 1. [dbo].[DD_ColumnExist]
--				  2. [dbo].[DD_TableExist]
-- =============================================
CREATE
	OR

ALTER PROCEDURE DD_ColumnCompare
	-- Add the parameters for the stored procedure here
	@strTableName1 VARCHAR(64)
	, @strColumnName1 VARCHAR(64)
	, @strTableName2 VARCHAR(64)
	, @strColumnName2 VARCHAR(64)
AS
DECLARE @strErrorMessage VARCHAR(MAX) = 'This is the first error I have encountered, you may have more: ';
DECLARE @strErrorBuilder VARCHAR(MAX);
--not doing recursive error checking for this, sorry. -- Dave Babler
DECLARE @boolOKToProceed BIT = NULL;

BEGIN TRY
	EXEC DD_TableExist @strTableName1
		, @boolOKToProceed OUTPUT
		, @strErrorBuilder OUTPUT;

	IF @boolOKToProceed = 1
	BEGIN
		--RESET THE FLAG and message holder
		SET @boolOKToProceed = NULL;
		SET @strErrorBuilder = NULL;

		--CHECK THE COLUMN 
		EXEC DD_ColumnExist @strTableName1
			, @strColumnName1
			, @boolOKToProceed OUTPUT
			, @strErrorBuilder OUTPUT;

		IF @boolOKToProceed = 1
		BEGIN
			--RESET THE FLAG and message holder
			SET @boolOKToProceed = NULL;
            SET @strErrorBuilder = NULL;

			--CHECK TABLE 2
			EXEC DD_TableExist @strTableName2
				, @boolOKToProceed OUTPUT
				, @strErrorBuilder OUTPUT;

			IF @boolOKToProceed = 1
			BEGIN
				--RESET THE FLAG and message holder
				SET @boolOKToProceed = NULL;
                SET @strErrorBuilder = NULL;

				--CHECK COLUMN 2
				EXEC DD_ColumnExist @strTableName2
					, @strColumnName2
					, @boolOKToProceed OUTPUT
					, @strErrorBuilder OUTPUT;

				IF @boolOKToProceed = 1
					/**FINALLY WE CAN CHECK THE COLUMNS VS EACH OTHER!*/
				BEGIN
					SELECT TABLE_NAME
						, COLUMN_NAME
						, DATA_TYPE
						, CHARACTER_MAXIMUM_LENGTH
						, CHARACTER_SET_NAME
						, COLLATION_NAME
					FROM INFORMATION_SCHEMA.COLUMNS c
					WHERE TABLE_NAME = @strTableName1
						AND COLUMN_NAME = @strColumnName1
					
					UNION
					
					SELECT TABLE_NAME
						, COLUMN_NAME
						, DATA_TYPE
						, CHARACTER_MAXIMUM_LENGTH
						, CHARACTER_SET_NAME
						, COLLATION_NAME
					FROM INFORMATION_SCHEMA.COLUMNS c
					WHERE TABLE_NAME = @strTableName2
						AND COLUMN_NAME = @strColumnName2
				END -- SECOND COLUMN SUCCESS END
				ELSE
				BEGIN
					SET @strErrorMessage += @strErrorBuilder;

					SELECT @strErrorMessage AS 'ERROR!';
				END
			END
			ELSE
			BEGIN
				SET @strErrorMessage += @strErrorBuilder;

				SELECT @strErrorMessage AS 'ERROR!';
			END
		END -- SECOND TABLE SUCCESS END
		ELSE
		BEGIN
			SET @strErrorMessage += @strErrorBuilder;

			SELECT @strErrorMessage AS 'ERROR!';
		END
	END --FIRST COLUMN CHECK SUCCESS END
	ELSE
	BEGIN
		SET @strErrorMessage += @strErrorBuilder;

		SELECT @strErrorMessage AS 'ERROR!';
	END --FIRST TABLE CHECK SUCCESS END
			/** I AM VERY TEMPTED TO TURN THE ERROR BUILDER INTO ITS OWN PROC BUT 
           * THAT MIGHT BE OVERKILL?
        *  Dave Babler -- 2020-08-26*/
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
