DROP FUNCTION IF EXISTS isValidSpanishNIF $$

CREATE FUNCTION isValidSpanishNIF( docNumber VARCHAR(15) )
    RETURNS VARCHAR(1)
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Validates a Spanish identification number (only accepts NIF numbers)'
BEGIN
    /*
	This function validates a Spanish identification number
	verifying its control digits.
	
	This function is intended to work with NIF numbers.

	This function is used by:
	    - isValidSpanishDoc
	
	This function requires:
	    - isValidSpanishNIFFormat
	
	This function returns:
	    1: If specified identification number is correct
	    0: Otherwise

	Algorithm works as described in:
	    http://www.interior.gob.es/dni-8/calculo-del-digito-de-control-del-nif-nie-2217

	Usage:
	    SELECT isValidSpanishNIF( '33576428Q' )
	Returns:
	    1
    */

    DECLARE isValid INT;
    DECLARE fixedDocNumber VARCHAR(15);
    DECLARE keyString VARCHAR(23);

    DECLARE position INT;
    DECLARE writtenLetter VARCHAR(1);
    DECLARE correctLetter VARCHAR(1);
     
    SET keyString = 'TRWAGMYFPDXBNJZSQVHLCKE';
    SET isValid = 0;
  
    SET fixedDocNumber =
	UPPER( CASE
	    WHEN LEFT( docNumber, 1 ) NOT REGEXP '^[[:alpha:]]' THEN
		RIGHT( CONCAT( '00000000', docNumber ), 9 )
	    ELSE docNumber END );

    SET writtenLetter = RIGHT( fixedDocNumber, 1 );
        
    IF ( isValidSpanishNIFFormat ( fixedDocNumber ) = 1 ) THEN
	SET fixedDocNumber = REPLACE(fixedDocNumber, 'K', '0');
	SET fixedDocNumber = REPLACE(fixedDocNumber, 'L', '0');
	SET fixedDocNumber = REPLACE(fixedDocNumber, 'M', '0');

	SET position = LEFT(fixedDocNumber, 8) % 23;
	SET correctLetter = SUBSTRING( keyString, position + 1, 1 );
	
	IF ( writtenLetter = correctLetter ) THEN
	    SET isValid = 1;
	END IF;
    END IF;
    
    RETURN isValid;
END $$