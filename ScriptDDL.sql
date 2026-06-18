-- Almacena los tipos de alergias que pueden presentar las mascotas 
create table alergia (
    id bigint generated always as identity,
    descripcion varchar(255) not null,
    constraint pk_alergia
        primary key (id)
);

-- Almacena las especies de animales registradas en la veterinaria
create table especie (
    id bigint generated always as identity,
    nombre varchar(100) not null,
    constraint pk_especie
        primary key (id),
    constraint uq_especie_nombre
        unique (nombre),
        constraint chk_especie_nombre
    check (
        nombre in (
            'perro',
            'gato',
            'conejo',
            'hamster',
            'loro',
            'canario',
            'tortuga',
            'iguana',
            'serpiente',
            'pez'
        )
    ) 
);

-- Almacena la información de los propietarios de las mascotas
create table cliente (
    id bigint generated always as identity,
 	nombre varchar(150) not null,
    correo varchar(150),
    telefono varchar(20),
    dui varchar(20),
    constraint pk_cliente
        primary key (id),
    constraint uq_cliente_correo
        unique (correo),
    constraint uq_cliente_dui
        unique (dui)
);

-- Almacena las especialidades médicas de los veterinarios
create table especialidad (
     id bigint generated always as identity,
    nombre varchar(100) not null,
    constraint pk_especialidad
        primary key (id),
    constraint uq_especialidad_nombre
        unique (nombre),
        constraint chk_especialidad_nombre
    check (
        nombre in (
            'medicina general',
            'cirugia',
            'dermatologia',
            'odontologia',
            'oftalmologia',
            'cardiologia',
            'traumatologia',
            'neurologia',
            'oncologia',
            'animales exoticos'
        )
    )
);

-- Almacena la información de los veterinarios y su especialidad
create table veterinario (
    id bigint generated always as identity,
    nombre varchar(150) not null,
    correo varchar(150),
    dui varchar(20),
    telefono varchar(20),
    fk_especialidad bigint not null,
    constraint pk_veterinario
        primary key (id),
    constraint uq_veterinario_correo
        unique (correo),
    constraint uq_veterinario_dui
        unique (dui),
    constraint fk_veterinario_especialidad
        foreign key (fk_especialidad)
        references especialidad(id)
        on update cascade
        on delete restrict
);

-- Almacena la información de las mascotas registradas en la clínica
create table mascota (
 	id bigint generated always as identity,
    nombre varchar(100) not null,
    peso decimal(6,2),
    fecha_nacimiento date,
    sexo varchar(20) not null,
    fk_especie bigint not null,
    fk_propietario bigint not null,
    constraint pk_mascota
        primary key (id),   
    constraint chk_mascota_sexo
    check (sexo in ('macho', 'hembra')),
    constraint fk_mascota_especie
        foreign key (fk_especie)
        references especie(id)
        on update cascade
        on delete restrict,
    constraint fk_mascota_cliente
        foreign key (fk_propietario)
        references cliente(id)
        on update cascade
        on delete restrict
);

-- Relaciona las mascotas con las alergias que padecen
create table alergia_mascota (
    id bigint generated always as identity,
    fk_mascota bigint not null,
    fk_alergia bigint not null,
    constraint pk_alergia_mascota
        primary key (id),
    constraint uq_alergia_mascota
        unique (fk_mascota, fk_alergia),
    constraint fk_alergia_mascota_mascota
        foreign key (fk_mascota)
        references mascota(id)
        on update cascade
        on delete restrict,
    constraint fk_alergia_mascota_alergia
        foreign key (fk_alergia)
        references alergia(id)
        on update cascade
        on delete restrict
);

-- Almacena los medicamentos utilizados en tratamientos veterinarios
create table medicamento (
    id bigint generated always as identity,
    nombre varchar(150) not null,
    tipo varchar(100),
    contenido varchar(255),
    precio decimal(10,2) not null,
    constraint pk_medicamento
        primary key (id),
    constraint chk_medicamento_precio
        check (precio >= 0)
);

-- Relaciona mascotas con medicamentos a los que pueden presentar alergia
create table alergia_mascota_medicamento (
    id bigint generated always as identity,
    fk_mascota bigint not null,
    fk_medicamento bigint not null,
    constraint pk_alergia_medicamento
        primary key (id),
    constraint uq_alergia_medicamento
        unique (fk_mascota, fk_medicamento),
    constraint fk_alergia_medicamento_mascota
        foreign key (fk_mascota)
        references mascota(id)
        on update cascade
        on delete restrict,
    constraint fk_alergia_medicamento_medicamento
        foreign key (fk_medicamento)
        references medicamento(id)
        on update cascade
        on delete restrict
);

-- Almacena las vacunas disponibles para aplicación en mascotas
create table vacuna (
    id bigint generated always as identity,
    nombre varchar(100) not null,
    descripcion text,
    constraint pk_vacuna 
    	primary key(id)
);

