DROP FUNCTION IF EXISTS isValidIdNumber $$

CREATE FUNCTION isValidIdNumber( docNumber VARCHAR(15) )
    RETURNS INTEGER
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Validates a Spanish identification number'
BEGIN
   /*
    * isValidIdNumber validates a Spanish identification number
    * verifying its check digits. It doesn't need to be told
    * about the document type, that can be a NIF, a NIE or a CIF.
    * 
    * - NIFs and NIEs are personal numbers.
    * - CIFs are corporates.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/isValidIdNumber
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
    * isValidNIF validates the check digits of an identification
    * number, after verifying the string structure actually fits
    * the NIF pattern.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/isValidNIF
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
    * isValidNIE validates the check digits of an identification number,
    * after verifying the string structure actually fits the NIE pattern.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/isValidNIE
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
    * isValidCIF validates the check digits of an identification number,
    * after verifying the string structure actually fits the CIF pattern.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/isValidCIF
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
    * isValidNIFFormat tests a string against a regexp pattern
    * to see if the string fits the NIF structure.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/isValidNIFFormat
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
    * isValidNIEFormat tests a string against a regexp pattern to see
    * if the string fits the NIE structure.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/isValidNIEFormat
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
    * isValidCIFFormat tests a string against a regexp pattern to see
    * if the string fits the CIF structure.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/isValidCIFFormat
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
    * getNIFCheckDigit obtains and returns the corresponding check digit for a
    * given string. In order to work, the string must match the NIF pattern.
    * 
    * This function has been written to be used from isValidNIF as a helper,
    * but it can still be calle directly.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/getNIFCheckDigit
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
    * getCIFCheckDigit obtains and returns the corresponding check digit
    * for a given string. In order to work, the string must match the
    * CIF pattern.
    * 
    * This function has been written to be used from isValidCIF as a
    * helper, but it can still be calle directly.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/getCIFCheckDigit
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
    * respectsDocPattern tests a string against a regexp pattern.
    * 
    * Actually, this function has been written as a helper for
    * isValidNIFFormat, isValidNIEFormat and isValidCIFFormat,
    * but it can still be called directly.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/respectsDocPattern
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
    * sumDigits is an auxiliary function that sums the digits of
    * the number received. For instance, it returns 6 for 123,
    * as long as 1+2+3 = 6.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/sumDigits
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
    * getIdType returns a description of the type of the given document number.
    * 
    * When possible, the description has been taken from an official source.
    * In all cases, the returned string will be in Spanish.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/getIdType
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
