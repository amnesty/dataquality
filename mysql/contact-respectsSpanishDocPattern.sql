DROP FUNCTION IF EXISTS respectsSpanishDocPattern $$

CREATE FUNCTION respectsSpanishDocPattern( givenString VARCHAR(15), pattern VARCHAR(64) )
    RETURNS INTEGER
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Validates a given string respects a regexp pattern'
BEGIN
    /*
	This function validates the format of a given string in order to
	see if it fits a regexp pattern.
	
	This function is intended to work with Spanish identification
	numbers, so it always checks string length (should be 9) and
	accepts the absence of leading zeros.
	
	This function is used by:
	    - isValidSpanishNIFFormat
	    - isValidSpanishNIEFormat
	    - isValidSpanishCIFFormat

	This function returns:
	    1: If specified string respects the pattern
	    0: Otherwise

	Usage:
	    SELECT respectsPattern(
		'33576428Q',
		'[KLM0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z]' )
	Returns:
	    1
    */
    
    DECLARE isValid INT;
    DECLARE fixedString VARCHAR(15);

    SET isValid = 0;
    
    SET fixedString = UPPER( RIGHT( CONCAT( '00000000', givenString ), 9 ) );
    
    IF ( LENGTH( fixedString ) = 9 AND fixedString REGEXP pattern ) THEN
	SET isValid = 1;
    END IF;
    
    RETURN isValid;
END $$