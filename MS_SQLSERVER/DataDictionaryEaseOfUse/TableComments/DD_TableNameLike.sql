-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Dave Babler
-- Create date: 08/31/2020
-- Description:	This returns a list of tables and comments based on a guessed name
-- =============================================
CREATE PROCEDURE DD_TableNameLike 
	-- Add the parameters for the stored procedure here
	@strTableGuess NVARCHAR(64) 

AS
BEGIN
    SET NOCOUNT ON;


 /** Always lowercase fuzzy paramaters 
 *  You do not know the name; therefore,
 *  you cannot be sure of the case! -- Dave Babler */
-- DECLARE @strTableNameLower NVARCHAR(64) = lower(@strTableGuess);--System Funcs always ALL CAPS except lower because its 'lower'
-- DECLARE @strTableNameLowerFuzzy NVARCHAR(80) = '%' + @strTableNameLower + '%';  --split to to declare to show work, can be done one line

DECLARE @strTableNameLowerFuzzy NVARCHAR(80) = '%' + lower(@strTableGuess) +'%';

/**When creating dynamic SQL leave one fully working example with filled in paramaters
* This way when the next person to come along to debug it sees it they know exactly what you are looking for
* I recommend putting it at the end of the code commented out with it's variable name so it doesn't create 
* code clutter. --Dave Babler */



DECLARE @SQLStatementFindTables AS NVARCHAR(1000);


SET @SQLStatementFindTables = 'SELECT 	sysObj.name AS "TableName"
	                            , ep.value AS "TableDescription" 
                                FROM sysobjects sysObj
                                INNER JOIN sys.tables sysTbl
                                    ON sysTbl.object_id = sysObj.id
                                LEFT JOIN sys.extended_properties ep
                                    ON ep.major_id = sysObj.id
                                        AND ep.name = ''MS_Description''
                                        AND ep.minor_id = 0
                                WHERE lower(sysObj.name) LIKE @strTbl';

EXECUTE sp_executesql @SQLStatementFindTables, N'@strTbl NVARCHAR(80)', @strTbl = @strTableNameLowerFuzzy;


SET NOCOUNT OFF;



--@SQLStatementFindTables working example is below.
-- SELECT --t.id                        as  "object_id",
-- 	sysObj.name AS "TableName"
-- 	, ep.value AS "TableDescription"
-- FROM sysobjects sysObj
-- INNER JOIN sys.tables sysTbl
-- 	ON sysTbl.object_id = sysObj.id
-- LEFT JOIN sys.extended_properties ep
-- 	ON ep.major_id = sysObj.id
-- 		AND ep.name = 'MS_Description'
-- 		AND ep.minor_id = 0
-- WHERE lower(sysObj.name) LIKE '%tank%'

END