import { getUsuariosFrecuentes } from "./actions";

export default async function Reporte1Page() {
  const { ok, data, error } = await getUsuariosFrecuentes();

  if (!ok) return <div>Error: {error}</div>;

  const totalGastado = data!.reduce(
    (acc, row) => acc + Number(row.total_gastado),
    0
  );

  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold">Reporte 1 - Usuarios frecuentes y su gasto total</h1>
      <p className="text-gray-600">Ranking de usuarios que más han comprado.</p>

      <h3 className="text-xl font-semibold mt-4">
        KPI: Total gastado acumulado: ${totalGastado}
      </h3>

      <table className="mt-6 border-collapse border w-full">
        <thead>
          <tr className="bg-green-200">
            <th className="border px-4 py-2">Usuario</th>
            <th className="border px-4 py-2">Ordenes</th>
            <th className="border px-4 py-2">Total Gastado</th>
            <th className="border px-4 py-2">Promedio</th>
            <th className="border px-4 py-2">Ranking</th>
          </tr>
        </thead>

        <tbody>
          {data!.map((u) => (
            <tr key={u.usuario_id}>
              <td className="border px-4 py-2">{u.usuario_nombre}</td>
              <td className="border px-4 py-2">{u.total_ordenes}</td>
              <td className="border px-4 py-2">${u.total_gastado}</td>
              <td className="border px-4 py-2">${u.promedio_por_orden}</td>
              <td className="border px-4 py-2">{u.ranking_por_gasto}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
