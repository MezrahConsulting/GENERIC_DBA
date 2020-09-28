/**Gets the distribution of transactions by hour for the length of the log */ 

;WITH
    ByDateHour
    AS
    (
        SELECT COUNT(*) AS Cnt   
        , CAST([Begin Time] AS DATE) AS Date_Day
        , DATEPART(hour, [Begin Time]) AS Date_Hour
        FROM fn_dblog(NULL, NULL)
        WHERE [Operation] = 'LOP_BEGIN_XACT'
        GROUP BY CAST([Begin Time] AS DATE)
        , DATEPART(hour, [Begin Time])
    ) --gets count of transactions by hour of each day 
,
    AvgPerHours
    AS
    (
        SELECT AVG(Cnt) AS AvgPerHour
        , Date_Hour
        FROM ByDateHour
        GROUP BY Date_Hour
    )
--gets the average transaction per hour
SELECT Date_Hour AS HourOfDay
    , ROUND((
            PERCENT_RANK() OVER (
                ORDER BY AvgPerHour
                )
            ) * 100, 2) AS PercentAvgTrx
--ranks the hour by percentage of  transactions done.
FROM AvgPerHours
ORDER BY 2 DESC --Have to order by ordinal because of the window function.
