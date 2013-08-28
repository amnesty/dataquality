DROP FUNCTION IF EXISTS isValidSpanishCIF $$

CREATE FUNCTION isValidSpanishCIF( docNumber VARCHAR(15) )
    RETURNS INTEGER
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Validates a Spanish identification number (only accepts CIF numbers)'
BEGIN
    /*
	This function validates a Spanish identification number
	verifying its control digits.
	
	This function is intended to work with CIF numbers.

	This function is used by:
	    - isValidSpanishDoc
	
	This function requires:
	    - isValidSpanishCIFFormat
	    - getSpanishCIFControl
	
	This function returns:
	    1: If specified identification number is correct
	    0: Otherwise

	CIF numbers structure is defined at:
	    BOE number 49. February 26th, 2008 (article 2)

	Usage:
	    SELECT isValidSpanishNIE( 'X6089822C' )
	Returns:
	    1
    */  
    
    DECLARE isValid VARCHAR(15);
    DECLARE fixedDocNumber VARCHAR(15);
    
    DECLARE correctDigit VARCHAR(1);
    DECLARE writtenDigit VARCHAR(1);
    
    SET isValid = 0;
    SET fixedDocNumber = UPPER( docNumber );
    SET writtenDigit = RIGHT( fixedDocNumber, 1 );
        
    IF ( isValidSpanishCIFFormat( fixedDocNumber ) = 1 ) THEN
	SET correctDigit = getSpanishCIFControl( fixedDocNumber );
		
	IF ( writtenDigit = correctDigit ) THEN
	    SET isValid = 1;
	END IF;
    END IF;

    RETURN isValid;
END $$