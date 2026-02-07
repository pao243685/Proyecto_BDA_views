import { pool } from "../../../lib/db";

export async function GET() {
  try {
    const result = await pool.query("SELECT NOW()");
    return Response.json({
      ok: true,
      db_time: result.rows[0].now,
    });
  } catch (error) {
    return Response.json({
      ok: false,
      error: "fallo al conectar a la base de datos",
    });
  }
}
