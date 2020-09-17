SELECT [Current LSN]
	, [Operation]
	, [Transaction ID]
	, [Parent Transaction ID]
	, [Begin Time]
	, [Transaction Name]
	, [Transaction SID]
FROM fn_dblog(NULL, NULL)
WHERE [Operation] = 'LOP_BEGIN_XACT'



USE PLPositions
GO

;with bydatehour as (		SELECT COUNT(*) AS Cnt, 
				CAST([Begin Time] AS DATE) AS Date_Day
				, DATEPART(hour, [Begin Time]) as Date_Hour
		FROM fn_dblog(NULL, NULL)
		WHERE [Operation] = 'LOP_BEGIN_XACT'
		GROUP BY  CAST([Begin Time] AS DATE), DATEPART(hour, [Begin Time])
)
SELECT SUM(Cnt) OVER (PARTITION BY Date_Day, Date_Hour Order BY Date_Day, Date_Hour) AS SUMOVER
, Date_Day
, Date_Hour
FROM bydatehour;



	SELECT COUNT(*) AS Cnt, 
				CAST([Begin Time] AS DATE) AS Date_Day
				, DATEPART(hour, [Begin Time]) as Date_Hour
		FROM fn_dblog(NULL, NULL)
		WHERE [Operation] = 'LOP_BEGIN_XACT'
		GROUP BY  CAST([Begin Time] AS DATE), DATEPART(hour, [Begin Time])
		order by Date_Day, Date_Hour
;