  /*
   * Inserts a given character into a string every n positions.
   * 
   * @link https://github.com/amnesty/dataquality/wiki/addEvery
   */
  function addEvery( string, char, n, removeExisting ) {
    //By default, remove existing instances of the character
    removeExisting = typeof removeExisting !== 'undefined' ? removeExisting : true;

    //n must be a positive integer
    n = +n;
    if( ( n <= 0 ) || ( n != ~~n ) ) {
      return string;
    }

    //Remove existing instances of the character, if we've been told to
    if( removeExisting ) {
      string = string.replace( new RegExp( char, 'g' ), '' );
    }
    
    //Every n positions, we insert the desired char
    var buffer = "";
    for( i = 0; i < string.length; i = i + n ) {
      subString = string.substr( i, n );
      
      if( ( subString.length == n ) && ( string.length != ( i + n ) ) ) {
        buffer += subString + char;
      } else {
        buffer += subString;
      }
    }
    
    //Returns the modified string
    return buffer;
  }

  /*
   * Adds the addEvery function to the String prototype.
   */
  String.prototype.addEvery = function ( char, n, removeExisting ) {
    return addEvery( this.toString(), char, n, removeExisting );
  }

