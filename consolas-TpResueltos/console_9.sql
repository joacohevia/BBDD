-- TP 5.2 Ej3,4,5
/*A. Controlar que las nacionalidades sean argetina, español,  Inglés, Alemán O Chilena;. */
alter table p5p1e1_articulo
add constraint ck_nacionalidad_especifica
check ( nacionalidad IN('Argentina','Espaniol','Ingles','Aleman','Chilena'));




--B. Para las fechas de publicaciones se debe considerar que sean fechas
-- posteriores o iguales al 2010.
alter table p5p1e1_articulo
add constraint  ck_publicaciones_posteriores
check ( extract(year from fecha_publicacion) >= 2010 );

--C. Cada palabra clave puede aparecer como máximo en 5 artículos.
alter table p5p1e1_contiene
add constraint ck_palabra_clave_art
check ( not exists(
    select 1
    from p5p1e1_contiene
    group by idioma,cod_palabra
    having count(*) >5
) );
CREATE TRIGGER tr_max_pal_art
BEFORE INSERT OR UPDATE OF idioma, cod_palabra ON p5p1e1_contiene
    FOR EACH ROW EXECUTE PROCEDURE fn_maxArticulosxPalabra();

create or replace function fn_maxArticulosxPalabra()
RETURNS Trigger AS
    $$ declare cant integer;
        begin
                SELECT count(id_articulo) INTO cant
                FROM p5p1e1_contiene
                WHERE idioma=NEW.idioma AND cod_palabra=NEW.cod_palabra;
                IF (cant > 4) THEN
                    RAISE EXCEPTION 'Esta palabra esta contenida en mas de 5 articulos: ';
                END IF;
            RETURN NEW;
        end
    $$
language 'plpgsql';

/*D. Sólo los autores argentinos pueden publicar artículos que contengan
más de 10 palabras claves, pero con un tope de 15 palabras, el resto
de los autores sólo pueden publicar artículos que contengan hasta
10 palabras claves.*/
--create assetion
alter table p5p1e1_contiene
add constraint ck_clave_arg_autores
check ( not exists(
    select
    from p5p1e1_articulo join p5p1e1_contiene
    on p5p1e1_articulo.id_articulo = p5p1e1_contiene.id_articulo
    where nacionalidad = 'Argentina'
    group by p5p1e1_contiene.id_articulo
    having count(*) > 15
) )

create or replace function fn_articulos_argentinos()
returns Trigger as
    $$ declare cantidad integer;
    declare autores_arg p5p1e1_articulo.nacionalidad%type;
    begin
        select nacionalidad as autores_arg
        from p5p1e1_articulo
        where id_articulo=new.id_articulo;
        select count(*) into cantidad
        from p5p1e1_contiene
        where id_articulo=new.id_articulo; --and cantidad < 9??
        if (autores_arg = 'Argentina' and cantidad > 15) or (autores_arg != 'Argentina' and cantidad>10)
            then
            raise exception 'tiene mas de 15';
        end if;
        return new;
    end
    $$
    language 'plpgsql';

CREATE TRIGGER th_art_arg
BEFORE INSERT OR UPDATE OF id_articulo, cod_palabra ON p5p1e1_contiene
    FOR EACH ROW EXECUTE PROCEDURE fn_articulos_argentinos();

--4_A. La modalidad de la imagen médica puede tomar los siguientes valores RADIOLOGIA
--CONVENCIONAL, FLUOROSCOPIA, ESTUDIOS RADIOGRAFICOS CON
--FLUOROSCOPIA, MAMOGRAFIA, SONOGRAFIA,
alter table p5p2e4_imagen_medica
add constraint ck_imagen_med_modalidad
check ( modalidad IN ('CONVENCIONAL', 'FLUROSCOPIA', 'ESTUDIOS RADIOGRAFICOS CON FLUROSCOPIA',
    'MAMOGRAFIA', 'SONOGRAFIA') )

--B. Cada imagen no debe tener más de 5 procesamientos.
alter table p5p2e4_procesamiento
add constraint ck_imagen_procesamiento_5
check ( not exists(
    select 1
    from p5p2e4_procesamiento
    group by id_paciente,id_imagen
    having count(*) > 5
) )

