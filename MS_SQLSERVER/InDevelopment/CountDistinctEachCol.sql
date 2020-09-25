/**This is a good start but it returns too many results, find a way to concatenate this into one giant table*/
DECLARE @Table SYSNAME = 'tbl_report_summary';
DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL = (
		SELECT ' SELECT ' + QUOTENAME(Name) + ', COUNT(*) AS [Count] FROM ' + QUOTENAME(@Table) + ' GROUP BY ' + QUOTENAME(Name) + 
			';'
		FROM sys.columns
		WHERE object_id = Object_id(@Table)
		-- concatenate result strings with FOR XML PATH
		FOR XML PATH('')
		);

EXECUTE sp_executesql @SQL;
