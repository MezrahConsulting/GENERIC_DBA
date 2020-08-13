/**This tells you if it's gonna be safe to create the relationship
--Dave Babler*/

SELECT [FK_COL] 
FROM [[FK_TABLE]]
WHERE [FK_COL] NOT IN 
                ( 
                    SELECT [PK_COL]
                    FROM [[PK_TABLE]]
                )