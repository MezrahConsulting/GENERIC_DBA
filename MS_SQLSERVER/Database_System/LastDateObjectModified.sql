/**This gets the last date the object was modified on SQLSERVER
    Dave Babler */

DECLARE @N int;
SET @N = ; --you set this!

SELECT name, modify_date  
FROM sys.objects  
WHERE type='P'  
AND DATEDIFF(D,modify_date,GETDATE())< @N  