/*Cómo debería implementar las Restricciones de Integridad Referencial
  (RIR) si se desea que cada vez que se elimine un registro de la tabla
  PALABRA , también se eliminen los artículos
  que la referencian en la tabla CONTIENE. */

ALTER TABLE p5p1e1_contiene
DROP CONSTRAINT fk_p5p1e1_contiene_palabra; --elimino a restric anterior

ALTER TABLE P5P1E1_CONTIENE
ADD CONSTRAINT FK_P5P1E1_CONTIENE_PALABRA
FOREIGN KEY (idioma, cod_palabra)
REFERENCES P5P1E1_PALABRA (idioma, cod_palabra)
ON DELETE CASCADE;

select * from p5p1e1_palabra;
select * from p5p1e1_contiene;
select * from p5p1e1_articulo;

drop TABLE p5p1e1_articulo;
delete from p5p1e1_contiene where;
delete  from p5p1e1_articulo where id_articulo=1;
delete from p5p1e1_palabra where cod_palabra=1;


insert into p5p1e1_palabra
(idioma, cod_palabra, descripcion)
VALUES ('ES', 1, 'hola'),
       ('IN', 2, 'adios'),
       ('ES', 3, 'hola22');

insert into p5p1e1_contiene
(id_articulo, idioma, cod_palabra)
values  (1,'IN',2),
        (1,'ES',1);

insert into p5p1e1_articulo
(id_articulo, titulo, autor)
values (1,'la fuga','picazzo');

/*b) Verifique qué sucede con las palabras contenidas en cada artículo, al eliminar una palabra,
si definen la Acción Referencial para las bajas (ON DELETE) de la RIR correspondiente
como:
ii) Restrict
iii) Es posible para éste ejemplo colocar SET NULL o SET DEFAULT para ON
DELETE y ON UPDATE?
  1_restric esta bien
  2_se puede colocar null si acepta nulos en este caso no y default si ya hay un valor por default*/
alter table p5p1e1_contiene
add constraint fk_contiene_palabra
foreign key (cod_palabra,idioma)
references p5p1e1_palabra (cod_palabra,idioma)
on delete restrict ;

ALTER TABLE p5p1e1_contiene
DROP CONSTRAINT fk_contiene_palabra; --elimino a restric anterior


-- Table: TP5_P1_EJ2_AUSPICIO
ALTER TABLE TP5_P1_EJ2_AUSPICIO ADD CONSTRAINT FK_TP5_P1_EJ2_AUSPICIO_EMPLEADO
    FOREIGN KEY (tipo_empleado, nro_empleado)
    REFERENCES TP5_P1_EJ2_EMPLEADO (tipo_empleado, nro_empleado)
	MATCH FULL
    ON DELETE  SET NULL
    ON UPDATE  RESTRICT
;
-- Reference: FK_TP5_P1_EJ2_AUSPICIO_PROYECTO (table: TP5_P1_EJ2_AUSPICIO)
ALTER TABLE TP5_P1_EJ2_AUSPICIO ADD CONSTRAINT FK_TP5_P1_EJ2_AUSPICIO_PROYECTO
    FOREIGN KEY (id_proyecto)
    REFERENCES TP5_P1_EJ2_PROYECTO (id_proyecto)
    ON DELETE  RESTRICT
    ON UPDATE  RESTRICT
;
-- Reference: FK_TP5_P1_EJ2_TRABAJA_EN_EMPLEADO (table: TP5_P1_EJ2_TRABAJA_EN)
ALTER TABLE TP5_P1_EJ2_TRABAJA_EN ADD CONSTRAINT FK_TP5_P1_EJ2_TRABAJA_EN_EMPLEADO
    FOREIGN KEY (tipo_empleado, nro_empleado)
    REFERENCES TP5_P1_EJ2_EMPLEADO (tipo_empleado, nro_empleado)
    ON DELETE  CASCADE
    ON UPDATE  RESTRICT
;
-- Reference: FK_TP5_P1_EJ2_TRABAJA_EN_PROYECTO (table: TP5_P1_EJ2_TRABAJA_EN)
ALTER TABLE TP5_P1_EJ2_TRABAJA_EN ADD CONSTRAINT FK_TP5_P1_EJ2_TRABAJA_EN_PROYECTO
    FOREIGN KEY (id_proyecto)
    REFERENCES TP5_P1_EJ2_PROYECTO (id_proyecto)
    ON DELETE  RESTRICT
    ON UPDATE  CASCADE
;






