DELIMITER $$

DROP FUNCTION IF EXISTS capitalize $$

CREATE FUNCTION capitalize(phrase VARCHAR(65535))
    RETURNS VARCHAR(65535)
    COMMENT 'Capitalizes propertly names and surnames'
BEGIN
    /*
	This function corrects capitalization for names and surnames.
    
	Usage:
            SELECT capitalizeNoun('fco. juan hernández-gómez gutiérrez-lópez');
        Returns:
            Fco. Juan Hernández-Gómez Gutiérrez-López
    */

    SET @break = ' -';
    SET @result = '';
    SET @word = '';

    SET @i = 0;

    WHILE (@i <= LENGTH(phrase)) DO
        SET @currentchar = SUBSTRING(phrase, @i, 1);

        IF (@word = '') THEN
            SET @word = UPPER(@currentchar);
        ELSE
            SET @word = CONCAT(@word, LOWER(@currentchar));
        END IF;

        IF (LOCATE(@currentchar, @break) OR @i = LENGTH(phrase)) THEN
            SET @result = CONCAT(@result, @word);
            SET @word = '';
        END IF;

        SET @i = @i + 1;
    END WHILE;

    RETURN @result;
END $$
