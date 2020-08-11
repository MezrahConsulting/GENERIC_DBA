/** Use this to determine how efficiently the proc is working with the dataset
* alternatively you can use it to see how vicciously your proc is attacking the server.
*  Dave Babler */


SET SHOWPLAN_ALL ON
GO

-- FMTONLY will not exec stored proc
SET FMTONLY ON
GO

EXEC [yourproc]
GO

SET FMTONLY OFF
GO

SET SHOWPLAN_ALL OFF
GO