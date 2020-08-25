-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Dave Babler
-- Create date: 08/25/2020
-- Description:	Checks to see if table comments exist
-- =============================================
CREATE PROCEDURE DD_ShowTableComments 

	@strTableName nvarchar(64)

AS


DECLARE @strMessageOut NVARCHAR(320);



BEGIN TRY
	IF EXISTS (
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
			WHERE ep.name = N'MS_Description' --sql server absurdly complex version of COMMENT
				AND ep.minor_id = 0 --prevents showing column comments
			)
		SELECT TOP 1 @strMessageOut = CAST(tp.epExtendedProperty AS NVARCHAR(320))
		FROM information_schema.tables AS t
		INNER JOIN tp
			ON t.table_name = tp.epTableName
		WHERE TABLE_TYPE = N'BASE TABLE'
			AND tp.epTableName = @strTableName
	END
	ELSE
	BEGIN
		SET @strMessageOut = @strTableName + 
			N' currently has no comments please use DD_AddTableComment to add comments!';
	END

	SELECT @strTableName AS 'Table Name'
		    , @strMessageOut AS 'TableComment';
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
