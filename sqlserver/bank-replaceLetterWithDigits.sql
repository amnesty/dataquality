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
