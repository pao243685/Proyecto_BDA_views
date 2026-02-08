# Tarea 6: Lab Reportes - Next.js Dashboard con PostgreSQL

## Descripción del Proyecto

Aplicación de dashboard de reportes construida con **Next.js** que consume datos desde **VIEWS** en **PostgreSQL**, desplegada completamente con **Docker Compose**. El proyecto implementa 5 reportes SQL avanzados utilizando funciones agregadas, window functions, CTEs, índices optimizados y un esquema de seguridad con permisos mínimos.

---

## Reportes Implementados

### 1. **Ranking de Usuarios por Gasto** (`vw_ranking_usuarios_por_gasto`)
- **Grain**: 1 fila = 1 usuario
- **Métricas**: Total de órdenes, total gastado, promedio por orden, ranking por gasto (RANK)
- **KPI**: Total gastado acumulado por usuarios frecuentes
- **Parámetros**: Sin filtros ni paginación

### 2. **Categorías con Más Ventas** (`vw_categorias_con_mas_ventas`)
- **Grain**: 1 fila = 1 categoría
- **Métricas**: Total de ventas, total de unidades vendidas
- **KPI**: Total de ventas acumuladas en página actual
- **Parámetros**: Paginación (page, limit) validada con Zod

### 3. **Productos Más Vendidos por Categoría** (`vw_productos_mas_vendidos_por_categoria`)
- **Grain**: 1 fila = 1 producto dentro de una categoría
- **Métricas**: Total de unidades vendidas, total de ventas, ranking por categoría (PARTITION BY)
- **KPI**: Total de unidades vendidas en criterios filtrados
- **Parámetros**: Filtro por nombre de categoría, paginación (page, limit) validada con Zod

### 4. **Productos sin Ventas en el Último Mes** (`vw_productos_sin_ventas_ultimo_mes`)
- **Grain**: 1 fila = 1 producto
- **Métricas**: Unidades vendidas (COALESCE para manejar nulos)
- **KPI**: Cantidad total de productos sin ventas recientes
- **Parámetros**: Sin filtros ni paginación

### 5. **Ventas Totales por Categoría** (`vw_ventas_totales_por_categoria`)
- **Grain**: 1 fila = 1 categoría
- **Métricas**: Total de ventas, nivel de ventas (ALTA/MEDIA/BAJA mediante CASE)
- **KPI**: Total de ventas sumadas de categorías visibles
- **Parámetros**: Filtro opcional por nivel de ventas (validado con Zod)

---

## 🚀 Instalación y Ejecución

### Prerrequisitos
- Docker
- Docker Compose

### 1. Clonar el Repositorio
```bash
git clone https://github.com/pao243685/Proyecto_BDA_views.git
cd Proyecto_BDA_views
```

### 2. Levantar los Servicios
```bash
docker compose up --build
```

### 3. Detener los Servicios
```bash
docker compose down
```

---

## Justificación de Índices

Para mejorar el rendimiento de las VIEWS se implementaron 3 índices estratégicos, validados con `EXPLAIN ANALYZE` (evidencias en `04_indexes.sql`).

### 1. `idx_ordenes_usuario_status`
```sql
CREATE INDEX idx_ordenes_usuario_status
ON ordenes(usuario_id, status);
```
- **VIEW beneficiada**: `vw_ranking_usuarios_por_gasto`
- **Justificación**: Filtrado rápido por status, menos filas antes del GROUP BY, reducción significativa en costo y tiempo

### 2. `idx_orden_detalles_producto_orden`
```sql
CREATE INDEX idx_orden_detalles_producto_orden
ON orden_detalles(producto_id, orden_id);
```
- **VIEWS beneficiadas**: `vw_productos_mas_vendidos_por_categoria`, `vw_categorias_con_mas_ventas`, `vw_ventas_totales_por_categoria`
- **Justificación**: Optimiza JOIN con productos y órdenes, reduce filas intermedias antes de agregaciones

### 3. `idx_productos_categoria_activo`
```sql
CREATE INDEX idx_productos_categoria_activo
ON productos(categoria_id)
WHERE categoria_id IS NOT NULL;
```
- **VIEWS beneficiadas**: Todas las vistas con agrupación por categoría
- **Justificación**: Permite filtrar eficientemente productos por categoria_id cuando no es nulo, mejorando agrupaciones y joins

---

## Trade-offs: SQL vs Next.js

### Procesamiento en SQL
- **Agregaciones y lógica pesada**: Funciones de agregación, window functions, filtros WHERE se calculan directamente en SQL
- **Views**: Facilitan el acceso desde Next.js a las consultas necesarias para los reportes
- **Ventaja**: Reduce el volumen de datos enviados al servidor y aprovecha los índices

### Procesamiento en Next.js
- **Validación y parsing de inputs**: Uso de Zod para evitar enviar valores inválidos a la base de datos
- **Cálculos de KPI**: Se hacen en el servidor Next.js porque es un cálculo ligero que sirve únicamente para presentación

---

## Evidencias de Performance

### Índice usado: `idx_orden_detalles_producto_orden`
Optimiza las búsquedas y joins por `producto_id` y `orden_id` en `orden_detalles`, reduciendo el tiempo de agregaciones y consultas de productos por orden.

### Índice usado: `idx_ordenes_usuario_status`
Mejora las consultas que filtran por `usuario_id` y `status`, acelerando joins y agregaciones sobre la tabla `ordenes` sin necesidad de escanear toda la tabla.

> **Nota**: Se utilizó `SET enable_seqscan = off` para las pruebas, ya que con tablas pequeñas el planner de PostgreSQL prefiere usar Sequential Scan.

---

## Threat Model: Medidas de Seguridad

### Prevención de SQL Injection
- **Queries parametrizados**: Todas las consultas usan `$1`, `$2`, etc. y se pasan parámetros con `pool.query(query, params)`
- **Validación con Zod**: Antes de ejecutar consultas impide valores arbitrarios

### Control de Acceso
- **Rol con permisos mínimos**: `just_vw_role` configurado para acceso del frontend solamente a las views
- **Sin permisos de lectura/escritura sobre tablas**: Evita acceso a datos sensibles

### Gestión de Secretos
- **Variables de entorno**: No se incluyen en el repositorio, reduciendo el riesgo de filtración de secretos

---

## Evidencia de DB

### Lista de Views y Tablas

             List of relations
 Schema |      Name      | Type  |  Owner
--------+----------------+-------+----------
 public | categorias     | table | postgres
 public | orden_detalles | table | postgres
 public | ordenes        | table | postgres
 public | productos      | table | postgres
 public | usuarios       | table | postgres

                         List of relations
 Schema |                  Name                   | Type |  Owner
--------+-----------------------------------------+------+----------
 public | vw_categorias_con_mas_ventas            | view | postgres
 public | vw_productos_mas_vendidos_por_categoria | view | postgres
 public | vw_productos_sin_ventas_ultimo_mes      | view | postgres
 public | vw_ranking_usuarios_por_gasto           | view | postgres
 public | vw_ventas_totales_por_categoria         | view | postgres



## Pruebas de Permisos de Roles

Se creó un usuario `vw_user` con permisos restringidos únicamente a las vistas (VIEWS).

**Verificación de permisos:**
```sql
SET ROLE vw_user;

SELECT * FROM members;                    -- Debe fallar (sin permisos)
SELECT * FROM vw_ventas_totales_por_categoria;     -- Debe funcionar (tiene permisos)
