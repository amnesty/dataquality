<?php
   /*
    *   This function validates a Spanish identification number
    *   verifying its control digits.
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
    *       1: If specified identification number is correct
    *       0: Otherwise
    *
    *   Usage:
    *       SELECT isValidIdNumber( 'G28667152' );
    *   Returns:
    *       1
    */
    function isValidIdNumber( $docNumber ) {
        $fixedDocNumber = strtoupper( $docNumber );

        if( isValidNIFFormat( $fixedDocNumber ) ) {
            return isValidNIF( $fixedDocNumber )
        } else {
            if( isValidNIEFormat( $fixedDocNumber ) ) {
                return isValidNIE( $fixedDocNumber )
            } else {
                if( isValidCIFFormat( $fixedDocNumber ) ) {
                    return isValidCIF( $fixedDocNumber )
                } else {
                    return FALSE;
                }
            }
        }
    }

   /*
    *   This function validates a Spanish identification number
    *   verifying its control digits.
    *
    *   This function is intended to work with NIF numbers.
    *
    *   This function is used by:
    *       - isValidIdNumber
    *
    *   This function requires:
    *       - isValidCIFFormat
    *       - getNIFControlDigit
    *
    *   This function returns:
    *       1: If specified identification number is correct
    *       0: Otherwise
    *
    *   Algorithm works as described in:
    *       http://www.interior.gob.es/dni-8/calculo-del-digito-de-control-del-nif-nie-2217
    *
    *   Usage:
    *       SELECT isValidNIF( '33576428Q' );
    *   Returns:
    *       1
    */
    function isValidNIF( $docNumber ) {
        $isValid = FALSE;
        $fixedDocNumber = "";

        $correctDigit = "";
        $writtenDigit = "";

        if( !preg_match( "/^[A-Z]+$/i", substr( $fixedDocNumber, 1, 1 ) ) ) {
            $fixedDocNumber = strtoupper( substr( "000000000" . $docNumber, 1, 9 ) );
        } else {
            $fixedDocNumber = strtoupper( $docNumber );
        }
     
        $writtenDigit = substr( $docNumber, -1, 1 );

        if( isValidNIFFormat( $fixedDocNumber ) ) {
            $correctDigit = getNIFControlDigit( $fixedDocNumber );

            if( $writtenDigit == $correctDigit ) {
                $isValid = TRUE;
            }
        }

        return $isValid;
    }

   /*
    *   This function validates a Spanish identification number
    *   verifying its control digits.
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
    *       1: If specified identification number is correct
    *       0: Otherwise
    *
    *   Algorithm works as described in:
    *       http://www.interior.gob.es/dni-8/calculo-del-digito-de-control-del-nif-nie-2217
    *
    *   Usage:
    *       SELECT isValidNIE( 'X6089822C' )
    *   Returns:
    *       1
    */
    function isValidNIE( $docNumber ) {
        $isValid = FALSE;
        $fixedDocNumber = "";

        if( !preg_match( "/^[A-Z]+$/i", substr( $fixedDocNumber, 1, 1 ) ) ) {
            $fixedDocNumber = strtoupper( substr( "000000000" . $docNumber, 1, 9 ) );
        } else {
            $fixedDocNumber = strtoupper( $docNumber );
        }

        if( isValidNIEFormat( $fixedDocNumber ) ) {
            if( substr( $fixedDocNumber, 1, 1 ) == "T" ) {
                $isValid = TRUE;
            } else {
                /* The algorithm for validating the control digits of a NIE number is
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
    *   This function validates a Spanish identification number
    *   verifying its control digits.
    * 
    *   This function is intended to work with CIF numbers.
    * 
    *   This function is used by:
    *       - isValidSpanishDoc
    * 
    *   This function requires:
    *       - isValidSpanishCIFFormat
    *       - getSpanishCIFControlDigit
    * 
    *   This function returns:
    *       1: If specified identification number is correct
    *       0: Otherwise
    * 
    * CIF numbers structure is defined at:
    *   BOE number 49. February 26th, 2008 (article 2)
    *
    *   Usage:
    *       echo isValidSpanishNIE( 'X6089822C' );
    *   Returns:
    *       1
    */
    function isValidCIF( $docNumber ) {
        $isValid = FALSE;
        $fixedDocNumber = "";

        $correctDigit = "";
        $writtenDigit = "";

        $fixedDocNumber = strtoupper( $docNumber );
        $writtenDigit = substr( $fixedDocNumber, -1, 1 );

        if( isValidCIFFormat( $fixedDocNumber ) == 1 ) {
            $correctDigit = getCIFControl( $fixedDocNumber );

            if( $writtenDigit == $correctDigit ) {
                $isValid = TRUE;
            }
        }

        return $isValid;
    }

   /*
    *   This function validates the format of a given string in order to
    *   see if it fits with NIF format. Practically, it performs a validation
    *   over a NIF, except this function does not check the control digit.
    *
    *   This function is intended to work with NIF numbers.
    *
    *   This function is used by:
    *       - isValidIdNumber
    *       - isValidNIF
    *
    *   This function returns:
    *       1: If specified string respects NIF format
    *       0: Otherwise
    *
    *   Usage:
    *       echo isValidNIFFormat( '33576428Q' )
    *   Returns:
    *       1
    */
    function isValidNIFFormat( $docNumber ) {
        return respectsDocPattern(
            $docNumber,
            '/^[KLM0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z]/' );
    }

   /*
    *   This function validates the format of a given string in order to
    *   see if it fits with NIE format. Practically, it performs a validation
    *   over a NIE, except this function does not check the control digit.
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
    *       1: If specified string respects NIE format
    *       0: Otherwise
    *
    *   Usage:
    *       echo isValidNIEFormat( 'X6089822C' )
    *   Returns:
    *       1
    */
    function isValidNIEFormat( $docNumber ) {
        return respectsDocPattern(
            $docNumber,
            '/^[XYZT][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z0-9]/' );
    }

   /*
    *   This function validates the format of a given string in order to
    *   see if it fits with CIF format. Practically, it performs a validation
    *   over a CIF, except this function does not check the control digit.
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
    *       1: If specified string respects CIF format
    *       0: Otherwise
    *
    *   Usage:
    *       echo isValidCIFFormat( 'H24930836' )
    *   Returns:
    *       1
    */
    function isValidCIFFormat( $docNumber ) {
        return
            respectsDocPattern(
                docNumber,
                '/^[PQSNWR][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z]/' )
        or
            respectsDocPattern(
                docNumber,
                '/^[ABCDEFGHJUV][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]/' );
    }

   /*
    *   This function calculates the control digit for an individual Spanish
    *   identification number (NIF).
    *
    *   You can replace control digit with a zero when calling the function.
    *
    *   This function is used by:
    *       - isValidNIF
    *
    *   This function requires:
    *       - isValidNIFFormat
    *
    *   This function returns:
    *       - Returns control digit if provided string had a correct NIF structure
    *       - An empty string otherwise
    *
    *   Usage:
    *       echo getNIFControlDigit( '335764280' )
    *   Returns:
    *       Q
    */
    function getNIFControlDigit( $docNumber ) {
        const $keyString = 'TRWAGMYFPDXBNJZSQVHLCKE';

        $fixedDocNumber = "";

        $position = 0;
        $writtenLetter = "";
        $correctLetter = "";

        if( !preg_match( "/^[A-Z]+$/i", substr( $fixedDocNumber, 1, 1 ) ) ) {
            $fixedDocNumber = strtoupper( substr( "000000000" . $docNumber, 1, 9 ) );
        } else {
            $fixedDocNumber = strtoupper( $docNumber );
        }

        if( isValidNIFFormat( $fixedDocNumber ) ) {
            $writtenLetter = substr( $fixedDocNumber );

            if( isValidNIFFormat( $fixedDocNumber ) ) {
                $fixedDocNumber = str_replace( 'K', '0', $fixedDocNumber );
                $fixedDocNumber = str_replace( 'L', '0', $fixedDocNumber );
                $fixedDocNumber = str_replace( 'M', '0', $fixedDocNumber );

                $position = substr( $fixedDocNumber, 8, 1 ) % 23;
                $correctLetter = substr( $keyString, $position + 1, 1 );
            }
        }

        return $correctLetter;
    }

   /*
    *   This function calculates the control digit for a corporate Spanish
    *   identification number (CIF).
    * 
    *   You can replace control digit with a zero when calling the function.
    * 
    *   This function is used by:
    *       - isValidSpanishCIF
    * 
    *   This function requires:
    *     - isValidSpanishCIFFormat
    * 
    *   This function returns:
    *       - The correct control digit if provided string had a
    *         correct CIF structure
    *       - An empty string otherwise
    * 
    *   Usage:
    *       echo getSpanishCIFControlDigit( 'H24930830' );
    *   Prints:
    *       6
    */
    function getCIFControlDigit( $docNumber ) {
        $fixeddocNumber = "";

        $centralChars = "";
        $firstChar = "";

        $evenSum = 0;
        $oddSum = 0;
        $totalSum = 0;
        $lastDigittotalSum = 0;

        $correctDigit = "";

        $fixeddocNumber = strtoupper( $docNumber );

        if( isValidCIFFormat( $fixeddocNumber ) == 1 ) {
            $firstChar = substr( $fixeddocNumber, 1, 1 );
            $centralChars = substr( $fixeddocNumber, 2, 7 );

            $evenSum =
                substr( $centralChars, 2, 1 ) +
                substr( $centralChars, 4, 1 ) +
                substr( $centralChars, 6, 1 );

            $oddSum =
                sumDigits( substr( $centralChars, 1, 1 ) * 2 ) +
                sumDigits( substr( $centralChars, 3, 1 ) * 2 ) +
                sumDigits( substr( $centralChars, 5, 1 ) * 2 ) +
                sumDigits( substr( $centralChars, 7, 1 ) * 2 );

            $totalSum = $evenSum + $oddSum;

            $lastDigittotalSum = substr( $totalSum, 1, 1 );

            if( $lastDigittotalSum > 0 ) {
                $correctDigit = 10 - ( $lastDigittotalSum % 10 );
            } else {
                $correctDigit = 0;
            }
        }

        /* If CIF number starts with P, Q, S, N, W or R,
            control digit sould be a letter */
        if( strpos( "PQSNWR", $firstChar ) ) {
            $correctDigit = substr( "JABCDEFGHI", $correctDigit + 1, 1 );
        }

        return $correctDigit;
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
    *       1: If specified string respects the pattern
    *       0: Otherwise
    *
    *   Usage:
    *       echo respectsDocPattern(
    *           '33576428Q',
    *           '/^[KLM0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z]/' );
    *   Returns:
    *       1
    */
    function respectsDocPattern( $givenString, $pattern ) {
        $isValid = 0;

        $fixedString = strtoupper( substr( "000000000" . $givenString , 9, 1 ) );

        if( ( strlen( $fixedString ) == 9 ) && ( preg_match( $pattern, $fixedString ) ) ) {
            $isValid = 1;
        }

        return $isValid;
    }

   /*
    *   This function performs the sum, one by one, of the digits
    *   in a given quantity.
    *
    *   For instance, it returns 6 for 123 (as it sums 1 + 2 + 3).
    *
    *   This function is used by:
    *       - getCIFControlDigit
    *
    *   Usage:
    *       echo sumDigits( 12345 );
    *   Returns:
    *       15
    */
    function sumDigits( $digits ) {
        $total = 0;
        $string = $digits;
        $i = 1;

        while( $i <= strlen( $string ) ) {
            $total += substr( $string, $i, 1 );
            $i++;
        }

        return $total;
    }

   /*
    *   This function obtains the description of a document type
    *   for Spanish identification number.
    *
    *   For instance, if A83217281 is passed, it returns "Sociedad Anónima".
    *
    *   This function requires:
    *       - identificationType (table)
    *       - isValidSpanishCIFFormat
    *       - isValidSpanishNIEFormat
    *       - isValidSpanishNIFFormat
    *
    *   Usage:
    *       SELECT getIdType( 'H67905364' )
    *   Returns:
    *       Comunidad de propietarios en régimen de propiedad horizontal
    */
    function getIdType( $docNumber ) {
        global $identificationType;

        $docTypeDescription = "";
        $firstChar = substr( $docNumber, 1, 1 );

        if( isValidSpanishNIFFormat( $docNumber ) or
            isValidSpanishNIEFormat( $docNumber ) or
            isValidSpanishCIFFormat( $docNumber ) ) {

            $docTypeDescription = $identificationType[ $firstChar ];
        }

        return $docTypeDescription;
    }

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

?>
