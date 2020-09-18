-- =============================================
-- Author:		Dave Babler
-- Create date: 9/11/2020
-- Description:	Used for quickly making comparisons when determining foreign keys on non-defined-relations
-- Subprocedures: 1. DD_ColumnCompare
-- WARNING: will not work with tables that have been defined as a keyword (looking at you 'plan')
-- =============================================
CREATE OR ALTER PROCEDURE DD_ParentToChildComparison 
    -- Add the parameters for the stored procedure here
    @strParentTable VARCHAR(64), 
    @strParentColumn VARCHAR(64),
    @strChildTable VARCHAR(64), 
    @strChildColumn VARCHAR(64) 
AS
BEGIN TRY 
    SET NOCOUNT ON;
    DECLARE @intChildTableSAFE INT --pay attention to this Fernando
    , @intParentTableSAFE INT -- again LOOK AT ME Fernando, I'm very important!!!!
    , @SQLUNION NVARCHAR(max)
    , @TSQLParameterDefinitionsFull NVARCHAR(500)
    , @TSQLParameterDefinitionsCount NVARCHAR(500)
    , @SQLORPHANS NVARCHAR(MAX)
    , @SQLORPHANCHECK NVARCHAR(MAX)
    , @intRowCount INT;

    SET @TSQLParameterDefinitionsFull = N'@strChildColumn_ph VARCHAR(64)
                                        , @strParentColumn_ph VARCHAR(64)';
    SET @TSQLParameterDefinitionsCount = N' @intRowCount INT OUTPUT
                                        , @strChildColumn_ph VARCHAR(64)
                                        , @strParentColumn_ph VARCHAR(64)
                                        ';
    SET @intChildTableSAFE = OBJECT_ID(@strChildTable);--will not parse if malformed or injected --Dave Babler
    SET @intParentTableSAFE = OBJECT_ID(@strParentTable) -- same as above; tables are DANGEROUS if not protected in dynamic 

    
    EXEC DD_ColumnCompare @strChildTable
        , @strChildColumn
        , @strParentTable
        , @strParentColumn;


        --ph for placeholder
        SET @SQLUNION = N'SELECT MAX(LEN(@strChildColumn_ph))	AS Length , @strChildColumn_ph AS ColumnName FROM ' + OBJECT_NAME(
                @intChildTableSAFE) + ' UNION ALL

        SELECT MAX(LEN(@strParentColumn_ph))
            , @strParentColumn_ph
        FROM ' + 
            OBJECT_NAME(@intParentTableSAFE) + '';

        EXEC sp_executesql @SQLUNION
            , @TSQLParameterDefinitionsFull
            , @strChildColumn_ph = @strChildColumn
            , @strParentColumn_ph = @strParentColumn;

       SET @SQLORPHANCHECK = N'
            SELECT @intRowCount = COUNT(' + @strChildColumn + ')  
            FROM ' + OBJECT_NAME(@intChildTableSAFE) + '
            WHERE ' + 
            @strChildColumn + '  NOT IN  (
                                                SELECT ' + @strParentColumn + 
            '
                                                FROM ' + OBJECT_NAME(@intParentTableSAFE) + 
            '                                                     
                                            )';
        PRINT @SQLORPHANCHECK;
  
        
        EXEC  sp_executesql @SQLORPHANS
            , @TSQLParameterDefinitionsCount
            , @intRowCount OUTPUT
            , @strChildColumn_ph = @strChildColumn
            , @strParentColumn_ph = @strParentColumn;
        PRINT '000000000000000000000000';
        PRINT @intRowCount;
        SELECT @intRowCount [Orphans to Kill];   

        SET @SQLORPHANS = N'
            SELECT ' + @strChildColumn + ' [Orphans]
            FROM ' + OBJECT_NAME(@intChildTableSAFE) + '
            WHERE ' + 
            @strChildColumn + '  NOT IN  (
                                                SELECT ' + @strParentColumn + 
            '
                                                FROM ' + OBJECT_NAME(@intParentTableSAFE) + 
            '                                                     
                                            )';

        EXEC  sp_executesql @SQLORPHANS;   

         PRINT @SQLORPHANS;
        END TRY 


BEGIN CATCH
    INSERT INTO dbo.DB_EXCEPTION_TANK
    VALUES (
        SUSER_SNAME()
        , ERROR_NUMBER()
        , ERROR_STATE()
        , ERROR_SEVERITY()
        , ERROR_PROCEDURE()
        , ERROR_LINE()
        , ERROR_MESSAGE()
        , GETDATE()
        );
END CATCH;
