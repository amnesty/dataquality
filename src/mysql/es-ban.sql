DROP FUNCTION IF EXISTS isValidAccountNumber $$

CREATE FUNCTION isValidAccountNumber(
    entity VARCHAR(4), office VARCHAR(4), CD VARCHAR(2), account VARCHAR(10) )

    RETURNS INTEGER
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Verifies the structure of an Spanish account number and its check digits'
BEGIN
    /*
        This function expects the different parts of an Spanish account as
        parameters: entity, office, check digits and account.

        This function returns 1 if the check digit is correct. 0 if it is not.

        Usage:
                SELECT isValidAccountNumber( '1234', '1234', '16', '1234567890' );
        Returns:
                1
    */

    DECLARE correctCD VARCHAR(2);

    SET correctCD = '';

    IF( respectsAccountPattern ( entity, office, account ) ) THEN
        SET correctCD = getBankAccountCheckDigits( entity, office, account );
    END IF;

    RETURN CASE WHEN correctCD = CD AND correctCD <> '' THEN 1 ELSE 0 END;
END$$

DROP FUNCTION IF EXISTS getBankAccountCheckDigits $$

CREATE FUNCTION getBankAccountCheckDigits(
    entity VARCHAR(4), office VARCHAR(4), account VARCHAR(10) )

    RETURNS VARCHAR(2)
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Obtains the correct check digits for a given Spanish account number'
BEGIN
    /*
        This function expects the different parts of an Spanish account as
        parameters: entity, office and account.

        This function returns the two check digits for the account number.

        Usage:
                SELECT getBankAccountCheckDigits( '1234', '1234', '1234567890' );
        Returns:
                16
    */

    DECLARE entitySum INT;
    DECLARE officeSum INT;
    DECLARE accountSum INT;

    DECLARE CD1 VARCHAR(1);
    DECLARE CD2 VARCHAR(1);

    SET CD1 = '';
    SET CD2 = '';

    IF( respectsAccountPattern ( entity, office, account ) ) THEN
        SET entitySum =
            CAST( SUBSTRING( entity, 1, 1 ) AS INT ) * 4 +
            CAST( SUBSTRING( entity, 2, 1 ) AS INT ) * 8 +
            CAST( SUBSTRING( entity, 3, 1 ) AS INT ) * 5 +
            CAST( SUBSTRING( entity, 4, 1 ) AS INT ) * 10;

        SET officeSum =
            CAST( SUBSTRING( office, 1, 1 ) AS INT ) * 9 +
            CAST( SUBSTRING( office, 2, 1 ) AS INT ) * 7 +
            CAST( SUBSTRING( office, 3, 1 ) AS INT ) * 3 +
            CAST( SUBSTRING( office, 4, 1 ) AS INT ) * 6;

        SET CD1 = 11 - ( ( entitySum + officeSum ) % 11 );

        SET accountSum =
            CAST( SUBSTRING( account, 1, 1 ) AS INT ) * 1 +
            CAST( SUBSTRING( account, 2, 1 ) AS INT ) * 2 +
            CAST( SUBSTRING( account, 3, 1 ) AS INT ) * 4 +
            CAST( SUBSTRING( account, 4, 1 ) AS INT ) * 8 +
            CAST( SUBSTRING( account, 5, 1 ) AS INT ) * 5 +
            CAST( SUBSTRING( account, 6, 1 ) AS INT ) * 10 +
            CAST( SUBSTRING( account, 7, 1 ) AS INT ) * 9 +
            CAST( SUBSTRING( account, 8, 1 ) AS INT ) * 7 +
            CAST( SUBSTRING( account, 9, 1 ) AS INT ) * 3 +
            CAST( SUBSTRING( account, 10, 1 ) AS INT ) * 6;

        SET CD2 = 11 - ( accountSum % 11 );
    END IF;

    RETURN CONCAT( CD1, CD2 );
END$$

DROP FUNCTION IF EXISTS respectsAccountPattern $$

CREATE FUNCTION respectsAccountPattern(
    entity VARCHAR(4), office VARCHAR(4), account VARCHAR(10) )

    RETURNS INTEGER
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Validates the structure of a Spanish account number'
BEGIN
    /*
        This function validates the format of a Spanish account number.
        We consider that the correct format is:
            - A string of 4 characters lenght, only numbers, for the entity
            - A string of 4 characters lenght, only numbers, for the office
            - A string of 10 characters lenght, only numbers, for the account

        This function does not validate the account check digits. Only validates
        its structure.

        This function returns:
            1: If specified string respects the pattern
            0: Otherwise

        Usage:
            SELECT respectsAccountPattern( '1234', '123A', '1234567890' );
        Returns:
            0
    */
    
    DECLARE isValid INT;

    SET isValid = 1;

    IF( entity NOT REGEXP '[0-9][0-9][0-9][0-9]' ) THEN
        SET isValid = 0;
    END IF;

    IF( office NOT REGEXP '[0-9][0-9][0-9][0-9]' ) THEN
        SET isValid = 0;
    END IF;

    IF( account NOT REGEXP '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' ) THEN
        SET isValid = 0;
    END IF;

    RETURN isValid;
END $$
