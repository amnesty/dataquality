DROP FUNCTION IF EXISTS isValidSpanishNIE $$

CREATE FUNCTION isValidSpanishNIE( docNumber VARCHAR(15) )
    RETURNS INTEGER
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Validates a Spanish identification number (only accepts NIE numbers)'
BEGIN
    /*
	This function validates a Spanish identification number
	verifying its control digits.
	
	This function is intended to work with NIE numbers.

	This function is used by:
	    - isValidSpanishDoc
	
	This function requires:
	    - isValidSpanishNIEFormat
	    - isValidSpanishNIF
	
	This function returns:
	    1: If specified identification number is correct
	    0: Otherwise

	Algorithm works as described in:
	    http://www.interior.gob.es/dni-8/calculo-del-digito-de-control-del-nif-nie-2217

	Usage:
	    SELECT isValidSpanishNIE( 'X6089822C' )
	Returns:
	    1
    */

    DECLARE isValid INT;
    DECLARE fixedDocNumber VARCHAR(15);
   
    SET isValid = 0;
  
    SET fixedDocNumber = UPPER( CASE WHEN LEFT( docNumber, 1 ) NOT REGEXP '^[[:alpha:]]' THEN
        RIGHT( CONCAT( '00000000', docNumber ), 9 ) ELSE docNumber END );
    
    IF ( isValidSpanishNIEFormat( fixedDocNumber ) = 1 ) THEN
        IF ( fixedDocNumber LIKE 'T%') THEN
            SET isValid = 1;
	ELSE
	    /* The algorithm for validating the control digits of a NIE number is
		identical to the altorithm for validating NIF numbers. We only have to
		replace Y, X and Z with 1, 0 and 2 respectively; and then, run
		the NIF altorithm, */
	    SET fixedDocNumber = REPLACE(fixedDocNumber, 'Y', '1');
	    SET fixedDocNumber = REPLACE(fixedDocNumber, 'X', '0');
    	    SET fixedDocNumber = REPLACE(fixedDocNumber, 'Z', '2');
	    
	    SET isValid = isValidSpanishNIF( fixedDocNumber );
        END IF;
    END IF;
    
    RETURN isValid;
END $$