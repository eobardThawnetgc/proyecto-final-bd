--FUNCIONES

--Obtener mascotas pertenecientes a un cliente 
create or replace function fn_obtener_mascotas_cliente(id_cliente bigint)
returns table (
	id bigint, 
	nombre varchar(100),
	sexo varchar(20)
)
language plpgsql
as $$
	begin	
		return query
		select mascota.id, mascota.nombre, mascota.sexo from mascota where fk_propietario = id_cliente;
	end;
$$;

select * from fn_obtener_mascotas_cliente(2);

--calcular edad de una mascota
create or replace function fn_calcular_edad_mascota(id_mascota bigint)
returns integer
language plpgsql
as $$
	declare edad integer;
	begin
		select extract(year from age(current_date, fecha_nacimiento)) into edad
		from mascota
		where id = id_mascota;
	return edad;
	end;
$$;

select fn_calcular_edad_mascota(57) as edad_mascota;

--calcular el total de citas de una mascota
create or replace function fn_total_citas_mascota(id_mascota bigint)
returns integer
language plpgsql
as $$
	declare total_citas integer;
	begin
		select count(*) into total_citas
		from cita
		where fk_mascota = id_mascota;
		return total_citas;
	end;
$$;

select fn_total_citas_mascota(50);

--verificar alergia 
create or replace function fn_verificar_alergia_mascota(
    id_mascota bigint
)
returns boolean
language plpgsql
as $$
begin
    return exists (
        select 1
        from alergia_mascota
        where fk_mascota = id_mascota
    );

end;
$$;

select fn_verificar_alergia_mascota(56);

--obtener la próxima cita de una mascota
create or replace function fn_obtener_proxima_cita(id_mascota bigint)
returns timestamp
language plpgsql
as $$
declare
    proxima_cita timestamp;
begin
    select min(fecha_hora)
    into proxima_cita
    from cita
    where fk_mascota = id_mascota
      and fecha_hora >= current_timestamp;

    return proxima_cita;
end;
$$;

select fn_obtener_proxima_cita(25);

-- obtener historial de vacunación de una mascota
create or replace function fn_obtener_vacunas_mascota(
    id_mascota bigint
)
returns table (
    vacuna varchar(100),
    fecha_aplicacion date,
    fecha_proxima_dosis date,
    observaciones text
)
language plpgsql
as $$
begin
    return query
    select
        v.nombre,
        vm.fecha_aplicacion,
        vm.fecha_proxima_dosis,
        vm.observaciones
    from vacunacion_mascota vm
    inner join vacuna v
        on vm.fk_vacuna = v.id
    where vm.fk_mascota = id_mascota
    order by vm.fecha_aplicacion desc;
end;
$$;

select * from fn_obtener_vacunas_mascota(58);

--generar el historial clínico de una mascota
create or replace function fn_historial_clinico_mascota(
    p_id_mascota bigint
)
returns table(
    fecha_cita timestamp,
    diagnostico text,
    medicamento varchar(150),
    cantidad_medicamento integer,
    procedimiento varchar(150)
)
language plpgsql
as $$
begin

    return query
    select
        c.fecha_hora,
        d.descripcion,
        m.nombre,
        t.cantidad_medicamento,
        p.nombre
    from cita c
    inner join diagnostico d
        on d.fk_cita = c.id
    left join tratamiento t
        on t.fk_diagnostico = d.id
    left join medicamento m
        on m.id = t.fk_medicamento
    left join procedimiento p
        on p.fk_diagnostico = d.id
    where c.fk_mascota = p_id_mascota
    order by c.fecha_hora desc;

end;
$$;

select * from fn_historial_clinico_mascota(25);



--PROCEDIMIENTOS ALMACENADOS

--registo de cita 
create or replace procedure sp_registrar_cita(
	p_fk_mascota bigint,
	p_fk_veterinario bigint,
	p_fecha_hora timestamp
)
language plpgsql
as $$
	begin
		--validaciones antes de insertar
		if not exists (
			select 1 from mascota 
			where id = p_fk_mascota
		) then raise exception 'La mascota no existe';
		end if;
		
		if not exists(
			select 1 from veterinario 
			where id = p_fk_veterinario
		) then raise exception 'El veterinario no existe';
		end if;

		if p_fecha_hora <= current_timestamp then	
			raise exception 'La cita debe programarse para una fecha futura';
		end if;

		insert into cita (
			fk_mascota,
			fk_veterinario,
			fecha_hora
		)
		values (
			p_fk_mascota,
			p_fk_veterinario,
			p_fecha_hora
		);
		raise notice 'Cita programada exitosamente';
	end;
$$;

call sp_registrar_cita(
    1,
    2,
    '2026-07-20 09:00:00'
);