create or replace function fn_imagen_procesamiento() returns trigger as
    $$declare cant int;
        begin
            select count(*) into cant
            from p5p2e4_procesamiento
            where id_imagen=new.id_imagen and id_paciente=new.id_paciente;
            if(cant>4) then
                raise exception 'No puede haber mas de 5 proc para cada img';
            end if;
            return new;
        end;
    $$ language plpgsql;

create or replace trigger tg_img_proc
    before insert or update of id_paciente,id_imagen on p5p2e4_procesamiento
    for each row execute procedure fn_imagen_procesamiento();


--C. Agregue dos atributos de tipo fecha a las tablas Imagen_medica y Procesamiento, una
--indica la fecha de la imagen y la otra la fecha de procesamiento de la imagen y controle
--que la segunda no sea menor que la primera.
alter table p5p2e4_imagen_medica add fecha_imagen date;
alter table p5p2e4_procesamiento add fecha_procesamiento date;
--create assertion
alter table p5p2e4_procesamiento
add constraint ck_fecha_imagen_proc
check ( not exists(
    select 1
    from p5p2e4_procesamiento p join p5p2e4_imagen_medica i on
        p.id_paciente = i.id_paciente and p.id_imagen = i.id_imagen
    where p.fecha_procesamiento < i.fecha_imagen
) )
--NECESITO DOS TRIGGERS UNO PARA CADA TABLA, EN PROC POR INSERTAR O MOD
--Y EN IMAGEN POR MOD LA FECHA
create or replace function fn_fecha_proc_fecha_img() returns trigger as
 $$ declare fecha_img p5p2e4_imagen_medica.fecha_imagen%type;
    declare fecha_proc date;
    begin
        SELECT fecha_imagen INTO fecha_img
        FROM p5p2e4_imagen_medica i
        WHERE new.id_paciente = i.id_paciente AND new.id_imagen = i.id_imagen;
        fecha_proc := new.fecha_procesamiento;
        if(fecha_proc > fecha_img) then
            raise exception 'la fecha de img es mayor a fecha del proc';

        end if;
    return new;
    end;
 $$ language plpgsql;

create trigger tg_fecha_img_fecha_proc
    before insert or update of id_imagen,id_paciente,fecha_procesamiento
    on p5p2e4_procesamiento for each row execute procedure fn_fecha_proc_fecha_img();

create or replace function fn_fecha_img() returns trigger as
    $$declare fecha_proc date;
    begin
        select max(fecha_procesamiento) into fecha_proc
        from p5p2e4_procesamiento
        where id_paciente=new.id_paciente and id_imagen=new.id_imagen;
        if (new.fecha_imagen>fecha_proc) then
            raise exception 'la img es mayor';
        end if;
    return new;
    end;
    $$ language plpgsql;

create trigger tg_fecha_img
    before update of fecha_imagen
    on p5p2e4_imagen_medica for each row execute procedure fn_fecha_img();

--D. Cada paciente sólo puede realizar dos FLUOROSCOPIA anuales.
--tabla imagen
alter table p5p2e4_imagen_medica
add constraint ck_imagen_anual
check ( not exists(
    select 1
    from p5p2e4_imagen_medica
    where modalidad = 'Fluroscopia'
    group by id_paciente,extract(year from fecha_imagen)
    having count(*) > 2
) );
create or replace function fn_img_fluroscopia() returns trigger as
    $$declare cantidad int;
    begin
        select count(*) into cantidad
        from p5p2e4_imagen_medica
        where id_paciente=new.id_paciente and modalidad = 'Fluroscopia'
        and extract(year from (fecha_imagen))=extract(year from (new.fecha_imagen));
        if (cantidad>1) then--podria tambien cantidad<=2
            raise exception 'ya tiene dos fluroscopias';
        end if;
        return new;
    end
    $$ language plpgsql;

create trigger tg_imagen_fluroscopia_anual
    before insert or update of id_paciente,fecha_imagen,modalidad on p5p2e4_imagen_medica
for each row execute procedure fn_img_fluroscopia();

