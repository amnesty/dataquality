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