create database Veterinaria;

CREATE TABLE alergia (
    id SERIAL PRIMARY KEY,
    descripcion VARCHAR(255) NOT NULL
);

CREATE TABLE especie (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE cliente (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    correo VARCHAR(150) UNIQUE,
    telefono VARCHAR(20),
    dui VARCHAR(20) UNIQUE
);

CREATE TABLE especialidad (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE veterinario (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    correo VARCHAR(150) UNIQUE,
    dui VARCHAR(20) UNIQUE,
    telefono VARCHAR(20),
    fk_especialidad INT NOT NULL,

    CONSTRAINT fk_veterinario_especialidad
        FOREIGN KEY (fk_especialidad)
        REFERENCES especialidad(id)
);

CREATE TABLE mascota (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    peso DECIMAL(6,2),
    fecha_nacimiento DATE,
    fk_especie INT NOT NULL,
    fk_propietario INT NOT NULL,

    CONSTRAINT fk_mascota_especie
        FOREIGN KEY (fk_especie)
        REFERENCES especie(id),

    CONSTRAINT fk_mascota_cliente
        FOREIGN KEY (fk_propietario)
        REFERENCES cliente(id)
);

CREATE TABLE alergia_mascota (
    id SERIAL PRIMARY KEY,
    fk_mascota INT NOT NULL,
    fk_alergia INT NOT NULL,

    CONSTRAINT fk_alergia_mascota_mascota
        FOREIGN KEY (fk_mascota)
        REFERENCES mascota(id),

    CONSTRAINT fk_alergia_mascota_alergia
        FOREIGN KEY (fk_alergia)
        REFERENCES alergia(id),

    CONSTRAINT uq_alergia_mascota
        UNIQUE (fk_mascota, fk_alergia)
);

CREATE TABLE cita (
    id SERIAL PRIMARY KEY,
    fecha_hora TIMESTAMP NOT NULL,
    fk_mascota INT NOT NULL,
    fk_veterinario INT NOT NULL,

    CONSTRAINT fk_cita_mascota
        FOREIGN KEY (fk_mascota)
        REFERENCES mascota(id),

    CONSTRAINT fk_cita_veterinario
        FOREIGN KEY (fk_veterinario)
        REFERENCES veterinario(id)
);

CREATE TABLE diagnostico (
    id SERIAL PRIMARY KEY,
    descripcion TEXT NOT NULL,
    observaciones TEXT,
    fk_cita INT NOT NULL UNIQUE,

    CONSTRAINT fk_diagnostico_cita
        FOREIGN KEY (fk_cita)
        REFERENCES cita(id)
);

CREATE TABLE medicamento (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    tipo VARCHAR(100),
    contenido VARCHAR(255),
    precio DECIMAL(10,2) NOT NULL CHECK (precio >= 0)
);

CREATE TABLE tratamiento (
    id SERIAL PRIMARY KEY,
    cantidad_medicamento INT NOT NULL CHECK (cantidad_medicamento > 0),
    informacion_adicional TEXT,
    fk_diagnostico INT NOT NULL,
    fk_medicamento INT NOT NULL,

    CONSTRAINT fk_tratamiento_diagnostico
        FOREIGN KEY (fk_diagnostico)
        REFERENCES diagnostico(id),

    CONSTRAINT fk_tratamiento_medicamento
        FOREIGN KEY (fk_medicamento)
        REFERENCES medicamento(id)
);

CREATE TABLE procedimiento (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL CHECK (precio >= 0),
    estado VARCHAR(50),
    fk_diagnostico INT NOT NULL,

    CONSTRAINT fk_procedimiento_diagnostico
        FOREIGN KEY (fk_diagnostico)
        REFERENCES diagnostico(id)
);

CREATE TABLE factura (
    id SERIAL PRIMARY KEY,
    total DECIMAL(10,2) NOT NULL CHECK (total >= 0),
    estado_pago VARCHAR(50) NOT NULL,
    metodo_pago VARCHAR(50) NOT NULL,
    fk_cliente INT NOT NULL,

    CONSTRAINT fk_factura_cliente
        FOREIGN KEY (fk_cliente)
        REFERENCES cliente(id)
);

CREATE TABLE detalle_factura (
    id SERIAL PRIMARY KEY,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio DECIMAL(10,2) NOT NULL CHECK (precio >= 0),
    subtotal DECIMAL(10,2) NOT NULL CHECK (subtotal >= 0),

    fk_medicamento INT,
    fk_procedimiento INT,
    fk_factura INT NOT NULL,

    CONSTRAINT fk_detalle_medicamento
        FOREIGN KEY (fk_medicamento)
        REFERENCES medicamento(id),

    CONSTRAINT fk_detalle_procedimiento
        FOREIGN KEY (fk_procedimiento)
        REFERENCES procedimiento(id),

    CONSTRAINT fk_detalle_factura
        FOREIGN KEY (fk_factura)
        REFERENCES factura(id),

    CONSTRAINT chk_detalle_item
        CHECK (
            (fk_medicamento IS NOT NULL AND fk_procedimiento IS NULL)
            OR
            (fk_medicamento IS NULL AND fk_procedimiento IS NOT NULL)
        )
);