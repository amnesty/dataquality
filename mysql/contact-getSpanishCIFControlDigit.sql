DROP FUNCTION IF EXISTS getSpanishCIFControlDigit $$

CREATE FUNCTION getSpanishCIFControlDigit( docNumber VARCHAR(15) )
    RETURNS VARCHAR(1)
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'This function calculates the correct control digit for a Spanish CIF'
BEGIN
    /*
	This function calculates the control digit for a corporate Spanish
	identification number (CIF).
	
	You can replace control digit with a zero when calling the function.
	
	This function is used by:
	    - isValidSpanishCIF
	
	This function requires:
	    - isValidSpanishCIFFormat
	
	This function returns:
	    - The correct control digit if provided string had a
	    correct CIF structure
	    - An empty string otherwise

	Usage:
	    SELECT getSpanishCIFControlDigit( 'H24930830' )
	Returns:
	    6
    */
    
    DECLARE fixeddocNumber VARCHAR(15);

    DECLARE centralChars VARCHAR(15);
    DECLARE firstChar VARCHAR(1);
    
    DECLARE evenSum INT;
    DECLARE oddSum INT;
    DECLARE totalSum INT;
    DECLARE lastDigittotalSum INT;
    
    DECLARE correctDigit VARCHAR(1);
    
    SET fixeddocNumber = UPPER( docNumber );
        
    IF ( isValidSpanishCIFFormat( fixeddocNumber ) = 1 ) THEN
	SET firstChar = LEFT( fixeddocNumber, 1);
	SET centralChars = SUBSTRING( fixeddocNumber, 2, 7 );

	SET evenSum =
	    CONVERT( SUBSTRING( centralChars, 2, 1 ), unsigned ) +
	    CONVERT( SUBSTRING( centralChars, 4, 1 ), unsigned ) +
	    CONVERT( SUBSTRING( centralChars, 6, 1 ), unsigned );

	SET oddSum =
	    sumDigits( CONVERT( SUBSTRING( centralChars, 1, 1 ), unsigned ) * 2 ) +
	    sumDigits( CONVERT( SUBSTRING( centralChars, 3, 1 ), unsigned ) * 2 ) +
	    sumDigits( CONVERT( SUBSTRING( centralChars, 5, 1 ), unsigned ) * 2 ) +
	    sumDigits( CONVERT( SUBSTRING( centralChars, 7, 1 ), unsigned ) * 2 );

	SET totalSum = evenSum + oddSum;
	SET lastDigittotalSum = RIGHT( CAST( totalSum AS CHAR ), 1);
	
	SET correctDigit = CASE
	    WHEN lastDigittotalSum > 0
		THEN 10 - ( lastDigittotalSum % 10 )
	    ELSE
		0 END;
	
	/* If CIF number starts with P, Q, S, N, W or R, control digit sould be a letter */
	IF ( INSTR( 'PQSNWR', firstChar ) > 0 ) THEN
	    SET correctDigit = SUBSTRING('JABCDEFGHI', CAST( correctDigit AS INT ) + 1, 1);
	END IF;
    END IF;

    RETURN correctDigit;
END $$