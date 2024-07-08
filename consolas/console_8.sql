/* no puede haber vol de mas de 70*/
alter table voluntariov
add constraint ck_edad_voluntariov
check ( extract(year from fecha_nacimiento)>1954);

alter table voluntariov drop constraint ck_edad_voluntariov;
/*B. Ningún voluntario puede aportar más horas que las de su coordinador. */
create assertion add constraint ck_horas_aportadas_voluntariov
check ( not exists
    (select 1
     from voluntario jefe
     join voluntario empleado on jefe.id_coordinador = empleado.nro_voluntario
     where empleado.horas_aportadas > jefe.horas_aportadas
) );

/*C. Las horas aportadas por los voluntarios deben estar dentro de los valores máximos y
mínimos consignados en la tarea.*/
create assertion
add constraint ck_horas_max_min_vol_tarea
check ( not exists
    (select 1
     from voluntario v join tarea t on v.id_tarea = t.id_tarea
     where v.horas_aportadas between t.min_horas and t.max_horas
    ) );
alter table voluntario drop constraint ck_horas_max_min_vol_tarea;

/*D. Todos los voluntarios deben realizar la misma tarea que su coordinador.*/
create assertion
add constraint ck_tarea_coodinador
check ( not exists(
    select 1
    from voluntario c join voluntario v on c.id_coordinador = v.nro_voluntario
    where v.id_tarea = c.id_tarea
) );

/*E. Los voluntarios no pueden cambiar de institución más de tres veces al año.*/
create assertion
add constraint ck_vol_historico
check ( not exists
    (select  h.id_institucion,v.nro_voluntario, count()
        from voluntario v join historico h on v.nro_voluntario = h.nro_voluntario
        where extract(year from fecha_fin) = extract(year from fecha_inicio)
        group by h.id_institucion,v.nro_voluntario
        having count(*) > 3
) );
/*F. En el histórico, la fecha de inicio debe ser siempre menor que la fecha de finalización. */
alter table historico
add constraint ck_his_fecha_inicio
check (historico.fecha_fin > historico.fecha_inicio)

/*Considere las siguientes restricciones que debe definir sobre el esquema de la BD de Películas:
A. Para cada tarea el sueldo máximo debe ser mayor que el sueldo mínimo.
B. No puede haber más de 70 empleados en cada departamento.
 */
set search_path = unc_esq_peliculas;
alter table tarea
add constraint tarea_fecha
check ( not exists(
select t.id_tarea
from tarea t
where t.sueldo_maximo > t.sueldo_minimo ))

alter table empleado
add constraint ck_empleado_departamento_70
check ( not exists(
    select e.id_departamento,count(e.id_empleado)
from empleado e
group by e.id_departamento
having count(e.id_empleado) < 70
))

/*C. Los empleados deben tener jefes que pertenezcan al mismo departamento. */
create assertion
add constraint ck_empleado_jefe
check ( not exists(
    select e.id_empleado
    from empleado e join empleado j on e.id_jefe = j.id_empleado
    where e.id_departamento != j.id_departamento
) )
/*Restricciones de Integridad: Domain, check y assertions
D. Todas las entregas, tienen que ser de películas de un mismo idioma.
 */
--create assertion entregas_idioma
create assertion add constraint entregas_idioma
check(not exists(
       select 1
       from entrega e join renglon_entrega r on e.nro_entrega = r.nro_entrega
       join pelicula p on r.codigo_pelicula = p.codigo_pelicula
       group by e.nro_entrega
       having count(distinct p.idioma) > 1));

--E. No pueden haber más de 10 empresas productoras por ciudad.
create assertion empresa_productora add constraint entrega_ciudad
check ( not exists( select 1
from empresa_productora ep join ciudad c on ep.id_ciudad = c.id_ciudad
group by c.id_ciudad,c.nombre_ciudad
having count(ep.nombre_productora) > 10) )

--F. Para cada película, si el formato es 8mm, el idioma tiene que ser francés.
alter table pelicula
add constraint pelicula_formato_idioma
 check ( not exists(
        select 1
from pelicula
where formato != 'formato 8' or idioma = 'Francés'
group by titulo
    ) )

--G. El teléfono de los distribuidores Nacionales debe tener la misma característica que la de su
--distribuidor mayorista.
select telefono
from distribuidor
where tipo = 'N'