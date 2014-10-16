DROP FUNCTION IF EXISTS isValidIBAN $$

CREATE FUNCTION isValidIBAN( accNumber VARCHAR(64) )
    RETURNS INT
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Verifies the structure of an IBAN and its check digits'
BEGIN
   /*
    * isValidIBAN validates an IBAN by verifying its structure and
    * check digits.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/isValidIBAN
    */

    DECLARE isValid INT;
    DECLARE countryCode VARCHAR(2);
    DECLARE writenDigits VARCHAR(2);

    SET isValid = 0;
    SET countryCode = LEFT( accNumber, 2 );
    SET writenDigits = SUBSTRING( accNumber, 3, 2 );

    IF ( isSepaCountry( countryCode ) ) THEN
        IF ( LENGTH( accNumber ) = getAccountLength( countryCode ) ) THEN
            IF ( writenDigits = getIBANCheckDigits( accNumber ) ) THEN
                SET isValid = 1;
            END IF;
        END IF;
    END IF;

    RETURN isValid;
END $$

DROP FUNCTION IF EXISTS isSepaCountry$$

CREATE FUNCTION isSepaCountry( countryCode VARCHAR(2) )
    RETURNS INT
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Verifies if a given string corresponds with a SEPA Country Code'
BEGIN
   /*
    * isSepaCountry helps to check the first two digits of an IBAN.
    * These two digits are referring to the country where the
    * account was created, so they only can correspond to one
    * of the countries in the Single Euro Payments Area (SEPA) area.
    * 
    * A document with a full list of the SEPA countries, its
    * corresponding IBAN structures and more is available at
    * the Swift website as IBAN Registry.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/isSepaCountry
    */

    DECLARE isSepa INT;

    SET isSepa = 0;

    IF ( getAccountLength( countryCode ) <> 0 ) THEN
        SET isSepa = 1;
    END IF;

    RETURN isSepa;
END $$

DROP FUNCTION IF EXISTS getAccountLength $$

CREATE FUNCTION getAccountLength( countryCode VARCHAR(2) )
    RETURNS INT
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Returns the expected length for accounts of a particular SEPA country'
BEGIN
   /*
    * getAccountLength returns the expected length for an IBAN given
    * its first two digits. For instance, British accounts have 22
    * characters when written in IBAN electronic format.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/getAccountLength
    */

    DECLARE accountLength INT;

    SET accountLength = 0;

    CREATE TEMPORARY TABLE accountLengthPerCountry (
        countryCode VARCHAR(2),
        accountLength INT,
        PRIMARY KEY( countryCode )
    );

    /* Information Source: IBAN Registry about all ISO 13616-compliant
        national IBAN formats (Release 45 – April 2013).
        http://www.swift.com/dsp/resources/documents/IBAN_Registry.pdf */

    INSERT INTO accountLengthPerCountry (countryCode, accountLength) VALUES
        ('AL', 28), ('AD', 24), ('AT', 20), ('AZ', 28), ('BH', 22),
        ('BE', 16), ('BA', 20), ('BR', 29), ('BG', 22), ('CR', 21),
        ('HR', 21), ('CY', 28), ('CZ', 24), ('DK', 18), ('DO', 28),
        ('EE', 20), ('FO', 18), ('FI', 18), ('FR', 27), ('GE', 22),
        ('DE', 22), ('GI', 23), ('GR', 27), ('GL', 18), ('GT', 28),
        ('HU', 28), ('IS', 26), ('IE', 22), ('IL', 23), ('IT', 27),
        ('KZ', 20), ('KW', 30), ('LV', 21), ('LB', 28), ('LI', 21),
        ('LT', 20), ('LU', 20), ('MK', 19), ('MT', 31), ('MR', 27),
        ('MU', 30), ('MC', 27), ('MD', 24), ('ME', 22), ('NL', 18),
        ('NO', 15), ('PK', 24), ('PS', 29), ('PL', 28), ('PT', 25),
        ('RO', 24), ('SM', 27), ('SA', 24), ('RS', 22), ('SK', 24),
        ('SI', 19), ('ES', 24), ('SE', 24), ('CH', 21), ('TN', 24),
        ('TR', 26), ('AE', 23), ('GB', 22), ('VG', 24), ('AO', 25),
        ('BJ', 28), ('BF', 27), ('BI', 16), ('CM', 27), ('CV', 25),
        ('IR', 26), ('CI', 28), ('MG', 27), ('ML', 28), ('MZ', 25),
        ('SN', 28);

    SET accountLength =
        IFNULL( ( SELECT lc.accountLength FROM accountLengthPerCountry AS lc
                WHERE lc.countryCode = countryCode LIMIT 1), 0 );

    DROP TEMPORARY TABLE accountLengthPerCountry;

    RETURN accountLength;
