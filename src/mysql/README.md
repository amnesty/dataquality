MySQL functions
===============

These functions are part of a Data Quality project.

For more information about the project, see: https://github.com/amnesty/dataquality

Why may these functions be useful?
----------------------------------

They are several reasons why you may want to perform data quality operations on a database server level. For instance:

* You may want to create a stored procedures layer for creating records in your database.
* You may have a -already populated- database and you want to perform queries over it to improve it's quality.

Example:

If you have a organisations table with a Spanish corporate tax identification number field (CIF), with these functions, you'll be able to perform queries as:

```
SELECT
    CIF,
    isValidCIF(CIF) AS IsValid,
    getIdType(CIF) AS Description
FROM organisations;
```

Could generate as output, for instance:


<table>
  <tr>
    <th>CIF</th><th>IsValid</th><th>Description</th>
  </tr>
  <tr>
    <td>J33374570</td><td>1</td><td>Sociedad Civil, con o sin personalidad jurídica</td>
  </tr>
  <tr>
    <td>H24117111</td><td>1</td><td>Comunidad de propietarios en régimen de propiedad horizonta</td>
  </tr>
  <tr>
    <td>S2614409G</td><td>1</td><td>Órgano de la Administración del Estado y Comunidades Autónomas</td>
  </tr>
  <tr>
    <td>47132737X</td><td>0</td><td>Español con documento nacional de identidad</td>
  </tr>
  <tr>
    <td>X9960779P</td><td>0</td><td>Extranjero residente en España e identificado por la Policía con un NIE</td>
  </tr>
  <tr>
    <td>ABCDEFGHI</td><td>0</td><td></td>
  </tr>
</table>
