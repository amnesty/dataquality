DROP FUNCTION IF EXISTS isValidIdNumber $$

CREATE FUNCTION isValidIdNumber( docNumber VARCHAR(15) )
    RETURNS INTEGER
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Validates a Spanish identification number'
BEGIN
    /*
        This function validates a Spanish identification number
        verifying its check digits.

        NIFs and NIEs are personal numbers.
        CIFs are corporates.

        This function requires:
            - isValidCIF and isValidCIFFormat
            - isValidNIE and isValidNIEFormat
            - isValidNIF and isValidNIFFormat

        This function returns:
            1: If specified identification number is correct
            0: Otherwise

        Usage:
            SELECT isValidIdNumber( 'G28667152' );
        Returns:
            1
    */

    DECLARE fixedDocNumber VARCHAR(15);
    SET fixedDocNumber = UPPER( docNumber );

    IF ( isValidNIFFormat( fixedDocNumber ) = 1 ) THEN
        RETURN isValidNIF( fixedDocNumber );
    ELSE
        IF ( isValidNIEFormat( fixedDocNumber ) = 1 ) THEN
            RETURN isValidNIE( fixedDocNumber );
        ELSE
            IF ( isValidCIFFormat( fixedDocNumber ) = 1 ) THEN
                RETURN isValidCIF( fixedDocNumber );
            ELSE
                RETURN 0;
            END IF;
        END IF;
    END IF;
END $$

DROP FUNCTION IF EXISTS isValidNIF $$

CREATE FUNCTION isValidNIF( docNumber VARCHAR(15) )
    RETURNS VARCHAR(1)
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Validates a Spanish identification number (only accepts NIF numbers)'
BEGIN
    /*
        This function validates a Spanish identification number
        verifying its check digits.

        This function is intended to work with NIF numbers.

        This function is used by:
            - isValidIdNumber

        This function requires:
            - isValidCIFFormat
            - getNIFCheckDigit

        This function returns:
            1: If specified identification number is correct
            0: Otherwise

        Algorithm works as described in:
            http://www.interior.gob.es/dni-8/calculo-del-digito-de-control-del-nif-nie-2217

        Usage:
            SELECT isValidNIF( '33576428Q' );
        Returns:
            1
    */

    DECLARE isValid VARCHAR(15);
    DECLARE fixedDocNumber VARCHAR(15);
    
    DECLARE correctDigit VARCHAR(1);
    DECLARE writtenDigit VARCHAR(1);
    
    SET isValid = 0;
    SET fixedDocNumber =
        UPPER( CASE
            WHEN LEFT( docNumber, 1 ) NOT REGEXP '^[[:alpha:]]' THEN
                RIGHT( CONCAT( '00000000', docNumber ), 9 )
            ELSE
                docNumber END );
    SET writtenDigit = RIGHT( fixedDocNumber, 1 );
        
    IF ( isValidNIFFormat( fixedDocNumber ) = 1 ) THEN
        SET correctDigit = getNIFCheckDigit( fixedDocNumber );

        IF ( writtenDigit = correctDigit ) THEN
            SET isValid = 1;
        END IF;
    END IF;

    RETURN isValid;
END $$

DROP FUNCTION IF EXISTS isValidNIE $$

CREATE FUNCTION isValidNIE( docNumber VARCHAR(15) )
    RETURNS INTEGER
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Validates a Spanish identification number (only accepts NIE numbers)'
BEGIN
    /*
        This function validates a Spanish identification number
        verifying its check digits.

        This function is intended to work with NIE numbers.

        This function is used by:
            - isValidIdNumber

        This function requires:
            - isValidNIEFormat
            - isValidNIF

        This function returns:
            1: If specified identification number is correct
            0: Otherwise

        Algorithm works as described in:
            http://www.interior.gob.es/dni-8/calculo-del-digito-de-control-del-nif-nie-2217

        Usage:
            SELECT isValidNIE( 'X6089822C' )
        Returns:
            1
    */

    DECLARE isValid INT;
    DECLARE fixedDocNumber VARCHAR(15);
   
    SET isValid = 0;
  
    SET fixedDocNumber =
        UPPER( CASE
            WHEN LEFT( docNumber, 1 ) NOT REGEXP '^[[:alpha:]]' THEN
                RIGHT( CONCAT( '00000000', docNumber ), 9 )
            ELSE
                docNumber END );
    
    IF ( isValidNIEFormat( fixedDocNumber ) = 1 ) THEN
        IF ( fixedDocNumber LIKE 'T%') THEN
            SET isValid = 1;
        ELSE
            /* The algorithm for validating the check digits of a NIE number is
                identical to the altorithm for validating NIF numbers. We only have to
                replace Y, X and Z with 1, 0 and 2 respectively; and then, run
                the NIF altorithm */

            SET fixedDocNumber = REPLACE(fixedDocNumber, 'Y', '1');
            SET fixedDocNumber = REPLACE(fixedDocNumber, 'X', '0');
            SET fixedDocNumber = REPLACE(fixedDocNumber, 'Z', '2');

            SET isValid = isValidNIF( fixedDocNumber );
        END IF;
    END IF;
    
    RETURN isValid;
