<?php
    require_once( '../../src/php/es-ban.php' );

    class EsBanTest extends PHPUnit_Framework_TestCase {
        public function testGetBankAccountCheckDigits() {
            $this->assertEquals( '16', getBankAccountCheckDigits( '1234', '1234', '1234567890' ) );
            $this->assertEquals( '', getBankAccountCheckDigits( 'AAAA', 'AAAA', 'AAAAAAAAAA' ) );
        }

        public function testIsValidAccountNumber() {
            $this->assertTrue( isValidAccountNumber( '1234', '1234', '16', '1234567890' ) );
            $this->assertFalse( isValidAccountNumber( '1234', '1234', '00', '1234567890' ) );
            $this->assertFalse( isValidAccountNumber( 'AAAA', 'AAAA', 'AA', 'AAAAAAAAAA' ) );
        }

        public function testRespectsAccountPattern() {
            $this->assertTrue( respectsAccountPattern( '1234', '1234', '1234567890' ) );
            $this->assertFalse( respectsAccountPattern( '1234', '123A', '1234567890' ) );
            $this->assertFalse( respectsAccountPattern( '', '', '' ) );
        }
    }
