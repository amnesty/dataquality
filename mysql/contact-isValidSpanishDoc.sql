DROP FUNCTION IF EXISTS isValidSpanishDoc $$

CREATE FUNCTION isValidSpanishDoc( docNumber VARCHAR(15) )
    RETURNS INTEGER
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Validates a Spanish identification number'
BEGIN
    /*
	This function validates a Spanish identification number
	verifying its control digits.
	
	NIFs and NIEs are personal numbers.
	CIFs are corporates.
	
	This function requires:
	    - isValidSpanishCIF and isValidSpanishCIFFormat
	    - isValidSpanishNIE and isValidSpanishNIEFormat
	    - isValidSpanishNIF and isValidSpanishNIFFormat
	
	This function returns:
	    1: If specified identification number is correct
	    0: Otherwise
	    
	Usage:
	    SELECT
		isValidSpanishDoc( 'G28667152' )
	Returns:
	    1
    */

    DECLARE fixedDocNumber VARCHAR(15);
    SET fixedDocNumber = UPPER( docNumber );

    IF ( isValidSpanishNIFFormat( fixedDocNumber ) = 1 ) THEN
        RETURN isValidSpanishNIF( fixedDocNumber );
    ELSE
	IF ( isValidSpanishNIEFormat( fixedDocNumber ) = 1 ) THEN
	    RETURN isValidSpanishNIE( fixedDocNumber );
	ELSE
	    IF ( isValidSpanishCIFFormat( fixedDocNumber ) = 1 ) THEN
		RETURN isValidSpanishCIF( fixedDocNumber );
	    ELSE
		RETURN 0;
	    END IF;
	END IF;
    END IF;
END $$