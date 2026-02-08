"use server";

import { pool } from "../../../../lib/db";
import { Report3Schema } from "./schema";

export interface ProductoMasVendido {
  categoria: string;
  producto: string;
  total_unidades: number;
  total_ventas: number;
}

export async function getProductosMasVendidos(rawParams: unknown) {
  try {
    const { categoria, page, limit } = Report3Schema.parse(rawParams);
    const offset = (page - 1) * limit;

    let q = `
      SELECT *
      FROM vw_productos_mas_vendidos_por_categoria
    `;

    const params: (string | number)[] = [limit, offset]; 

    if (categoria) {
      params.push(categoria); 
      q += ` WHERE categoria = $${params.length}`;
    }

    q += ` LIMIT $1 OFFSET $2`;

    const result = await pool.query<ProductoMasVendido>(q, params);

    return { ok: true, data: result.rows };
  } catch (err) {
    console.error("Error al mostrar productos mas vendidos", err);
    return { ok: false, error: "Error en productos mas vendidos" };
  }
}
