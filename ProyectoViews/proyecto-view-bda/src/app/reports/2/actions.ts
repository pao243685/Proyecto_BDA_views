"use server";

import { pool } from "../../../../lib/db";
import { Report2Schema } from "./schema";

export interface CategoriaCrecimiento {
  categoria_id: number;
  nombre_categoria: string;
  ventas_mes_actual: number;
  ventas_mes_anterior: number;
  porcentaje_crecimiento: number;
}

export async function getCategoriasPorCrecimiento(rawParams: unknown): Promise<{
  ok: boolean;
  data?: CategoriaCrecimiento[];
  error?: string;
}> {
  try {
    const { page, limit } = Report2Schema.parse(rawParams);
    const offset = (page - 1) * limit;

    const q = `
      SELECT *
      FROM vw_categorias_por_crecimiento
      LIMIT $1 OFFSET $2;
    `;

    const result = await pool.query<CategoriaCrecimiento>(q, [limit, offset]);

    return { ok: true, data: result.rows };
  } catch (err) {
    console.error("Error al mostrar categorías por crecimiento:", err);
    return { ok: false, error: "Error al mostrar categorías por crecimiento" };
  }
}
