## 📚 Asignatura

**Bases de Datos**

Universidad Centroamericana José Simeón Cañas (UCA)

**Proyecto Final – Sistema de Gestión Clínica Veterinaria**

---

## 👥 Integrantes

* Juan Manuel Flores Crisóstomo, 00135025
* Diego Alejandro González García, 00072825
* Jorge Alberto Escobar Menjivar, 00072325
* Sofía Nicole Rodríguez Campos, 00175525
---

## 📖 Descripción

Este proyecto implementa una base de datos relacional para la gestión integral de una clínica veterinaria. El sistema permite administrar propietarios, mascotas, especies, veterinarios, especialidades, citas médicas, diagnósticos, tratamientos, medicamentos, vacunaciones y facturación.

El desarrollo fue realizado siguiendo el ciclo completo de diseño de bases de datos:

* Modelo Entidad-Relación (Notación Chen).
* Transformación a esquema relacional.
* Normalización hasta Tercera Forma Normal (3FN).
* Implementación en PostgreSQL.
* Programación de funciones, procedimientos almacenados y triggers.
* Consultas de análisis y gestión operativa.

---

## 🎯 Objetivos del Proyecto

* Gestionar la información clínica de mascotas.
* Controlar citas y diagnósticos veterinarios.
* Registrar tratamientos y medicamentos.
* Mantener historial de vacunación.
* Gestionar alergias para garantizar la seguridad clínica.
* Automatizar procesos mediante procedimientos y triggers.
* Administrar la facturación de los servicios prestados.

---

## 🗄️ Modelo de Datos

### Entidades Principales

* Cliente
* Mascota
* Especie
* Veterinario
* Especialidad
* Cita
* Diagnóstico
* Tratamiento
* Medicamento
* Alergia
* Vacuna
* Vacunación_Mascota
* Procedimiento
* Factura
* Detalle_Factura

---

## ⚙️ Tecnologías Utilizadas

* PostgreSQL 17
* PL/pgSQL
* DBeaver

---

## 🔍 Consultas Implementadas

### Consultas Gerenciales

* Veterinario con mayor número de citas.
* Mascotas más atendidas por mes.
* Medicamentos prescritos con mayor frecuencia.
* Top enfermedades por especie.
* Ingresos por especialidad veterinaria.

### Consultas Operativas

* Información general de mascotas.
* Historial clínico.
* Historial de vacunación.
* Antecedentes de alergias.
* Clientes sin visitas recientes.

---

## 🔒 Integridad de Datos

La base de datos implementa:

* Primary Keys (PK)
* Foreign Keys (FK)
* Restricciones UNIQUE
* Restricciones CHECK
* Validaciones mediante Triggers
* Automatización mediante Procedimientos Almacenados

---
Este proyecto permitió aplicar los conceptos fundamentales de diseño, implementación y programación de bases de datos relacionales en PostgreSQL mediante el desarrollo de un sistema de gestión para una clínica veterinaria.