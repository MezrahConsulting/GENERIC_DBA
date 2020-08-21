DECLARE @intRowCountTable1 AS INT

SELECT @intRowCountTable1 = count(*)
FROM TABLE1
/**Make me into a dynamic stored procedure */
DECLARE @intRowCountTable2 AS INT

SELECT @intRowCountTable2 = count(*)
FROM TABLE2

DECLARE @intRowCountMergedTables AS INT

SELECT @intRowCountMergedTables = count(*)
FROM (
	SELECT *
	FROM TABLE1
	
	UNION
	
	SELECT *
	FROM TABLE2
	) T

IF @intRowCountTable1 >= @intRowCountMergedTables --Can also check as @intRowCountTable2=@intRowCountMergedTables
BEGIN
	PRINT 'Very high probability of identical data (99+%), UNION created same number of rows.'
	PRINT 'Row Count in first table is ' + convert(VARCHAR(3), @intRowCountTable1)
	PRINT 'Row Count in second table is ' + convert(VARCHAR(3), @intRowCountTable2)
	PRINT 'Row count in merge of first and second tables ' + convert(VARCHAR(3), @intRowCountMergedTables)
END
ELSE
BEGIN
	PRINT 'The tables are not identical; the data is different somewhere'
	PRINT 'Row Count in first table is ' + convert(VARCHAR(3), @intRowCountTable1)
	PRINT 'Row Count in second table is ' + convert(VARCHAR(3), @intRowCountTable2)
	PRINT 'Row count in merge of first and second tables ' + convert(VARCHAR(3), @intRowCountMergedTables)
END


--maybe also add a checksum validation?