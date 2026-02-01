"use server";

import { pool } from "../../../../lib/db";
import { Report5Schema } from "./schema";

export interface VentasPorCategoria {
  categoria: string;
  total_ventas: number;
  nivel_ventas: "ALTA" | "MEDIA" | "BAJA";
}

export async function getVentasPorCategoria(rawParams: unknown): Promise<{
    ok: boolean;
    data?:VentasPorCategoria[];
    error?:string;
}>{
  try{
     const { nivelVentas } = Report5Schema.parse(rawParams);

    let whereSQL = "";
    const params: string[] = [];

    if (nivelVentas) {
      params.push(nivelVentas);
      whereSQL = "WHERE nivel_ventas = $1";
    }
    const q = `SELECT * FROM
    vw_ventas_totales_por_categoria
    ${whereSQL};`;

    const result = await pool.query<VentasPorCategoria>(q, params);

    return {ok: true, data: result.rows};
  } catch (err) {
    console.error("Error al mostrar ventas por categoria", err);
    return { ok: false, error: "Error en ventas por categoria"};
  }
}