END $$

DROP FUNCTION IF EXISTS getIBANCheckDigits $$

CREATE FUNCTION getIBANCheckDigits( accNumber VARCHAR(64) )
    RETURNS VARCHAR(64)
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Obtains the correct IBAN check digits for a given account number'
BEGIN
   /*
    * This function expects the entire account number in the electronic
    * format (without spaces), as described in the ISO 13616-Compliant
    * IBAN Formats document.
    *
    * You can replace check digits with zeros when calling the function.
    *
    * @link https://github.com/amnesty/dataquality/wiki/getIBANCheckDigits
    */

    DECLARE countryCode VARCHAR(2);
    DECLARE accountLength INT;
    DECLARE accRearranged VARCHAR(64);
    DECLARE accWithoutLetters VARCHAR(64);
    DECLARE accMod97 INT;
    DECLARE digits VARCHAR(2);

    SET digits = '';

    SET countryCode = LEFT( accNumber, 2 );
    SET accountLength = getAccountLength( countryCode );

    IF ( isSepaCountry( countryCode ) ) THEN
        IF ( LENGTH( accNumber ) = accountLength ) THEN
            /* Replace the two check digits by 00 (e.g., GB00 for the UK) and
                Move the four initial characters to the end of the string. */
            SET accRearranged =
                CONCAT( RIGHT( accNumber, LENGTH( accNumber ) - 4 ), LEFT( accNumber, 2 ), '00' );

            /* Replace the letters in the string with digits, expanding the string as necessary,
                such that A or a = 10, B or b = 11, and Z or z = 35.
                Each alphabetic character is therefore replaced by 2 digits. */
            SET accWithoutLetters = replaceLetterWithDigits( accRearranged );

            /* Convert the string to an integer (i.e., ignore leading zeroes) and
                Calculate mod-97 of the new number, which results in the remainder. */
            SET accMod97 =
                CAST( accWithoutLetters AS DECIMAL(64) ) MOD 97;

            /* Subtract the remainder from 98, and use the result for the two check digits. */
            SET digits = 98 - accMod97;

            /* If the result is a single digit number, pad it with a leading 0 to make a two-digit number. */
            SET digits = RIGHT( CONCAT( '00', digits ), 2);
        END IF;
    END IF;

    RETURN digits;
END $$

DROP FUNCTION IF EXISTS getGlobalIdentifier $$

