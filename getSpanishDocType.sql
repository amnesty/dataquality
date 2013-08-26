DELIMITER $$

DROP TABLE IF EXISTS SpanishDocTypeDescriptions $$

CREATE TABLE SpanishDocTypeDescriptions (
    Id VARCHAR(1),
    Description VARCHAR(255)) $$

INSERT INTO SpanishDocTypeDescriptions(Id, Description) VALUES
    ('K', 'Español menor de catorce años o extranjero menor de dieciocho'),
    ('L', 'Español mayor de catorce años residiendo en el extranjero y que se traslada por tiempo '
        + 'inferior a seis meses a España'),
    ('M', 'Extranjero mayor de dieciocho años no residente en España no obligado a disponer de NIE '
        + 'y que realiza operaciones con trascendencia tributaria'),
    ('A', 'Sociedad Anónima'),
    ('B', 'Sociedad de responsabilidad limitada'),
    ('C', 'Sociedad colectiva'),
    ('D', 'Sociedad comanditaria'),
    ('E', 'Comunidad de bienes y herencias yacentes'),
    ('F', 'Sociedad cooperativa'),
    ('G', 'Sindicato, partido político, asoc. de consumidores y usuarios, federación deportiva o '
        + 'fundación (entidades sin ánimo de lucro o Caja de Ahorros)'),
    ('H', 'Comunidad de propietarios en régimen de propiedad horizontal'),
    ('J', 'Sociedad Civil, con o sin personalidad jurídica'),
    ('N', 'Entidad extranjera'),
    ('P', 'Corporación local'),
    ('Q', 'Organismo público, agencia estatal, organismo autónomo y asimilados, cámara agraria, etc'),
    ('R', 'Congregación o Institución Religiosa'),
    ('S', 'Órgano de la Administración del Estado y Comunidades Autónomas'),
    ('U', 'Unión Temporal de Empresas'),
    ('V', 'Fondo de inversiones o de pensiones, agrupación de interés económico, sociedad agraria '
        + 'de transformación, etc'),
    ('W', 'Establecimiento permanente de entidades no residentes en España') $$

DROP FUNCTION IF EXISTS getSpanishDocType $$

CREATE FUNCTION getSpanishDocType(DocNumber VARCHAR(15))
RETURNS VARCHAR(3)
BEGIN
    /* Spanish Document Types are described in:
        http://www.emesn.com/autoitforum/viewtopic.php?f=4&t=1704 */

    DECLARE FirstChar VARCHAR(1);
    DECLARE DocType VARCHAR(255);

    SET FirstChar = LEFT(DocNumber, 1);

    SET DocType =
        CASE
            WHEN FirstChar NOT REGEXP '^[[:alpha:]]' THEN 'NIF'
            WHEN FirstChar REGEXP '^[KLM]' THEN 'NIF'
            WHEN FirstChar REGEXP '^[XYZ]' THEN 'NIE'
            WHEN FirstChar REGEXP '^[ABCDEFGHJNPQRSUVW]' THEN 'CIF'
        ELSE '' END;

    RETURN DocType;
END $$

DROP FUNCTION IF EXISTS getSpanishDocTypeDescription $$

CREATE FUNCTION getSpanishDocTypeDescription(DocNumber VARCHAR(15))
RETURNS VARCHAR(255)
BEGIN
    /* Spanish Document Types are described in:
        http://www.emesn.com/autoitforum/viewtopic.php?f=4&t=1704 */

    DECLARE FirstChar VARCHAR(1);
    DECLARE DocTypeDescription VARCHAR(255);

    SET FirstChar = LEFT(DocNumber, 1);

    SET DocTypeDescription =
        (SELECT Description FROM SpanishDocTypeDescriptions
                WHERE Id = FirstChar LIMIT 1);

    RETURN IFNULL(DocTypeDescription, '');
END $$