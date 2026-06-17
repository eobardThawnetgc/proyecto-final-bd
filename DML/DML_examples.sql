-- =====================================
-- EJEMPLOS DE UPDATE
-- =====================================

-- Actualizar teléfono de un cliente
UPDATE cliente
SET telefono = '7777-8888'
WHERE id = 1;

-- Actualizar precio de un medicamento
UPDATE medicamento
SET precio = 25.50
WHERE id = 1;

-- Cambiar estado de un procedimiento
UPDATE procedimiento
SET estado = 'finalizado'
WHERE id = 1;


-- =====================================
-- EJEMPLOS DE DELETE
-- =====================================

-- Eliminar un detalle de factura
DELETE FROM detalle_factura
WHERE id = 1;

-- Eliminar una relación alergia-mascota
DELETE FROM alergia_mascota
WHERE id = 1;

-- Eliminar una factura de prueba
DELETE FROM factura
WHERE id = 100;