CREATE FUNCTION getGlobalIdentifier( localId VARCHAR(64), countryCode VARCHAR(2), suffix VARCHAR(3) )
    RETURNS VARCHAR(64)
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Obtains the global identifier for a given local identifier'
BEGIN
   /*
    * This "global identifier" refers to the code AT-02 created for the
    * C19.14. The C19.14 is a temporary file format to be used in Spain
    * until the ISO 20022 XML format is finally adopted.
    * 
    * If the IBAN is built by adding a few digits to the national bank
    * accounts, the AT-02 is build by adding digits to the national
    * identifier. In the case of Spain, this identifiers are NIFs,
    * NIEs and CIFs.
    * 
    * For instance, the Spanish CIF G28667152, can be expressed
    * internationally as ES03000G28667152.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/getGlobalIdentifier
    */

    DECLARE withCountry VARCHAR(64);
    DECLARE without5and7 VARCHAR(64);
    DECLARE alphaNumerical VARCHAR(64);
    DECLARE withoutLetters VARCHAR(64);
    DECLARE mod97 INT;
    DECLARE digits VARCHAR(2);
    DECLARE globalId VARCHAR(64);

    /* Concatenate localId plus country code and two zeros (00) */
    SET withCountry = CONCAT( localId, countryCode, '00' );

    /* Exclude positions 5 and 7 */
    SET without5and7 = CONCAT(
        SUBSTRING( withCountry, 1, 4 ),
        SUBSTRING( withCountry, 6, 1 ),
        SUBSTRING( withCountry, 8 ) );

    /* Removes non alpha-numerical characters */
    SET alphaNumerical = replaceCharactersNotInPattern( without5and7,
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', '' );

    /* Replace the letters in the string with digits, expanding the string as necessary,
    such that A or a = 10, B or b = 11, and Z or z = 35.
    Each alphabetic character is therefore replaced by 2 digits. */
    SET withoutLetters = replaceLetterWithDigits( alphaNumerical );

    /* Convert the string to an integer (i.e., ignore leading zeroes) and
    Calculate mod-97 of the new number, which results in the remainder. */
    SET mod97 = CAST( withoutLetters AS DECIMAL(64) ) MOD 97;

    /* Subtract the remainder from 98, and use the result for the two check digits. */
    SET digits = 98 - mod97;

    /* If the result is a single digit number, pad it with a leading 0 to make a two-digit number. */
    SET digits = RIGHT( CONCAT( '00', digits ), 2);

    /* Suffix must be a number from 000 to 999 */
    SET suffix = replaceCharactersNotInPattern( suffix, '0123456789', '0' );
    SET suffix = RIGHT( CONCAT( '000', suffix ), 3 );
       
    RETURN CONCAT( countryCode, digits, suffix, localId );
END $$

DROP FUNCTION IF EXISTS replaceCharactersNotInPattern $$

CREATE FUNCTION replaceCharactersNotInPattern(
    givenString VARCHAR(256), pattern VARCHAR(64), replaceWith VARCHAR(1) )

    RETURNS VARCHAR(256)
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Replace unwanted characters in a given string with a character'
BEGIN
   /*
    * replaceCharactersNotInPattern replaces unwanted characters from a string
    * with a given character.
    * 
    * An example:
    * - We have this string: 1!2/3·A|B@C#
    * - This are the characters we accept: 123ABC
    * - This is the character we want to replace extra characters with: 0
    * - The example would return: 102030A0B0C0
    * 
    * @link https://github.com/amnesty/dataquality/wiki/replaceCharactersNotInPattern
    */

    DECLARE verifyLetter VARCHAR(1);
    DECLARE i INT;
    
    SET i = 0;
    
    WHILE ( i <= LENGTH( givenString ) ) DO
        SET verifyLetter = SUBSTRING( givenString, i, 1 );
        IF INSTR( pattern, verifyLetter ) = 0 THEN
            SET givenString = REPLACE( givenString, verifyLetter, replaceWith );
        END IF;
    
        SET i = i + 1;
    END WHILE;
        
    RETURN givenString;
END $$

DROP FUNCTION IF EXISTS replaceLetterWithDigits $$

CREATE FUNCTION replaceLetterWithDigits( accNumber VARCHAR(64) )
    RETURNS VARCHAR(64)
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Replaces letters with numbers (taking A=1 and Z=35)'
BEGIN
   /*
    * replaceLetterWithDigits changes letters in a given string with its
    * correspondent numbers, as described in ECBS EBS204 V3.2 [August 2003]
    * document: A=1, B=2, ..., Y=34, Z=35.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/replaceLetterWithDigits
    */
    
    DECLARE letters VARCHAR(64);
    DECLARE findLetter VARCHAR(1);
    DECLARE replaceWith INT;
    DECLARE i INT;

    SET i = 0;
    SET letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    
    WHILE ( i <= LENGTH( letters ) ) DO
        SET findLetter = SUBSTRING( letters, i, 1 );
        SET replaceWith = INSTR( letters, findLetter ) + 9;
        SET accNumber = REPLACE( accNumber, findLetter, replaceWith );

        SET i = i + 1;
    END WHILE;
    
    RETURN accNumber;
END $$

