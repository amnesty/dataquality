DROP FUNCTION IF EXISTS isValidAccountNumber $$

CREATE FUNCTION isValidAccountNumber(
    entity VARCHAR(4), office VARCHAR(4), CD VARCHAR(2), account VARCHAR(10) )

    RETURNS INTEGER
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Verifies the structure of an Spanish account number and its check digits'
BEGIN
   /*
    * isValidAccountNumber validates an Spanish bank account by verifying
    * its structure and check digits.
    *
    * @link https://github.com/amnesty/dataquality/wiki/isValidAccountNumber
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
     * getBankAccountCheckDigits calculates the check digits for an Spanish bank
     * account. To calculate them, it needs the rest of the parts of the account.
     *
     * @link https://github.com/amnesty/dataquality/wiki/getBankAccountCheckDigits
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
    * respectsAccountPattern verifies that three strings respect the
    * expected pattern for an Spanish bank account number.
    *
    * @link https://github.com/amnesty/dataquality/wiki/respectsAccountPattern
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
