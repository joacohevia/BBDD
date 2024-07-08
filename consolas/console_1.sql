ALTER TABLE IF EXISTS audio
    DROP CONSTRAINT IF EXISTS audio_objeto;

ALTER TABLE IF EXISTS documento
    DROP CONSTRAINT IF EXISTS documento_objeto;

ALTER TABLE IF EXISTS objeto
    DROP CONSTRAINT IF EXISTS objeto_pertenece;

ALTER TABLE IF EXISTS objeto
    DROP CONSTRAINT IF EXISTS objeto_se_encuentra;

ALTER TABLE IF EXISTS video
    DROP CONSTRAINT IF EXISTS video_objeto;

DROP TABLE IF EXISTS audio;

DROP TABLE IF EXISTS coleccion;

DROP TABLE IF EXISTS documento;

DROP TABLE IF EXISTS objeto;

DROP TABLE IF EXISTS repositorio;

DROP TABLE IF EXISTS video;

CREATE TABLE audio (
    formato varchar(15)  NOT NULL,
    duraccion int  NOT NULL,
    objeto_id_objeto int  NOT NULL,
    objeto_coleccion_id_coleccion int  NOT NULL,
    CONSTRAINT audio_pk PRIMARY KEY (objeto_coleccion_id_coleccion,objeto_id_objeto)
);

-- Table: coleccion
CREATE TABLE coleccion (
    id_coleccion int  NOT NULL,
    titulo_coleccion varchar(15)  NOT NULL,
    descripcion varchar(15)  NOT NULL,
    CONSTRAINT coleccion_pk PRIMARY KEY (id_coleccion)
);

CREATE TABLE documento (
    tipo_publicacion varchar(15)  NOT NULL,
    modos_color varchar(15)  NOT NULL,
    resolucion_captura varchar(15)  NOT NULL,
    objeto_id_objeto int  NOT NULL,
    objeto_coleccion_id_coleccion int  NOT NULL,
    CONSTRAINT documento_pk PRIMARY KEY (objeto_coleccion_id_coleccion,objeto_id_objeto)
);

-- Table: objeto
CREATE TABLE objeto (
    id_objeto int  NOT NULL,
    coleccion_id_coleccion int  NOT NULL,
    repositorio_id_repositorio int  NOT NULL,
    titulo varchar(15)  NOT NULL,
    descripcion varchar(15)  NOT NULL,
    fuente varchar(15)  NOT NULL,
    fecha date  NOT NULL,
    CONSTRAINT objeto_pk PRIMARY KEY (id_objeto,coleccion_id_coleccion)
);

-- Table: repositorio
CREATE TABLE repositorio (
    id_repositorio int  NOT NULL,
    nombre varchar(15)  NOT NULL,
    publico boolean  NOT NULL,
    descripcion varchar(15)  NOT NULL,
    duenio varchar(15)  NULL,
    CONSTRAINT repositorio_pk PRIMARY KEY (id_repositorio)
);

-- Table: video
CREATE TABLE video (
    resolucion int  NOT NULL,
    frames_x_segundo int  NOT NULL,
    objeto_id_objeto int  NOT NULL,
    objeto_coleccion_id_coleccion int  NOT NULL,
    CONSTRAINT video_pk PRIMARY KEY (objeto_coleccion_id_coleccion,objeto_id_objeto)
);

-- foreign keys
-- Reference: audio_objeto (table: audio)
ALTER TABLE audio ADD CONSTRAINT audio_objeto
    FOREIGN KEY (objeto_id_objeto, objeto_coleccion_id_coleccion)
    REFERENCES objeto (id_objeto, coleccion_id_coleccion)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: documento_objeto (table: documento)
ALTER TABLE documento ADD CONSTRAINT documento_objeto
    FOREIGN KEY (objeto_id_objeto, objeto_coleccion_id_coleccion)
    REFERENCES objeto (id_objeto, coleccion_id_coleccion)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

ALTER TABLE objeto ADD CONSTRAINT objeto_pertenece
    FOREIGN KEY (coleccion_id_coleccion)
    REFERENCES coleccion (id_coleccion)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

ALTER TABLE objeto ADD CONSTRAINT objeto_se_encuentra
    FOREIGN KEY (repositorio_id_repositorio)
    REFERENCES repositorio (id_repositorio)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: video_objeto (table: video)
ALTER TABLE video ADD CONSTRAINT video_objeto
    FOREIGN KEY (objeto_id_objeto, objeto_coleccion_id_coleccion)
    REFERENCES objeto (id_objeto, coleccion_id_coleccion)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;