END $$

DROP FUNCTION IF EXISTS isValidCIF $$

CREATE FUNCTION isValidCIF( docNumber VARCHAR(15) )
    RETURNS INTEGER
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Validates a Spanish identification number (only accepts CIF numbers)'
BEGIN
    /*
        This function validates a Spanish identification number
        verifying its check digits.

        This function is intended to work with CIF numbers.

        This function is used by:
            - isValidIdNumber

        This function requires:
            - isValidCIFFormat
            - getCIFCheckDigit

        This function returns:
            1: If specified identification number is correct
            0: Otherwise

        CIF numbers structure is defined at:
        BOE number 49. February 26th, 2008 (article 2)

        Usage:
            SELECT isValidCIF( 'C4090266J' );
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
        
    IF ( isValidCIFFormat( fixedDocNumber ) = 1 ) THEN
        SET correctDigit = getCIFCheckDigit( fixedDocNumber );

        IF ( writtenDigit = correctDigit ) THEN
            SET isValid = 1;
        END IF;
    END IF;

    RETURN isValid;
END $$

DROP FUNCTION IF EXISTS isValidNIFFormat $$

CREATE FUNCTION isValidNIFFormat( docNumber VARCHAR(15) )
    RETURNS INTEGER
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Validates the format of a given string against NIF pattern'
BEGIN
    /*
        This function validates the format of a given string in order to
        see if it fits with NIF format. Practically, it performs a validation
        over a NIF, except this function does not check the check digit.

        This function is intended to work with NIF numbers.

        This function is used by:
            - isValidIdNumber
            - isValidNIF

        This function returns:
            1: If specified string respects NIF format
            0: Otherwise

        Usage:
            SELECT isValidNIFFormat( '33576428Q' )
        Returns:
            1
    */
        
    RETURN respectsDocPattern(
        docNumber,
        '[KLM0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z0-9]' );
END $$

DROP FUNCTION IF EXISTS isValidNIEFormat $$

CREATE FUNCTION isValidNIEFormat( docNumber VARCHAR(15) )
    RETURNS INTEGER
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Validates the format of a given string against NIE pattern'
BEGIN
    /*
        This function validates the format of a given string in order to
        see if it fits with NIE format. Practically, it performs a validation
        over a NIE, except this function does not check the check digit.

        This function is intended to work with NIE numbers.

        This function is used by:
            - isValidIdNumber
            - isValidNIE

        This function requires:
            - respectsDocPattern

        This function returns:
            1: If specified string respects NIE format
            0: Otherwise

        Usage:
            SELECT isValidNIEFormat( 'X6089822C' )
        Returns:
            1
    */

    RETURN respectsDocPattern(
        docNumber,
        '[XYZT][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z0-9]' );
END $$

DROP FUNCTION IF EXISTS isValidCIFFormat $$

CREATE FUNCTION isValidCIFFormat( docNumber VARCHAR(15) )
    RETURNS INTEGER
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Validates the format of a given string against CIF pattern'
BEGIN
    /*
        This function validates the format of a given string in order to
        see if it fits with CIF format. Practically, it performs a validation
        over a CIF, except this function does not check the check digit.

        This function is intended to work with CIF numbers.

        This function is used by:
            - isValidIdNumber
            - isValidCIF

        This function requires:
            - respectsDocPattern

        This function returns:
            1: If specified string respects CIF format
            0: Otherwise

        Usage:
            SELECT isValidCIFFormat( 'H24930836' )
        Returns:
            1
    */

    RETURN
        respectsDocPattern(
            docNumber,
            '[PQSNWR][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z0-9]' )
    OR
        respectsDocPattern(
            docNumber,
            '[ABCDEFGHJUV][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' );    
END $$

DROP FUNCTION IF EXISTS getNIFCheckDigit $$

