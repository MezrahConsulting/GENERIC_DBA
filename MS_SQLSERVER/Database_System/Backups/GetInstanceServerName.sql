SET NOCOUNT ON

DECLARE @key VARCHAR(100)
	, @PortNumber VARCHAR(20)

IF charindex('\', CONVERT(CHAR(20), SERVERPROPERTY('servername')), 0) <> 0
BEGIN
	SET @key = 'SOFTWARE\MICROSOFT\Microsoft SQL Server\' + @@servicename + '\MSSQLServer\Supersocketnetlib\TCP'
END
ELSE
BEGIN
	SET @key = 'SOFTWARE\MICROSOFT\MSSQLServer\MSSQLServer\Supersocketnetlib\TCP'
END

EXEC master..xp_regread @rootkey = 'HKEY_LOCAL_MACHINE'
	, @key = @key
	, @value_name = 'Tcpport'
	, @value = @PortNumber OUTPUT

SELECT CONVERT(CHAR(20), SERVERPROPERTY('servername')) ServerName
	, CONVERT(CHAR(20), SERVERPROPERTY('InstanceName')) instancename
	, CONVERT(CHAR(20), SERVERPROPERTY('MachineName')) AS HOSTNAME
	, convert(VARCHAR(10), @PortNumber) PortNumber
