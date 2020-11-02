/**This will give you the full list of the foreign keys in a databASe 
including the type of relation.
--Dave Babler
*/

SELECT schema_name(FK_TAB.schema_id) + '.' + FK_TAB.name AS foreign_table,
    '>-' AS rel,
    schema_name(PK_TAB.schema_id) + '.' + PK_TAB.name AS primary_table,
    SUBSTRING(column_names, 1, len(column_names)-1) AS [fk_columns],
    FK.name AS fk_constraint_name
FROM sys.foreign_keys FK
    INNER JOIN sys.tables FK_TAB
        ON FK_TAB.object_id = FK.parent_object_id
    INNER JOIN sys.tables PK_TAB
        ON PK_TAB.object_id = FK.referenced_object_id
    CROSS APPLY (SELECT COL.[name] + ', '
                    FROM sys.foreign_key_columns FK_C
                        INNER JOIN sys.columns COL
                            ON FK_C.parent_object_id = COL.object_id
                            AND FK_C.parent_column_id = COL.column_id
                    WHERE FK_C.parent_object_id = FK_TAB.object_id
                      AND FK_C.constraint_object_id = FK.object_id
                            ORDER BY COL.column_id
                            for xml path ('') ) D (column_names)
ORDER BY schema_name(FK_TAB.schema_id) + '.' + FK_TAB.name,
    schema_name(PK_TAB.schema_id) + '.' + PK_TAB.name
