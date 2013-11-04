DROP FUNCTION IF EXISTS getIBANControlDigits $$

CREATE FUNCTION getIBANControlDigits( accNumber VARCHAR(64) )
    RETURNS VARCHAR(64)
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Obtains the correct IBAN control digits for a given account number'
BEGIN
    /*
        This function expects the entire account number in the electronic
        format (without spaces), as described in the ISO 13616-Compliant
        IBAN Formats document.

        You can replace control digits with zeros when calling the function.

        This function requires:
                - replaceLetterWithDigits
                - accountLegthPerCountry (table)

        Usage:
                SELECT getIBANControlDigits( 'GB00WEST12345698765432' )
        Returns:
                82
    */

    DECLARE countryCode VARCHAR(2);
    DECLARE accountLength INT;
    DECLARE accRearranged VARCHAR(64);
    DECLARE accWithoutLetters VARCHAR(64);
    DECLARE accMod97 INT;
    DECLARE digits VARCHAR(2);
    
    SET countryCode = LEFT( accNumber, 2 );

    SET accountLength =
        ( SELECT lc.accountLength FROM accountLegthPerCountry AS lc
                WHERE lc.countryCode = countryCode LIMIT 1);
    
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
    ELSE
        SET digits = '';
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
        The identification numbers used in Sepa are calculated from the local
        identification numbers. For instance, if your Spanish (local)
        identification number is G28667152, your global identification
        number must be ES03000G28667152.

        This function requires:
                - replaceLetterWithDigits
                - replaceCharactersNotInPattern

        Usage:
                SELECT getGlobalIdentifier( 'G28667152', 'ES', '' )
        Returns:
                ES03000G28667152
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
        This function replaces unwanted characters from a string with a given
        character.

        If a string 'ABCDEF%' and a pattern 'ABDF' are given, it returns
        a new string where:
            - the characters in the string that respect the patter remain unchanged
            - other characters are replaced with the given substitution character

        This function is used by:
            - getGlobalIdentifier
        
        Usage:
            SELECT replaceCharactersNotInPattern(
                'ABC123-?:', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', '0' )
        Returns:
            'ABC123000'
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
        This functions changes letters in a given string
        with its correspondant numbers, as described in
        ECBS EBS204 V3.2 [August 2003] document:

        A=1, B=2, ..., Y=34, Z=35

        Usage:
            SELECT replaceLetterWithDigits( '510007547061BE00' )
        Returns:
            510007547061111400
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

DROP TABLE IF EXISTS accountLegthPerCountry $$

CREATE TABLE accountLegthPerCountry (
    countryCode VARCHAR(2),
    accountLength INT,
    PRIMARY KEY( countryCode )
) COMMENT 'IBAN length -in characters- per country' $$

/* Information Source: IBAN Registry about all ISO 13616-compliant
    national IBAN formats (Release 45 – April 2013).
    http://www.swift.com/dsp/resources/documents/IBAN_Registry.pdf */
    
INSERT INTO accountLegthPerCountry (countryCode, accountLength) VALUES
    ('AL', '28'), ('AD', '24'), ('AT', '20'), ('AZ', '28'), ('BH', '22'),
    ('BE', '16'), ('BA', '20'), ('BR', '29'), ('BG', '22'), ('CR', '21'),
    ('HR', '21'), ('CY', '28'), ('CZ', '24'), ('DK', '18'), ('DO', '28'),
    ('EE', '20'), ('FO', '18'), ('FI', '18'), ('FR', '27'), ('GE', '22'),
    ('DE', '22'), ('GI', '23'), ('GR', '27'), ('GL', '18'), ('GT', '28'),
    ('HU', '28'), ('IS', '26'), ('IE', '22'), ('IL', '23'), ('IT', '27'),
    ('KZ', '20'), ('KW', '30'), ('LV', '21'), ('LB', '28'), ('LI', '21'),
    ('LT', '20'), ('LU', '20'), ('MK', '19'), ('MT', '31'), ('MR', '27'),
    ('MU', '30'), ('MC', '27'), ('MD', '24'), ('ME', '22'), ('NL', '18'),
    ('NO', '15'), ('PK', '24'), ('PS', '29'), ('PL', '28'), ('PT', '25'),
    ('RO', '24'), ('SM', '27'), ('SA', '24'), ('RS', '22'), ('SK', '24'),
    ('SI', '19'), ('ES', '24'), ('SE', '24'), ('CH', '21'), ('TN', '24'),
    ('TR', '26'), ('AE', '23'), ('GB', '22'), ('VG', '24'), ('AO', '25'),
    ('BJ', '28'), ('BF', '27'), ('BI', '16'), ('CM', '27'), ('CV', '25'),
    ('IR', '26'), ('CI', '28'), ('MG', '27'), ('ML', '28'), ('MZ', '25'),
    ('SN', '28') $$
