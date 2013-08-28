DROP FUNCTION IF EXISTS isValidSpanishNIEFormat $$

CREATE FUNCTION isValidSpanishNIEFormat( docNumber VARCHAR(15) )
    RETURNS INTEGER
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Validates the format of a given string against NIE pattern'
BEGIN
    /*
	This function validates the format of a given string in order to
	see if it fits with NIE format. Practically, it performs a validation
	over a NIE, except this function doesn't check the control digit.
	
	This function is intended to work with NIE numbers.

	This function is used by:
	    - isValidSpanishDoc
	    - isValidSpanishNIE

	This function returns:
	    1: If specified string respects NIE format
	    0: Otherwise

	Usage:
	    SELECT isValidSpanishNIEFormat( 'X6089822C' )
	Returns:
	    1
    */

    RETURN respectsSpanishDocPattern(
	docNumber,
	'[XYZT][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z0-9]' );
END $$