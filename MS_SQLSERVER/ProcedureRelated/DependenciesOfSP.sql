/** This --usually-- gets a list of all the objects that depend on a 
    Stored Procedure
    -- Dave Babler */

;WITH stored_procedures AS (  
  
SELECT  
OO.name AS table_name,  
ROW_NUMBER() OVER(partition by O.name,OO.name ORDER BY O.name,OO.name) AS row  
FROM sysdepends D 
INNER JOIN sysobjects O ON O.id=D.id   
INNER JOIN sysobjects OO ON OO.id=D.depid  
WHERE O.xtype = 'P' AND O.name LIKE '%SP_NAme%' )    

SELECT Table_name FROM stored_procedures  
WHERE row = 1  