--E. No se pueden aplicar algoritmos de costo computacional “O(n)” a imágenes de
--FLUOROSCOPIA
create assertion
check( not exists(
    select 1
    from p5p2e4_imagen_medica  i join p5p2e4_procesamiento p
    on i.id_paciente = p.id_paciente and i.id_imagen = p.id_imagen
    join p5p2e4_algoritmo a on p.id_algoritmo = a.id_algoritmo
    where i.modalidad = 'Fluroscopia' and a.costo_computacional = '0(n)'
));
--EJ2-E--|TABLAS          | UPDATE                              | INSERT                       | DELETE
--       |  imagen_medica | SI id_paciente,modalidad            | NO                           | NO
--       |  algoritmo     | SI costo_computacional,id_algoritmo | NO                           | NO
--       |  procesamiento | SI id_algorit/id_paciente/id_imagen | SI id_algor/id_pacient/id_img| NO
--E. No se pueden aplicar algoritmos de costo computacional “O(n)” a imágenes de FLUOROSCOPIA

create or replace trigger tg_proc_img_algoritmos
    before insert or update of id_paciente,id_imagen,id_algoritmo on p5p2e4_procesamiento
    for each row execute function fn_proc_img_algoritmos();

create or replace function fn_proc_img_algoritmos() returns trigger as
    $$declare modalidad p5p2e4_imagen_medica.modalidad%type;
        declare costo_com p5p2e4_algoritmo.id_algoritmo%type;
        begin
            select modalidad into modalidad
            from p5p2e4_imagen_medica i join p5p2e4_procesamiento  on
                i.id_imagen=new.id_imagen and i.id_paciente=new.id_paciente;
            if(modalidad = 'Fluroscopia') then
                select costo_computacional into costo_com
                from p5p2e4_algoritmo a join p5p2e4_procesamiento on
                a.id_algoritmo=new.id_algoritmo;
                if(costo_com = '0(n)') then
                    raise exception 'La mod fluroscopia no puede tener costo 0(n)';
                end if;
            end if;
        return new;
        end;
    $$ language plpgsql;

create or replace trigger tg_img_modalidad
    before update of id_paciente,id_imagen,modalidad on p5p2e4_imagen_medica
    for each row execute function fc_img_modalidad();

create or replace function fc_img_modalidad() returns trigger as
    $$--si mod en imagen med primero controlo que sea fluros y luego que pertenezca a ese paciente
    declare costo p5p2e4_algoritmo.costo_computacional%type;
    begin
        if(new.modalidad = 'Fluroscopia') then
        select a.costo_computacional into costo
        from p5p2e4_algoritmo a join p5p2e4_procesamiento p on a.id_algoritmo = p.id_algoritmo
            join p5p2e4_imagen_medica i on p.id_paciente = new.id_paciente and p.id_imagen = new.id_imagen
            if(costo = '0(n)') then
                raise exception 'la mod fluroscopia no puede ser 0(n)';
            end if;
        end if;
    return new;
    end;
    $$ language plpgsql;

create trigger tr_modalidad_acept_algoritmo
        before update of id_algoritmo, costo_computacional on p5p2e4_algoritmo
        for each row execute function fc_modalidad_acept_algoritmo();
    create or replace function fc_modalidad_acept_algoritmo() returns trigger as
        $$
        declare modalidad varchar(80);
        begin
            if(NEW.costo_computacional='O(n)')then
                select i.modalidad into modalidad
                from p5p2e4_imagen_medica i
                join p5p2e4_procesamiento p on (i.id_paciente=p.id_paciente and i.id_imagen=p.id_imagen)
                join p5p2e4_algoritmo a on(p.id_algoritmo=NEW.id_algoritmo);
                if(modalidad = 'FLUOROSCOPIA')then
                    raise exception 'costo computacional invalido para el tipo de modalidad';
                end if;
            end if;
            return NEW;
        end
        $$language plpgsql;

--EJ 5
--A. Los descuentos en las ventas son porcentajes y deben estar entre 0 y 100.
alter table p5p2e5_venta
add constraint ck_venta_descuento
check ( descuento between 0 and 100)

--B. Los descuentos realizados en fechas de liquidación deben superar el 30%.
alter table p5p2e5_venta
add mes_liq int not null,
add dia_liq int not null;

alter table p5p2e5_venta
add constraint fk_fecha_liq_venta
foreign key (mes_liq,dia_liq)
references p5p2e5_fecha_liq (mes_liq,dia_liq)
NOT DEFERRABLE
INITIALLY IMMEDIATE;

