<?php
   /*
    *   This function expects the entire account number in the electronic
    *   format (without spaces), as described in the ISO 13616-Compliant
    *   IBAN Formats document.
    *
    *   This function returns:
    *       TRUE: If the given account number is valid.
    *       FALSE: Otherwise.
    *
    *   Usage:
    *       SELECT isValidIBAN( 'GB82WEST12345698765432' );
    *   Returns:
    *       TRUE
    */
    function isValidIBAN( $accNumber ) {
        $isValid = FALSE;
        $countryCode = substr( $accNumber, 0, 2 );
        $writenDigits = substr( $accNumber, 2, 2 );

        if ( isSepaCountry( $countryCode ) ) {
            if ( strlen( $accNumber ) == getAccountLength( $countryCode ) ) {
                if ( $writenDigits == getIBANControlDigits( $accNumber ) ) {
                    $isValid = TRUE;
                }
            }
        }

        return $isValid;
    }

   /*
    *   This function expects a country code as parameter. The code must follow
    *   the ISO format of 2 characters (as in ES for Spain).
    *
    *   This function returns:
    *       - TRUE: If countryCode is a valid Sepa Country Code.
    *       - FALSE: Otherwise.
    *
    *   Usage:
    *       SELECT isSepaCountry( 'ES' );
    *   Returns:
    *       TRUE
    */
    function isSepaCountry( $countryCode ) {
        $isSepa = FALSE;

        if ( getAccountLength( $countryCode ) <> 0 ) {
            $isSepa = TRUE;
        }

        return $isSepa;
    }

   /*
    *   This function expects a country code as parameter. The code must follow
    *   the ISO format of 2 characters (as in ES for Spain).
    *
    *   This function returns:
    *       - The expected account length for the given country code.
    *       - 0: If countryCode is not a country that belongs to the SEPA area.
    *
    *   Usage:
    *       echo getAccountLength( 'GB' );
    *   Returns:
    *       22
    */
    function getAccountLength( $countryCode ) {
        $accountLength = 0;

        /* Information Source: IBAN Registry about all ISO 13616-compliant
            national IBAN formats (Release 45 – April 2013).
            http://www.swift.com/dsp/resources/documents/IBAN_Registry.pdf */

        $accountLengthPerCountry = array(
            'AL' => 28, 'AD' => 24, 'AT' => 20, 'AZ' => 28, 'BH' => 22,
            'BE' => 16, 'BA' => 20, 'BR' => 29, 'BG' => 22, 'CR' => 21,
            'HR' => 21, 'CY' => 28, 'CZ' => 24, 'DK' => 18, 'DO' => 28,
            'EE' => 20, 'FO' => 18, 'FI' => 18, 'FR' => 27, 'GE' => 22,
            'DE' => 22, 'GI' => 23, 'GR' => 27, 'GL' => 18, 'GT' => 28,
            'HU' => 28, 'IS' => 26, 'IE' => 22, 'IL' => 23, 'IT' => 27,
            'KZ' => 20, 'KW' => 30, 'LV' => 21, 'LB' => 28, 'LI' => 21,
            'LT' => 20, 'LU' => 20, 'MK' => 19, 'MT' => 31, 'MR' => 27,
            'MU' => 30, 'MC' => 27, 'MD' => 24, 'ME' => 22, 'NL' => 18,
            'NO' => 15, 'PK' => 24, 'PS' => 29, 'PL' => 28, 'PT' => 25,
            'RO' => 24, 'SM' => 27, 'SA' => 24, 'RS' => 22, 'SK' => 24,
            'SI' => 19, 'ES' => 24, 'SE' => 24, 'CH' => 21, 'TN' => 24,
            'TR' => 26, 'AE' => 23, 'GB' => 22, 'VG' => 24, 'AO' => 25,
            'BJ' => 28, 'BF' => 27, 'BI' => 16, 'CM' => 27, 'CV' => 25,
            'IR' => 26, 'CI' => 28, 'MG' => 27, 'ML' => 28, 'MZ' => 25,
            'SN' => 28 );

        if( $countryCode ) {
            if( array_key_exists( $countryCode, $accountLengthPerCountry ) ) {
                $accountLength = $accountLengthPerCountry[ $countryCode ];
            }
        }

        return $accountLength;
    }

   /*
    *   This function expects the entire account number in the electronic
    *   format (without spaces), as described in the ISO 13616-Compliant
    *   IBAN Formats document.
    *
    *   You can replace control digits with zeros when calling the function.
    *
    *   This function requires:
    *           - replaceLetterWithDigits
    *           - accountLegthPerCountry (table)
    *
    *   Usage:
    *           echo getIBANControlDigits( 'GB00WEST12345698765432' );
    *   Returns:
    *           82
    */
    function getIBANControlDigits( $accNumber ) {
        $countryCode = "";
        $accountLength = 0;
        $accRearranged = "";
        $accWithoutLetters = "";
        $accMod97 = 0;
        $digits = "";

        $countryCode = substr( $accNumber, 0, 2 );
        $accountLength = getAccountLength( $countryCode );

        if( isSepaCountry( $countryCode ) ) {
            if( strlen( $accNumber ) == $accountLength ) {
                /* Replace the two check digits by 00 (e.g., GB00 for the UK) and
                    Move the four initial characters to the end of the string. */
                $accRearranged =
                    substr( $accNumber, 4 - strlen( $accNumber ) ) . substr( $accNumber, 0, 2 ) . '00';

                /* Replace the letters in the string with digits, expanding the string as necessary,
                    such that A or a = 10, B or b = 11, and Z or z = 35.
                    Each alphabetic character is therefore replaced by 2 digits. */
                $accWithoutLetters = replaceLetterWithDigits( $accRearranged );

                /* Convert the string to an integer (i.e., ignore leading zeroes) and
                    Calculate mod-97 of the new number, which results in the remainder. */
                $accMod97 = bcmod( $accWithoutLetters, 97 );

                /* Subtract the remainder from 98, and use the result for the two check digits. */
                $digits = 98 - $accMod97;

                /* If the result is a single digit number, pad it with a leading 0 to make a two-digit number. */
                $digits = substr( '00' . $digits, -2);
            }
        }

        return $digits;
    }

   /*
    *   The identification numbers used in Sepa are calculated from the local
    *   identification numbers. For instance, if your Spanish (local)
    *   identification number is G28667152, your global identification
    *   number must be ES03000G28667152.
    *
    *   This function requires:
    *           - replaceLetterWithDigits
    *           - replaceCharactersNotInPattern
    *
    *   Usage:
    *           echo getGlobalIdentifier( 'G28667152', 'ES', '' );
    *   Returns:
    *           ES03000G28667152
    */
    function getGlobalIdentifier( $localId, $countryCode, $suffix ) {
        $withCountry = "";
        $without5and7 = "";
        $alphaNumerical = "";
        $withoutLetters = "";
        $mod97 = 0;
        $digits = "";
        $globalId = "";

        /* Concatenate localId plus country code and two zeros (00) */
        $withCountry = $localId . $countryCode . '00';

        /* Exclude positions 5 and 7 */
        $without5and7 =
            substr( $withCountry, 0, 4 ) .
            substr( $withCountry, 5, 1 ) .
            substr( $withCountry, 7 );

        /* Removes non alpha-numerical characters */
        $alphaNumerical = replaceCharactersNotInPattern( $without5and7,
            'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', '' );

        /* Replace the letters in the string with digits, expanding the string as necessary,
        such that A or a = 10, B or b = 11, and Z or z = 35.
        Each alphabetic character is therefore replaced by 2 digits. */
        $withoutLetters = replaceLetterWithDigits( $alphaNumerical );

        /* Convert the string to an integer (i.e., ignore leading zeroes) and
        Calculate mod-97 of the new number, which results in the remainder. */
        $mod97 = $withoutLetters % 97;

        /* Subtract the remainder from 98, and use the result for the two check digits. */
        $digits = 98 - $mod97;

        /* If the result is a single digit number, pad it with a leading 0 to make a two-digit number. */
        $digits = substr( '00' . $digits, -2);

        /* Suffix must be a number from 000 to 999 */
        $suffix = replaceCharactersNotInPattern( $suffix, '0123456789', '0' );
        $suffix = substr( '000' . $suffix, -3 );

        return $countryCode . $digits . $suffix . $localId;
    }

   /*
    *   This function replaces unwanted characters from a string with a given
    *   character.
    *
    *   If a string 'ABCDEF%' and a pattern 'ABDF' are given, it returns
    *   a new string where:
    *       - the characters in the string that respect the patter remain unchanged
    *       - other characters are replaced with the given substitution character
    *
    *   This function is used by:
    *       - getGlobalIdentifier
    *
    *   Usage:
    *       SELECT replaceCharactersNotInPattern(
    *           'ABC123-?:', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', '0' )
    *   Returns:
    *       'ABC123000'
    */
    function replaceCharactersNotInPattern( $givenString, $pattern, $replaceWith ) {
        $verifyLetter = "";
        $i = 1;

        while( $i <= strlen( $givenString ) ) {
            $verifyLetter = substr( $givenString, $i-1, 1 );

            if( strpos( $pattern, $verifyLetter ) === false ) {
                $givenString = str_replace( $verifyLetter, $replaceWith, $givenString );
            }

            $i++;
        }

        return $givenString;
    }

   /*
    *   This functions changes letters in a given string
    *   with its correspondant numbers, as described in
    *   ECBS EBS204 V3.2 [August 2003] document:
    *
    *   A=1, B=2, ..., Y=34, Z=35
    *
    *   Usage:
    *       SELECT replaceLetterWithDigits( '510007547061BE00' )
    *   Returns:
    *       510007547061111400
    */
    function replaceLetterWithDigits( $accNumber ) {
        $letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        $findLetter = "";
        $replaceWith = 0;
        $i = 0;

        while( $i <= strlen( $letters ) ) {
            $findLetter = substr( $letters, $i-1, 1 );
            $replaceWith = strpos( $letters, $findLetter ) + 10;
            $accNumber = str_replace( $findLetter, $replaceWith, $accNumber );

            $i++;
        }

        return $accNumber;
    }
?>