CREATE FUNCTION getNIFCheckDigit( docNumber VARCHAR(15) )
    RETURNS VARCHAR(1)
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'This function calculates the correct check digit for a Spanish NIF'
BEGIN
    /*
        This function calculates the check digit for an individual Spanish
        identification number (NIF).

        You can replace check digit with a zero when calling the function.

        This function is used by:
            - isValidNIF

        This function requires:
            - isValidNIFFormat

        This function returns:
            - Returns check digit if provided string had a correct NIF structure
            - An empty string otherwise

        Usage:
            SELECT getNIFCheckDigit( '335764280' )
        Returns:
            Q
    */

    DECLARE fixedDocNumber VARCHAR(15);
    DECLARE keyString VARCHAR(23);

    DECLARE position INT;
    DECLARE writtenLetter VARCHAR(1);
    DECLARE correctLetter VARCHAR(1);
     
    SET keyString = 'TRWAGMYFPDXBNJZSQVHLCKE';
    SET correctLetter = '';

    SET fixedDocNumber =
        UPPER( CASE
            WHEN LEFT( docNumber, 1 ) NOT REGEXP '^[[:alpha:]]' THEN
                RIGHT( CONCAT( '00000000', docNumber ), 9 )
            ELSE
                docNumber END );

    IF ( isValidNIFFormat( fixedDocNumber ) = 1 ) THEN
        SET writtenLetter = RIGHT( fixedDocNumber, 1 );
            
        SET fixedDocNumber = REPLACE(fixedDocNumber, 'K', '0');
        SET fixedDocNumber = REPLACE(fixedDocNumber, 'L', '0');
        SET fixedDocNumber = REPLACE(fixedDocNumber, 'M', '0');

        SET position = LEFT(fixedDocNumber, 8) % 23;
        SET correctLetter = SUBSTRING( keyString, position + 1, 1 );
    END IF;

    RETURN correctLetter;
END $$

DROP FUNCTION IF EXISTS getCIFCheckDigit $$

CREATE FUNCTION getCIFCheckDigit( docNumber VARCHAR(15) )
    RETURNS VARCHAR(1)
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'This function calculates the correct check digit for a Spanish CIF'
BEGIN
    /*
        This function calculates the check digit for a corporate Spanish
        identification number (CIF).

        You can replace check digit with a zero when calling the function.

        This function is used by:
            - isValidCIF

        This function requires:
            - isValidCIFFormat

        This function returns:
            - Returns check digit if provided string had a correct CIF structure
            - An empty string otherwise

        Usage:
            SELECT getCIFCheckDigit( 'H24930830' )
        Returns:
            6
    */
    
    DECLARE fixedDocNumber VARCHAR(15);

    DECLARE centralChars VARCHAR(15);
    DECLARE firstChar VARCHAR(1);
    
    DECLARE evenSum INT;
    DECLARE oddSum INT;
    DECLARE totalSum INT;
    DECLARE lastDigitTotalSum INT;
    
    DECLARE correctDigit VARCHAR(1);
    
    SET correctDigit = '';
    
    SET fixedDocNumber = UPPER( docNumber );
        
    IF ( isValidCIFFormat( fixedDocNumber ) = 1 ) THEN
        SET firstChar = LEFT( fixedDocNumber, 1);
        SET centralChars = SUBSTRING( fixedDocNumber, 2, 7 );

        SET evenSum =
            CONVERT( SUBSTRING( centralChars, 2, 1 ), unsigned ) +
            CONVERT( SUBSTRING( centralChars, 4, 1 ), unsigned ) +
            CONVERT( SUBSTRING( centralChars, 6, 1 ), unsigned );

        SET oddSum =
            sumDigits( CONVERT( SUBSTRING( centralChars, 1, 1 ), unsigned ) * 2 ) +
            sumDigits( CONVERT( SUBSTRING( centralChars, 3, 1 ), unsigned ) * 2 ) +
            sumDigits( CONVERT( SUBSTRING( centralChars, 5, 1 ), unsigned ) * 2 ) +
            sumDigits( CONVERT( SUBSTRING( centralChars, 7, 1 ), unsigned ) * 2 );

        SET totalSum = evenSum + oddSum;
        SET lastDigitTotalSum = RIGHT( CAST( totalSum AS CHAR ), 1);

        SET correctDigit = CASE
            WHEN lastDigitTotalSum > 0
                THEN 10 - ( lastDigitTotalSum % 10 )
            ELSE
                0 END;

        /* If CIF number starts with P, Q, S, N, W or R, check digit sould be a letter */
        IF ( INSTR( 'PQSNWR', firstChar ) > 0 ) THEN
            SET correctDigit = SUBSTRING('JABCDEFGHI', CAST( correctDigit AS UNSIGNED ) + 1, 1);
        END IF;
    END IF;

    RETURN correctDigit;
END $$

DROP FUNCTION IF EXISTS respectsDocPattern $$

CREATE FUNCTION respectsDocPattern( givenString VARCHAR(15), pattern VARCHAR(64) )
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
            - isValidNIFFormat
            - isValidNIEFormat
            - isValidCIFFormat

        This function returns:
            1: If specified string respects the pattern
            0: Otherwise

        Usage:
            SELECT respectsDocPattern(
                '33576428Q',
                '[KLM0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z]' );
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

