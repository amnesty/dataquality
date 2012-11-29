Capitalize first character (for names and surnames)
===================================================

Allows you to capitalize the first character in names and surnames.

Parameters
----------

The name -or surname- in a string format (varchar of a maximum of 65535).

Return values
-------------

The name -or surname- corrected.

Examples:

> SELECT capitalizeNoun('fco. juan hernández-gómez gutiérrez-lópez');

Returns Fco. Juan Hernández-Gómez Gutiérrez-López.

Validation of Spanish Id's
==========================

These functions perform standard validations over id Spanish numbers.

Parameters
----------

Easy. Only the number to validate.

Return values
-------------

In the case of isValidDocNumber_es, I kept the convention used by the original
JavaScript version:

* returns a positive value if the number is valid
    1: specified document number is a valid NIF
    2: specified document number is a valid CIF
    3: specified document number is a valid NIE
* returns a negative value if the number is not valid
    -1: specified document number is a invalid NIF
    -2: specified document number is a invalid CIF
    -3: specified document number is a invalid NIE
* returns zero in other cases (empty string, unknown document types, etc).

Examples:

> SELECT isValidDocNumber_es('11111111A') AS IsValid;

Returns -1 because the specified document number is not valid.

> SELECT isValidDocNumber_es('Q2816003D') AS IsValid;

Returns 2 because the specified document number is a valid CIF.

The function getSpanishDocType, returns a 3 characters string corresponding
to the document type (in Spanish). Possible values are: NIF, NIE or CIF.

Examples:

> SELECT getSpanishDocType('11111111A') AS Type;

Returns 'NIF', even if the specified document number is not correct.

> SELECT getSpanishDocTypeDescription('A83217281') AS Description;

Returns 'Sociedad Anónima'.

Why would we validate in MySQL?
-------------------------------

It may be interesting to validate id numbers in MySQL. The most importants ones:

* you may create a stored procedures layer before creating records in your database,
* you may already have data and you want to perform queries to improve it's qualitie.

Example:

If you have a organisations table with a CIF field, these functions will allow you to
list the different kind of organisations you've got:

> SELECT
>     CIF,
>     isValidDocNumber_es(CIF) AS IsValid,
>     getSpanishDocType(CIF) AS Type,
>     getSpanishDocTypeDescription(CIF) AS Description
> FROM organisations;

Sources
-------

In fact, what I've done is just to translate two functions shared by Josep Rosell
originally written in JavaScript. The code is here:
http://compartecodigo.com/javascript/validar-nif-cif-nie-segun-ley-vigente-31.html
