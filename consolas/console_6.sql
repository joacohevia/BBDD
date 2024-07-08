set search_path = unc_esq_peliculas; 

--Listar todas las películas que poseen entregas de películas de idioma inglés durante
--el año 2006. (P)
select *
from pelicula p
where p.codigo_pelicula in (select r.codigo_pelicula
                          from renglon_entrega r
                          where r.nro_entrega in (select e.nro_entrega
                                                  from entrega e
                                                  where extract(year from fecha_entrega) = 2006
                                                  )
                          )AND p.idioma ilike 'Inglés';

SELECT *
FROM pelicula p
WHERE p.codigo_pelicula IN (
    SELECT codigo_pelicula FROM renglon_entrega r
    WHERE r.nro_entrega IN (
        SELECT nro_entrega FROM entrega e
        WHERE EXTRACT(YEAR FROM fecha_entrega) = 2006
    )
) AND  idioma ILIKE 'Inglés';

-- 1.2) Indicar la cantidad de películas que han sido entregadas en 2006 por un distribuidor
-- nacional. Trate de resolverlo utilizando ensambles.(P)
SELECT distinct p.codigo_pelicula, count(*),p.titulo
FROM pelicula p
JOIN renglon_entrega r on p.codigo_pelicula = r.codigo_pelicula
JOIN entrega e on r.nro_entrega = e.nro_entrega
JOIN distribuidor d on e.id_distribuidor = d.id_distribuidor
WHERE d.tipo = 'N' AND  EXTRACT(YEAR FROM e.fecha_entrega) >= 2006
GROUP BY p.codigo_pelicula;

--Indicar los departamentos que no posean empleados cuya diferencia de sueldo
--máximo y mínimo (asociado a la tarea que realiza) no supere el 40% del sueldo máximo.
--(P) (Probar con 10% para que retorne valores)
SELECT *
FROM departamento d
WHERE (id_departamento,id_distribuidor) NOT IN
      (SELECT DISTINCT id_departamento, id_distribuidor
        FROM empleado p
        WHERE p.id_tarea IN
              (SELECT t.id_tarea
                FROM tarea t
                WHERE (t.sueldo_maximo - t.sueldo_minimo) <= (t.sueldo_maximo * 0.1)));

set search_path = unc_esq_peliculas;

--1.4. Liste las películas que nunca han sido entregadas por un distribuidor nacional.(P)
SELECT DISTINCT *
FROM pelicula p
WHERE p.codigo_pelicula IN(
    SELECT r.codigo_pelicula
    FROM renglon_entrega r
    WHERE r.nro_entrega IN(
        SELECT e.nro_entrega
        FROM entrega e
        WHERE e.id_distribuidor IN(
            SELECT d.id_distribuidor
            FROM distribuidor d
            WHERE d.id_distribuidor NOT IN(
                SELECT n.id_distribuidor
                FROM nacional n
                WHERE d.tipo ='N'
                )
            )
        )
    )
--1.5. Determinar los jefes que poseen personal a cargo y cuyos departamentos (los del
--jefe) se encuentren en la Argentina.
SELECT DISTINCT e.nombre,e.apellido,e.id_jefe,e.id_empleado
FROM empleado e
JOIN departamento d ON e.id_departamento = d.id_departamento
JOIN ciudad c ON d.id_ciudad = c.id_ciudad
WHERE e.id_jefe IS NULL AND c.id_pais ILIKE '%AR%';

/*1.6. Liste el apellido y nombre de los empleados que pertenecen a aquellos
departamentos de Argentina y donde el jefe de departamento posee una comisión de más
del 10% de la que posee su empleado a cargo.*/
SELECT DISTINCT e.apellido,e.nombre,e.id_jefe,d.nombre
FROM empleado e
JOIN departamento d ON e.id_departamento = d.id_departamento AND
                       e.id_distribuidor = d.id_distribuidor
JOIN empleado jefe ON d.jefe_departamento = jefe.id_empleado
JOIN ciudad c ON d.id_ciudad = c.id_ciudad
WHERE jefe.porc_comision > (e.porc_comision * 1.1) AND c.id_pais ILIKE '%AR%';

SELECT e.nombre,e.apellido
FROM empleado e
WHERE (id_departamento,id_distribuidor) IN
      (SELECT d.id_departamento,d.id_distribuidor
    FROM departamento d JOIN empleado jefe ON d.jefe_departamento = jefe.id_empleado
    WHERE d.id_ciudad IN(
        SELECT c.id_ciudad
        FROM ciudad c
        WHERE jefe.porc_comision > (e.porc_comision * 1.1) AND c.id_pais ILIKE 'AR'
        )
    );

/*1.7. Indicar la cantidad de películas entregadas a partir del 2010, por género. */

SELECT count(DISTINCT p.codigo_pelicula)
FROM pelicula p
JOIN renglon_entrega r ON p.codigo_pelicula=r.codigo_pelicula
JOIN entrega e ON r.nro_entrega=e.nro_entrega
WHERE extract(year FROM e.fecha_entrega) >= 2010
GROUP BY p.genero

/* Realizar un resumen de entregas por día, indicando el video club al cual se le
realizó la entrega y la cantidad entregada. Ordenar el resultado por fecha.*/
SELECT e.fecha_entrega,v.id_video,SUM(r.cantidad)
FROM entrega e
JOIN renglon_entrega r ON e.nro_entrega = r.nro_entrega
JOIN video v ON e.id_video = v.id_video
GROUP BY e.fecha_entrega,v.id_video
ORDER BY e.fecha_entrega
set search_path = unc_esq_peliculas;
/*1.9. Listar, para cada ciudad, el nombre de la ciudad y la cantidad de empleados
mayores de edad que desempeñan tareas en departamentos de la misma y que posean al
menos 30 empleados. */
SELECT c.nombre_ciudad,c.id_pais, count(e.id_empleado) as cantidad
FROM ciudad c
JOIN departamento d ON c.id_ciudad = d.id_ciudad
JOIN empleado e ON d.id_distribuidor = e.id_distribuidor AND d.id_departamento = e.id_departamento
JOIN tarea t ON e.id_tarea = t.id_tarea
WHERE extract(year FROM fecha_nacimiento) <= 2005
group by c.nombre_ciudad,c.id_pais
HAVING count(e.id_empleado) >=30