-- Registra el historial de vacunación de cada mascota
create table vacunacion_mascota (
    id bigint generated always as identity,
    fk_mascota bigint not null,
    fk_vacuna bigint not null,
    fecha_aplicacion date not null,
    fecha_proxima_dosis date,
    observaciones text,
    constraint pk_vacunacion_mascota 
    	primary key(id),
    constraint fk_vacunacion_mascota 
    	foreign key (fk_mascota) 
    	references mascota(id),
    constraint fk_mascota_mascota 
    	foreign key (fk_vacuna) 
    	references vacuna(id)
);

-- Registra las citas médicas entre mascotas y veterinarios
create table cita (
    id bigint generated always as identity,
    fecha_hora timestamp not null,
    fk_mascota bigint not null,
    fk_veterinario bigint not null,
    constraint pk_cita
        primary key (id),
    constraint fk_cita_mascota
        foreign key (fk_mascota)
        references mascota(id)
        on update cascade
        on delete restrict,
    constraint fk_cita_veterinario
        foreign key (fk_veterinario)
        references veterinario(id)
        on update cascade
        on delete restrict
);

-- Almacena los diagnósticos generados durante una cita veterinaria
create table diagnostico (
    id bigint generated always as identity,
    descripcion text not null,
    observaciones text,
    fk_cita bigint not null,
    constraint pk_diagnostico
        primary key (id),
    constraint uq_diagnostico_cita
        unique (fk_cita),
    constraint fk_diagnostico_cita
        foreign key (fk_cita)
        references cita(id)
        on update cascade
        on delete restrict
);

-- Registra los tratamientos y medicamentos indicados en un diagnóstico
create table tratamiento (
    id bigint generated always as identity,
    cantidad_medicamento int not null,
    informacion_adicional text,
    fk_diagnostico bigint not null,
    fk_medicamento bigint not null,
    constraint pk_tratamiento
        primary key (id),
    constraint chk_tratamiento_cantidad
        check (cantidad_medicamento > 0),
    constraint fk_tratamiento_diagnostico
        foreign key (fk_diagnostico)
        references diagnostico(id)
        on update cascade
        on delete restrict,
    constraint fk_tratamiento_medicamento
        foreign key (fk_medicamento)
        references medicamento(id)
        on update cascade
        on delete restrict
);

-- Almacena los procedimientos médicos realizados a las mascotas
create table procedimiento (
    id bigint generated always as identity,
    nombre varchar(150) not null,
    descripcion text,
    precio decimal(10,2) not null,
    estado varchar(50),
    fk_diagnostico bigint not null,
    constraint pk_procedimiento
        primary key (id),
    constraint chk_procedimiento_precio
        check (precio >= 0),
        constraint chk_procedimiento_nombre
    check (
        nombre in (
            'consulta general',
            'vacunacion',
            'desparasitacion',
            'radiografia',
            'ultrasonido',
            'cirugia',
            'limpieza dental',
            'hospitalizacion',
            'curacion',
            'esterilizacion'
        )
    ),
constraint chk_procedimiento_estado
    check (
        estado in (
            'pendiente',
            'en proceso',
            'finalizado',
            'cancelado'
        )
    ),
    constraint fk_procedimiento_diagnostico
        foreign key (fk_diagnostico)
        references diagnostico(id)
        on update cascade
        on delete restrict
);

-- Registra la facturación de los servicios prestados a los clientes
create table factura (
    id bigint generated always as identity,
    total decimal(10,2) not null,
    estado_pago varchar(50) not null,
    metodo_pago varchar(50) not null,
    fk_cliente bigint not null,
    constraint pk_factura
        primary key (id),
    constraint chk_factura_total
        check (total >= 0),
    constraint fk_factura_cliente
        foreign key (fk_cliente)
        references cliente(id)
        on update cascade
        on delete restrict
);

-- Almacena el detalle de medicamentos y procedimientos incluidos en una factura
create table detalle_factura ( 
    id bigint generated always as identity,
    cantidad int not null,
    precio decimal(10,2) not null,
    subtotal decimal(10,2) not null,
    fk_medicamento bigint,
    fk_procedimiento bigint,
    fk_factura bigint not null,
    constraint pk_detalle_factura
        primary key (id),
    constraint chk_detalle_cantidad
        check (cantidad > 0),
    constraint chk_detalle_precio
        check (precio >= 0),
    constraint chk_detalle_subtotal
        check (subtotal >= 0),
    constraint fk_detalle_medicamento
        foreign key (fk_medicamento)
        references medicamento(id)
        on update cascade
        on delete restrict,
    constraint fk_detalle_procedimiento
        foreign key (fk_procedimiento)
        references procedimiento(id)
        on update cascade
        on delete restrict,
    constraint fk_detalle_factura
        foreign key (fk_factura)
        references factura(id)
        on update cascade
        on delete restrict,
    constraint chk_detalle_item
        check (
            (fk_medicamento is not null and fk_procedimiento is null)
            or
            (fk_medicamento is null and fk_procedimiento is not null)
        )
);