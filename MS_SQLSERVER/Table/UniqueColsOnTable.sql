DECLARE @strTableName varchar(100), @strSQLSelect varchar(max);
SET @strTableName = 'Policy_SF';

SELECT
  @strSQLSelect = COALESCE(@strSQLSelect + ', ', '') + ColumnExpression
FROM (
  SELECT
    ColumnExpression =
      'CASE COUNT(DISTINCT ' + COLUMN_NAME + ') ' 
      + 'WHEN COUNT(*) THEN ''UNIQUE'' ' 
      + 'WHEN COUNT(*) - 1 THEN ' 
      + 'CASE COUNT(DISTINCT ' + COLUMN_NAME + ') ' 
      + 'WHEN COUNT(' + COLUMN_NAME + ') THEN ''UNIQUE WITH SINGLE NULL'' ' 
      + 'ELSE '''' ' 
      + 'END ' 
      + 'WHEN COUNT(' + COLUMN_NAME + ') THEN ''UNIQUE with NULLs'' ' 
      + 'ELSE '''' ' 
      + 'END AS ' + COLUMN_NAME
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = @strTableName
) s

SET @strSQLSelect = 'SELECT ' + @strSQLSelect + ' FROM ' + @strTableName;

EXEC(@strSQLSelect);



/**UNIQUE means no duplicate values and no NULLs (can either be a PK or have a unique constraint/index);

UNIQUE WITH SINGLE NULL – as can be guessed, no duplicates, but there's one NULL (cannot be a PK, but can have a unique constraint/index);

UNIQUE with NULLs – no duplicates, two or more NULLs (in theory we could a conditional unique index for non-NULL values only);

empty string – there are duplicates, possibly NULLs too.*/