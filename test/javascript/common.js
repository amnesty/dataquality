QUnit.test( "testAddEvery", function( assert ) {
    assert.equal(addEvery( '0000000', '-', 2 ), '00-00-00-0', 'Add "-" every "2" positions' );
    assert.equal(addEvery( '00000000', '-', 2 ), '00-00-00-00', 'Do not add extra char at the end' );
    assert.equal(addEvery( '00000000', '', 2 ), '00000000', 'Return original string if char is empty' );
    assert.equal(addEvery( '00000000', '-', 0 ), '00000000', 'Return original string if n is zero' );
} );