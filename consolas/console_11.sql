/*
 Ejercicio 1
Para el esquema unc_voluntarios considere que se quiere mantener un registro de quién y
cuándo realizó actualizaciones sobre la tabla TAREA en la tabla HIS_TAREA. Dicha tabla tiene la
siguiente estructura:
HIS_TAREA(nro_registro, fecha, operación, usuario)
a) Provea el/los trigger/s necesario/s para mantener en forma automática la tabla HIS_TAREA
cuando se realizan actualizaciones (insert, update o delete) en la tabla TAREA.
b) Muestre los resultados de las tablas si se ejecuta la operación:

DELETE FROM TAREA
WHERE id_tarea like ‘AD%’;
Según el o los triggers definidos sean FOR EACH ROW->>SI ELIMINO 10 FILAS SE ACTIVA 10 VECES
                                       FOR EACH STATEMENT->>SI ELIMINO 10 FILAS SE ACTIVA UNA SOLA VEZ PARA LAS 10
Evalúe la diferencia entre ambos tipos de granularidad.
  */
create  table p6_p2_ej1_tareas as
select * from unc_esq_peliculas.tarea;;

CREATE TABLE his_tarea (
    nro_registro int NOT NULL,
    fecha TIMESTAMP NOT NULL,
    operacion VARCHAR(50) NOT NULL,
    usuario VARCHAR(50) NOT NULL,
    PRIMARY KEY (nro_registro, fecha, operacion)
--clave primaria compuesta asi puedo eliminar y mod el mismo reg con id
);

alter table p6_p2_ej1_tareas
add constraint p6_p2_ej1_tareas_pk
primary key (id_tarea);

ALTER TABLE p6_p2_ej1_tareas
ALTER COLUMN id_tarea TYPE INTEGER USING id_tarea::integer;
--AMBAS CLAVES PRIMARIAS DEBEN SER INT Y TENER CONSTRAINT
CREATE OR REPLACE FUNCTION fn_auditoria_tarea_his_t()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO his_tarea (nro_registro, fecha, operacion, usuario)
        VALUES (NEW.id_tarea, current_timestamp, 'INSERT', current_user::text);
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO his_tarea (nro_registro, fecha, operacion, usuario)
        VALUES (NEW.id_tarea, current_timestamp, 'UPDATE', current_user::text);
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO his_tarea (nro_registro, fecha, operacion, usuario)
        VALUES (OLD.id_tarea, current_timestamp, 'DELETE', current_user::text);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

create or replace trigger tg_auditoria_his_tarea
after insert or update or delete  on p6_p2_ej1_tareas
for each row execute function fn_auditoria_tarea_his_t();
--si es quien y cuando es for statement
update p6_p2_ej1_tareas set nombre_tarea = 'tareaee 531'
where id_tarea = 521;

insert into p6_p2_ej1_tareas (id_tarea, nombre_tarea, sueldo_maximo, sueldo_minimo)
values(101000,'tar',666,55);

/*
 Ejercicio 2
A partir del esquema unc_peliculas, realice procedimientos para:
c) Completar una tabla denominada MAS_ENTREGADAS con los datos de las 20 películas
más entregadas en los últimos seis meses desde la ejecución del procedimiento. Esta tabla
por lo menos debe tener las columnas código_pelicula, nombre, cantidad_de_entregas (en
caso de coincidir en cantidad de entrega ordenar por código de película).
 */
create table p_mas_entregadas (
    codigo_pelicula numeric(10) not null,
    nombre varchar(50) not null,
    cantidad_de_entregas int not null,
    primary key (codigo_pelicula)
);

CREATE OR REPLACE FUNCTION actualizar_mas_entregadas()
RETURNS VOID AS $$
BEGIN
    delete from p_mas_entregadas where codigo_pelicula=0;
    -- Insertar los 20 registros más recientes en los últimos seis meses
    INSERT INTO p_mas_entregadas (codigo_pelicula, nombre, cantidad_de_entregas)
    SELECT p.codigo_pelicula, p.titulo, COUNT(*) AS cantidad_de_entregas
    FROM p_pelicula p join p_renglon_entrega r on p.codigo_pelicula = r.codigo_pelicula
    join p_entrega e on r.nro_entrega = e.nro_entrega
    where extract(year from fecha_entrega) >= 2001
    --WHERE e.fecha_entrega >= current_date - interval '6 months'
    GROUP BY p.codigo_pelicula, p.titulo
    ORDER BY count(*) DESC, p.codigo_pelicula
    LIMIT 20;
