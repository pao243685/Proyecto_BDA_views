
CREATE INDEX idx_ordenes_usuario_status 
ON ordenes(usuario_id, status);

/*
EXPLAIN ANALYZE select * from vw_ranking_usuarios_por_gasto;

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
 */


CREATE INDEX idx_ordenes_id_created_status 
ON ordenes(id, created_at, status);

/*


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
 */


CREATE INDEX idx_orden_detalles_producto_subtotal 
ON orden_detalles(producto_id, subtotal, cantidad);

/*
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
*/