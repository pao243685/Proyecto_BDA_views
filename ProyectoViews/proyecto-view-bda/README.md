# Tarea 6: Lab Reportes - Next.js Dashboard con PostgreSQL

# Descripción del Proyecto

Aplicación Next.js que visualiza reportes SQL mediante VIEWS de PostgreSQL, la aplicación se ejecuta con Docker Compose y utiliza un usuario de base de datos con permisos mínimos



# Justificación de Índices

Para mejorar el rendimiento de las VIEWS se crearon los siguientes indices, cada índice fue probado con EXPLAIN para observar cómo optimiza el plan de ejecución, esto se encuetra en el archivo de 04_indexes.sql

## 1. Índice `idx_ordenes_usuario_status`

```sql
CREATE INDEX idx_ordenes_usuario_status
ON ordenes(usuario_id, status);
```
- VIEW beneficiada: vw_ranking_usuarios_por_gasto

- Optimiza el JOIN entre ordenes y usuarios mediante usuario_id.
- Permite filtrar directamente por status sin recorrer toda la tabla.
- Reduce las filas procesadas antes de agrupar GROUP BY.

## 2. Índice `idx_orden_detalles_producto_orden`

```sql
CREATE INDEX idx_orden_detalles_producto_orden
ON orden_detalles(producto_id, orden_id);
```
- VIEWS beneficiadas: vw_productos_mas_vendidos_por_categoria, vw_categorias_con_mas_ventas, vw_ventas_totales_por_categoria

- Optimiza los JOIN de orden_detalles con productos (producto_id) y con ordenes (orden_id)
- Reduce el número de filas intermedias antes de agregaciones y rankings

## 3. Índice `idx_productos_categoria_activo`

```sql
CREATE INDEX idx_productos_categoria_activo
ON productos(categoria_id)
WHERE categoria_id IS NOT NULL;
```
- VIEW beneficiada: vw_productos_mas_vendidos_por_categoria,vw_categorias_con_mas_ventas, vw_ventas_totales_por_categoria

- Optimiza los JOIN entre productos y categorias
- Evita procesar productos sin categoria
- Reduce las filas procesadas antes de rankings



# Ejecutar el proyecto

1. **Clonar el repositorio** 
```bash
git clone https://github.com/pao243685/Proyecto_BDA_views.git
```

2. **Levantar los servicios**
```bash
docker compose up --build
```

3. **Detener los servicios**
```bash
docker compose down
```
