DROP TABLE IF EXISTS spanishDocTypeDescriptions $$

CREATE TABLE spanishDocTypeDescriptions (
    id VARCHAR(1),
    description VARCHAR(255),
    PRIMARY KEY( id )
) COMMENT 'Relates different types of Spanish document types with its descriptions' $$

/*
    This data is used by:
	- getSpanishDocTypeDescription
*/

INSERT INTO spanishDocTypeDescriptions( id, description ) VALUES
    ( 'K', 'Español menor de catorce años o extranjero menor de dieciocho' ),
    ( 'L', 'Español mayor de catorce años residiendo en el extranjero' ),
    ( 'M', 'Extranjero mayor de dieciocho años sin NIE' ),
    
    ( '0', 'Español con documento nacional de identidad' ),
    ( '1', 'Español con documento nacional de identidad' ),
    ( '2', 'Español con documento nacional de identidad' ),
    ( '3', 'Español con documento nacional de identidad' ),
    ( '4', 'Español con documento nacional de identidad' ),
    ( '5', 'Español con documento nacional de identidad' ),
    ( '6', 'Español con documento nacional de identidad' ),
    ( '7', 'Español con documento nacional de identidad' ),
    ( '8', 'Español con documento nacional de identidad' ),
    ( '9', 'Español con documento nacional de identidad' ),

    ( 'T', 'Extranjero residente en España e identificado por la Policía con un NIE' ),
    ( 'X', 'Extranjero residente en España e identificado por la Policía con un NIE' ),
    ( 'Y', 'Extranjero residente en España e identificado por la Policía con un NIE' ),
    ( 'Z', 'Extranjero residente en España e identificado por la Policía con un NIE' ),
  
    /* As described in BOE number 49. February 26th, 2008 (article 3) */
    ( 'A', 'Sociedad Anónima' ),
    ( 'B', 'Sociedad de responsabilidad limitada' ),
    ( 'C', 'Sociedad colectiva' ),
    ( 'D', 'Sociedad comanditaria' ),
    ( 'E', 'Comunidad de bienes y herencias yacentes' ),
    ( 'F', 'Sociedad cooperativa' ),
    ( 'G', 'Asociación' ),
    ( 'H', 'Comunidad de propietarios en régimen de propiedad horizontal' ),
    ( 'J', 'Sociedad Civil, con o sin personalidad jurídica' ),
    ( 'N', 'Entidad extranjera' ),
    ( 'P', 'Corporación local' ),
    ( 'Q', 'Organismo público' ),
    ( 'R', 'Congregación o Institución Religiosa' ),
    ( 'S', 'Órgano de la Administración del Estado y Comunidades Autónomas' ),
    ( 'U', 'Unión Temporal de Empresas' ),
    ( 'V', 'Fondo de inversiones o de pensiones, agrupación de interés económico, etc' ),
    ( 'W', 'Establecimiento permanente de entidades no residentes en España' ) $$