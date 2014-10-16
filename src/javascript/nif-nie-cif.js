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