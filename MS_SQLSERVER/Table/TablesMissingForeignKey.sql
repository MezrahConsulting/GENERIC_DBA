/**Gets tables that are missing foreign keys
    -- Dave Babler */
    
SELECT name AS [Table_Name]  
FROM sys.tables  
WHERE OBJECTPROPERTY(OBJECT_ID,'TableHasForeignKey') = 0  
ORDER BY Table_Name;  