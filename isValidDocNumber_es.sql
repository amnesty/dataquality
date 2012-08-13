delimiter $$

create function isValidSpanishDoc(DocNumber varchar(15) returns integer
begin

        /* Devuelve:
                1 = NIF ok, 2 = CIF ok, 3 = NIE ok
                1 = NIF error, -2 = CIF error, -3 = NIE error
                0 = ??? error */

        /* Esta función empezó siendo una traducción a Transact SQL de la función publicada en:
                http://compartecodigo.com/javascript/validar-nif-cif-nie-segun-ley-vigente-31.html */

    declare IsValid int;
    declare FixedDocNumber varchar(15);
    declare Letters varchar(28);
    declare KeyString varchar(23);

    declare Posicion int;
    declare LetraDNI varchar(1);

    declare i int;
    declare Suma int;
    declare Char1 varchar(5);
    declare Char2 varchar(5);
    declare n int;

    declare tmp varchar(5);
    declare LetraCIF varchar(1);

    set IsValid = 0;

    /* Si es NIF, relleno con ceros a la izquierda */
    set DocNumber = case when left(DocNumber, 1) not regexp '^[[:alpha:]]' then
        right(concat('00000000', DocNumber), 9) else DocNumber end;

    set FixedDocNumber = upper(DocNumber);
    set Letters = '[ABCDEFGHIJKLMNOPQRSTUVWXYZ]';
    set KeyString = 'TRWAGMYFPDXBNJZSQVHLCKE';

    if (FixedDocNumber &lt;&gt; '') then
        /* Si no tiene un formato valido, devuelve error */
        if (FixedDocNumber not regexp '[A-Z][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z0-9]' and
            FixedDocNumber not regexp 'T[A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9]' and
            FixedDocNumber not regexp '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z]') then
            set IsValid = 0;
            return IsValid;
        end if;

        /* Comprobación de NIFs estandar */
        if (left(FixedDocNumber, 8) regexp ('^[0-9]+$') and right(FixedDocNumber, 1) regexp Letters) then
            set Posicion = left(FixedDocNumber, 8) % 23;
            set LetraDNI = right(FixedDocNumber, 1);

            if (substring(KeyString, Posicion + 1, 1) = LetraDNI) then
                set IsValid = 1;
            else
                set IsValid = -1;
            end if;

            return IsValid;
        end if;

        /* Algoritmo para comprobacion de codigos tipo CIF */
        set i = 1;

        set Suma =
                convert(substring(DocNumber, 3, 1), unsigned) +
                convert(substring(DocNumber, 5, 1), unsigned) +
                convert(substring(DocNumber, 7, 1), unsigned);

        while (i &lt; 8) do
            temp1 = temp1.substring(0,1); */
            set Char1 = 2 * convert(substring(DocNumber, i + 1, 1), unsigned);
            set Char1 = substring(Char1, 1, 1);

            set Char2 = 2 * convert(substring(DocNumber, i + 1, 1), unsigned);
            set Char2 = substring(Char2, 2, 1);

            if (ifnull(Char2, '') = '') then
                    set Char2 = '0';
            end if;

            set i = i + 2;
            set Suma = Suma + convert(Char1, unsigned) + convert(Char2, unsigned);
        end while;

        set n = 10 - substring(convert(Suma, char(5)), length(convert(Suma, char(5))), 1);

        /* Comprobacion de CIFs */
        if (left(FixedDocNumber, 1) regexp '[ABCDEFGHJNPQRSUVW]') then
            set tmp = n;

            if (substring(DocNumber, 9, 1) = char(64 + n) or
                    convert(substring(DocNumber, 9, 1), unsigned) = convert(right(FixedDocNumber, 1), unsigned)) then
                    set IsValid = 2;
            else
                    set IsValid = -2;
            end if;

            return IsValid;
        end if;

        /* Comprobacion de NIEs que comienzan por T */
        if (left(FixedDocNumber, 1) like '[T]') then
            set IsValid = 3;
            return IsValid;
        end if;

        /* Comprobacion de NIEs que comienzan por X, Y o Z
                y de NIFs especiales */
        if (left(FixedDocNumber, 1) like '[KLMXYZ]') then
            set LetraCIF = right(FixedDocNumber, 1);

            set FixedDocNumber = replace(FixedDocNumber, 'Y', '1');
            set FixedDocNumber = replace(FixedDocNumber, 'Z', '2');
            set FixedDocNumber = replace(FixedDocNumber, 'X', '0');
            set FixedDocNumber = replace(FixedDocNumber, 'K', '0');
            set FixedDocNumber = replace(FixedDocNumber, 'L', '0');
            set FixedDocNumber = replace(FixedDocNumber, 'M', '0');

            set Posicion = left(FixedDocNumber, 8) % 23;

            if (substring(KeyString, Posicion + 1, 1) = @letracif) then
                    set IsValid = 3;
            else
                    set IsValid = -3;
            end if;

            return IsValid;
        end if;
    end if;

    return IsValid;
end
