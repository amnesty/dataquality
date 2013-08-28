DROP FUNCTION IF EXISTS sumdigits $$

CREATE FUNCTION sumdigits ( digits INT )
    RETURNS INTEGER
    DETERMINISTIC
    READS SQL DATA
    COMMENTS 'Performs the sum, one by one, of the digits in a quantity'
BEGIN
    /*
	This function performs the sum, one by one, of the digits
	in a given quantity.
	
	For instance, it returns 6 for 123 (as it sums 1 + 2 + 3).
	
	This function is used by:
	    - getSpanishCIFControl
	
	Usage:
	    SELECT sumdigits( 12345 )
	Returns:
	    
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