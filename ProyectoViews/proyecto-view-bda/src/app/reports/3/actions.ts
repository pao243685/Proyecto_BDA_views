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

    const whereClauses: string[] = [];
    const params: (string|number)[] = [];

    if (categoria) {
      params.push(categoria);
      whereClauses.push(`categoria = $${params.length}`);
    }


    const whereSQL = whereClauses.length > 0 ? "WHERE " + whereClauses.join(" AND ") : "";

    params.push(limit);
    params.push(offset);

    const q = `
      SELECT *
      FROM vw_productos_mas_vendidos_por_categoria
      ${whereSQL}
      LIMIT $${params.length - 1} OFFSET $${params.length};
    `;

    const result = await pool.query<ProductoMasVendido>(q, params);

    return { ok: true, data: result.rows };

  } catch (err) {
    console.error("Error al mostrar productos mas vendidos", err);
    return { ok: false, error: "Error en productos mas vendidos" };
  }
}
