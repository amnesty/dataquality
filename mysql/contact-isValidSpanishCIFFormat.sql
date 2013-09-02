DROP FUNCTION IF EXISTS isValidSpanishCIFFormat $$

CREATE FUNCTION isValidSpanishCIFFormat( docNumber VARCHAR(15) )
    RETURNS INTEGER
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Validates the format of a given string against CIF pattern'
BEGIN
    /*
        This function validates the format of a given string in order to
        see if it fits with CIF format. Practically, it performs a validation
        over a CIF, except this function doesn't check the control digit.

        This function is intended to work with CIF numbers.

        This function is used by:
            - isValidSpanishDoc
            - isValidSpanishCIF

        This function requires:
            - respectsSpanishDocPattern

        This function returns:
            1: If specified string respects CIF format
            0: Otherwise

        Usage:
            SELECT isValidSpanishCIFFormat( 'H24930836' )
        Returns:
            1
    */

    RETURN
        respectsSpanishDocPattern(
            docNumber,
            '[PQSNWR][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z]' )
    OR
        respectsSpanishDocPattern(
            docNumber,
            '[ABCDEFGHJUV][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' );    
END $$
