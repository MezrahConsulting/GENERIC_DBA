SELECT schema_name(TAB.schema_id) + '.' + TAB.name AS [table], 
       COUNT (*) AS [columns]
FROM sys.tables AS TAB
        inner join sys.columns AS COL
            ON TAB.object_id = COL.object_id
GROUP BY schema_name(TAB.schema_id), 
       TAB.name
ORDER BY COUNT (*) DESC