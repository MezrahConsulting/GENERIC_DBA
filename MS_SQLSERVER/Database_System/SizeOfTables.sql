/**This gets the size of all tables in the database as Bytes 
    Dave Babler*/


SELECT sob.name AS [Table_Name], SUM(sys.length) AS [Size_Table(Bytes)]  
FROM sysobjects sob, syscolumns sys  
WHERE sob.xtype='u' AND sys.id=sob.id  
GROUP BY sob.name