--cancelar una cita pendiente
create or replace procedure sp_cancelar_cita(
    p_id_cita bigint
)
language plpgsql
as $$
begin

    -- Verificar existencia
    if not exists (
        select 1
        from cita
        where id = p_id_cita
    ) then
        raise exception 'La cita no existe';
    end if;

    -- Verificar que no haya diagnóstico asociado
    if exists (
        select 1
        from diagnostico
        where fk_cita = p_id_cita
    ) then
        raise exception 'No se puede cancelar una cita que ya posee diagnóstico';
    end if;

    delete from cita
    where id = p_id_cita;

    raise notice 'Cita cancelada correctamente';

end;
$$;

call sp_cancelar_cita(65);


-- Registrar una vacunación para una mascota
create or replace procedure sp_registrar_vacunacion(
    p_fk_mascota bigint,
    p_fk_vacuna bigint,
    p_fecha_aplicacion date,
    p_fecha_proxima_dosis date,
    p_observaciones text
)
language plpgsql
as $$
begin

    -- Verificar que la mascota exista
    if not exists (
        select 1
        from mascota
        where id = p_fk_mascota
    ) then
        raise exception 'La mascota no existe';
    end if;

    -- Verificar que la vacuna exista
    if not exists (
        select 1
        from vacuna
        where id = p_fk_vacuna
    ) then
        raise exception 'La vacuna no existe';
    end if;

    -- Verificar fecha válida
    if p_fecha_aplicacion > current_date then
        raise exception 'La fecha de aplicación no puede ser futura';
    end if;

    -- Registrar vacunación
    insert into vacunacion_mascota(
        fk_mascota,
        fk_vacuna,
        fecha_aplicacion,
        fecha_proxima_dosis,
        observaciones
    )
    values(
        p_fk_mascota,
        p_fk_vacuna,
        p_fecha_aplicacion,
        p_fecha_proxima_dosis,
        p_observaciones
    );

    raise notice 'Vacunación registrada exitosamente';

end;
$$;

call sp_registrar_vacunacion(
    1,
    1,
    '2026-06-18',
    '2027-06-18',
    'Vacunación anual'
);



-- Agregar un medicamento a una factura
create or replace procedure sp_generar_detalle_factura(
    p_fk_factura bigint,
    p_fk_medicamento bigint,
    p_cantidad integer
)
language plpgsql
as $$
declare
    v_precio decimal(10,2);
    v_subtotal decimal(10,2);
begin

    -- Verificar factura
    if not exists (
        select 1
        from factura
        where id = p_fk_factura
    ) then
        raise exception 'La factura no existe';
    end if;

    -- Verificar medicamento
    if not exists (
        select 1
        from medicamento
        where id = p_fk_medicamento
    ) then
        raise exception 'El medicamento no existe';
    end if;

    -- Verificar cantidad
    if p_cantidad <= 0 then
        raise exception 'La cantidad debe ser mayor que cero';
    end if;

    -- Obtener precio del medicamento
    select precio
    into v_precio
    from medicamento
    where id = p_fk_medicamento;

    -- Calcular subtotal
    v_subtotal := v_precio * p_cantidad;

    -- Insertar detalle
    insert into detalle_factura(
        cantidad,
        precio,
        subtotal,
        fk_medicamento,
        fk_factura
    )
    values(
        p_cantidad,
        v_precio,
        v_subtotal,
        p_fk_medicamento,
        p_fk_factura
    );

    raise notice 'Detalle de factura registrado correctamente';

end;
$$;

call sp_generar_detalle_factura(
    1, -- factura
    2, -- medicamento
    3  -- cantidad
);



--TRIGGERS
--creación de función 
create or replace function fn_verificar_alergia_tratamiento()
returns trigger
language plpgsql
as $$
declare
    v_mascota bigint;
begin

    select c.fk_mascota
    into v_mascota
    from diagnostico d
    inner join cita c
        on c.id = d.fk_cita
    where d.id = new.fk_diagnostico;

    if exists (
        select 1
        from alergia_mascota_medicamento amm
        where amm.fk_mascota = v_mascota
          and amm.fk_medicamento = new.fk_medicamento
    ) then

        raise exception
        'La mascota tiene alergia al medicamento seleccionado';

    end if;

    return new;

end;
$$;

--creación de trigger
create trigger tg_verificar_alergia_tratamiento
before insert or update
on tratamiento
for each row
execute function fn_verificar_alergia_tratamiento();

insert into tratamiento
(
    cantidad_medicamento,
    informacion_adicional,
    fk_diagnostico,
    fk_medicamento
)
values
(
    1,
    'Prueba trigger',
    1,
    44
);




