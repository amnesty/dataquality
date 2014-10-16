<?php
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
    function isValidIdNumber( $docNumber ) {
        $fixedDocNumber = strtoupper( $docNumber );

        if( isValidNIFFormat( $fixedDocNumber ) ) {
            return isValidNIF( $fixedDocNumber );
        } else {
            if( isValidNIEFormat( $fixedDocNumber ) ) {
                return isValidNIE( $fixedDocNumber );
            } else {
                if( isValidCIFFormat( $fixedDocNumber ) ) {
                    return isValidCIF( $fixedDocNumber );
                } else {
                    return FALSE;
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
    function isValidNIF( $docNumber ) {
        $isValid = FALSE;
        $fixedDocNumber = "";

        $correctDigit = "";
        $writtenDigit = "";

        if( !preg_match( "/^[A-Z]+$/i", substr( $fixedDocNumber, 1, 1 ) ) ) {
            $fixedDocNumber = strtoupper( substr( "000000000" . $docNumber, -9 ) );
        } else {
            $fixedDocNumber = strtoupper( $docNumber );
        }

        $writtenDigit = substr( $docNumber, -1, 1 );

        if( isValidNIFFormat( $fixedDocNumber ) ) {
            $correctDigit = getNIFCheckDigit( $fixedDocNumber );

            if( $writtenDigit == $correctDigit ) {
                $isValid = TRUE;
            }
        }

        return $isValid;
    }

   /*
    * isValidNIE validates the check digits of an identification number,
    * after verifying the string structure actually fits the NIE pattern.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/isValidNIE
    */
    function isValidNIE( $docNumber ) {
        $isValid = FALSE;
        $fixedDocNumber = "";

        if( !preg_match( "/^[A-Z]+$/i", substr( $fixedDocNumber, 1, 1 ) ) ) {
            $fixedDocNumber = strtoupper( substr( "000000000" . $docNumber, -9 ) );
        } else {
            $fixedDocNumber = strtoupper( $docNumber );
        }

        if( isValidNIEFormat( $fixedDocNumber ) ) {
            if( substr( $fixedDocNumber, 1, 1 ) == "T" ) {
                $isValid = TRUE;
            } else {
                /* The algorithm for validating the check digits of a NIE number is
                    identical to the altorithm for validating NIF numbers. We only have to
                    replace Y, X and Z with 1, 0 and 2 respectively; and then, run
                    the NIF altorithm */

                $fixedDocNumber = str_replace('Y', '1', $fixedDocNumber);
                $fixedDocNumber = str_replace('X', '0', $fixedDocNumber);
                $fixedDocNumber = str_replace('Z', '2', $fixedDocNumber);

                $isValid = isValidNIF( $fixedDocNumber );
            }
        }

        return $isValid;
    }

   /*
    * isValidCIF validates the check digits of an identification number,
    * after verifying the string structure actually fits the CIF pattern.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/isValidCIF
    */
    function isValidCIF( $docNumber ) {
        $isValid = FALSE;
        $fixedDocNumber = "";

        $correctDigit = "";
        $writtenDigit = "";

        $fixedDocNumber = strtoupper( $docNumber );
        $writtenDigit = substr( $fixedDocNumber, -1, 1 );

        if( isValidCIFFormat( $fixedDocNumber ) == 1 ) {
            $correctDigit = getCIFCheckDigit( $fixedDocNumber );

            if( $writtenDigit == $correctDigit ) {
                $isValid = TRUE;
            }
        }

        return $isValid;
    }

   /*
    * isValidNIFFormat tests a string against a regexp pattern
    * to see if the string fits the NIF structure.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/isValidNIFFormat
    */
    function isValidNIFFormat( $docNumber ) {
        return respectsDocPattern(
            $docNumber,
            '/^[KLM0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z0-9]/' );
    }

   /*
    * isValidNIEFormat tests a string against a regexp pattern to see
    * if the string fits the NIE structure.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/isValidNIEFormat
    */
    function isValidNIEFormat( $docNumber ) {
        return respectsDocPattern(
            $docNumber,
            '/^[XYZT][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z0-9]/' );
    }

   /*
    * isValidCIFFormat tests a string against a regexp pattern to see
    * if the string fits the CIF structure.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/isValidCIFFormat
    */
    function isValidCIFFormat( $docNumber ) {
        return
            respectsDocPattern(
                $docNumber,
                '/^[PQSNWR][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z0-9]/' )
        or
            respectsDocPattern(
                $docNumber,
                '/^[ABCDEFGHJUV][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]/' );
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
    function getNIFCheckDigit( $docNumber ) {
        $keyString = 'TRWAGMYFPDXBNJZSQVHLCKE';

        $fixedDocNumber = "";

        $position = 0;
        $writtenLetter = "";
        $correctLetter = "";

        if( !preg_match( "/^[A-Z]+$/i", substr( $fixedDocNumber, 1, 1 ) ) ) {
            $fixedDocNumber = strtoupper( substr( "000000000" . $docNumber, -9 ) );
        } else {
            $fixedDocNumber = strtoupper( $docNumber );
        }

        if( isValidNIFFormat( $fixedDocNumber ) ) {
            $writtenLetter = substr( $fixedDocNumber, -1 );

            $fixedDocNumber = str_replace( 'K', '0', $fixedDocNumber );
            $fixedDocNumber = str_replace( 'L', '0', $fixedDocNumber );
            $fixedDocNumber = str_replace( 'M', '0', $fixedDocNumber );

            $position = substr( $fixedDocNumber, 0, 8 ) % 23;
            $correctLetter = substr( $keyString, $position, 1 );
        }

        return $correctLetter;
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
    function getCIFCheckDigit( $docNumber ) {
        $fixedDocNumber = "";

        $centralChars = "";
        $firstChar = "";

        $evenSum = 0;
        $oddSum = 0;
        $totalSum = 0;
        $lastDigitTotalSum = 0;

        $correctDigit = "";

        $fixedDocNumber = strtoupper( $docNumber );

        if( isValidCIFFormat( $fixedDocNumber ) ) {
            $firstChar = substr( $fixedDocNumber, 0, 1 );
            $centralChars = substr( $fixedDocNumber, 1, 7 );

            $evenSum =
                substr( $centralChars, 1, 1 ) +
                substr( $centralChars, 3, 1 ) +
                substr( $centralChars, 5, 1 );

            $oddSum =
                sumDigits( substr( $centralChars, 0, 1 ) * 2 ) +
                sumDigits( substr( $centralChars, 2, 1 ) * 2 ) +
                sumDigits( substr( $centralChars, 4, 1 ) * 2 ) +
                sumDigits( substr( $centralChars, 6, 1 ) * 2 );

            $totalSum = $evenSum + $oddSum;

            $lastDigitTotalSum = substr( $totalSum, -1 );

            if( $lastDigitTotalSum > 0 ) {
                $correctDigit = 10 - ( $lastDigitTotalSum % 10 );
            } else {
                $correctDigit = 0;
            }
        }

        /* If CIF number starts with P, Q, S, N, W or R,
            check digit sould be a letter */
        if( preg_match( '/[PQSNWR]/', $firstChar ) ) {
            $correctDigit = substr( "JABCDEFGHI", $correctDigit, 1 );
        }

        return $correctDigit;
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
    function respectsDocPattern( $givenString, $pattern ) {
        $isValid = FALSE;

        $fixedString = strtoupper( $givenString );

        if( is_int( substr( $fixedString, 0, 1 ) ) ) {
            $fixedString = substr( "000000000" . $givenString , -9 );
        }

        if( preg_match( $pattern, $fixedString ) ) {
            $isValid = TRUE;
        }

        return $isValid;
    }

   /*
    * sumDigits is an auxiliary function that sums the digits of
    * the number received. For instance, it returns 6 for 123,
    * as long as 1+2+3 = 6.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/sumDigits
    */
    function sumDigits( $digits ) {
        $total = 0;
        $i = 1;

        while( $i <= strlen( $digits ) ) {
            $thisNumber = substr( $digits, $i - 1, 1 );
            $total += $thisNumber;

            $i++;
        }

        return $total;
    }

   /*
    * getIdType returns a description of the type of the given document number.
    * 
    * When possible, the description has been taken from an official source.
    * In all cases, the returned string will be in Spanish.
    * 
    * @link https://github.com/amnesty/dataquality/wiki/getIdType
    */
    $identificationType = array(
        'K' => 'Español menor de catorce años o extranjero menor de dieciocho',
        'L' => 'Español mayor de catorce años residiendo en el extranjero',
        'M' => 'Extranjero mayor de dieciocho años sin NIE',

        '0' => 'Español con documento nacional de identidad',
        '1' => 'Español con documento nacional de identidad',
        '2' => 'Español con documento nacional de identidad',
        '3' => 'Español con documento nacional de identidad',
        '4' => 'Español con documento nacional de identidad',
        '5' => 'Español con documento nacional de identidad',
        '6' => 'Español con documento nacional de identidad',
        '7' => 'Español con documento nacional de identidad',
        '8' => 'Español con documento nacional de identidad',
        '9' => 'Español con documento nacional de identidad',

        'T' => 'Extranjero residente en España e identificado por la Policía con un NIE',
        'X' => 'Extranjero residente en España e identificado por la Policía con un NIE',
        'Y' => 'Extranjero residente en España e identificado por la Policía con un NIE',
        'Z' => 'Extranjero residente en España e identificado por la Policía con un NIE',

        /* As described in BOE number 49. February 26th, 2008 (article 3) */
        'A' => 'Sociedad Anónima',
        'B' => 'Sociedad de responsabilidad limitada',
        'C' => 'Sociedad colectiva',
        'D' => 'Sociedad comanditaria',
        'E' => 'Comunidad de bienes y herencias yacentes',
        'F' => 'Sociedad cooperativa',
        'G' => 'Asociación',
        'H' => 'Comunidad de propietarios en régimen de propiedad horizontal',
        'J' => 'Sociedad Civil => con o sin personalidad jurídica',
        'N' => 'Entidad extranjera',
        'P' => 'Corporación local',
        'Q' => 'Organismo público',
        'R' => 'Congregación o Institución Religiosa',
        'S' => 'Órgano de la Administración del Estado y Comunidades Autónomas',
        'U' => 'Unión Temporal de Empresas',
        'V' => 'Fondo de inversiones o de pensiones, agrupación de interés económico, etc',
        'W' => 'Establecimiento permanente de entidades no residentes en España' );

    function getIdType( $docNumber ) {
        global $identificationType;

        $docTypeDescription = "";
        $firstChar = substr( $docNumber, 0, 1 );

        if( isValidNIFFormat( $docNumber ) or
            isValidNIEFormat( $docNumber ) or
            isValidCIFFormat( $docNumber ) ) {

            $docTypeDescription = $identificationType[ $firstChar ];
        }

        return $docTypeDescription;
    }

?>
