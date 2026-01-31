-- Rol solo para vistas
CREATE ROLE just_vw_role;

-- Usuario de vistas
CREATE USER vw_user WITH PASSWORD 'annara10';

-- Relación entre ellos
GRANT just_vw_role TO vw_user;

-- Permiso para conexion con BD
GRANT CONNECT ON DATABASE tarea5 TO just_vw_role;

-- Permiso para usar el esquema 
GRANT USAGE ON SCHEMA public TO just_vw_role;

-- Quitar permisos en tablas
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM just_vw_role;

-- Permisos en vistas
GRANT SELECT ON
  vw_ranking_usuarios_por_gasto,
  vw_categorias_con_mas_ventas,
  vw_productos_mas_vendidos_por_categoria,
  vw_productos_sin_ventas_ultimo_mes,
  vw_ventas_totales_por_categoria
TO just_vw_role;

-- Permisos para nuevas vistas
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT ON TABLES TO just_vw_role;
