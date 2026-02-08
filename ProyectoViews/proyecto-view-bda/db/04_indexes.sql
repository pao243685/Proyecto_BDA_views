

CREATE INDEX idx_ordenes_usuario_status ON ordenes(usuario_id, status);

CREATE INDEX idx_orden_detalles_producto_orden ON orden_detalles(producto_id, orden_id);

CREATE INDEX idx_productos_categoria_activo ON productos(categoria_id) 
WHERE categoria_id IS NOT NULL;


