QUnit.test( "testGetIbanCheckDigits", function( assert ) {  
    assert.equal(getIBANCheckDigits( 'GB00WEST12345698765432' ), '82', 'Get check digits of an IBAN' );
    assert.equal(getIBANCheckDigits( '1234567890' ), '', 'If string isn\'t an IBAN, returns empty' );
    assert.equal(getIBANCheckDigits( '' ), '', 'If string is empty, returns empty' );
} );

QUnit.test( "testGetGlobalIdentifier", function( assert ) {
    assert.equal(getGlobalIdentifier( 'G28667152', 'ES', '' ), 'ES55000G28667152', 'Obtain a global Id' );
} );

QUnit.test( "testReplaceCharactersNotInPattern", function( assert ) {
    assert.equal(replaceCharactersNotInPattern(
                     'ABC123-?:',
                     'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',
                     '0' ), 'ABC123000', 'Remove unwanted characters' );
    assert.equal(replaceCharactersNotInPattern(
                     '12345',
                     '0123456789',
                     '0' ), '12345', 'If the string didn\'t have unwanted characters, returns it' );
} );

QUnit.test( "testReplaceLetterWithDigits", function( assert ) {
    assert.equal(replaceLetterWithDigits( '510007547061BE00' ), '510007547061111400', 'Replaces letters with digits' );
    assert.equal(replaceLetterWithDigits( '1234567890' ), '1234567890', 'If we only receive digits, we return them' );
    assert.equal(replaceLetterWithDigits( '' ), '', 'If we receive empty, we return empty' );
} );

QUnit.test( "testGetAccountLength", function( assert ) {
    assert.equal(getAccountLength( 'GB' ), 22, 'Returns  tohe string th a SEPA country' );
    assert.equal(getAccountLength( 'US' ), 0, 'If string isn\'t a SEPA country code, returns empty' );
    assert.equal(getAccountLength( '' ), 0, 'If string is empty, returns empty' );
} );

QUnit.test( "testIsSepaCountry", function( assert ) {
    assert.equal(isSepaCountry( 'ES' ) , 1, 'Detects SEPA countries' );
    assert.equal(isSepaCountry( 'US' ), 0, 'Rejects non SEPA countries' );
    assert.equal(isSepaCountry( '' ) , 0, 'If string is empty, returns empty' );
} );

QUnit.test( "testIsValidIban", function( assert ) {
    assert.equal(isValidIBAN( 'GB82WEST12345698765432' ), 1, 'Accepts a good IBAN' );
    assert.equal(isValidIBAN( 'GB00WEST12345698765432' ) , 0, 'Rejects a wrong IBAN' );
    assert.equal(isValidIBAN( '' ), 0, 'Rejects empty strings' );
} );
