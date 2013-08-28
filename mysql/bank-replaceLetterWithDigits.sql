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