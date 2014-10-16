<?php
   /*
    * isValidAccountNumber validates an Spanish bank account by verifying
    * its structure and check digits.
    *
    * @link https://github.com/amnesty/dataquality/wiki/isValidAccountNumber
    */
    function isValidAccountNumber( $entity, $office, $CD, $account ) {
        $correctCD = "";

        if( respectsAccountPattern ( $entity, $office, $account ) ) {
            $correctCD = getBankAccountCheckDigits( $entity, $office, $account );
        }

        return ( ( $correctCD == $CD ) && ( $correctCD != "" ) );
    }

    /*
     * getBankAccountCheckDigits calculates the check digits for an Spanish bank
     * account. To calculate them, it needs the rest of the parts of the account.
     *
     * @link https://github.com/amnesty/dataquality/wiki/getBankAccountCheckDigits
     */
    function getBankAccountCheckDigits( $entity, $office, $account ) {
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
    * respectsAccountPattern verifies that three strings respect the
    * expected pattern for an Spanish bank account number.
    *
    * @link https://github.com/amnesty/dataquality/wiki/respectsAccountPattern
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

