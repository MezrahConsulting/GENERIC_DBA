-- =============================================
-- Author:		Dave Babler
-- Create date: 08/25/2020
-- Description:	Checks to see if table exists use output boolean for logic flow in other procedures
-- =============================================

CREATE OR ALTER PROCEDURE DD_TableExist 
	@strTableName NVARCHAR(64), 
	@boolSuccessFlag BIT OUTPUT,
    @strMessageOut NVARCHAR(400) = NULL  OUTPUT

    AS
SET NOCOUNT ON;
BEGIN TRY 
     /** If the table doesn't exist we're going to output a message and throw a false flag,
     *  ELSE we'll throw a true flag so external operations can commence
     * Dave Babler 2020-08-26  */
 IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = @strTableName
 )
    BEGIN 
        SET @boolSuccessFlag = 0;
        SET @strMessageOut =  @strTableName + 
			' does not exist, check spelling, try again?';
    END 
    ELSE 
        BEGIN 
            SET @boolSuccessFlag = 1;
            SET @strMessageOut = NULL;
        END 
SET NOCOUNT OFF;
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
