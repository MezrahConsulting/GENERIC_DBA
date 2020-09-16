-- ===============================================================================
-- Author:		Dave Babler
-- Create date: 9/16/2020
-- Description:	Searches through all stored procedures, views, and functions 
--				(based on selection)  for a specific keyword
-- ===============================================================================
CREATE PROCEDURE DD_FindKeyWordInCode 
	-- Add the parameters for the stored procedure here
	@strKeyWord NVARCHAR(MAX), 
	@dlistTypeOfCodeToSearch VARCHAR(16) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT @strKeyWord, @dlistTypeOfCodeToSearch
END
GO
