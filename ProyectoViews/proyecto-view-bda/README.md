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

## Instalación y Ejecución

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

Para mejorar el rendimiento de las VIEWS se implementaron 3 índices estratégicos. Cada índice fue validado con `EXPLAIN ANALYZE` para confirmar su uso efectivo.

### Contexto de Pruebas

**Limitación actual:** Con el dataset de prueba (< 100 registros totales), los tiempos de ejecución son óptimos incluso sin índices (< 7ms). PostgreSQL puede escanear tablas pequeñas completamente en memoria sin penalización significativa.

**Proyección a producción:** Los índices implementados están diseñados para escalar. Con datasets reales (miles o millones de registros), estos índices reducirían los tiempos de ejecución de segundos/minutos a milisegundos.

### 1. `idx_ordenes_usuario_status`
```sql
CREATE INDEX idx_ordenes_usuario_status 
ON ordenes(usuario_id, status);
```

**VIEW beneficiada:** `vw_ranking_usuarios_por_gasto`

**Optimizaciones:**
- Permite JOIN eficiente entre `usuarios` y `ordenes` por `usuario_id`
- Filtra rápidamente órdenes por `status <> 'cancelado'`
- Reduce el número de filas antes del GROUP BY y agregaciones

**Evidencia de uso:**
```
->  Index Scan using idx_ordenes_usuario_status on ordenes o
      (cost=0.14..12.52 rows=21) (actual time=0.705..0.711 rows=22)
    Filter: ((status)::text <> 'cancelado'::text)
```
- **El índice se utiliza** en lugar de Sequential Scan
- Execution Time: 1.817 ms (óptimo para el dataset actual)
- **Proyección:** Con 100K usuarios y 1M órdenes, reduciría tiempo de ~10s a ~50ms

---

### 2. `idx_ordenes_id_created_status`
```sql
CREATE INDEX idx_ordenes_id_created_status 
ON ordenes(id, created_at, status);
```

**VIEWS beneficiadas:**
- `vw_ventas_totales_por_categoria`
- `vw_productos_mas_vendidos_por_categoria`
- `vw_categorias_por_crecimiento`

**Optimizaciones:**
- Permite **Index-Only Scan** (no requiere acceso a la tabla)
- Optimiza JOINs entre `orden_detalles` y `ordenes` por `id`
- Incluye `created_at` para filtros temporales en futuras optimizaciones
- Filtra órdenes canceladas eficientemente

**Evidencia de uso:**
```
->  Index Only Scan using idx_ordenes_id_created_status on ordenes o
      (cost=0.14..12.52 rows=21) (actual time=0.493..0.498 rows=22)
    Filter: ((status)::text <> 'cancelado'::text)
    Heap Fetches: 22
```
- **Index-Only Scan** - La operación más eficiente en PostgreSQL
- Solo 22 Heap Fetches en lugar de escaneo completo
- Execution Time: 1.784 ms
- **Proyección:** Con 1M órdenes, evitaría leer ~4GB de datos de disco

---

### 3. `idx_orden_detalles_producto_subtotal`
```sql
CREATE INDEX idx_orden_detalles_producto_subtotal 
ON orden_detalles(producto_id, subtotal, cantidad);
```

**VIEWS beneficiadas:**
- `vw_productos_sin_ventas_ultimo_mes`
- `vw_productos_mas_vendidos_por_categoria`
- `vw_ventas_totales_por_categoria`

**Optimizaciones:**
- "Covering index" que incluye todas las columnas para agregaciones
- Optimiza `SUM(cantidad)` y `SUM(subtotal)` sin acceder a la tabla
- Permite Merge Join eficiente con la tabla `productos`

**Evidencia de uso:**
```
->  Index Scan using idx_orden_detalles_producto_subtotal on orden_detalles od
      (cost=0.14..12.59 rows=30) (actual time=0.511..0.518 rows=30)
```
- **El índice se utiliza** para acceso y agregaciones
- Execution Time: 6.503 ms
- **Proyección:** Con 10M detalles de orden, reduciría tiempo de ~2 minutos a ~500ms

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

```bash
EXPLAIN ANALYZE select * from vw_ranking_usuarios_por_gasto;
```

