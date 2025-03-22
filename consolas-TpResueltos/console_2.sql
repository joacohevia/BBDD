/*
 Considere el esquema de la BD unc_esq_peliculas:
1. Escriba las sentencias de creación de cada una de las vistas solicitadas en cada caso.
2. Indique si para el estandar SQL y/o Postgresql dicha vista es actualizable o no, si es de
Proyección-Selección (una tabla) o Proyección-Selección-Ensamble (más de una tabla).
Justifique cada respuesta.

1. Cree una vista EMPLEADO_DIST que liste el nombre, apellido, sueldo, y fecha_nacimiento de
los empleados que pertenecen al distribuidor cuyo identificador es 20.
 */
create view empleado_dist
as select nombre,apellido,sueldo,fecha_nacimiento
from p_empleado
where id_distribuidor = 20;

select * from empleado_dist;

/*2. Sobre la vista anterior defina otra vista EMPLEADO_DIST_2000 con el nombre, apellido y sueldo
de los empleados que cobran más de 2000.*/

create view empleado_dist_2000 as
select nombre,apellido,sueldo
from empleado_dist
where sueldo > 2000;

select * from empleado_dist_2000
/*3. Sobre la vista EMPLEADO_DIST cree la vista EMPLEADO_DIST_20_70 con aquellos
empleados que han nacido en la década del 70 (entre los años 1970 y 1979).*/

create view empleado_dist_20_70 as
select *
from empleado_dist
where extract(year from fecha_nacimiento) between 1970 AND 1979;

select * from empleado_dist_20_70
/*4. Cree una vista PELICULAS_ENTREGADA que contenga el código de la película y la cantidad de
unidades entregadas.*/

create view peliculas_entregada as
select codigo_pelicula,sum(cantidad) as cantidad
from p_renglon_entrega
group by codigo_pelicula

select * from peliculas_entregada

/*5. Cree una vista ACCION_2000 con el código, el titulo el idioma y el formato de las películas del
género ‘Acción’ entregadas en el año 2006.*/

create view accion_2000 as
select codigo_pelicula,titulo,idioma,formato
from p_pelicula
where genero='Acción' and codigo_pelicula IN(
    select r.nro_entrega
    from p_renglon_entrega r
    where r.nro_entrega IN(
        select e.nro_entrega
        from p_entrega e
        where extract(years from fecha_entrega)=2006
        )
    );
select * from accion_2000

/*6. Cree una vista DISTRIBUIDORAS_ARGENTINA con los datos completos de las distribuidoras
nacionales y sus respectivos departamentos.*/
create view distribuidoras_argentinas as
select depto.id_departamento,depto.nombre as nombre_Depto,dis.*
from p_departamento depto join p_distribuidor dis on depto.id_distribuidor = dis.id_distribuidor
where dis.tipo='N';
select *
from distribuidoras_argentinas;

/*7. De la vista anterior cree la vista Distribuidoras_mas_2_emp con los datos completos de las
distribuidoras cuyos departamentos tengan más de 2 empleados.*/

create view distribuidoras_mas_2_emp as--de la tabla depto solo puedo agregar dos campos
    --porq son los que seleccione en la primer vista, de distribuidor puedo selecionar todos ya q en la primer view es *
select da.id_departamento,da.nombre_Depto,da.nombre,da.id_distribuidor
     ,da.tipo,da.telefono,da.direccion,count(e.id_empleado) as num
from distribuidoras_argentinas da
    join p_empleado e on da.id_distribuidor=e.id_distribuidor
and da.id_departamento=e.id_departamento
group by da.id_departamento, da.nombre_Depto,da.nombre,da.id_departamento, da.nombre_Depto, da.id_distribuidor,
         da.tipo, da.telefono,da.direccion
having count(e.id_empleado)>2;

select * from distribuidoras_mas_2_emp;

/*8. Cree la vista PELI_ARGENTINA con los datos completos de las productoras y las películas que
fueron producidas por empresas productoras de nuestro país.*/

create view peli_argentina as
select p.*,e.nombre_productora, e.id_ciudad
from p_pelicula p join p_empresa_productora e using (codigo_productora)
join p_ciudad c using (id_ciudad)
where c.id_pais = 'AR';

select * from peli_argentina

/*9. De la vista anterior cree la vista ARGENTINAS_NO_ENTREGADA para las películas producidas
por empresas argentinas pero que no han sido entregadas*/

create view argetinas_no_entregada as
select p.*
from peli_argentina p join p_renglon_entrega using (codigo_pelicula)
where nro_entrega is null;

select * from argetinas_no_entregada;

/*10. Cree una vista PRODUCTORA_MARKETINERA con las empresas productoras que hayan
entregado películas a TODOS los distribuidores.*/

create view productora_marketinera as
select  ep.nombre_productora,ep.codigo_productora,count(id_distribuidor)
from p_empresa_productora ep join p_pelicula p using (codigo_productora)
join p_renglon_entrega re using (codigo_pelicula)
join p_entrega e using (nro_entrega)
group by ep.nombre_productora,ep.codigo_productora
having count(id_distribuidor) = 1050;

drop view productora_marketinera;
select * from productora_marketinera

