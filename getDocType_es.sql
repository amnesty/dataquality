-- --------------------------------------------------------------------------------
-- Routine DDL
-- Note: comments before and after the routine body will not be stored by the server
-- --------------------------------------------------------------------------------
DELIMITER $$

CREATE DEFINER=`root`@`localhost` FUNCTION `getDocType_es`(DocNumber varchar(15)) RETURNS varchar(255) CHARSET latin1
begin
	/* La definición de los tipos de documento la extraje del script publicado en:
		http://www.emesn.com/autoitforum/viewtopic.php?f=4&t=1704 */

	declare Type varchar(255);

	set Type = case
		when left(DocNumber, 1) not regexp '^[[:alpha:]]' then 'NIF'
		when left(DocNumber, 1) = 'K' then 'NIF especial: Español menor de catorce años o extranjero menor de dieciocho'
		when left(DocNumber, 1) = 'L' then 'NIF especial: Español mayor de catorce años residiendo en el extranjero y que se traslada por tiempo inferior a seis meses a España'
		when left(DocNumber, 1) = 'M' then 'NIF especial: Extranjero mayor de dieciocho años no residente en España no obligado a disponer de NIE y que realiza operaciones con trascendencia tributaria'
		when left(DocNumber, 1) = 'A' then 'CIF: Sociedad Anónima'
		when left(DocNumber, 1) = 'B' then 'CIF: Sociedad de responsabilidad limitada'
		when left(DocNumber, 1) = 'C' then 'CIF: Sociedad colectiva'
		when left(DocNumber, 1) = 'D' then 'CIF: Sociedad comanditaria'
		when left(DocNumber, 1) = 'E' then 'CIF: Comunidad de bienes y herencias yacentes'
		when left(DocNumber, 1) = 'F' then 'CIF: Sociedad cooperativa'
		when left(DocNumber, 1) = 'G' then 'CIF: Sindicato, partido político, asoc. de consumidores y usuarios, federación deportiva o fundación (entidades sin ánimo de lucro o Caja de Ahorros)'
		when left(DocNumber, 1) = 'H' then 'CIF: Comunidad de propietarios en régimen de propiedad horizontal'
		when left(DocNumber, 1) = 'J' then 'CIF: Sociedad Civil, con o sin personalidad jurídica'
		when left(DocNumber, 1) = 'N' then 'CIF: Entidad extranjera'
		when left(DocNumber, 1) = 'P' then 'CIF: Corporación local'
		when left(DocNumber, 1) = 'Q' then 'CIF: Organismo público, agencia estatal, organismo autónomo y asimilados, cámara agraria, etc'
		when left(DocNumber, 1) = 'R' then 'CIF: Congregación o Institución Religiosa'
		when left(DocNumber, 1) = 'S' then 'CIF: Órgano de la Administración del Estado y Comunidades Autónomas'
		when left(DocNumber, 1) = 'U' then 'CIF: Unión Temporal de Empresas'
		when left(DocNumber, 1) = 'V' then 'CIF: Fondo de inversiones o de pensiones, agrupación de interés económico, sociedad agraria de transformación, etc'
		when left(DocNumber, 1) = 'W' then 'CIF: Establecimiento permanente de entidades no residentes en España'
		when left(DocNumber, 1) in ('X', 'Y', 'Z') then 'NIE'
		else '' end;

	return Type;
end