alter table p5p2e5_venta
add constraint ck_fecha_liq_30
check ( not exists(
    select 1
    from p5p2e5_venta
    where descuento < 30 and extract(day from fecha) = dia_liq and extract(month from fecha) = mes_liq
) );

create or replace function fc_venta_liq() returns trigger as
    $$
    begin
    SELECT
    FROM p5p2e5_venta
    where extract(month from fecha) = new.mes_liq
      and extract(day from fecha) = new.dia_liq;
    if(new.descuento <= 30) then
        raise exception 'El desc no supera el 30%';
    end if;
    return new;
    end;
    $$ language plpgsql;
create  or replace trigger tr_fecha_liq
    before insert or update of id_venta,descuento
    on p5p2e5_venta for each row execute function fc_venta_liq();

--C. Las liquidaciones de Julio y Diciembre no deben superar los 5 días.
alter table p5p2e5_fecha_liq
add constraint ck_liq_julio_diciembre
check (not exists(
    select 1
    from p5p2e5_fecha_liq
    where mes_liq = '6' or mes_liq = '12'
    having count(dia_liq) > 5
));
create or replace trigger tg_liq_julio_dic
    before insert or update of mes_liq,cant_dias on p5p2e5_fecha_liq
    for each row execute function fn_liq_julio_diciembre();

create or replace function fn_liq_julio_diciembre() returns trigger as
    $$
    begin
        if(new.mes_liq = 6 or new.mes_liq = 12) then
            if(new.cant_dias > 5) then
                raise exception 'Entre julio y diciembre la cantidad de dias no puede se mayor a 5';
            end if;
        end if;
    return new;
    end;
    $$ language plpgsql;

--D. Las prendas de categoría ‘oferta’ no tienen descuentos.
--es un assertion
alter table p5p2e5_prenda
add constraint ck_prenda_categ_desc
check ( not exists(
    select 1
    from p5p2e5_prenda p join p5p2e5_venta v on p.id_prenda = v.id_prenda
    where categoria = 'oferta' and descuento in not null
) )
create or replace function fn_prenda_oferta_descuento() returns trigger as
    $$
    declare descuento decimal(10,2);
    begin
        if(new.categoria = 'oferta') then
            select descuento into descuento
            from p5p2e5_venta join p5p2e5_prenda p on
                new.id_prenda=p.id_prenda;
            if(descuento !== null)then
                raise exception 'Las prendas en oferta no tienen desc';
            end if;
        end if;
    return new;
    end;
    $$ language plpgsql;

create or replace trigger tg_prenda_oferta_desc
    before insert or update of id_prenda,categoria on p5p2e5_prenda
    for each row execute function fn_prenda_oferta_descuento();

--PRACTICO 6 EJERCICIO 4 (ESTADISTICA)
CREATE TABLE  P6_E4_Pelicula AS
SELECT * FROM unc_esq_peliculas.pelicula;

CREATE TABLE p6_e4_estadistica AS
SELECT genero, COUNT(*) total_peliculas, count (distinct idioma) cantidad_idiomas
FROM p6_e4_Pelicula GROUP BY genero;

/*c) Cree un trigger que cada vez que se realice una modificación en la tabla película (la creada
en su esquema) tiene que actualizar la tabla estadística.No se olvide de identificar:
i) la granularidad del trigger.
ii) Eventos ante los cuales se debe disparar.
iii) Analice si conviene modificar por cada operación de actualización o reconstruirla de
cero.
*/
CREATE TABLE p6_e4_estadistica (
    genero VARCHAR(255) PRIMARY KEY,
    total_peliculas INT,
    cantidad_idiomas INT
);

CREATE OR REPLACE FUNCTION fn_auditoria_peliculas_estadistica() RETURNS TRIGGER AS
$$
BEGIN
    -- Inserta los nuevos datos agrupados
    INSERT INTO p6_e4_estadistica (genero, total_peliculas, cantidad_idiomas)
    SELECT genero, COUNT(*) total_peliculas, COUNT(DISTINCT idioma) cantidad_idiomas
    FROM p6_e4_pelicula
    WHERE genero = NEW.genero
    GROUP BY genero;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
--GENERO NO PUEDE SER PRIMARI KEY

create or replace trigger tg_auditoria_peliculas
    after update of genero,idioma on p6_e4_pelicula
    for each row execute function fn_auditoria_peliculas_estadistica();

select * from p6_e4_estadistica;
