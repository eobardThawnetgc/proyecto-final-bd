-- ======================================
-- Consultas Clinica Veterinaria
-- ======================================

-- ======================================
--Mascotas mas atendidas por mes (Reportes Generales)
SELECT 
    EXTRACT(YEAR FROM c.fecha_hora) AS anio,
    EXTRACT(MONTH FROM c.fecha_hora) AS mes,
    m.id AS id_mascota,
    m.nombre AS nombre_mascota,
    COUNT(c.id) AS total_atenciones
FROM cita c
JOIN mascota m ON c.fk_mascota = m.id
GROUP BY EXTRACT(YEAR FROM c.fecha_hora), EXTRACT(MONTH FROM c.fecha_hora), m.id, m.nombre
ORDER BY anio DESC, mes DESC, total_atenciones DESC;

-- ======================================
--Veterinario con mayor numero de citas en el trimestre (Reportes Gerenciales)
SELECT 
    v.id AS id_veterinario,
    v.nombre AS nombre_veterinario,
    COUNT(c.id) AS total_citas
FROM cita c
JOIN veterinario v ON c.fk_veterinario = v.id
WHERE c.fecha_hora BETWEEN '2025-01-01' AND '2025-03-31'
GROUP BY v.id, v.nombre
ORDER BY total_citas DESC
LIMIT 1;

-- ======================================
--Medicamentos preescritos con mayor frecuencia (Reportes Gerenciales)
SELECT 
    med.id AS id_medicamento,
    med.nombre AS medicamento,
    COUNT(t.id) AS veces_recetado
FROM tratamiento t
JOIN medicamento med ON t.fk_medicamento = med.id
GROUP BY med.id, med.nombre
ORDER BY veces_recetado DESC;

-- ======================================
--Ingresos totales (Citas) por especialidad veterinaria (Reportes Gerenciales)
SELECT esp.nombre AS especialidad,
       COUNT(c.id) AS visitas_totales
FROM especialidad esp
JOIN veterinario v ON esp.id = v.fk_especialidad
JOIN cita c ON v.id = c.fk_veterinario
GROUP BY esp.nombre
ORDER BY visitas_totales DESC;

-- ======================================
--Propietarios con mascotas rezagadas (Gestion del paciente)
SELECT 
    cl.id AS id_cliente,
    cl.nombre AS cliente,
    cl.telefono
FROM cliente cl
WHERE NOT EXISTS (
    SELECT 1 
    FROM mascota m
    JOIN cita c ON c.fk_mascota = m.id
    WHERE m.fk_propietario = cl.id 
      AND c.fecha_hora >= CURRENT_DATE - INTERVAL '6 months'
);

-- ======================================
--Ficha tecnica y datos generales del paciente (mascota) (Gestion del paciente)
SELECT 
    m.nombre AS nombre_mascota,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, m.fecha_nacimiento)) AS edad_anos,
    e.nombre AS especie,
    m.peso AS peso_actual,
    cl.nombre AS propietario
FROM mascota m
JOIN especie e ON m.fk_especie = e.id
JOIN cliente cl ON m.fk_cliente = cl.id
WHERE m.id = :id_mascota; -- Sustituir por el ID de la mascota a consultar

-- ======================================
--Antecedentes de alergias (Gestion del paciente)
SELECT 
    med.nombre AS medicamento_prohibido,
    al.descripcion AS tipo_alergia
FROM alergia_mascota_medicamento amm
JOIN medicamento med ON amm.fk_medicamento = med.id
JOIN alergia al ON amm.fk_medicamento = al.id
WHERE amm.fk_mascota = :id_mascota; -- Sustituir por el ID de la mascota a consultar

-- ======================================
--Historial de enfermedades y diagnosticos pasados (Gestion del paciente)
SELECT 
    c.fecha_hora AS fecha_visita,
    d.descripcion AS diagnostico_emitido,
    v.nombre AS atendido_por
FROM diagnostico d
JOIN cita c ON d.fk_cita = c.id
JOIN veterinario v ON c.fk_veterinario = v.id
WHERE c.fk_mascota = :id_mascota -- Sustituir por el ID de la mascota a consultar
ORDER BY c.fecha_hora DESC;

-- ======================================
--Registro de cirugias o intervenciones pasadas (Gestion del paciente)
SELECT 
    c.fecha_hora AS fecha_procedimiento,
    p.nombre AS procedimiento_realizado,
    p.estado AS estado_procedimiento
FROM procedimiento p
JOIN diagnostico d ON p.fk_diagnostico = d.id
JOIN cita c ON d.fk_cita = c.id
WHERE c.fk_mascota = :id_mascota -- Sustituir por el ID de la mascota a consultar
ORDER BY c.fecha_hora DESC;

-- ======================================
--Motivo de consulta y revision por sistemas (de consultas anteriores) (Gestion del paciente)
SELECT 
    c.fecha_hora AS fecha_visita,
    d.observaciones AS historial_clinico -- Aquí se lee el resumen de la entrevista, síntomas y revisión
FROM cita c
JOIN diagnostico d ON d.fk_cita = c.id
WHERE c.fk_mascota = :id_mascota -- Sustituir por el ID de la mascota a consultar
ORDER BY c.fecha_hora DESC;

-- ======================================
--Control de vacunacion y desparacitaciones (Gestion del paciente)
SELECT 
    v.nombre AS vacuna_o_antiparasitario,
    vm.fecha_aplicacion AS fecha_administracion,
    v.descripcion AS detalles
FROM vacunacion_mascota vm
JOIN vacuna v ON vm.fk_vacuna = v.id
WHERE vm.fk_mascota = :id_mascota -- Sustituir por el ID de la mascota a consultar
ORDER BY vm.fecha_aplicacion DESC;

-- ======================================
--Reporte de top 5 enfermedades mas comunes por especie (Reporte Gerenciales)
SELECT 
    e.nombre AS especie,
    d.descripcion AS enfermedad_diagnostico,
    COUNT(d.id) AS total_casos
FROM diagnostico d
JOIN cita c ON d.fk_cita = c.id
JOIN mascota m ON c.fk_mascota = m.id
JOIN especie e ON m.fk_especie = e.id
GROUP BY e.nombre, d.descripcion
ORDER BY total_casos DESC
LIMIT 5;

-- ======================================
