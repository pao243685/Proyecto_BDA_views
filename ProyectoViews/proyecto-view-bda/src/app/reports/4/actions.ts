"use server";

import { pool } from "../../../../lib/db";

export interface ProductoSinVenta {
  producto_id: string;
  producto: string;
  unidades_vendidas: number;
}

export async function getProductosSinVentas(): Promise<{
    ok: boolean;
    data?:ProductoSinVenta[];
    error?:string;
}>{
  try{
    const q = `SELECT * FROM
    vw_productos_sin_ventas_ultimo_mes;`;

    const result = await pool.query<ProductoSinVenta>(q);

    return {ok: true, data: result.rows};
  } catch (err) {
    console.error("Error al mostrar productos sin ventas", err);
    return { ok: false, error: "Error en productos sin ventas"};
  }
}