SELECT c.nombre_ciudad
FROM ciudad c
WHERE c.id_ciudad IN
    (SELECT d.id_ciudad
     FROM departamento d
     WHERE (d.id_distribuidor,d.id_departamento) IN
    (SELECT e.id_distribuidor,e.id_departamento
    FROM empleado e
    WHERE e.id_tarea IN
    (SELECT t.id_tarea
     FROM tarea t
     WHERE extract(year FROM fecha_nacimiento) <= 2005
     group by c.nombre_ciudad
     HAVING count(e.id_empleado) >=30
    )
    )
    );

/*Muestre, para cada institución, su nombre y la cantidad de voluntarios que realizan
aportes. Ordene el resultado por nombre de institución. V */
SELECT i.nombre_institucion, count(v.nro_voluntario)
FROM institucion i
JOIN voluntario v ON i.id_institucion=v.id_institucion
WHERE v.horas_aportadas IS NOT NULL
GROUP BY i.nombre_institucion
ORDER BY i.nombre_institucion
/*2.2. Determine la cantidad de coordinadores en cada país, agrupados por nombre de
país y nombre de continente. Etiquete la primer columna como &#39;Número de coordinadores&#39;
*/
SELECT count(v.id_coordinador) as Numero_Coordinadores, p.nombre_pais,c.nombre_continente
FROM voluntario v
JOIN institucion i ON v.id_institucion=i.id_institucion
JOIN direccion d ON i.id_direccion=d.id_direccion
JOIN pais p ON d.id_pais = p.id_pais
JOIN continente c ON p.id_continente=c.id_continente
GROUP BY p.nombre_pais,c.nombre_continente

/*2.3. Escriba una consulta para mostrar el apellido, nombre y fecha de nacimiento de
cualquier voluntario que trabaje en la misma institución que el Sr. de apellido Zlotkey.
Excluya del resultado a Zlotkey. */
set search_path = unc_esq_voluntario;

SELECT v.nombre, v.apellido, v.fecha_nacimiento
FROM voluntario v inner join institucion i on v.id_institucion = i.id_institucion
where v.apellido not like 'Zlotkey' AND v.id_institucion in (
    SELECT v2.id_institucion
    FROM voluntario v2
    where v2.apellido ilike 'Zlotkey'
    )

/*Cree una consulta para mostrar los números de voluntarios y los apellidos de todos
los voluntarios cuya cantidad de horas aportadas sea mayor que la media de las horas
aportadas. Ordene los resultados por horas aportadas en orden ascendente. */
SELECT v.nro_voluntario,v.apellido
FROM voluntario v
WHERE v.horas_aportadas > (SELECT avg(v2.horas_aportadas)
                           FROM voluntario v2)
ORDER BY v.horas_aportadas

set search_path = unc_252169;
CREATE TABLE distribuidor_nac
(
id_distribuidor numeric(5,0) NOT NULL,
nombre character varying(80) NOT NULL,
direccion character varying(120) NOT NULL,
telefono character varying(20),
nro_inscripcion numeric(8,0) NOT NULL,
encargado character varying(60) NOT NULL,
id_distrib_mayorista numeric(5,0),
CONSTRAINT pk_distribuidorNac PRIMARY KEY (id_distribuidor)
);

set search_path = unc_esq_voluntario
select DISTINCT d.nombre,d.direccion,d.telefono,n.nro_inscripcion,n.encargado,n.id_distrib_mayorista
from distribuidor d
JOIN nacional n ON d.id_distribuidor = n.id_distribuidor

/*3.1 Se solicita llenarla con la información correspondiente a los datos completos de
todos los distribuidores nacionales. */
INSERT INTO unc_252169.distribuidor_nac (id_distribuidor, nombre, direccion, telefono, nro_inscripcion, encargado, id_distrib_mayorista)
SELECT d.id_distribuidor, d.nombre, d.direccion, d.telefono, n.nro_inscripcion, n.encargado, n.id_distrib_mayorista
FROM unc_esq_peliculas.distribuidor d
JOIN unc_esq_peliculas.nacional n ON d.id_distribuidor = n.id_distribuidor;

/*Agregar a la definición de la tabla distribuidor_nac, el campo "CODIGO PAIS" que
indica el código de país del distribuidor mayorista que atiende a cada distribuidor
nacional.(codigo_pais varchar(5) NULL) */
ALTER TABLE distribuidor_nac
ADD codigo_pais varchar(5) NULL;

INSERT INTO distribuidor_nac (codigo_pais)
SELECT i.codigo_pais
FROM unc_esq_peliculas.internacional i
JOIN unc_esq_peliculas.nacional d on i.id_distribuidor = d.id_distribuidor
/*3.3. Para todos los registros de la tabla distribuidor_nac, llenar el nuevo campo
&quot;codigo_pais&quot; con el valor correspondiente existente en la tabla &quot;Internacional&quot;.
3.4. Eliminar de la tabla distribuidor_nac los registros que no tienen asociado un
distribuidor mayorista. */

delete from distribuidor_nac n
where n.id_distrib_mayorista IS null;

