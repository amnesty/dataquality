IF object_id('getGlobalIdentifier', 'FN') IS NOT NULL
    DROP FUNCTION getGlobalIdentifier
GO

CREATE FUNCTION getGlobalIdentifier( @localId VARCHAR(64), @countryCode VARCHAR(2), @suffix VARCHAR(3) )
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

    DECLARE @withCountry VARCHAR(64)
    DECLARE @without5and7 VARCHAR(64)
    DECLARE @alphaNumerical VARCHAR(64)
    DECLARE @withoutLetters VARCHAR(64)
    DECLARE @mod97 INT
    DECLARE @digits VARCHAR(2)
    DECLARE @globalId VARCHAR(64)

    /* Concatenate localId plus country code and two zeros (00) */
    SET @withCountry = @localId + @countryCode + '00'

    /* Exclude positions 5 and 7 */
    SET @without5and7 = 
        SUBSTRING( @withCountry, 1, 4 ) +
        SUBSTRING( @withCountry, 6, 1 ) +
        SUBSTRING( @withCountry, 8, LEN( @withCountry ) )

    /* Removes non alpha-numerical characters */
    SET @alphaNumerical = dbo.replaceCharactersNotInPattern( @without5and7,
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', '' )

    /* Replace the letters in the string with digits, expanding the string as necessary,
    such that A or a = 10, B or b = 11, and Z or z = 35.
    Each alphabetic character is therefore replaced by 2 digits. */
    SET @withoutLetters = dbo.replaceLetterWithDigits( @alphaNumerical )

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
