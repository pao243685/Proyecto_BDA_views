

CREATE INDEX idx_ordenes_usuario_status ON ordenes(usuario_id, status);
/*

Sin Indice

HashAggregate  (cost=35.83..36.58 rows=60 width=44) (actual time=0.170..0.178 rows=10 loops=1)
   Group Key: u.id
   Batches: 1  Memory Usage: 24kB
   ->  Hash Join  (cost=11.35..31.06 rows=637 width=24) (actual time=0.148..0.155 rows=22 loops=1)
         Hash Cond: (o.usuario_id = u.id)
         ->  Seq Scan on ordenes o  (cost=0.00..18.00 rows=637 width=24) (actual time=0.073..0.076 rows=22 loops=1)
               Filter: ((status)::text <> 'cancelado'::text)       
         ->  Hash  (cost=10.60..10.60 rows=60 width=4) (actual time=0.051..0.051 rows=11 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 9kB        
               ->  Seq Scan on usuarios u  (cost=0.00..10.60 rows=60 width=4) (actual time=0.030..0.031 rows=11 loops=1)
 Planning Time: 0.475 ms
 Execution Time: 0.269 ms
 */
/*

Con Indice


  HashAggregate  (cost=12.73..12.99 rows=21 width=44) (actual time=0.082..0.085 rows=10 loops=1)
   Group Key: u.id
   Batches: 1  Memory Usage: 24kB
   ->  Hash Join  (cost=1.54..12.57 rows=21 width=24) (actual time=0.067..0.071 rows=22 loops=1)
         Hash Cond: (u.id = o.usuario_id)
         ->  Seq Scan on usuarios u  (cost=0.00..10.60 rows=60 width=4) (actual time=0.017..0.018 rows=11 loops=1)
         ->  Hash  (cost=1.27..1.27 rows=21 width=24) (actual time=0.029..0.029 rows=22 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 10kB       
               ->  Seq Scan on ordenes o  (cost=0.00..1.27 rows=21 width=24) (actual time=0.018..0.021 rows=22 loops=1)
                     Filter: ((status)::text <> 'cancelado'::text) 
 Planning Time: 0.544 ms
 Execution Time: 0.172 ms
 */

CREATE INDEX idx_orden_detalles_producto_orden ON orden_detalles(producto_id, orden_id);


 /* 

Sin Indice

  Limit  (cost=48.20..48.32 rows=10 width=458) (actual time=0.190..0.194 rows=10 loops=1)
   ->  HashAggregate  (cost=48.20..49.70 rows=120 width=458) (actual time=0.189..0.192 rows=10 loops=1)
         Group Key: p.nombre
         Batches: 1  Memory Usage: 40kB
         ->  Hash Join  (cost=14.24..40.54 rows=1021 width=438) (actual time=0.164..0.174 rows=30 loops=1)
               Hash Cond: (od.producto_id = p.id)
               ->  Hash Join  (cost=1.54..25.10 rows=1021 width=24) (actual time=0.115..0.122 rows=30 loops=1)
                     Hash Cond: (od.orden_id = o.id)
                     ->  Seq Scan on orden_detalles od  (cost=0.00..20.70 rows=1070 width=28) (actual time=0.051..0.052 rows=30 loops=1)
                     ->  Hash  (cost=1.27..1.27 rows=21 width=4) (actual time=0.030..0.030 rows=22 loops=1)
                           Buckets: 1024  Batches: 1  Memory Usage: 9kB
                           ->  Seq Scan on ordenes o  (cost=0.00..1.27 rows=21 width=4) (actual time=0.019..0.021 rows=22 loops=1)    
                                 Filter: ((status)::text <> 'cancelado'::text)
               ->  Hash  (cost=11.20..11.20 rows=120 width=422) (actual time=0.030..0.030 rows=15 loops=1)
                     Buckets: 1024  Batches: 1  Memory Usage: 9kB  
                     ->  Seq Scan on productos p  (cost=0.00..11.20 rows=120 width=422) (actual time=0.015..0.016 rows=15 loops=1)    
 Planning Time: 0.799 ms
 Execution Time: 0.324 ms


 Con Indice
 
 Limit  (cost=15.47..15.59 rows=10 width=458) (actual time=0.132..0.136 rows=10 loops=1)
   ->  HashAggregate  (cost=15.47..15.83 rows=29 width=458) (actual time=0.131..0.134 rows=10 loops=1)
         Group Key: p.nombre
         Batches: 1  Memory Usage: 24kB
         ->  Hash Join  (cost=3.21..15.25 rows=29 width=438) (actual time=0.107..0.117 rows=30 loops=1)
               Hash Cond: (od.orden_id = o.id)
               ->  Hash Join  (cost=1.68..13.63 rows=30 width=442) (actual time=0.060..0.065 rows=30 loops=1)
                     Hash Cond: (p.id = od.producto_id)
                     ->  Seq Scan on productos p  (cost=0.00..11.20 rows=120 width=422) (actual time=0.014..0.015 rows=15 loops=1)    
                     ->  Hash  (cost=1.30..1.30 rows=30 width=28) (actual time=0.024..0.024 rows=30 loops=1)
                           Buckets: 1024  Batches: 1  Memory Usage: 10kB
                           ->  Seq Scan on orden_detalles od  (cost=0.00..1.30 rows=30 width=28) (actual time=0.013..0.016 rows=30 loops=1)
               ->  Hash  (cost=1.27..1.27 rows=21 width=4) (actual time=0.032..0.032 rows=22 loops=1)
                     Buckets: 1024  Batches: 1  Memory Usage: 9kB  
                     ->  Seq Scan on ordenes o  (cost=0.00..1.27 rows=21 width=4) (actual time=0.022..0.024 rows=22 loops=1)
                           Filter: ((status)::text <> 'cancelado'::text)
 Planning Time: 1.133 ms
 Execution Time: 0.267 ms
 */

CREATE INDEX idx_productos_categoria_activo ON productos(categoria_id) 
WHERE categoria_id IS NOT NULL;

/*

Sin indice 

 HashAggregate  (cost=28.32..29.51 rows=119 width=226) (actual time=0.078..0.080 rows=5 loops=1)
   Group Key: c.nombre
   Batches: 1  Memory Usage: 40kB
   ->  Hash Join  (cost=12.69..27.73 rows=119 width=222) (actual time=0.066..0.069 rows=15 loops=1)
         Hash Cond: (c.id = p.categoria_id)
         ->  Seq Scan on categorias c  (cost=0.00..12.80 rows=280 width=222) (actual time=0.021..0.022 rows=5 loops=1)
         ->  Hash  (cost=11.20..11.20 rows=119 width=8) (actual time=0.020..0.021 rows=15 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 9kB        
               ->  Seq Scan on productos p  (cost=0.00..11.20 rows=119 width=8) (actual time=0.010..0.012 rows=15 loops=1)
                     Filter: (categoria_id IS NOT NULL)
 Planning Time: 0.663 ms
 Execution Time: 0.192 ms

*/

