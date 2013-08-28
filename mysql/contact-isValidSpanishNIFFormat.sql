DROP FUNCTION IF EXISTS isValidSpanishNIFFormat $$

CREATE FUNCTION isValidSpanishNIFFormat( docNumber VARCHAR(15) )
    RETURNS INTEGER
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Validates the format of a given string against NIF pattern'
BEGIN
    /*
	This function validates the format of a given string in order to
	see if it fits with NIF format. Practically, it performs a validation
	over a NIF, except this function doesn't check the control digit.
	
	This function is intended to work with NIF numbers.

	This function is used by:
	    - isValidSpanishDoc
	    - isValidSpanishNIF

	This function returns:
	    1: If specified string respects NIF format
	    0: Otherwise

	Usage:
	    SELECT isValidSpanishNIFFormat( '33576428Q' )
	Returns:
	    1
    */
        
    RETURN respectsSpanishDocPattern(
	docNumber,
	'[KLM0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z]' );
END $$