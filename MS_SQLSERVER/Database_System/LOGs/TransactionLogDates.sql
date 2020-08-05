SELECT [Current LSN]
	, [Operation]
	, [Transaction ID]
	, [Parent Transaction ID]
	, [Begin Time]
	, [Transaction Name]
	, [Transaction SID]
FROM fn_dblog(NULL, NULL)
WHERE [Operation] = 'LOP_BEGIN_XACT'
