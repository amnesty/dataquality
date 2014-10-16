   /*
    * isValidIBAN validates an IBAN by verifying its structure and
    * check digits.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/isValidIBAN
    */
    function isValidIBAN( accNumber ) {
        var isValid = false;
        var countryCode = accNumber.substr( 0, 2 );
        var writenDigits = accNumber.substr( 2, 2 );

        if ( isSepaCountry( countryCode ) ) {
            if ( accNumber.length == getAccountLength( countryCode ) ) {
                if ( writenDigits == getIBANCheckDigits( accNumber ) ) {
                    isValid = true;
                }
            }
        }

        return isValid;
    }

   /*
    * isSepaCountry helps to check the first two digits of an IBAN.
    * These two digits are referring to the country where the
    * account was created, so they only can correspond to one
    * of the countries in the Single Euro Payments Area (SEPA) area.
    * 
    * A document with a full list of the SEPA countries, its
    * corresponding IBAN structures and more is available at
    * the Swift website as IBAN Registry.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/isSepaCountry
    */
    function isSepaCountry( countryCode ) {
        isSepa = false;

        if ( getAccountLength( countryCode ) != 0 ) {
            isSepa = true;
        }

        return isSepa;
    }

   /*
    * getAccountLength returns the expected length for an IBAN given
    * its first two digits. For instance, British accounts have 22
    * characters when written in IBAN electronic format.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/getAccountLength
    */
    function getAccountLength( countryCode ) {
        var accountLength = 0;

        /* Information Source: IBAN Registry about all ISO 13616-compliant
            national IBAN formats (Release 45 – April 2013).
            http://www.swift.com/dsp/resources/documents/IBAN_Registry.pdf */

        accountLengthPerCountry = {
            'AL': 28, 'AD': 24, 'AT': 20, 'AZ': 28, 'BH': 22,
            'BE': 16, 'BA': 20, 'BR': 29, 'BG': 22, 'CR': 21,
            'HR': 21, 'CY': 28, 'CZ': 24, 'DK': 18, 'DO': 28,
            'EE': 20, 'FO': 18, 'FI': 18, 'FR': 27, 'GE': 22,
            'DE': 22, 'GI': 23, 'GR': 27, 'GL': 18, 'GT': 28,
            'HU': 28, 'IS': 26, 'IE': 22, 'IL': 23, 'IT': 27,
            'KZ': 20, 'KW': 30, 'LV': 21, 'LB': 28, 'LI': 21,
            'LT': 20, 'LU': 20, 'MK': 19, 'MT': 31, 'MR': 27,
            'MU': 30, 'MC': 27, 'MD': 24, 'ME': 22, 'NL': 18,
            'NO': 15, 'PK': 24, 'PS': 29, 'PL': 28, 'PT': 25,
            'RO': 24, 'SM': 27, 'SA': 24, 'RS': 22, 'SK': 24,
            'SI': 19, 'ES': 24, 'SE': 24, 'CH': 21, 'TN': 24,
            'TR': 26, 'AE': 23, 'GB': 22, 'VG': 24, 'AO': 25,
            'BJ': 28, 'BF': 27, 'BI': 16, 'CM': 27, 'CV': 25,
            'IR': 26, 'CI': 28, 'MG': 27, 'ML': 28, 'MZ': 25,
            'SN': 28 };

        if( countryCode ) {
            if( countryCode in accountLengthPerCountry ) {
                accountLength = accountLengthPerCountry[ countryCode ];
            }
        }

        return accountLength;
    }

   /*
    * This function expects the entire account number in the electronic
    * format (without spaces), as described in the ISO 13616-Compliant
    * IBAN Formats document.
    *
    * You can replace check digits with zeros when calling the function.
    *
    * @link https://github.com/amnesty/dataquality/wiki/getIBANCheckDigits
    */
    function getIBANCheckDigits( accNumber ) {
        var countryCode = "";
        var accountLength = 0;
        var accRearranged = "";
        var accWithoutLetters = "";
        var accMod97 = 0;
        var digits = "";
        var digitsWithZeros = "";

        countryCode = accNumber.substr( 0, 2 );
        accountLength = getAccountLength( countryCode );

        if( isSepaCountry( countryCode ) ) {
            if( accNumber.length == accountLength ) {
                /* Replace the two check digits by 00 (e.g., GB00 for the UK) and
                    Move the four initial characters to the end of the string. */
                accRearranged =
                    accNumber.substr( 4 - accNumber.length ) + accNumber.substr( 0, 2 ) + '00';

                /* Replace the letters in the string with digits, expanding the string as necessary,
                    such that A or a = 10, B or b = 11, and Z or z = 35.
                    Each alphabetic character is therefore replaced by 2 digits. */
                accWithoutLetters = replaceLetterWithDigits( accRearranged );

                /* Convert the string to an integer (i.e., ignore leading zeroes) and
                    Calculate mod-97 of the new number, which results in the remainder. */
                accMod97 = modulus( accWithoutLetters, 97 );

                /* Subtract the remainder from 98, and use the result for the two check digits. */
                digits = 98 - accMod97;

                /* If the result is a single digit number, pad it with a leading 0 to make a two-digit number. */
                digitsWithZeros = '00' + digits.toString();
                digits = digitsWithZeros.substr( -2 );
            }
        }

        return digits;
    }

    /*
     * Auxiliary function. Helps to calculate modulus when working
     * with big integers.
     * 
     * @link http://stackoverflow.com/questions/929910/modulo-in-javascript-large-number
     */
    function modulus(divident, divisor) {
        var cDivident = '';
        var cRest = '';

        for (var i in divident ) {
            var cChar = divident[i];
            var cOperator = cRest + '' + cDivident + '' + cChar;

            if ( cOperator < parseInt(divisor) ) {
                    cDivident += '' + cChar;
            } else {
                    cRest = cOperator % divisor;
                    if ( cRest == 0 ) {
                        cRest = '';
                    }
                    cDivident = '';
            }

        }
        cRest += '' + cDivident;
        if (cRest == '') {
            cRest = 0;
        }
        return cRest;
    }

   /*
    * This "global identifier" refers to the code AT-02 created for the
    * C19.14. The C19.14 is a temporary file format to be used in Spain
    * until the ISO 20022 XML format is finally adopted.
    * 
    * If the IBAN is built by adding a few digits to the national bank
    * accounts, the AT-02 is build by adding digits to the national
    * identifier. In the case of Spain, this identifiers are NIFs,
    * NIEs and CIFs.
    * 
    * For instance, the Spanish CIF G28667152, can be expressed
    * internationally as ES03000G28667152.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/getGlobalIdentifier
    */
    function getGlobalIdentifier( localId, countryCode, suffix ) {
        var withCountry = "";
        var without5and7 = "";
        var alphaNumerical = "";
        var withoutLetters = "";
        var mod97 = 0;
        var digitsWithZeros = "";
        var digits = "";
        var suffixWithZeros = "";
        var globalId = "";

        /* Concatenate localId plus country code and two zeros (00) */
        withCountry = localId + countryCode + '00';

        /* Exclude positions 5 and 7 */
        without5and7 =
            withCountry.substr( 0, 4 ) +
            withCountry.substr( 5, 1 ) +
            withCountry.substr( 7 );

        /* Removes non alpha-numerical characters */
        alphaNumerical = replaceCharactersNotInPattern( without5and7,
            'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', '' );

        /* Replace the letters in the string with digits, expanding the string as necessary,
        such that A or a = 10, B or b = 11, and Z or z = 35.
        Each alphabetic character is therefore replaced by 2 digits. */
        withoutLetters = replaceLetterWithDigits( alphaNumerical );

        /* Convert the string to an integer (i.e., ignore leading zeroes) and
        Calculate mod-97 of the new number, which results in the remainder. */
        mod97 = withoutLetters % 97;

        /* Subtract the remainder from 98, and use the result for the two check digits. */
        digits = 98 - mod97;

        /* If the result is a single digit number, pad it with a leading 0 to make a two-digit number. */
        digitsWithZeros = '00' + digits;
        digits = digitsWithZeros.substr( -2 );

        /* Suffix must be a number from 000 to 999 */
        suffix = replaceCharactersNotInPattern( suffix, '0123456789', '0' );
        suffixWithZeros = '000' + suffix;
        suffix = suffixWithZeros.substr( -3 );

        return countryCode + digits + suffix + localId;
    }

   /*
    * replaceCharactersNotInPattern replaces unwanted characters from a string
    * with a given character.
    * 
    * An example:
    * - We have this string: 1!2/3·A|B@C#
    * - This are the characters we accept: 123ABC
    * - This is the character we want to replace extra characters with: 0
    * - The example would return: 102030A0B0C0
    * 
    * @link https://github.com/amnesty/dataquality/wiki/replaceCharactersNotInPattern
    */
    function replaceCharactersNotInPattern( givenString, pattern, replaceWith ) {
        var verifyLetter = "";
        var i = 1;

        while( i <= givenString.length ) {
            verifyLetter = givenString.substr( i-1, 1 );

            if( pattern.indexOf( verifyLetter ) < 0 ) {
                givenString = givenString.replace( verifyLetter, replaceWith );
            }

            i++;
        }

        return givenString;
    }

   /*
    * replaceLetterWithDigits changes letters in a given string with its
    * correspondent numbers, as described in ECBS EBS204 V3.2 [August 2003]
    * document: A=1, B=2, ..., Y=34, Z=35.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/replaceLetterWithDigits
    */
    function replaceLetterWithDigits( accNumber ) {
        var letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        var findLetter = "";
        var replaceWith = 0;
        var i = 0;

        while( i <= letters.length ) {
            findLetter = letters.substr( i-1, 1 );
            replaceWith = letters.indexOf( findLetter ) + 10;
            accNumber = accNumber.replace( findLetter, replaceWith );

            i++;
        }

        return accNumber;
    }
