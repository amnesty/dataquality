<?php
    require_once( '../../src/php/iban.php' );

    class IbanTest extends PHPUnit_Framework_TestCase {
        public function testGetIbanControlDigits() {
            $this->assertEquals( '82', getIBANControlDigits( 'GB00WEST12345698765432' ) );
            $this->assertEmpty( getIBANControlDigits( '1234567890' ) );
            $this->assertEmpty( getIBANControlDigits( '' ) );
        }

        public function testGetGlobalIdentifier() {
            $this->assertEquals( 'ES03000G28667152', getGlobalIdentifier( 'G28667152', 'ES', '' ) );
        }

        public function testReplaceCharactersNotInPattern() {
            $this->assertEquals( 'ABC123000',
                replaceCharactersNotInPattern( 'ABC123-?:', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', '0' ) );
            $this->assertEquals( '12345', replaceCharactersNotInPattern( '12345', '0123456789', '0' ) );
        }

        public function testReplaceLetterWithDigits() {
            $this->assertEquals( '510007547061111400', replaceLetterWithDigits( '510007547061BE00' ) );
            $this->assertEquals( '1234567890', replaceLetterWithDigits( '1234567890' ) );
            $this->assertEmpty( replaceLetterWithDigits( '' ) );
        }

        public function testGetAccountLength() {
            $this->assertEquals( 22, getAccountLength( 'GB' ) );
            $this->assertEquals( 0, getAccountLength( 'US' ) );
            $this->assertEquals( 0, getAccountLength( '' ) );
        }

        public function testIsSepaCountry() {
            $this->assertTrue( isSepaCountry( 'ES' ) );
            $this->assertFalse( isSepaCountry( 'US' ) );
            $this->assertFalse( isSepaCountry( '' ) );
        }

        public function testIsValidIban() {
            $this->assertTrue( isValidIBAN( 'GB82WEST12345698765432' ) );
            $this->assertFalse( isValidIBAN( 'GB00WEST12345698765432' ) );
            $this->assertFalse( isValidIBAN( '' ) );
        }
    }
