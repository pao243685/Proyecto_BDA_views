
-- VIEW: vw_ranking_usuarios_por_gasto
-- Qué devuelve:
--   Usuarios frecuentes con métricas de órdenes y ranking por gasto total
-- Grain:
--   1 fila representa 1 usuario
-- Métricas:
--   total_ordenes, total_gastado, promedio_por_orden, ranking_por_gasto
-- Por qué GROUP BY / HAVING:
--   Se agrupa por usuario para calcular métricas agregadas
--   y se filtran usuarios con más de 3 órdenes
-- VERIFY:
--   SELECT * FROM vw_ranking_usuarios_por_gasto LIMIT 5;
--   SELECT COUNT(*) FROM vw_ranking_usuarios_por_gasto;


CREATE OR REPLACE VIEW vw_ranking_usuarios_por_gasto AS
WITH resumen_usuarios AS (
  SELECT
    u.id AS usuario_id,
    u.nombre AS usuario_nombre,
    COUNT(o.id) AS total_ordenes,
    SUM(o.total) AS total_gastado,
    AVG(o.total) AS promedio_por_orden
  FROM usuarios u
  JOIN ordenes o ON o.usuario_id = u.id
  WHERE o.status <> 'cancelado'
  GROUP BY u.id, u.nombre
)
SELECT
  usuario_id,
  usuario_nombre,
  total_ordenes,
  total_gastado,
  promedio_por_orden,
  RANK() OVER (ORDER BY total_gastado DESC) AS ranking_por_gasto
FROM resumen_usuarios
WHERE total_ordenes > 2;


-- VIEW: vw_categorias_con_mas_ventas
-- Qué devuelve:
--   Categorías con ventas totales significativas
-- Grain:
--   1 fila representa 1 categoría
-- Métricas:
--   total_ventas, total_unidades
-- Por qué GROUP BY / HAVING:
--   Se agrupa por categoría y se filtran aquellas con ventas significativas
-- VERIFY:
--   SELECT * FROM vw_categorias_con_mas_ventas;


CREATE OR REPLACE VIEW vw_categorias_con_mas_ventas AS
SELECT
  c.id AS categoria_id,
  c.nombre AS nombre_categoria,
  SUM(od.subtotal) AS total_ventas,
  SUM(od.cantidad) AS total_unidades
FROM categorias c
JOIN productos p ON p.categoria_id = c.id
JOIN orden_detalles od ON od.producto_id = p.id
JOIN ordenes o ON o.id = od.orden_id
WHERE o.status <> 'cancelado'
GROUP BY c.id, c.nombre
HAVING SUM(od.subtotal) > 500;



-- VIEW: vw_productos_mas_vendidos_por_categoria
-- Qué devuelve:
--   Productos más vendidos dentro de cada categoría
-- Grain:
--   1 fila representa 1 producto por categoría
-- Métricas:
--   total_unidades, total_ventas, ranking_categoria
-- Por qué GROUP BY:
--   Se agrupa por producto para calcular ventas
-- VERIFY:
--   SELECT * FROM vw_productos_mas_vendidos_por_categoria LIMIT 5;


CREATE OR REPLACE VIEW vw_productos_mas_vendidos_por_categoria AS
SELECT
  c.nombre AS categoria,
  p.id AS producto_id,
  p.nombre AS producto,
  SUM(od.cantidad) AS total_unidades,
  SUM(od.subtotal) AS total_ventas,
  RANK() OVER (
    PARTITION BY c.id
    ORDER BY SUM(od.subtotal) DESC
  ) AS ranking_categoria
FROM categorias c
JOIN productos p ON p.categoria_id = c.id
JOIN orden_detalles od ON od.producto_id = p.id
JOIN ordenes o ON o.id = od.orden_id
WHERE o.status <> 'cancelado'
GROUP BY c.id, c.nombre, p.id, p.nombre;
ORDER BY total_unidades DESC;


-- VIEW: vw_productos_sin_ventas_ultimo_mes
-- Qué devuelve:
--   Productos que no han tenido ventas en el último mes
-- Grain:
--   1 fila representa 1 producto
-- Métricas:
--   unidades_vendidas
-- Por qué GROUP BY:
--   Se agrupa por producto para evaluar ventas recientes
-- VERIFY:
--   SELECT * FROM vw_productos_sin_ventas_ultimo_mes;


CREATE OR REPLACE VIEW vw_productos_sin_ventas_ultimo_mes AS
SELECT
  p.id AS producto_id,
  p.nombre AS producto,
  COALESCE(SUM(od.cantidad), 0) AS unidades_vendidas
FROM productos p
LEFT JOIN orden_detalles od ON od.producto_id = p.id
LEFT JOIN ordenes o 
  ON o.id = od.orden_id
  AND o.created_at >= CURRENT_DATE - INTERVAL '1 month'
GROUP BY p.id, p.nombre
HAVING COALESCE(SUM(od.cantidad), 0) = 0;



-- VIEW: vw_ventas_totales_por_categoria
-- Qué devuelve:
--   Ventas totales por categoría con clasificación de desempeño
-- Grain:
--   1 fila representa 1 categoría
-- Métricas:
--   total_ventas, nivel_ventas
-- Por qué GROUP BY:
--   Se agrupa por categoría para calcular ventas totales
-- VERIFY:
--   SELECT * FROM vw_ventas_totales_por_categoria;


CREATE OR REPLACE VIEW vw_ventas_totales_por_categoria AS
SELECT
  c.id AS categoria_id,
  c.nombre AS categoria,
  SUM(od.subtotal) AS total_ventas,
  CASE
    WHEN SUM(od.subtotal) >= 5000 THEN 'ALTA'
    WHEN SUM(od.subtotal) >= 2000 THEN 'MEDIA'
    ELSE 'BAJA'
  END AS nivel_ventas
FROM categorias c
JOIN productos p ON p.categoria_id = c.id
JOIN orden_detalles od ON od.producto_id = p.id
JOIN ordenes o ON o.id = od.orden_id
WHERE o.status <> 'cancelado'
GROUP BY c.id, c.nombre;
