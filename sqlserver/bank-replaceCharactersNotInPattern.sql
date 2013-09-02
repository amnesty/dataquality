IF object_id('replaceCharactersNotInPattern', 'FN') IS NOT NULL
    DROP FUNCTION replaceCharactersNotInPattern
GO

CREATE FUNCTION replaceCharactersNotInPattern( @givenString VARCHAR(256), @pattern VARCHAR(64), @replaceWith VARCHAR(1) )
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
