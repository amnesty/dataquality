QUnit.test( "testGetIdType", function( assert ) {
    assert.equal( getIdType( 'A49640873' ), 'Sociedad Anónima',
                  'Valid number returns its identification type' );
    assert.equal( getIdType( '' ), '',
                  'Empty number returns empty type' );
    assert.equal( getIdType( '0A0A0A0A0A' ), '',
                  'Invalid number returns empty identification type' );
} );

QUnit.test( "testSumDigits", function( assert ) {
    assert.equal( sumDigits( '123' ), 6, '1+2+3 = 6' );
    assert.equal( sumDigits( '12345' ), 15, '1+2+3+4+5 = 15' );
} );

QUnit.test( "testRespectsDocPattern", function( assert ) {
    assert.ok( respectsDocPattern( '33576428Q',
                                   /^[KLM0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z]/ ),
               'respectsDocPattern returns true if string matches the pattern' );
    assert.ok( ! respectsDocPattern( 'A0A0A0A0A',
                                   /^[KLM0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z]/ ),
               'respectsDocPattern returns false if string doesn\'t match the pattern' );
} );

QUnit.test( "testGetCIFCheckDigit", function( assert ) {
    assert.equal( getCIFCheckDigit( 'H24930830' ), '6',
                  'getCIFCheckDigit works for numbers not starting with P, Q, S, N, W or R' );
    assert.equal( getCIFCheckDigit( 'Q54626360' ), 'A',
                  'getCIFCheckDigit works for numbers starting with P, Q, S, N, W or R' );
} );

QUnit.test( "testGetNIFCheckDigit", function( assert ) {
    assert.equal( getNIFCheckDigit( '335764280' ), 'Q',
                  'getNIFCheckDigit works for a standard 9 digit NIF' );
    assert.equal( getNIFCheckDigit( '060898220' ), 'C',
                  'getNIFCheckDigit works for a standard 9 digit NIF' );
    assert.equal( getNIFCheckDigit( '0A0A0A0A' ), '',
                  'getNIFCheckDigit returns empty for random strings' );
} );

QUnit.test( "testIsValidCIFFormat", function( assert ) {
    assert.ok( isValidCIFFormat( 'H24930836' ),
               'isValidCIFFormat accepts valid CIFs' );
    assert.ok( ! isValidCIFFormat( '0A0A0A0A' ),
               'isValidCIFFormat rejects random strings' );
    assert.ok( ! isValidCIFFormat( '' ),
               'isValidCIFFormat returns false for empty strings' );    
} );

QUnit.test( "testIsValidNIEFormat", function( assert ) {
    assert.ok( isValidNIEFormat( 'X6089822C' ),
               'isValidNIEFormat accepts valid NIEs' );
    assert.ok( ! isValidNIEFormat( '0A0A0A0A' ),
               'isValidNIEFormat rejects random strings' );
    assert.ok( ! isValidNIEFormat( '' ),
               'isValidNIEFormat returns false for empty strings' );    
} );

QUnit.test( "testIsValidNIFFormat", function( assert ) {
    assert.ok( isValidNIFFormat( '11111111H' ),
               'isValidNIFFormat accepts valid NIFs' );
    assert.ok( isValidNIFFormat( '11111111A' ),
               'isValidNIFFormat rejects invalid NIFs' );
    assert.ok( ! isValidNIFFormat( '0A0A0A0A' ),
               'isValidNIFFormat rejects random strings' );
    assert.ok( ! isValidNIFFormat( '' ),
               'isValidNIFFormat returns false for empty strings' );    
} );

QUnit.test( "testIsValidCIF", function( assert ) {
    assert.ok( isValidCIF( 'F43298256' ), 'isValidCIF returns true for valid CIFs' );
    assert.ok( ! isValidCIF( 'F43298257' ), 'isValidCIF returns false if check digit is wrong' );
    assert.ok( ! isValidCIF( '0A0A0A0A' ), 'isValidCIF returns false for random strings' );
    assert.ok( ! isValidCIF( '' ), 'isValidCIF returns false for empty strings' );
} );

QUnit.test( "testIsValidNIE", function( assert ) {
    assert.ok( isValidNIE( 'X6089822C' ), 'isValidNIE returns true for valid NIEs' );
    assert.ok( ! isValidNIE( 'X6089822D' ), 'isValidNIE returns false if check digit is wrong' );
    assert.ok( ! isValidNIE( '0A0A0A0A' ), 'isValidNIE returns false for random strings' );
    assert.ok( ! isValidNIE( '' ), 'isValidNIE returns false for empty strings' );
} );

QUnit.test( "testIsValidNIF", function( assert ) {
    assert.ok( isValidNIF( '06089822C' ), 'isValidNIF returns true for valid NIFs with leading zeros' );
    assert.ok( isValidNIF( '11111111H' ), 'isValidNIF returns true for valid NIFs' );
    assert.ok( ! isValidNIF( '11111111A' ), 'isValidNIF returns false if check digit is wrong' );
} );

QUnit.test( "testIsValidNIF", function( assert ) {
    assert.ok( isValidIdNumber( '11111111H' ), 'isValidIdNumber returns true for valid NIFs' );
    assert.ok( ! isValidIdNumber( '11111111A' ), 'isValidIdNumber returns false for invalid NIFs' );
    assert.ok( isValidIdNumber( 'X6089822C' ), 'isValidIdNumber returns true for valid NIEs' );
    assert.ok( ! isValidIdNumber( 'X6089822D' ), 'isValidIdNumber returns false for invalid NIEs' );
    assert.ok( isValidIdNumber( 'F43298256' ), 'isValidIdNumber returns true for valid CIFs' );
    assert.ok( ! isValidIdNumber( 'F43298257' ), 'isValidIdNumber returns false for invalid CIFs' );
    assert.ok( ! isValidIdNumber( '0A0A0A0A' ), 'isValidIdNumber returns false for random strings' );
    assert.ok( ! isValidIdNumber( '' ), 'isValidIdNumber returns false for empty strings' );
} );
