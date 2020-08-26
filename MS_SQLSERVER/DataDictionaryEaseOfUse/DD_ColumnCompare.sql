DECLARE @strTableName1 VARCHAR(64);
DECLARE @strTableName2 VARCHAR(64);
DECLARE @strColumnName1 VARCHAR(64);
DECLARE @strColumnName2 VARCHAR(64);
SET  @strTableName1 = 'ParticipantTrades';
SET  @strTableName2 = 'fundd';
SET  @strColumnName1 = 'Fund';
SET  @strColumnName2 = 'UID';
DECLARE @strErrorMessage VARCHAR(MAX) = 'This is the first error I have encountered, you may have more: ';
DECLARE @strErrorBuilder VARCHAR(MAX);
--not doing recursive error checking for this, sorry. -- Dave Babler
DECLARE @boolOKToProceed BIT = NULL;

BEGIN
	EXEC DD_TableExist @strTableName1
		, @boolOKToProceed OUTPUT
		, @strErrorBuilder OUTPUT;

	IF @boolOKToProceed = 1
	BEGIN
		--RESET THE FLAG and message holder
		SET @boolOKToProceed = NULL;
		SET @strErrorMessage = NULL;

		--CHECK THE COLUMN 
		EXEC DD_ColumnExist @strTableName1
            , @strColumnName1
			, @boolOKToProceed OUTPUT
			, @strErrorBuilder OUTPUT;

		IF @boolOKToProceed = 1
		BEGIN
			--RESET THE FLAG and message holder
			SET @boolOKToProceed = NULL;
			SET @strErrorMessage = NULL;

			--CHECK TABLE 2
			EXEC DD_TableExist @strTableName2
				, @boolOKToProceed OUTPUT
				, @strErrorBuilder OUTPUT;

			IF @boolOKToProceed = 1
			BEGIN
				--RESET THE FLAG and message holder
				SET @boolOKToProceed = NULL;
				SET @strErrorMessage = NULL;

				--CHECK COLUMN 2
				EXEC DD_ColumnExist @strTableName2 
                    , @strColumnName2
					, @boolOKToProceed OUTPUT
					, @strErrorBuilder OUTPUT;

				IF @boolOKToProceed = 1
					/**FINALLY WE CAN CHECK THE COLUMNS VS EACH OTHER!*/
				BEGIN
					SELECT TABLE_NAME
						, COLUMN_NAME
						, DATA_TYPE
						, CHARACTER_MAXIMUM_LENGTH
						, CHARACTER_SET_NAME
						, COLLATION_NAME
					FROM INFORMATION_SCHEMA.COLUMNS c
					WHERE TABLE_NAME = @strTableName1
						AND COLUMN_NAME = @strColumnName1
					
					UNION
					
					SELECT TABLE_NAME
						, COLUMN_NAME
						, DATA_TYPE
						, CHARACTER_MAXIMUM_LENGTH
						, CHARACTER_SET_NAME
						, COLLATION_NAME
					FROM INFORMATION_SCHEMA.COLUMNS c
					WHERE TABLE_NAME = @strTableName2
						AND COLUMN_NAME = @strColumnName2
				END -- SECOND COLUMN SUCCESS END
				ELSE
					SET @strErrorMessage += @strErrorBuilder;

				SELECT @strErrorMessage AS 'ERROR!';
			END
		END -- SECOND TABLE SUCCESS END
		ELSE
		BEGIN
			SET @strErrorMessage += @strErrorBuilder;

			SELECT @strErrorMessage AS 'ERROR!';
		END
	END --FIRST COLUMN CHECK SUCCESS END
	ELSE
	BEGIN
		SET @strErrorMessage += @strErrorBuilder;

		SELECT @strErrorMessage AS 'ERROR!';
	END
END --FIRST TABLE CHECK SUCCESS END
	/** I AM VERY TEMPTED TO TURN THE ERROR BUILDER INTO ITS OWN PROC BUT 
    * THAT MIGHT BE OVERKILL?
    *  Dave Babler -- 2020-08-26*/
