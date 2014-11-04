  /*
   * Inserts a given character into a string every n positions.
   * 
   * @link https://github.com/amnesty/dataquality/wiki/addEvery
   */
  function addEvery( string, char, n, removeExisting ) {
    //By default, remove existing instances of the character
    removeExisting = typeof removeExisting !== 'undefined' ? removeExisting : true;

    //n must be a positive integer
    n = +n;
    if( ( n <= 0 ) || ( n != ~~n ) ) {
      return string;
    }

    //Remove existing instances of the character, if we've been told to
    if( removeExisting ) {
      string = string.replace( new RegExp( char, 'g' ), '' );
    }
    
    //Every n positions, we insert the desired char
    var buffer = "";
    for( i = 0; i < string.length; i = i + n ) {
      subString = string.substr( i, n );
      
      if( ( subString.length == n ) && ( string.length != ( i + n ) ) ) {
        buffer += subString + char;
      } else {
        buffer += subString;
      }
    }
    
    //Returns the modified string
    return buffer;
  }

  /*
   * Adds the addEvery function to the String prototype.
   */
  String.prototype.addEvery = function ( char, n, removeExisting ) {
    return addEvery( this.toString(), char, n, removeExisting );
  }

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
     * Auxiliary function. Helps to calculate modulus when working
     * with big integers.
     * 
     * @link http://stackoverflow.com/questions/929910/modulo-in-javascript-large-number
     */
    function modulus(divident, divisor) {
      var partLength = 10;

      while (divident.length > partLength) {
        var part = divident.substring(0, partLength);
        divident = (part % divisor) +  divident.substring(partLength);          
      }

      return divident % divisor;
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

   /*
    * isValidIdNumber validates a Spanish identification number
    * verifying its check digits. It doesn't need to be told
    * about the document type, that can be a NIF, a NIE or a CIF.
    * 
    * - NIFs and NIEs are personal numbers.
    * - CIFs are corporates.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/isValidIdNumber
    */
    function isValidIdNumber( docNumber ) {
        fixedDocNumber = docNumber.toUpperCase();

        if( isValidNIFFormat( fixedDocNumber ) ) {
            return isValidNIF( fixedDocNumber );
        } else {
            if( isValidNIEFormat( fixedDocNumber ) ) {
                return isValidNIE( fixedDocNumber );
            } else {
                if( isValidCIFFormat( fixedDocNumber ) ) {
                    return isValidCIF( fixedDocNumber );
                } else {
                    return false;
                }
            }
        }
    }

   /*
    * isValidNIF validates the check digits of an identification
    * number, after verifying the string structure actually fits
    * the NIF pattern.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/isValidNIF
    */
    function isValidNIF( docNumber ) {
        var isValid = false;
        var fixedDocNumber = docNumber.toUpperCase();

        var correctDigit = "";
        var writtenDigit = "";

        if( ! /^[A-Z]+$/i.test( fixedDocNumber.substr( 1, 1 ) ) ) {
            fixedDocNumber = "000000000" + docNumber;
            fixedDocNumber = fixedDocNumber.substr( -9 );
        }

        writtenDigit = docNumber.substr( -1, 1 );

        if( isValidNIFFormat( fixedDocNumber ) ) {
            correctDigit = getNIFCheckDigit( fixedDocNumber );

            if( writtenDigit == correctDigit ) {
                isValid = true;
            }
        }

        return isValid;
    }

   /*
    * isValidNIE validates the check digits of an identification number,
    * after verifying the string structure actually fits the NIE pattern.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/isValidNIE
    */
    function isValidNIE( docNumber ) {
        var isValid = false;
        var fixedDocNumber = docNumber.toUpperCase();

        if( ! /^[A-Z]+$/i.test( fixedDocNumber.substr( 1, 1 ) ) ) {
            fixedDocNumber = "000000000" + docNumber;
            fixedDocNumber = fixedDocNumber.substr( -9 );
        }

        if( isValidNIEFormat( fixedDocNumber ) ) {
            if( fixedDocNumber.substr( 1, 1 ) == "T" ) {
                isValid = true;
            } else {
                /* The algorithm for validating the check digits of a NIE number is
                    identical to the altorithm for validating NIF numbers. We only have to
                    replace Y, X and Z with 1, 0 and 2 respectively; and then, run
                    the NIF altorithm */

                fixedDocNumber = fixedDocNumber.replace( 'Y', '1' );
                fixedDocNumber = fixedDocNumber.replace( 'X', '0' );
                fixedDocNumber = fixedDocNumber.replace( 'Z', '2' );

                isValid = isValidNIF( fixedDocNumber );
            }
        }

        return isValid;
    }

   /*
    * isValidCIF validates the check digits of an identification number,
    * after verifying the string structure actually fits the CIF pattern.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/isValidCIF
    */
    function isValidCIF( docNumber ) {
        var isValid = false;
        var fixedDocNumber = "";

        var correctDigit = "";
        var writtenDigit = "";

        fixedDocNumber = docNumber.toUpperCase();
        writtenDigit = fixedDocNumber.substr( -1, 1 );

        if( isValidCIFFormat( fixedDocNumber ) ) {
            correctDigit = getCIFCheckDigit( fixedDocNumber );

            if( writtenDigit == correctDigit ) {
                isValid = true;
            }
        }

        return isValid;
    }

   /*
    * isValidNIFFormat tests a string against a regexp pattern
    * to see if the string fits the NIF structure.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/isValidNIFFormat
    */
    function isValidNIFFormat( docNumber ) {
        return respectsDocPattern(
            docNumber,
            /^[KLM0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z0-9]/ );
    }

   /*
    * isValidNIEFormat tests a string against a regexp pattern to see
    * if the string fits the NIE structure.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/isValidNIEFormat
    */
    function isValidNIEFormat( docNumber ) {
        return respectsDocPattern(
            docNumber,
            /^[XYZT][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z0-9]/ );
    }

   /*
    * isValidCIFFormat tests a string against a regexp pattern to see
    * if the string fits the CIF structure.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/isValidCIFFormat
    */
    function isValidCIFFormat( docNumber ) {     
        var isValid = false;
        
        isValid = (
                ( respectsDocPattern(
                      docNumber,
                      /^[PQSNWR][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z0-9]/ )
                )
            ||
                ( respectsDocPattern(
                      docNumber,
                      /^[ABCDEFGHJUV][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]/ )
                )
            );
        
        return isValid;
    }

   /*
    * getNIFCheckDigit obtains and returns the corresponding check digit for a
    * given string. In order to work, the string must match the NIF pattern.
    * 
    * This function has been written to be used from isValidNIF as a helper,
    * but it can still be calle directly.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/getNIFCheckDigit
    */
    function getNIFCheckDigit( docNumber ) {
        var keyString = 'TRWAGMYFPDXBNJZSQVHLCKE';

        var fixedDocNumber = docNumber.toUpperCase();

        var position = 0;
        var writtenLetter = "";
        var correctLetter = "";

        if( ! /^[A-Z]+$/i.test( fixedDocNumber.substr( 1, 1 ) ) ) {
            fixedDocNumber = "000000000" + fixedDocNumber;
            fixedDocNumber = fixedDocNumber.substr( -9 );
        } else {
            fixedDocNumber = docNumber.toUpperCase();
        }

        if( isValidNIFFormat( fixedDocNumber ) ) {
            writtenLetter = fixedDocNumber.substr( -1 );

            fixedDocNumber = fixedDocNumber.replace( 'K', '0' );
            fixedDocNumber = fixedDocNumber.replace( 'L', '0' );
            fixedDocNumber = fixedDocNumber.replace( 'M', '0' );

            position = fixedDocNumber.substr( 0, 8 ) % 23;
            correctLetter = keyString.substr( position, 1 );
        }

        return correctLetter;
    }

   /*
    * getCIFCheckDigit obtains and returns the corresponding check digit
    * for a given string. In order to work, the string must match the
    * CIF pattern.
    * 
    * This function has been written to be used from isValidCIF as a
    * helper, but it can still be calle directly.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/getCIFCheckDigit
    */
    function getCIFCheckDigit( docNumber ) {
        var fixedDocNumber = "";

        var centralChars = "";
        var firstChar = "";

        var evenSum = 0;
        var oddSum = 0;
        var totalSum = 0;
        var lastDigitTotalSum = 0;

        var correctDigit = 0;

        var fixedDocNumber = docNumber.toUpperCase();

        if( isValidCIFFormat( fixedDocNumber ) ) {
            firstChar = fixedDocNumber.substr( 0, 1 );
            centralChars = fixedDocNumber.substr( 1, 7 );

            evenSum =
                parseInt( centralChars.substr( 1, 1 ) ) +
                parseInt( centralChars.substr( 3, 1 ) ) +
                parseInt( centralChars.substr( 5, 1 ) );

            oddSum =
                sumDigits( parseInt( centralChars.substr( 0, 1 ) ) * 2 ) +
                sumDigits( parseInt( centralChars.substr( 2, 1 ) ) * 2 ) +
                sumDigits( parseInt( centralChars.substr( 4, 1 ) ) * 2 ) +
                sumDigits( parseInt( centralChars.substr( 6, 1 ) ) * 2 );

            totalSum = evenSum + oddSum;

            lastDigitTotalSum = parseInt( totalSum.toString().substr( -1 ) );

            if( lastDigitTotalSum > 0 ) {
                correctDigit = 10 - ( lastDigitTotalSum % 10 );
            } else {
                correctDigit = 0;
            }
        }

        /* If CIF number starts with P, Q, S, N, W or R,
            check digit sould be a letter */
        if( /[PQSNWR]/.test( firstChar ) ) {
            correctDigit = "JABCDEFGHI".substr( correctDigit, 1 );
        }

        return correctDigit;
    }

   /*
    * respectsDocPattern tests a string against a regexp pattern.
    * 
    * Actually, this function has been written as a helper for
    * isValidNIFFormat, isValidNIEFormat and isValidCIFFormat,
    * but it can still be called directly.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/respectsDocPattern
    */
    function respectsDocPattern( givenString, pattern ) {
        var isValid = false;
        
        var fixedString = givenString.toUpperCase();
        var firstChar = parseInt( fixedString.substr( 0, 1 ) );

        if ( firstChar % 1 === 0 ) {
            fixedString = "000000000" + fixedString;
            fixedString = fixedString.substr( -9 );
        }

        if( pattern.test( fixedString ) ) {
            isValid = true;
        }

        return isValid;
    }

   /*
    * sumDigits is an auxiliary function that sums the digits of
    * the number received. For instance, it returns 6 for 123,
    * as long as 1+2+3 = 6.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/sumDigits
    */
    function sumDigits( digits ) {
        var total = 0;
        var i = 1;
        
        if( typeof digits === 'number' ) { digits = digits.toString(); }

        while( i <= digits.length ) {
            thisNumber = parseInt( digits.substr( i - 1, 1 ) );
            total += thisNumber;

            i++;
        }

        return total;
    }

   /*
    * getIdType returns a description of the type of the given document number.
    * 
    * When possible, the description has been taken from an official source.
    * In all cases, the returned string will be in Spanish.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/getIdType
    */
    var identificationType = {
        K: 'Español menor de catorce años o extranjero menor de dieciocho',
        L: 'Español mayor de catorce años residiendo en el extranjero',
        M: 'Extranjero mayor de dieciocho años sin NIE',

        0: 'Español con documento nacional de identidad',
        1: 'Español con documento nacional de identidad',
        2: 'Español con documento nacional de identidad',
        3: 'Español con documento nacional de identidad',
        4: 'Español con documento nacional de identidad',
        5: 'Español con documento nacional de identidad',
        6: 'Español con documento nacional de identidad',
        7: 'Español con documento nacional de identidad',
        8: 'Español con documento nacional de identidad',
        9: 'Español con documento nacional de identidad',

        T: 'Extranjero residente en España e identificado por la Policía con un NIE',
        X: 'Extranjero residente en España e identificado por la Policía con un NIE',
        Y: 'Extranjero residente en España e identificado por la Policía con un NIE',
        Z: 'Extranjero residente en España e identificado por la Policía con un NIE',

        /* As described in BOE number 49. February 26th, 2008 (article 3) */
        A: 'Sociedad Anónima',
        B: 'Sociedad de responsabilidad limitada',
        C: 'Sociedad colectiva',
        D: 'Sociedad comanditaria',
        E: 'Comunidad de bienes y herencias yacentes',
        F: 'Sociedad cooperativa',
        G: 'Asociación',
        H: 'Comunidad de propietarios en régimen de propiedad horizontal',
        J: 'Sociedad Civil => con o sin personalidad jurídica',
        N: 'Entidad extranjera',
        P: 'Corporación local',
        Q: 'Organismo público',
        R: 'Congregación o Institución Religiosa',
        S: 'Órgano de la Administración del Estado y Comunidades Autónomas',
        U: 'Unión Temporal de Empresas',
        V: 'Fondo de inversiones o de pensiones, agrupación de interés económico, etc',
        W: 'Establecimiento permanente de entidades no residentes en España' };

    function getIdType( docNumber ) {
        var docTypeDescription = "";
        var firstChar = docNumber.substring(0, 1);

        if( isValidNIFFormat( docNumber ) ||
            isValidNIEFormat( docNumber ) ||
            isValidCIFFormat( docNumber ) ) {

            docTypeDescription = identificationType[ firstChar ];
        }

        if (! docTypeDescription ) {
            return "";
        } else {
            return docTypeDescription;
        }
    }

