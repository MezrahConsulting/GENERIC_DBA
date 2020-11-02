-- =============================================
-- Author:		Dave Babler
-- Create date: 9/10/2020
-- Description:	Demonstrates Suppress Output
-- Subprocedures: 1. [fn_SuppressOutput]
-- =============================================
CREATE OR ALTER PROCEDURE TEMP_SUPPOUT1
	-- Add the parameters for the stored procedure here
	@strInVal VARCHAR(80) = 0
	, @strOutMessage VARCHAR(160) = NULL OUTPUT
AS
BEGIN TRY
	SET NOCOUNT ON;

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	DECLARE @boolSuppressVisualOutput BIT;

	SELECT @boolSuppressVisualOutput = dbo.fn_SuppressOutput();

	SET @strOutMessage = @strInVal + ' Team';

	IF @boolSuppressVisualOutput = 0
	BEGIN
		SELECT @strInVal + ' I should only show when output is not suppressed';
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



