IF object_id('getIBANControlDigits', 'FN') IS NOT NULL
    DROP FUNCTION getIBANControlDigits
GO

CREATE FUNCTION getIBANControlDigits( @accNumber VARCHAR(64) )
    RETURNS VARCHAR(64)
BEGIN
    /*
        This function expects the entire account number in the electronic
        format (without spaces), as described in the ISO 13616-Compliant
        IBAN Formats document.

        You can replace control @digits with zeros when calling the function.

        This function requires:
            - replaceLetterWithDigits
            - accountLegthPerCountry (table)

        Usage:
            SELECT dbo.getIBANControlDigits( 'GB00WEST12345698765432' )
        Returns:
            82
    */
    
    DECLARE @countryCode VARCHAR(2)
    DECLARE @accountLength INT
    DECLARE @accRearranged VARCHAR(64)
    DECLARE @accWithoutLetters VARCHAR(64)
    DECLARE @accMod97 INT
    DECLARE @digits VARCHAR(2)
    
    SET @countryCode = LEFT( @accNumber, 2 )

    SET @accountLength =
        ( SELECT TOP 1 lc.accountLength FROM accountLegthPerCountry AS lc
            WHERE lc.countryCode = @countryCode)
    
    IF ( LEN( @accNumber ) = @accountLength )
    BEGIN
        /* Replace the two check @digits by 00 (e.g., GB00 for the UK) and
            Move the four initial characters to the end of the string. */
        SET @accRearranged = RIGHT( @accNumber, LEN( @accNumber ) - 4 ) + LEFT( @accNumber, 2 ) + '00'

        /* Replace the letters in the string with @digits, expanding the string as necessary,
            such that A or a = 10, B or b = 11, and Z or z = 35.
            Each alphabetic character is therefore replaced by 2 @digits. */
        SET @accWithoutLetters = dbo.replaceLetterWithDigits( @accRearranged )

        /* Convert the string to an integer (i.e., ignore leading zeroes) and
            Calculate mod-97 of the new number, which results in the remainder. */
        SET @accMod97 = CAST( @accWithoutLetters AS DECIMAL(64) ) % 97

        /* Subtract the remainder from 98, and use the result for the two check @digits. */
        SET @digits = 98 - @accMod97

        /* If the result is a single digit number, pad it with a leading 0 to make a two-digit number. */
        SET @digits = RIGHT(  '00' + @digits, 2)
    END
    ELSE
    BEGIN
        SET @digits = ''
    END

    RETURN @digits
END
GO

EXECUTE sys.sp_addextendedproperty
    @name = 'MS_Description',
    @value = 'Obtains the correct IBAN control @digits for a given account number',
    @level0type = 'SCHEMA',
    @level0name = 'dbo',
    @level1type = 'function',
    @level1name = 'getIBANControlDigits'
GO

IF object_id('getGlobalIdentifier', 'FN') IS NOT NULL
    DROP FUNCTION getGlobalIdentifier
GO

