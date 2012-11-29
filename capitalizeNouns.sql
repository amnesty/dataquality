DELIMITER $$

DROP FUNCTION IF EXISTS capitalizeNoun $$

CREATE FUNCTION capitalizeNoun(phrase varchar(65535))
RETURNS varchar(65535) CHARSET latin1
BEGIN
    /*	Example:
        This query;
            SELECT initcap('fco. juan hernández-gómez gutiérrez-lópez');
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