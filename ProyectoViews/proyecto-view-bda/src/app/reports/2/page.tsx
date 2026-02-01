import { getCategoriasConMasVentas } from "./actions";
import { Report2Schema } from "./schema";

interface Reporte2PageProps {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}

export default async function Reporte2Page({ searchParams }: Reporte2PageProps) {
  const params = Report2Schema.parse(await searchParams);

  const { ok, data, error } = await getCategoriasConMasVentas(params);
  if (!ok || !data) return <div>Error: {error}</div>;

  const totalVentas = data.reduce(
    (acc, row) => acc + Number(row.total_ventas),
    0
  );

  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold">
        Reporte 2 - Categorías con mas ventas
      </h1>
      <p className="text-gray-600">
        Ranking de categorías con mayores ventas con paginacion
      </p>

      <div className="mt-4 grid grid-cols-2 gap-4">
        <div className=" p-4 rounded">
          <h3 className="text-lg font-semibold">
            KPI: Total Ventas ${totalVentas.toFixed(2)}
          </h3>
          
        </div>
      </div>

      <form method="get" className="mt-6 p-4 border rounded bg-gray-50">
        <p className="font-semibold mb-3">Paginación:</p>
        <div className="flex gap-4 items-center flex-wrap">
          <div className="flex flex-col">
            <label htmlFor="page" className="text-sm mb-1">
              Página:
            </label>
            <input
              id="page"
              name="page"
              type="number"
              min="1"
              defaultValue={params.page}
              placeholder="Página"
              className="px-3 py-2 border rounded w-24"
            />
          </div>

          <div className="flex flex-col">
            <label htmlFor="limit" className="text-sm mb-1">
              Límite:
            </label>
            <input
              id="limit"
              name="limit"
              type="number"
              min="5"
              max="50"
              defaultValue={params.limit}
              placeholder="Límite"
              className="px-3 py-2 border rounded w-24"
            />
          </div>

          <button
            type="submit"
            className="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700 mt-auto"
          >
            Aplicar
          </button>
        </div>
      </form>

      <table className="mt-6 border-collapse border w-full">
        <thead>
          <tr className="bg-green-200">
            <th className="border px-4 py-2">Categoría</th>
            <th className="border px-4 py-2">Total Ventas</th>
            <th className="border px-4 py-2">Total Unidades</th>
          </tr>
        </thead>

        <tbody>
          {data.map((c) => (
            <tr key={c.nombre_categoria}>
              <td className="border px-4 py-2">{c.nombre_categoria}</td>
              <td className="border px-4 py-2">${c.total_ventas}</td>
              <td className="border px-4 py-2">{c.total_unidades}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
