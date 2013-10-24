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
    * This function validates a Spanish identification number
    * verifying its control digits.
    * 
    * This function is intended to work with CIF numbers.
    * 
    * This function is used by:
    *   - isValidSpanishDoc
    * 
    * This function requires:
    *   - isValidSpanishCIFFormat
    *   - getSpanishCIFControlDigit
    * 
    * This function returns:
    *   1: If specified identification number is correct
    *   0: Otherwise
    * 
    * CIF numbers structure is defined at:
    * BOE number 49. February 26th, 2008 (article 2)
    * 
    * Usage:
    *   echo isValidSpanishNIE( 'X6089822C' );
    * Returns:
    *   TRUE
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
    *       SELECT isValidNIFFormat( '33576428Q' )
    *   Returns:
    *       1
    */
    function isValidNIFFormat( $docNumber ) {
        return respectsDocPattern(
            $docNumber,
            '[KLM0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z]' );
    }

   /*
    *   TODO:
    *   Translate the following functions:
    *       - isValidNIEFormat
    *       - isValidCIFFormat
    *       - getNIFControlDigit
    *       - respectsDocPattern
    *       - sumDigits
    *       - getIdType
    */

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

?>
