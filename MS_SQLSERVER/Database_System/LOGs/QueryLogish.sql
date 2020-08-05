/**This is about as good of a quick look at the query log as you'll get.
It isn't great, sorry --Dave Babler */

SELECT  *
    --use only text to see relevant query information
FROM    
  sys.dm_exec_query_stats STATS
CROSS APPLY 
  sys.dm_exec_sql_text(STATS.sql_handle) 
 -- Note that this is a function which takes in sql_handle as parameter
ORDER BY last_execution_time DESC