CREATE FUNCTION getGlobalIdentifier(
    @localId VARCHAR(64), @countryCode VARCHAR(2), @suffix VARCHAR(3) )

    RETURNS VARCHAR(64)
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
                SELECT dbo.getGlobalIdentifier( 'G28667152', 'ES', '' )
        Returns:
                ES03000G28667152
    */

    DECLARE @alphaNumerical VARCHAR(64)
    DECLARE @git stwithCountry VARCHAR(64)
    DECLARE @withoutLetters VARCHAR(64)
    DECLARE @mod97 INT
    DECLARE @digits VARCHAR(2)
    DECLARE @globalId VARCHAR(64)

    /* Removes non alpha-numerical characters */
    SET @alphaNumerical = dbo.replaceCharactersNotInPattern( @localId,
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', '' )

    /* Adds country plus '00' at the end */
    SET @withCountry = @alphaNumerical + @countryCode + '00'

    /* Replace the letters in the string with digits, expanding the string as necessary,
    such that A or a = 10, B or b = 11, and Z or z = 35.
    Each alphabetic character is therefore replaced by 2 digits. */
    SET @withoutLetters = dbo.replaceLetterWithDigits( @withCountry )

    /* Convert the string to an integer (i.e., ignore leading zeroes) and
    Calculate mod-97 of the new number, which results in the remainder. */
    SET @mod97 = CAST( @withoutLetters AS DECIMAL(64) ) % 97;

    /* Subtract the remainder from 98, and use the result for the two check digits. */
    SET @digits = 98 - @mod97

    /* If the result is a single digit number, pad it with a leading 0 to make a two-digit number. */
    SET @digits = RIGHT( '00' + @digits, 2);

    /* Suffix must be a number from 000 to 999 */
    SET @suffix = dbo.replaceCharactersNotInPattern( @suffix, '0123456789', '0' );
    SET @suffix = RIGHT( '000' + @suffix, 3 );
       
    RETURN @countryCode + @digits + @suffix + @localId
END
GO

EXECUTE sys.sp_addextendedproperty
    @name = 'MS_Description',
    @value = 'Obtains the global identifier for a given local identifier',
    @level0type = 'SCHEMA',
    @level0name = 'dbo',
    @level1type = 'function',
    @level1name = 'getGlobalIdentifier'
GO

IF object_id('replaceCharactersNotInPattern', 'FN') IS NOT NULL
    DROP FUNCTION replaceCharactersNotInPattern
GO

CREATE FUNCTION replaceCharactersNotInPattern(
    @givenString VARCHAR(256), @pattern VARCHAR(64), @replaceWith VARCHAR(1) )

    RETURNS VARCHAR(256)
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
            SELECT dbo.replaceCharactersNotInPattern(
                'ABC123-?:', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', '0' )
        Returns:
            'ABC123000'
    */

    DECLARE @verifyLetter VARCHAR(1)
    DECLARE @i INT
    
    SET @i = 0
    
    WHILE ( @i <= LEN( @givenString ) )
    BEGIN
        SET @verifyLetter = SUBSTRING( @givenString, @i, 1 )
        
        IF CHARINDEX( @verifyLetter, @pattern ) = 0
        BEGIN
            SET @givenString = REPLACE( @givenString, @verifyLetter, @replaceWith )
        END
    
        SET @i = @i + 1
    END
        
    RETURN @givenString
END
GO

EXECUTE sys.sp_addextendedproperty
    @name = 'MS_Description',
    @value = 'Replace unwanted characters in a given string with a character',
    @level0type = 'SCHEMA',
    @level0name = 'dbo',
    @level1type = 'function',
    @level1name = 'replaceCharactersNotInPattern'
GO

IF object_id('replaceLetterWithDigits', 'FN') IS NOT NULL
    DROP FUNCTION replaceLetterWithDigits
GO

CREATE FUNCTION replaceLetterWithDigits( @accNumber VARCHAR(64) )
    RETURNS VARCHAR(64)
BEGIN
    /*
        This functions changes letters in a given string
        with its correspondant numbers, as described in
        ECBS EBS204 V3.2 [August 2003] document:

        A=1, B=2, ..., Y=34, Z=35

        Usage:
            SELECT dbo.replaceLetterWithDigits( '510007547061BE00' )
        Returns:
            510007547061111400
    */
    
    DECLARE @letters VARCHAR(64)
    DECLARE @findLetter VARCHAR(1)
    DECLARE @replaceWith INT
    DECLARE @i INT
    
    SET @i = 0
    SET @letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    
    WHILE ( @i <= LEN( @letters ) )
    BEGIN
        SET @findLetter = SUBSTRING( @letters, @i, 1 )
        SET @replaceWith = CHARINDEX( @findLetter, @letters ) + 9
        SET @accNumber = REPLACE( @accNumber, @findLetter, @replaceWith )

        SET @i = @i + 1
    END
    
    RETURN @accNumber
END
GO

EXECUTE sys.sp_addextendedproperty
    @name = 'MS_Description',
    @value = 'Replaces letters with numbers (taking A=1 and Z=35)',
    @level0type = 'SCHEMA',
    @level0name = 'dbo',
    @level1type = 'function',
    @level1name = 'replaceLetterWithDigits'
GO

IF object_id('accountLegthPerCountry', 'U') IS NOT NULL
    DROP TABLE accountLegthPerCountry
GO

CREATE TABLE accountLegthPerCountry (
    countryCode VARCHAR(2),
    accountLength INT,
    PRIMARY KEY( countryCode )
)
GO

EXECUTE sys.sp_addextendedproperty
    @name = 'MS_Description',
    @value = 'IBAN length -in characters- per country',
    @level0type = 'SCHEMA',
    @level0name = 'dbo',
    @level1type = 'table',
    @level1name = 'accountLegthPerCountry'
GO

/* Information Source: IBAN Registry about all ISO 13616-compliant
    national IBAN formats (Release 45 – April 2013).
    http://www.swift.com/dsp/resources/documents/IBAN_Registry.pdf */
    
INSERT INTO accountLegthPerCountry (countryCode, accountLength)
    SELECT 'AL', '28' UNION ALL SELECT 'AD', '24' UNION ALL SELECT 'AT', '20' UNION ALL SELECT 'AZ', '28' UNION ALL
    SELECT 'BH', '22' UNION ALL SELECT 'BE', '16' UNION ALL SELECT 'BA', '20' UNION ALL SELECT 'BR', '29' UNION ALL
    SELECT 'BG', '22' UNION ALL SELECT 'CR', '21' UNION ALL SELECT 'HR', '21' UNION ALL SELECT 'CY', '28' UNION ALL
    SELECT 'CZ', '24' UNION ALL SELECT 'DK', '18' UNION ALL SELECT 'DO', '28' UNION ALL SELECT 'EE', '20' UNION ALL
    SELECT 'FO', '18' UNION ALL SELECT 'FI', '18' UNION ALL SELECT 'FR', '27' UNION ALL SELECT 'GE', '22' UNION ALL
    SELECT 'DE', '22' UNION ALL SELECT 'GI', '23' UNION ALL SELECT 'GR', '27' UNION ALL SELECT 'GL', '18' UNION ALL
    SELECT 'GT', '28' UNION ALL SELECT 'HU', '28' UNION ALL SELECT 'IS', '26' UNION ALL SELECT 'IE', '22' UNION ALL
    SELECT 'IL', '23' UNION ALL SELECT 'IT', '27' UNION ALL SELECT 'KZ', '20' UNION ALL SELECT 'KW', '30' UNION ALL
    SELECT 'LV', '21' UNION ALL SELECT 'LB', '28' UNION ALL SELECT 'LI', '21' UNION ALL SELECT 'LT', '20' UNION ALL
    SELECT 'LU', '20' UNION ALL SELECT 'MK', '19' UNION ALL SELECT 'MT', '31' UNION ALL SELECT 'MR', '27' UNION ALL
    SELECT 'MU', '30' UNION ALL SELECT 'MC', '27' UNION ALL SELECT 'MD', '24' UNION ALL SELECT 'ME', '22' UNION ALL
    SELECT 'NL', '18' UNION ALL SELECT 'NO', '15' UNION ALL SELECT 'PK', '24' UNION ALL SELECT 'PS', '29' UNION ALL
    SELECT 'PL', '28' UNION ALL SELECT 'PT', '25' UNION ALL SELECT 'RO', '24' UNION ALL SELECT 'SM', '27' UNION ALL
    SELECT 'SA', '24' UNION ALL SELECT 'RS', '22' UNION ALL SELECT 'SK', '24' UNION ALL SELECT 'SI', '19' UNION ALL
    SELECT 'ES', '24' UNION ALL SELECT 'SE', '24' UNION ALL SELECT 'CH', '21' UNION ALL SELECT 'TN', '24' UNION ALL
    SELECT 'TR', '26' UNION ALL SELECT 'AE', '23' UNION ALL SELECT 'GB', '22' UNION ALL SELECT 'VG', '24' UNION ALL
    SELECT 'AO', '25' UNION ALL SELECT 'BJ', '28' UNION ALL SELECT 'BF', '27' UNION ALL SELECT 'BI', '16' UNION ALL
    SELECT 'CM', '27' UNION ALL SELECT 'CV', '25' UNION ALL SELECT 'IR', '26' UNION ALL SELECT 'CI', '28' UNION ALL
    SELECT 'MG', '27' UNION ALL SELECT 'ML', '28' UNION ALL SELECT 'MZ', '25' UNION ALL SELECT 'SN', '28'
