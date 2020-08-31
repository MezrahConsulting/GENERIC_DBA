-- ================================================
-- Template generated from Template Explorer using:
-- Create Scalar Function (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Dave Babler
-- Create date: 08/26/2020
-- Description:	This can be used as a hack to suppress output of a stored procedure temporarily.  
--				It works like this: You call the fake temp table in this procedure in your wrapping proc, 
--				Then in any proc that you want to use either as an embedded procedure or a stand alone 
--				procedure you check this function for a 1 if it is a 1 you bypass output, if it is a 0  you show output.
-- =============================================
CREATE FUNCTION fn_SuppressOutput (
	-- NO PARAMATERS NEEDED
	-- REMINDER EXCEPTION HANDLING WITH TRY CATCH DOES NOT WORK IN FUNCTIONS
	)
RETURNS BIT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @boolSuppress BIT

	/**what do we do when you have output that you may want to suppress in another situation?
	 * Unlike Oracle we cannot suppress results, 
	 * So let's fake it!  Create a suppress results temp table in your calling proc and then 
	 * call this proc, finally drop your suppress results temp table in your calling proc when done
	 * that way this procedure is still useful as a stand alone proc.  
	 * RATHER THAN HAVING TO MEMORIZE THIS WEIRD TABLE NAME let's just memorize if this returns a 1 we suppress!
	 * -- Dave Babler 08/26/2020  */
	IF OBJECT_ID('tempdb..#__suppress_results') IS NULL
	BEGIN
		SET @boolSuppress = 0;
	END
	ELSE
	BEGIN
		SET @boolSuppress = 1;
	END

	-- Return the result of the function
	RETURN @boolSuppress
END
GO