END;
$$ LANGUAGE plpgsql;

select actualizar_mas_entregadas();

select * from p_mas_entregadas;

CREATE OR REPLACE FUNCTION actualizar_mas_entregadas_cursor()
RETURNS VOID AS $$
DECLARE
    cur_entregas CURSOR FOR
    SELECT p.codigo_pelicula, p.titulo, COUNT(*) AS cantidad_de_entregas
    FROM p_pelicula p
    JOIN p_renglon_entrega r ON p.codigo_pelicula = r.codigo_pelicula
    JOIN p_entrega e ON r.nro_entrega = e.nro_entrega
        where extract(year from fecha_entrega) >= 2001
    --WHERE e.fecha_entrega >= current_date - interval '6 months'--current_date(fecha actual)-6meses
    GROUP BY p.codigo_pelicula, p.titulo
    ORDER BY COUNT(*) DESC, p.codigo_pelicula
    LIMIT 20;

    rec RECORD;
BEGIN

    -- Abrir el cursor
    OPEN cur_entregas;

    -- Iterar sobre cada registro del cursor
    LOOP
        FETCH cur_entregas INTO rec;--el fetch recupera la fila del cursor cur... y almacena en rec(tipo record)
        EXIT WHEN NOT FOUND;--cuando no tiene mas filas

        -- Insertar cada registro en la tabla p_mas_entregadas
        INSERT INTO p_mas_entregadas (codigo_pelicula, nombre, cantidad_de_entregas)
        VALUES (rec.codigo_pelicula, rec.titulo, rec.cantidad_de_entregas);
    END LOOP;

    -- Cerrar el cursor
    CLOSE cur_entregas;
END;
$$ LANGUAGE plpgsql;


select actualizar_mas_entregadas_cursor();

--tablas sin datos
CREATE TABLE v_historico AS
SELECT *
FROM unc_esq_voluntario.historico;

--datos de tabla
INSERT INTO p_empleado
SELECT *
FROM unc_esq_peliculas.empleado;

alter table p_departamento
    add constraint p_departamento_p_empleado_id_empleado_fk
        foreign key (jefe_departamento) references p_empleado;

--tablas con indices
CREATE TABLE unc_252169.v_historico (LIKE unc_esq_voluntario.historico INCLUDING ALL);

--CURSOR QUE DEVUELVE TABLAS
CREATE OR REPLACE FUNCTION limites_credito(limite_presupuesto integer)
RETURNS TABLE(cliente  int, limite_credito int)
AS $$
DECLARE
	    var_r record;
BEGIN
  -- Resetear el limite de crédito de todos los clientes
  UPDATE cliente SET limite_credito = 0
  WHERE 1=1;

  FOR var_r IN (
     SELECT id_cliente,
	   SUM(precio * cantidad) total,
       ROUND(SUM(precio * cantidad) * 0.05) limite_credito
	   FROM renglon
	   JOIN factura USING (nro_factura)
	   WHERE estado = 'ENTREGADA'
	   GROUP BY id_cliente
	   ORDER BY total DESC)
  LOOP

    -- actualiza el limite de crédito para el cliente actual
    UPDATE
        cliente
    SET
        limite_credito =
            CASE WHEN limite_presupuesto > var_r.limite_credito
                        THEN var_r.limite_credito
                            ELSE limite_presupuesto
            END
    WHERE
        nro_cliente = var_r.id_cliente;

    -- retorno los valores en la tabla
		cliente := var_r.id_cliente;
		limite_credito := CASE WHEN limite_presupuesto > var_r.limite_credito
							THEN var_r.limite_credito
                            ELSE limite_presupuesto
						  END;

	--  reduce el limite_presupuesto a el limites_credito asignado
    limite_presupuesto := limite_presupuesto - var_r.limite_credito;
    RETURN NEXT;

	-- Chequea el limite_presupuesto
    EXIT WHEN limite_presupuesto <= 0;
  END LOOP;