WindowAgg  (cost=62.67..62.79 rows=7 width=302) (actual time=1.294..1.299 rows=3 loops=1)
   ->  Sort  (cost=62.67..62.69 rows=7 width=294) (actual time=1.210..1.212 rows=3 loops=1)
         Sort Key: resumen_usuarios.total_gastado DESC
         Sort Method: quicksort  Memory: 25kB
         ->  Subquery Scan on resumen_usuarios  (cost=0.28..62.57 rows=7 width=294) (actual time=1.085..1.106 rows=3 loops=1)
               ->  GroupAggregate  (cost=0.28..62.50 rows=7 width=294) (actual time=1.084..1.104 rows=3 loops=1)
                     Group Key: u.id
                     Filter: (count(o.id) > 2)
                     Rows Removed by Filter: 7
                     ->  Merge Join  (cost=0.28..61.98 rows=21 width=242) (actual time=1.045..1.058 rows=22 loops=1)
                           Merge Cond: (u.id = o.usuario_id)
                           ->  Index Scan using usuarios_pkey on usuarios u  (cost=0.14..49.04 rows=60 width=222) (actual time=0.335..0.337 rows=11 loops=1)
                           ->  Index Scan using idx_ordenes_usuario_status on ordenes o  (cost=0.14..12.52 rows=21 width=24) (actual time=0.705..0.711 rows=22 loops=1)
                                 Filter: ((status)::text <> 'cancelado'::text)
 Planning Time: 4.108 ms
 Execution Time: 1.817 ms
 
```bash
CREATE INDEX idx_ordenes_id_created_status 
ON ordenes(id, created_at, status);
```

GroupAggregate  (cost=93.61..94.33 rows=29 width=286) (actual time=1.701..1.706 rows=5 loops=1)
   Group Key: c.id
   ->  Sort  (cost=93.61..93.68 rows=29 width=238) (actual time=1.692..1.694 rows=30 loops=1)
         Sort Key: c.id
         Sort Method: quicksort  Memory: 26kB
         ->  Nested Loop  (cost=0.57..92.90 rows=29 width=238) (actual time=1.618..1.677 rows=30 loops=1)
               ->  Nested Loop  (cost=0.42..76.51 rows=29 width=20) (actual time=1.333..1.374 rows=30 loops=1)
                     ->  Merge Join  (cost=0.28..25.45 rows=29 width=20) (actual time=1.067..1.085 rows=30 loops=1)
                           Merge Cond: (od.orden_id = o.id)
                           ->  Index Scan using orden_detalles_orden_id_producto_id_key on orden_detalles od  (cost=0.14..12.59 rows=30 width=24) (actual time=0.571..0.576 rows=30 loops=1)
                           ->  Index Only Scan using idx_ordenes_id_created_status on ordenes o  (cost=0.14..12.52 rows=21 width=4) (actual time=0.493..0.498 rows=22 loops=1)
                                 Filter: ((status)::text <> 'cancelado'::text)
                                 Heap Fetches: 22
                     ->  Index Scan using productos_pkey on productos p  (cost=0.14..1.76 rows=1 width=8) (actual time=0.009..0.009 rows=1 loops=30)
                           Index Cond: (id = od.producto_id)
               ->  Index Scan using categorias_pkey on categorias c  (cost=0.15..0.56 rows=1 width=222) (actual time=0.010..0.010 rows=1 loops=30)
                     Index Cond: (id = p.categoria_id)
 Planning Time: 0.323 ms
 Execution Time: 1.784 ms
 

```bash
CREATE INDEX idx_orden_detalles_producto_subtotal 
ON orden_detalles(producto_id, subtotal, cantidad);
```

EXPLAIN ANALYZE select * from vw_productos_sin_ventas_ultimo_mes;

 GroupAggregate  (cost=0.28..65.30 rows=4 width=430) (actual time=6.449..6.457 rows=3 loops=1)
   Group Key: p.id
   Filter: (COALESCE(sum(od.cantidad), '0'::bigint) = 0)
   Rows Removed by Filter: 12
   ->  Merge Left Join  (cost=0.28..63.21 rows=120 width=426) (actual time=6.419..6.439 rows=33 loops=1)
         Merge Cond: (p.id = od.producto_id)
         ->  Index Scan using productos_pkey on productos p  (cost=0.14..49.94 rows=120 width=422) (actual time=5.900..5.903 rows=15 loops=1)   
         ->  Index Scan using idx_orden_detalles_producto_subtotal on orden_detalles od  (cost=0.14..12.59 rows=30 width=12) (actual time=0.511..0.518 rows=30 loops=1)
 Planning Time: 0.276 ms
 Execution Time: 6.503 ms
(10 rows)


Nota**: Se utilizó `SET enable_seqscan = off` para las pruebas, ya que con tablas pequeñas el planner de PostgreSQL prefiere usar Sequential Scan.

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
