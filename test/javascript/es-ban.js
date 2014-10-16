QUnit.test( "testGetBankAccountCheckDigits", function( assert ) {
    assert.equal(getBankAccountCheckDigits( '1234', '1234', '1234567890' ), '16', 'Get check digits of an account' );
    assert.equal(getBankAccountCheckDigits( 'AAAA', 'AAAA', 'AAAAAAAAAA' ), '', 'Don\'t receive an account, return empty' );
} );

QUnit.test( "testIsValidAccountNumber", function( assert ) {
    assert.ok(isValidAccountNumber( '1234', '1234', '16', '1234567890' ), 'Returns true if check digits are correct' );
    assert.ok(! isValidAccountNumber( '1234', '1234', '00', '1234567890' ), 'Returns false if check digits aren\'t correct' );
    assert.ok(! isValidAccountNumber( 'AAAA', 'AAAA', 'AA', 'AAAAAAAAAA' ), 'Returns false for non valid strings' );
} );

QUnit.test( "testRespectsAccountPattern", function( assert ) {
    assert.ok(respectsAccountPattern( '1234', '1234', '1234567890' ), 'All strings of numbers of the expected length, returns true' );
    assert.ok(! respectsAccountPattern( 'AAAA', 'AAAA', 'AAAAAAAAAA' ), 'Random strings, return false' );
    assert.ok(! respectsAccountPattern( '', '', '' ), 'Empty input, returns false' );
} );
