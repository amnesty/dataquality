   /*
    *   This function validates a Spanish identification number
    *   verifying its check digits.
    *
    *   NIFs and NIEs are personal numbers.
    *   CIFs are corporates.
    *
    *   This function requires:
    *       - isValidCIF and isValidCIFFormat
    *       - isValidNIE and isValidNIEFormat
    *       - isValidNIF and isValidNIFFormat
    *
    *   This function returns:
    *       TRUE: If specified identification number is correct
    *       FALSE: Otherwise
    *
    *   Usage:
    *       echo isValidIdNumber( 'G28667152' );
    *   Returns:
    *       TRUE
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
    *   This function validates a Spanish identification number
    *   verifying its check digits.
    *
    *   This function is intended to work with NIF numbers.
    *
    *   This function is used by:
    *       - isValidIdNumber
    *
    *   This function requires:
    *       - isValidCIFFormat
    *       - getNIFCheckDigit
    *
    *   This function returns:
    *       TRUE: If specified identification number is correct
    *       FALSE: Otherwise
    *
    *   Algorithm works as described in:
    *       http://www.interior.gob.es/dni-8/calculo-del-digito-de-Check-del-nif-nie-2217
    *
    *   Usage:
    *       echo isValidNIF( '33576428Q' );
    *   Returns:
    *       TRUE
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
    *   This function validates a Spanish identification number
    *   verifying its check digits.
    *
    *   This function is intended to work with NIE numbers.
    *
    *   This function is used by:
    *       - isValidIdNumber
    *
    *   This function requires:
    *       - isValidNIEFormat
    *       - isValidNIF
    *
    *   This function returns:
    *       TRUE: If specified identification number is correct
    *       FALSE: Otherwise
    *
    *   Algorithm works as described in:
    *       http://www.interior.gob.es/dni-8/calculo-del-digito-de-control-del-nif-nie-2217
    *
    *   Usage:
    *       echo isValidNIE( 'X6089822C' )
    *   Returns:
    *       TRUE
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
    *   This function validates a Spanish identification number
    *   verifying its check digits.
    *
    *   This function is intended to work with CIF numbers.
    *
    *   This function is used by:
    *       - isValidDoc
    *
    *   This function requires:
    *       - isValidCIFFormat
    *       - getCIFCheckDigit
    *
    *   This function returns:
    *       TRUE: If specified identification number is correct
    *       FALSE: Otherwise
    *
    * CIF numbers structure is defined at:
    *   BOE number 49. February 26th, 2008 (article 2)
    *
    *   Usage:
    *       echo isValidCIF( 'F43298256' );
    *   Returns:
    *       TRUE
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
    *   This function validates the format of a given string in order to
    *   see if it fits with NIF format. Practically, it performs a validation
    *   over a NIF, except this function does not check the check digit.
    *
    *   This function is intended to work with NIF numbers.
    *
    *   This function is used by:
    *       - isValidIdNumber
    *       - isValidNIF
    *
    *   This function returns:
    *       TRUE: If specified string respects NIF format
    *       FALSE: Otherwise
    *
    *   Usage:
    *       echo isValidNIFFormat( '33576428Q' )
    *   Returns:
    *       TRUE
    */
    function isValidNIFFormat( docNumber ) {
        return respectsDocPattern(
            docNumber,
            /^[KLM0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z0-9]/ );
    }

   /*
    *   This function validates the format of a given string in order to
    *   see if it fits with NIE format. Practically, it performs a validation
    *   over a NIE, except this function does not check the check digit.
    *
    *   This function is intended to work with NIE numbers.
    *
    *   This function is used by:
    *       - isValidIdNumber
    *       - isValidNIE
    *
    *   This function requires:
    *       - respectsDocPattern
    *
    *   This function returns:
    *       TRUE: If specified string respects NIE format
    *       FALSE: Otherwise
    *
    *   Usage:
    *       echo isValidNIEFormat( 'X6089822C' )
    *   Returns:
    *       TRUE
    */
    function isValidNIEFormat( docNumber ) {
        return respectsDocPattern(
            docNumber,
            /^[XYZT][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z0-9]/ );
    }

   /*
    *   This function validates the format of a given string in order to
    *   see if it fits with CIF format. Practically, it performs a validation
    *   over a CIF, but this function does not check the check digit.
    *
    *   This function is intended to work with CIF numbers.
    *
    *   This function is used by:
    *       - isValidIdNumber
    *       - isValidCIF
    *
    *   This function requires:
    *       - respectsDocPattern
    *
    *   This function returns:
    *       TRUE: If specified string respects CIF format
    *       FALSE: Otherwise
    *
    *   Usage:
    *       echo isValidCIFFormat( 'H24930836' )
    *   Returns:
    *       TRUE
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
    *   This function calculates the check digit for an individual Spanish
    *   identification number (NIF).
    *
    *   You can replace check digit with a zero when calling the function.
    *
    *   This function is used by:
    *       - isValidNIF
    *
    *   This function requires:
    *       - isValidNIFFormat
    *
    *   This function returns:
    *       - Returns check digit if provided string had a correct NIF structure
    *       - An empty string otherwise
    *
    *   Usage:
    *       echo getNIFCheckDigit( '335764280' )
    *   Returns:
    *       Q
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
    *   This function calculates the check digit for a corporate Spanish
    *   identification number (CIF).
    *
    *   You can replace check digit with a zero when calling the function.
    *
    *   This function is used by:
    *       - isValidCIF
    *
    *   This function requires:
    *     - isValidCIFFormat
    *
    *   This function returns:
    *       - The correct check digit if provided string had a
    *         correct CIF structure
    *       - An empty string otherwise
    *
    *   Usage:
    *       echo getCIFCheckDigit( 'H24930830' );
    *   Prints:
    *       6
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
    *   This function validates the format of a given string in order to
    *   see if it fits a regexp pattern.
    *
    *   This function is intended to work with Spanish identification
    *   numbers, so it always checks string length (should be 9) and
    *   accepts the absence of leading zeros.
    *
    *   This function is used by:
    *       - isValidNIFFormat
    *       - isValidNIEFormat
    *       - isValidCIFFormat
    *
    *   This function returns:
    *       TRUE: If specified string respects the pattern
    *       FALSE: Otherwise
    *
    *   Usage:
    *       echo respectsDocPattern(
    *           '33576428Q',
    *           '/^[KLM0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z]/' );
    *   Returns:
    *       TRUE
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
    *   This function performs the sum, one by one, of the digits
    *   in a given quantity.
    *
    *   For instance, it returns 6 for 123 (as it sums 1 + 2 + 3).
    *
    *   This function is used by:
    *       - getCIFCheckDigit
    *
    *   Usage:
    *       echo sumDigits( 12345 );
    *   Returns:
    *       15
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
    *   This function obtains the description of a document type
    *   for Spanish identification number.
    *
    *   For instance, if A83217281 is passed, it returns "Sociedad Anónima".
    *
    *   This function requires:
    *       - identificationType (table)
    *       - isValidCIFFormat
    *       - isValidNIEFormat
    *       - isValidNIFFormat
    *
    *   Usage:
    *       echo getIdType( 'A49640873' )
    *   Returns:
    *       Sociedad Anónima
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