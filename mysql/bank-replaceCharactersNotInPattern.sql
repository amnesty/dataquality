DROP FUNCTION IF EXISTS replaceCharactersNotInPattern $$

CREATE FUNCTION replaceCharactersNotInPattern( givenString VARCHAR(256), pattern VARCHAR(64), replaceWith VARCHAR(1) )
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