END
$$ LANGUAGE 'plpgsql';

/*
 d) Generar los datos para una tabla denominada SUELDOS, con los datos de los empleados
cuyas comisiones superen a la media del departamento en el que trabajan. Esta tabla debe
tener las columnas id_empleado, apellido, nombre, sueldo, porc_comision.

 */
create table p_sueldos(
    id_empleado numeric(6) null,
    apellido varchar(30) not null,
    nombre varchar(30) null,
    sueldo numeric(8,2) null,
    porc_comision numeric(6,2) not null,
    primary key (id_empleado)
);
create or replace function act_sueldos() returns void as
$$
begin
    insert into p_sueldos (id_empleado, apellido, nombre, sueldo, porc_comision)
    select p.id_empleado,p.apellido,p.nombre,p.sueldo,porc_comision
    from p_empleado p
    join (select
            id_departamento,
            AVG(porc_comision) AS media_comision
         FROM
            p_empleado
         GROUP BY
            id_departamento) dept_avg--calcula comision para cada deptob y guarda en dept_avg
    ON
        p.id_departamento = dept_avg.id_departamento--une ambas tablas por su depto
        WHERE p.porc_comision > dept_avg.media_comision;
end;
$$ language plpgsql;


delete from p_sueldos where id_empleado>0
select * from p_sueldos
select act_sueldos();

--mismo ejercicio que devulve tabla
create or replace function comisiones_promedio_empleados() returns table(id_empleado numeric(6,0),
    apellido varchar(30), nombre varchar(30), sueldo numeric(8,2),porc_comisio numeric(6,2))as
    $$
    declare var_r record;
    begin
        FOR var_r IN(select *
                     from p_empleado e
                     where e.porc_comision > (select avg(porc_comision)
                                              from p_empleado sub
                                              where sub.id_departamento=e.id_departamento and
                                                    sub.id_distribuidor=e.id_distribuidor)
                     )
        LOOP
            id_empleado:=var_r.id_empleado;
            apellido:=var_r.apellido;
            nombre:=var_r.nombre;
            sueldo:=var_r.sueldo;
            porc_comisio:=var_r.porc_comision;
            RETURN NEXT;
        end loop;
    end;
    $$language plpgsql;

/*
 e) Cambiar el distribuidor de las entregas sucedidas a partir de una fecha dada, siendo que el
par de valores de distribuidor viejo y distribuidor nuevo es variable.
 */
create or replace function cambiar_distribuidor(fecha_dada date, id_viejo numeric, id_nuevo numeric)
returns table (nro_entrga int, id_distribuidor numeric, fecha date)
as $$
    declare
        dist record;
    begin
        for dist in
            select nro_entrega,id_distribuidor,fecha_entrega
            from p_entrega
            where fecha_entrega >= fecha_dada and id_distribuidor = id_viejo
        loop
            update
            p_entrega set id_distribuidor=id_nuevo
            where nro_entrega = dist.nro_entrega
            RETURNING nro_entrega, id_distribuidor, fecha_entrega
            INTO dist.nro_entrega, dist.id_distribuidor, dist.fecha_entrega;
            return next;
        end loop;
    end;
    $$ language plpgsql;

SELECT * FROM cambiar_distribuidor_F('2000-01-01', 1, 4569);

CREATE OR REPLACE FUNCTION cambiar_distribuidor_F(fecha_dada DATE, dist_viejo NUMERIC, dist_nuevo NUMERIC)
RETURNS TABLE (nro_entrega numeric, id_distribuidor NUMERIC, fecha_entrega DATE) AS $$
BEGIN
    -- Actualizar el distribuidor para las entregas a partir de la fecha dada
    UPDATE p_entrega
    SET id_distribuidor = dist_nuevo
    WHERE fecha_entrega >= fecha_dada
      AND id_distribuidor = dist_viejo
    RETURNING nro_entrega, id_distribuidor, fecha_entrega
    INTO nro_entrega, id_distribuidor, fecha_entrega;

    RETURN;
END;
$$ LANGUAGE plpgsql;






