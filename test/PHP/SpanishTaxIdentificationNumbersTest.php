<?php
    require_once( '../../src/PHP/spanish-tax-identification-numbers.php' );

    class SpanishTaxIdentificationNumbersTest extends PHPUnit_Framework_TestCase {
        public function testGetIdType() {
            $this->assertEquals( 'Sociedad Anónima', getIdType( 'A49640873' ) );
            $this->assertEmpty( getIdType( '' ) );
            $this->assertEmpty( getIdType( '0A0A0A0A0A' ) );
        }

        public function testSumDigits() {
            $this->assertEquals( 6, sumDigits( '123' ) );
            $this->assertEquals( 15, sumDigits( 12345 ) );
        }

        public function testRespectsDocPattern() {
            $this->assertTrue( respectsDocPattern( '33576428Q',
                '/^[KLM0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z]/' ) );
            $this->assertFalse( respectsDocPattern( 'A0A0A0A0A',
                '/^[KLM0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z]/' ) );
        }

        public function testGetCIFControlDigit() {
            $this->assertEquals( '6', getCIFControlDigit( 'H24930830' ) );
            $this->assertEquals( 'A', getCIFControlDigit( 'Q54626360' ) );
        }

        public function testGetNIFControlDigit() {
            $this->assertEquals( 'Q', getNIFControlDigit( '335764280' ) );
            $this->assertEquals( 'C', getNIFControlDigit( '060898220' ) );
            $this->assertEmpty( getNIFControlDigit( '0A0A0A0A' ) );
        }

        public function testIsValidCIFFormat() {
            $this->assertTrue( isValidCIFFormat( 'H24930836' ) );
            $this->assertFalse( isValidCIFFormat( '0A0A0A0A' ) );
            $this->assertFalse( isValidCIFFormat( '' ) );
        }

        public function testIsValidNIEFormat() {
            $this->assertTrue( isValidNIEFormat( 'X6089822C' ) );
            $this->assertFalse( isValidNIEFormat( '0A0A0A0A' ) );
            $this->assertFalse( isValidNIEFormat( '' ) );
        }

        public function testIsValidNIFFormat() {
            $this->assertTrue( isValidNIFFormat( '11111111H' ) );
            $this->assertTrue( isValidNIFFormat( '11111111A' ) );
            $this->assertFalse( isValidNIFFormat( '0A0A0A0A' ) );
            $this->assertFalse( isValidNIFFormat( '' ) );
        }

        public function testIsValidCIF() {
            $this->assertTrue( isValidCIF( 'F43298256' ) );
            $this->assertFalse( isValidCIF( 'F43298257' ) );
            $this->assertFalse( isValidCIF( '0A0A0A0A' ) );
            $this->assertFalse( isValidCIF( '' ) );
        }

        public function testIsValidNIE() {
            $this->assertTrue( isValidNIE( 'X6089822C' ) );
            $this->assertFalse( isValidNIE( 'X6089822D' ) );
            $this->assertFalse( isValidNIE( '0A0A0A0A' ) );
            $this->assertFalse( isValidNIE( '' ) );
        }

        public function testIsValidNIF() {
            $this->assertTrue( isValidNIF( '06089822C' ) );
            $this->assertTrue( isValidNIF( '11111111H' ) );
            $this->assertFalse( isValidNIF( '11111111A' ) );
        }

        public function testIsValidIdNumber() {
            $this->assertTrue( isValidIdNumber( '11111111H' ) );
            $this->assertFalse( isValidIdNumber( '11111111A' ) );
            $this->assertTrue( isValidIdNumber( 'X6089822C' ) );
            $this->assertFalse( isValidIdNumber( 'X6089822D' ) );
            $this->assertTrue( isValidIdNumber( 'F43298256' ) );
            $this->assertFalse( isValidIdNumber( 'F43298257' ) );
            $this->assertFalse( isValidIdNumber( '0A0A0A0A' ) );
            $this->assertFalse( isValidIdNumber( '' ) );
        }

    }
