DROP FUNCTION IF EXISTS getSpanishDocTypeDescription $$

CREATE FUNCTION getSpanishDocTypeDescription( docNumber VARCHAR(15) )
    RETURNS VARCHAR(255)
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Obtains document type description for Spanish identification numbers'
BEGIN
    /*
	This function obtains the description of a document type
	for Spanish identification number.
	
	For instance, if A83217281 is passed, it returns "Sociedad Anónima".
	
	This function requires:
	    - spanishDocTypeDescriptions (table)
	    - isValidSpanishCIFFormat
	    - isValidSpanishNIEFormat
	    - isValidSpanishNIFFormat
	
	Usage:
	    SELECT getSpanishDocTypeDescription( 'H67905364' )
	Returns:
	    Comunidad de propietarios en régimen de propiedad horizontal
    */
    
    DECLARE firstChar VARCHAR(1);
    DECLARE docTypeDescription VARCHAR(255);

    SET docTypeDescription = '';
    SET firstChar = LEFT(docNumber, 1);

    IF (isValidSpanishNIFFormat( docNumber ) = 1 OR
	isValidSpanishNIEFormat( docNumber ) = 1 OR
	isValidSpanishCIFFormat( docNumber ) = 1 ) THEN
	
	SET docTypeDescription =
	    ( SELECT description FROM spanishDocTypeDescriptions
		    WHERE id = firstChar LIMIT 1 );
    END IF;
    
    RETURN IFNULL(docTypeDescription, '');
END $$