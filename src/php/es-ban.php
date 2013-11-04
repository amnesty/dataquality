<?php
   /*
    *   This function expects the different parts of an Spanish account as
    *   parameters: entity, office, control digits and account.
    *
    *   This function returns 1 if the control digit is correct. 0 if it is not.
    *
    *   Usage:
    *           echo isValidAccountNumber( '1234', '1234', '16', '1234567890' );
    *   Returns:
    *           TRUE
    */
    function isValidAccountNumber( $entity, $office, $CD, $account ) {
        $correctCD = "";

        if( respectsAccountPattern ( $entity, $office, $account ) ) {
            $correctCD = getBankAccountControlDigits( $entity, $office, $account );
        }

        return ( ( $correctCD == $CD ) && ( $correctCD != "" ) );
    }

   /*
    *   This function expects the different parts of an Spanish account as
    *   parameters: entity, office and account.
    *
    *   This function returns the two control digits for the account number.
    *
    *   Usage:
    *           echo getBankAccountControlDigits( '1234', '1234', '1234567890' );
    *   Returns:
    *           16
    */
    function getBankAccountControlDigits( $entity, $office, $account ) {
        $entitySum = 0;
        $officeSum = 0;
        $accountSum = 0;

        $CD1 = "";
        $CD2 = "";

        if( respectsAccountPattern ( $entity, $office, $account ) ) {
            $entitySum =
                substr( $entity, 0, 1 ) * 4 +
                substr( $entity, 1, 1 ) * 8 +
                substr( $entity, 2, 1 ) * 5 +
                substr( $entity, 3, 1 ) * 10;

            $officeSum =
                substr( $office, 0, 1 ) * 9 +
                substr( $office, 1, 1 ) * 7 +
                substr( $office, 2, 1 ) * 3 +
                substr( $office, 3, 1 ) * 6;

            $CD1 = 11 - ( ( $entitySum + $officeSum ) % 11 );

            $accountSum =
                substr( $account, 0, 1 ) * 1 +
                substr( $account, 1, 1 ) * 2 +
                substr( $account, 2, 1 ) * 4 +
                substr( $account, 3, 1 ) * 8 +
                substr( $account, 4, 1 ) * 5 +
                substr( $account, 5, 1 ) * 10 +
                substr( $account, 6, 1 ) * 9 +
                substr( $account, 7, 1 ) * 7 +
                substr( $account, 8, 1 ) * 3 +
                substr( $account, 9, 1 ) * 6;

            $CD2 = 11 - ( $accountSum % 11 );
        }

        return $CD1 . $CD2;
    }

   /*
    *   This function validates the format of a Spanish account number.
    *   We consider that the correct format is:
    *       - A string of 4 characters lenght, only numbers, for the entity
    *       - A string of 4 characters lenght, only numbers, for the office
    *       - A string of 10 characters lenght, only numbers, for the account
    *
    *   This function does not validate the account control digits. Only validates
    *   its structure.
    *
    *   This function returns:
    *       TRUE: If specified string respects the pattern
    *       FALSE: Otherwise
    *
    *   Usage:
    *       echo respectsAccountPattern( '1234', '123A', '1234567890' );
    *   Returns:
    *       FALSE
    */
    function respectsAccountPattern( $entity, $office, $account ) {
        $isValid = TRUE;

        if( !preg_match( "/^[0-9][0-9][0-9][0-9]/", $entity ) ) {
            $isValid = FALSE;
        }

        if( !preg_match( "/^[0-9][0-9][0-9][0-9]/", $office ) ) {
            $isValid = FALSE;
        }

        if( !preg_match( "/^[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]/", $account ) ) {
            $isValid = FALSE;
        }

        return $isValid;
    }
?>

