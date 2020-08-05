/**This is best run on a PRODUCTION database because you're not going to be 
* doing as many CRUD in development, so run it during a slow time
* --Dave Babler*/


--get columns helpful for determining insert, update, and delete operations

SELECT OBJECT_NAME(A.[OBJECT_ID]) AS [OBJECT NAME] 
       , I.[NAME] AS [INDEX NAME] 
       , A.LEAF_INSERT_COUNT 
       , A.LEAF_UPDATE_COUNT
       , A.LEAF_DELETE_COUNT 
FROM   SYS.DM_DB_INDEX_OPERATIONAL_STATS (NULL,NULL,NULL,NULL ) A 
       INNER JOIN SYS.INDEXES AS I 
         ON I.[OBJECT_ID] = A.[OBJECT_ID] 
            AND I.INDEX_ID = A.INDEX_ID 
WHERE  OBJECTPROPERTY(A.[OBJECT_ID],'IsUserTable') = 1


--get reads 

SELECT   OBJECT_NAME(S.[OBJECT_ID]) AS [OBJECT NAME]
         , I.[NAME] AS [INDEX NAME]
         , USER_SEEKS 
         , USER_SCANS 
         , USER_LOOKUPS 
         , USER_UPDATES 
FROM     SYS.DM_DB_INDEX_USAGE_STATS AS S 
         INNER JOIN SYS.INDEXES AS I 
           ON I.[OBJECT_ID] = S.[OBJECT_ID] 
              AND I.INDEX_ID = S.INDEX_ID 
WHERE    OBJECTPROPERTY(S.[OBJECT_ID],'IsUserTable') = 1 