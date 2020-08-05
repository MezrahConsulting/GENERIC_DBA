/** The syntax to pull data from the error log

--Dave Babler */


Exec xp_ReadErrorLog  int LogNumber,  int LogType, N'SearchItem1', N'StartDate', N'EndDate', N'ASC OR DESC';