DROP FUNCTION IF EXISTS sumDigits $$

CREATE FUNCTION sumDigits ( digits INT )
    RETURNS INTEGER
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Performs the sum, one by one, of the digits in a quantity'
BEGIN
    /*
        This function performs the sum, one by one, of the digits
        in a given quantity.

        For instance, it returns 6 for 123 (as it sums 1 + 2 + 3).

        This function is used by:
            - getCIFCheckDigit

        Usage:
            SELECT sumDigits( 12345 )
        Returns:
            15
    */

    DECLARE string VARCHAR(16);
    DECLARE total INT;
    DECLARE i INT;

    SET total = 0;
    SET string = digits;
    SET i = 1;    

    WHILE ( i <= LENGTH (string) ) DO
        SET total = total + SUBSTRING( string, i, 1 );
        SET i = i + 1;
    END WHILE;

    RETURN total;
END $$

DROP FUNCTION IF EXISTS getIdType $$

CREATE FUNCTION getIdType( docNumber VARCHAR(15) )
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
            - identificationType (table)
            - isValidCIFFormat
            - isValidNIEFormat
            - isValidNIFFormat

        Usage:
            SELECT getIdType( 'H67905364' )
        Returns:
            Comunidad de propietarios en régimen de propiedad horizontal
    */
    
    DECLARE firstChar VARCHAR(1);
    DECLARE docTypeDescription VARCHAR(255);

    SET docTypeDescription = '';
    SET firstChar = LEFT(docNumber, 1);

    IF ( isValidNIFFormat( docNumber ) = 1 OR
        isValidNIEFormat( docNumber ) = 1 OR
        isValidCIFFormat( docNumber ) = 1 ) THEN

        SET docTypeDescription =
            ( SELECT description FROM identificationType
                WHERE id = firstChar LIMIT 1 );
    END IF;
    
    RETURN IFNULL( docTypeDescription, '' );
END $$

DROP TABLE IF EXISTS identificationType $$

CREATE TABLE identificationType (
    id VARCHAR(1),
    description VARCHAR(255),
    PRIMARY KEY( id )
) COMMENT 'Relates different types of Spanish document types with its descriptions' $$

/*
    This data is used by:
        - getIdType
*/

INSERT INTO identificationType( id, description ) VALUES
    ( 'K', 'Español menor de catorce años o extranjero menor de dieciocho' ),
    ( 'L', 'Español mayor de catorce años residiendo en el extranjero' ),
    ( 'M', 'Extranjero mayor de dieciocho años sin NIE' ),
    
    ( '0', 'Español con documento nacional de identidad' ),
    ( '1', 'Español con documento nacional de identidad' ),
    ( '2', 'Español con documento nacional de identidad' ),
    ( '3', 'Español con documento nacional de identidad' ),
    ( '4', 'Español con documento nacional de identidad' ),
    ( '5', 'Español con documento nacional de identidad' ),
    ( '6', 'Español con documento nacional de identidad' ),
    ( '7', 'Español con documento nacional de identidad' ),
    ( '8', 'Español con documento nacional de identidad' ),
    ( '9', 'Español con documento nacional de identidad' ),

    ( 'T', 'Extranjero residente en España e identificado por la Policía con un NIE' ),
    ( 'X', 'Extranjero residente en España e identificado por la Policía con un NIE' ),
    ( 'Y', 'Extranjero residente en España e identificado por la Policía con un NIE' ),
    ( 'Z', 'Extranjero residente en España e identificado por la Policía con un NIE' ),
  
    /* As described in BOE number 49. February 26th, 2008 (article 3) */
    ( 'A', 'Sociedad Anónima' ),
    ( 'B', 'Sociedad de responsabilidad limitada' ),
    ( 'C', 'Sociedad colectiva' ),
    ( 'D', 'Sociedad comanditaria' ),
    ( 'E', 'Comunidad de bienes y herencias yacentes' ),
    ( 'F', 'Sociedad cooperativa' ),
    ( 'G', 'Asociación' ),
    ( 'H', 'Comunidad de propietarios en régimen de propiedad horizontal' ),
    ( 'J', 'Sociedad Civil, con o sin personalidad jurídica' ),
    ( 'N', 'Entidad extranjera' ),
    ( 'P', 'Corporación local' ),
    ( 'Q', 'Organismo público' ),
    ( 'R', 'Congregación o Institución Religiosa' ),
    ( 'S', 'Órgano de la Administración del Estado y Comunidades Autónomas' ),
    ( 'U', 'Unión Temporal de Empresas' ),
    ( 'V', 'Fondo de inversiones o de pensiones, agrupación de interés económico, etc' ),
    ( 'W', 'Establecimiento permanente de entidades no residentes en España' ) $$
