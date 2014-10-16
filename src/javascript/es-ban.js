   /*
    * isValidAccountNumber validates an Spanish bank account by verifying
    * its structure and check digits.
    *
    * @link https://github.com/amnesty/dataquality/wiki/isValidAccountNumber
    */
    function isValidAccountNumber( entity, office, CD, account ) {
        var correctCD = "";

        if( respectsAccountPattern ( entity, office, account ) ) {
            correctCD = getBankAccountCheckDigits( entity, office, account );
        }

        return ( ( correctCD == CD ) && ( correctCD != "" ) );
    }

    /*
     * getBankAccountCheckDigits calculates the check digits for an Spanish bank
     * account. To calculate them, it needs the rest of the parts of the account.
     *
     * @link https://github.com/amnesty/dataquality/wiki/getBankAccountCheckDigits
     */
    function getBankAccountCheckDigits( entity, office, account ) {
        var entitySum = 0;
        var officeSum = 0;
        var accountSum = 0;

        var CD1 = "";
        var CD2 = "";

        if( respectsAccountPattern ( entity, office, account ) ) {
            entitySum =
                parseInt( entity.substr( 0, 1 ) ) * 4 +
                parseInt( entity.substr( 1, 1 ) ) * 8 +
                parseInt( entity.substr( 2, 1 ) ) * 5 +
                parseInt( entity.substr( 3, 1 ) ) * 10;

            officeSum =
                parseInt( office.substr( 0, 1 ) ) * 9 +
                parseInt( office.substr( 1, 1 ) ) * 7 +
                parseInt( office.substr( 2, 1 ) ) * 3 +
                parseInt( office.substr( 3, 1 ) ) * 6;

            CD1 = 11 - ( ( entitySum + officeSum ) % 11 );

            accountSum =
                parseInt( account.substr( 0, 1 ) ) * 1 +
                parseInt( account.substr( 1, 1 ) ) * 2 +
                parseInt( account.substr( 2, 1 ) ) * 4 +
                parseInt( account.substr( 3, 1 ) ) * 8 +
                parseInt( account.substr( 4, 1 ) ) * 5 +
                parseInt( account.substr( 5, 1 ) ) * 10 +
                parseInt( account.substr( 6, 1 ) ) * 9 +
                parseInt( account.substr( 7, 1 ) ) * 7 +
                parseInt( account.substr( 8, 1 ) ) * 3 +
                parseInt( account.substr( 9, 1 ) ) * 6;

            CD2 = 11 - ( accountSum % 11 );
        }

        return CD1.toString() + CD2.toString();
    }

   /*
    * respectsAccountPattern verifies that three strings respect the
    * expected pattern for an Spanish bank account number.
    *
    * @link https://github.com/amnesty/dataquality/wiki/respectsAccountPattern
    */
    function respectsAccountPattern( entity, office, account ) {
        var isValid = true;

        if( ! /^[0-9][0-9][0-9][0-9]/.test( entity ) ) {
            isValid = false;
        }

        if( ! /^[0-9][0-9][0-9][0-9]/.test( office ) ) {
            isValid = false;
        }

        if( ! /^[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]/.test( account ) ) {
            isValid = false;
        }

        return isValid;
    }
