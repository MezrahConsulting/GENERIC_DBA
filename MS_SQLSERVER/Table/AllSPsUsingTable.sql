/**Gets the stored procedures that call a table, assuming 
    1. the table names are quite distinctive
    2. they are not used in any weird concatenations when called in the stored procedures 

    -- Dave Babler
    */

SELECT DISTINCT O.name, O.xtype
FROM syscomments C
    INNER JOIN sysobjects O ON C.id=O.id 
WHERE C.TEXT LIKE '%%' AND O.xtype='P';


--Alternatative but with less options

EXEC sp_depends @objname = N'';  --fill in the table name between the two quotes!!!