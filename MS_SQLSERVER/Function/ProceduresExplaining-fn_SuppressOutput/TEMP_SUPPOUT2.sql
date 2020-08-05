-- =============================================
-- Author:		Dave Babler
-- Create date: 9/10/2020
-- Description:	Shows output suppression
-- Subprocedures: 1. [TEMP_SUPPOUT1]
-- =============================================
CREATE OR ALTER PROCEDURE TEMP_SUPPOUT2
	-- Add the parameters for the stored procedure here
	@strFirstPartMess VARCHAR(80)
	, @strSecondPartMess VARCHAR(80)
AS
BEGIN TRY
	DECLARE @strProc1Output VARCHAR(80);
	DECLARE @strFinalMess VARCHAR(200);

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--CREATE A FAKE TEMP TABLE TO SUPPRESS RESULTS
	CREATE TABLE #__suppress_results (col1 INT);

	EXEC TEMP_SUPPOUT1 @strFirstPartMess
		, @strProc1Output OUTPUT;

	SET @strFinalMess = @strProc1Output + ' ' + @strSecondPartMess;

	SELECT @strFinalMess;

	DROP TABLE IF EXISTS #__suppress_results;-- ALWAYS DROP IT!
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
