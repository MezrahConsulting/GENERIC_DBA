--all scripts orginally came from https://www.sqlshack.com/forecast-sql-backup-size/ 
--most have been modified by Dave Babler
EXEC sp_spaceused @updateusage = 'true';

SELECT 
 DATEPART(MONTH,backup_finish_date) AS [BackupMonth] ,
 (AVG(msdb.dbo.backupset.backup_size)/1048576) as [BackupSize (MB)] ,
DATEPART(YEAR,backup_finish_date)  AS [BackupYear],
msdb.dbo.backupset.database_name
 
 
FROM msdb.dbo.backupmediafamily 
INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id 
WHERE  msdb..backupset.type='D' 
AND database_name='Mapbenefits'
and DATEPART(YEAR,backup_finish_date)=DATEPART(YEAR,GETDATE())
GROUP BY msdb.dbo.backupset.database_name 
, DATEPART(MONTH,backup_finish_date) ,
DATEPART(YEAR,backup_finish_date) 
order by  
 DATEPART(MONTH,backup_finish_date)
 Asc

execute sp_execute_external_script
    @language = N'R',
    @script = N' mybackupdata  &lt;- SQLIn;
                SQLOut &lt;- data.frame(cor(mybackupdata))
				',
    @input_data_1 = N'SELECT 
 DATEPART(MONTH,backup_finish_date) AS [X] ,
ROUND((AVG(msdb.dbo.backupset.backup_size)/1048576),0) as [Y]
FROM msdb.dbo.backupmediafamily 
INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id 
WHERE  msdb..backupset.type=''D'' 
AND database_name=''mapbenefits''
AND DATEPART(YEAR,backup_finish_date)=DATEPART(YEAR,GETDATE())
GROUP BY msdb.dbo.backupset.database_name 
, DATEPART(MONTH,backup_finish_date) ,
DATEPART(YEAR,backup_finish_date) ',
    @input_data_1_name = N'SQLIn',
    @output_data_1_name = N'SQLOut'
with result sets ((XCof Int, Ycof Int));