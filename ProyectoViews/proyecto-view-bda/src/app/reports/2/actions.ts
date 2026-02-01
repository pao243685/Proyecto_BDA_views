"use server";

import { pool } from "../../../../lib/db";
import { Report2Schema } from "./schema";

export interface CategoriaVenta {
  nombre_categoria: string;
  total_ventas: number;
  total_unidades: number;
}

export async function getCategoriasConMasVentas(rawParams: unknown): Promise<{
  ok: boolean;
  data?: CategoriaVenta[];
  error?: string;
}> {
  try {
    const { page, limit } = Report2Schema.parse(rawParams);

    const offset = (page - 1) * limit;

    const params: number[] = [limit, offset];

    const q = `
      SELECT *
      FROM vw_categorias_con_mas_ventas
      LIMIT $1 OFFSET $2;
    `;

    const result = await pool.query<CategoriaVenta>(q, params);

    return { ok: true, data: result.rows };
  } catch (err) {
    console.error("Error al mostrar categorias con mas ventas:", err);
    return { ok: false, error: "Error al mostraar categorias con mas ventas" };
  }
}