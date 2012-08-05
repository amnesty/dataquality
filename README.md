What do these functions do?
===========================

These functions perform standard validations over id Spanish numbers.

What do these functions receive?
================================

Easy. Only the number to validate.

What will these functions return?
=================================

In the case of isValidDocNumber_es, I kept the convention used by the original
JavaScript version:

- returns a positive value if the number is valid
    (1 for a valid NIF, 2 for a valid CIF and 3 for a valid NIE),
- returns a negative value if the number is not valid
    (-1 for a invalid NIF, -2 for a invalid CIF and -3 for a invalid NIE),
- returns zero in other cases (empty string, etc).

Examples:

- select IsValidDocNumber_es('11111111A') as IsValid;
    /* Will return -1 */

- select IsValidDocNumber_es('Q2816003D') as IsValid;
    /* Will return 2 */

In the case of getDocType_es, it returns a (Spanish) description about the kind
of organisation.

Examples:

- select getDocType_es('11111111A') as DocType;
    /* Will return 'NIF' */

- select getDocType_es('Q2816003D') as DocType;
    /* Will return 'CIF: Organismo público, agencia estatal,
        organismo autónomo y asimilados, cámara agraria, etc' */

Why would we validate in MySQL?
===============================

It may be interesting to validate id numbers in MySQL. The most importants ones:

- you may create a stored procedures layer before creating records in your database,
- you may already have data and you want to perform queries to improve it's qualitie.

Example:

If you have a organisations table with a CIF field, these functions will allow you to
determine the different kind of organisations you've got:

- select CIF, isValidDocNumber_es(CIF) as IsValid, getDocType(CIF) as DocType
    from organisations

Sources
=======

In fact, what I've done is just to translate two functions shared by Josep Rosell
originally written in JavaScript. The code is here:
http://compartecodigo.com/javascript/validar-nif-cif-nie-segun-ley-vigente-31.html
