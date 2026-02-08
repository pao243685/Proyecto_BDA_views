
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


-- VIEW: vw_categorias_por_crecimiento
-- Qué devuelve:
--   Todas las categorías con ventas del mes actual y del mes anterior,
--   y el porcentaje de crecimiento mensual.
-- Grain:
--   1 fila representa 1 categoría
-- Métricas:
--   ventas_mes_actual, ventas_mes_anterior, porcentaje_crecimiento
-- Por qué GROUP BY / CTE:
--   Se agrupa por categoría y mes para calcular totales,
--   luego se compara mes actual vs mes anterior para obtener el crecimiento.
-- VERIFY:
--   SELECT * FROM vw_categorias_por_crecimiento
--   ORDER BY porcentaje_crecimiento DESC
--   LIMIT 10;



CREATE OR REPLACE VIEW vw_categorias_por_crecimiento AS
WITH ventas_por_mes AS (
    SELECT
        c.id AS categoria_id,
        c.nombre AS nombre_categoria,
        DATE_TRUNC('month', o.created_at) AS mes,
        SUM(od.subtotal) AS total_ventas
    FROM categorias c
    JOIN productos p ON p.categoria_id = c.id
    JOIN orden_detalles od ON od.producto_id = p.id
    JOIN ordenes o ON o.id = od.orden_id
    WHERE o.status <> 'cancelado'
    GROUP BY c.id, c.nombre, DATE_TRUNC('month', o.created_at)
),
ventas_actual_anterior AS (
    SELECT
        c.categoria_id,
        c.nombre_categoria,
        COALESCE(v_actual.total_ventas,0) AS ventas_mes_actual,
        COALESCE(v_anterior.total_ventas,0) AS ventas_mes_anterior,
        CASE 
            WHEN COALESCE(v_anterior.total_ventas,0) = 0 
                THEN 0
            ELSE ((v_actual.total_ventas - v_anterior.total_ventas) / v_anterior.total_ventas::numeric) * 100
        END AS porcentaje_crecimiento
    FROM (SELECT DISTINCT categoria_id, nombre_categoria FROM ventas_por_mes) c
    LEFT JOIN ventas_por_mes v_actual
        ON c.categoria_id = v_actual.categoria_id
       AND v_actual.mes = DATE_TRUNC('month', CURRENT_DATE)
    LEFT JOIN ventas_por_mes v_anterior
        ON c.categoria_id = v_anterior.categoria_id
       AND v_anterior.mes = DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
)
SELECT *
FROM ventas_actual_anterior
ORDER BY porcentaje_crecimiento DESC;




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
