-- ============================================
-- 1. CATEGORÍAS
-- ============================================

INSERT INTO categorias (nombre, descripcion) VALUES
    ('Electrónica', 'Dispositivos electrónicos y accesorios'),
    ('Ropa', 'Vestimenta y accesorios de moda'),
    ('Hogar', 'Artículos para el hogar y decoración'),
    ('Deportes', 'Equipamiento y ropa deportiva'),
    ('Libros', 'Libros físicos y digitales');

-- ============================================
-- 2. USUARIOS (10 + edge case)
-- ============================================

INSERT INTO usuarios (email, nombre, password_hash) VALUES
    ('luna.sanchez@example.com', 'Luna Sánchez', 'hash_1'),
    ('mateo.rios@example.com', 'Mateo Ríos', 'hash_2'),
    ('sofia.mendoza@example.com', 'Sofía Mendoza', 'hash_3'),
    ('diego.martinez@example.com', 'Diego Martínez', 'hash_4'),
    ('valeria.castillo@example.com', 'Valeria Castillo', 'hash_5'),
    ('nicolas.torres@example.com', 'Nicolás Torres', 'hash_6'),
    ('camila.perez@example.com', 'Camila Pérez', 'hash_7'),
    ('julian.rodriguez@example.com', 'Julián Rodríguez', 'hash_8'),
    ('mariana.lopez@example.com', 'Mariana López', 'hash_9'),
    ('sebastian.vargas@example.com', 'Sebastián Vargas', 'hash_10'),

    -- Edge case
    ('usuario.muy.largo@subdominio.empresa.ejemplo.com',
     'Nombre Muy Largo Para Probar Límites en la Base de Datos',
     'hash_11');

-- ============================================
-- 3. PRODUCTOS
-- ============================================

INSERT INTO productos (codigo, nombre, descripcion, precio, stock, categoria_id) VALUES
    -- Electrónica
    ('ELEC-001', 'Laptop Pro 15"', 'Laptop de alto rendimiento', 1299.99, 50, 1),
    ('ELEC-002', 'Mouse Inalámbrico', 'Mouse Bluetooth', 29.99, 200, 1),
    ('ELEC-003', 'Teclado Mecánico', 'RGB switches azules', 89.99, 75, 1),
    ('ELEC-004', 'Monitor 27"', '4K IPS', 399.99, 30, 1),
    ('ELEC-005', 'Webcam HD', '1080p con micrófono', 59.99, 100, 1),
    ('ELEC-006', 'Audífonos ANC', 'Cancelación activa', 129.99, 80, 1),

    -- Ropa
    ('ROPA-001', 'Camiseta Básica', 'Algodón 100%', 19.99, 500, 2),
    ('ROPA-002', 'Jeans Clásico', 'Mezclilla azul', 49.99, 200, 2),
    ('ROPA-003', 'Sudadera Tech', 'Con capucha', 39.99, 150, 2),

    -- Hogar
    ('HOME-001', 'Lámpara LED', 'Regulable', 34.99, 80, 3),
    ('HOME-002', 'Silla Ergonómica', 'Ajustable', 249.99, 25, 3),

    -- Deportes
    ('SPORT-001', 'Balón de Fútbol', 'Profesional', 34.99, 90, 4),
    ('SPORT-002', 'Mancuernas 10kg', 'Par de mancuernas', 59.99, 40, 4),

    -- Libros
    ('BOOK-001', 'Clean Code', 'Robert C. Martin', 39.99, 120, 5),

    -- Edge case
    ('EDGE-001', 'Producto Gratuito', 'Precio 0 y stock 0', 0.00, 0, 1);

-- ============================================
-- 4. ÓRDENES (varias por usuario)
-- ============================================

INSERT INTO ordenes (usuario_id, total, status) VALUES
    (1, 1419.97, 'entregado'),
    (1, 399.99, 'pagado'),
    (1, 29.99, 'pendiente'),

    (2, 69.98, 'enviado'),
    (2, 129.99, 'entregado'),

    (3, 284.98, 'pagado'),
    (3, 59.99, 'pendiente'),

    (4, 89.98, 'pendiente'),
    (4, 49.99, 'entregado'),

    (5, 1299.99, 'pagado'),
    (5, 19.99, 'entregado'),

    (6, 159.98, 'entregado'),
    (6, 399.99, 'pendiente'),
    (6, 39.99, 'pagado'),

    (7, 399.99, 'enviado'),
    (7, 89.99, 'entregado'),

    (8, 84.98, 'pendiente'),
    (8, 19.99, 'entregado'),

    (9, 524.97, 'pagado'),
    (9, 129.99, 'pagado'),
    (9, 59.99, 'enviado'),

    (10, 1299.99, 'entregado');

-- ============================================
-- 5. DETALLES DE ÓRDENES
-- ============================================

INSERT INTO orden_detalles (orden_id, producto_id, cantidad, precio_unitario) VALUES
    -- Luna (usuario 1)
    (1, 1, 1, 1299.99),
    (1, 2, 1, 29.99),
    (1, 3, 1, 89.99),

    (2, 4, 1, 399.99),

    (3, 2, 1, 29.99),

    -- Mateo (usuario 2)
    (4, 7, 2, 19.99),
    (4, 5, 1, 59.99),

    (5, 6, 1, 129.99),

    -- Sofía (usuario 3)
    (6, 12, 1, 249.99),
    (6, 11, 1, 34.99),

    (7, 5, 1, 59.99),

    -- Diego (usuario 4)
    (8, 8, 1, 49.99),
    (8, 9, 1, 39.99),

    (9, 8, 1, 49.99),

    -- Valeria (usuario 5)
    (10, 1, 1, 1299.99),

    (11, 7, 1, 19.99),

    -- Nicolás (usuario 6)
    (12, 6, 1, 129.99),
    (12, 14, 1, 29.99),

    (13, 4, 1, 399.99),

    (14, 3, 1, 39.99),

    -- Camila (usuario 7)
    (15, 4, 1, 399.99),

    (16, 3, 1, 89.99),

    -- Julián (usuario 8)
    (17, 3, 1, 89.99),

    (18, 7, 1, 19.99),

    -- Mariana (usuario 9)
    (19, 3, 1, 89.99),
    (19, 4, 1, 399.99),
    (19, 2, 1, 29.99),

    (20, 6, 1, 129.99),

    (21, 5, 1, 59.99),

    -- Sebastián (usuario 10)
    (22, 1, 1, 1299.99);
