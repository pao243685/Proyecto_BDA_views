import { getProductosMasVendidos } from "./actions";
import { Report3Schema } from "./schema";

interface Reporte3PageProps {
    searchParams: Promise<Record<string, string | string[] | undefined>>;
}

export default async function Reporte3Page({ searchParams }: Reporte3PageProps) {
    const params = Report3Schema.parse(await searchParams);

    const { ok, data, error } = await getProductosMasVendidos(params);
    if (!ok || !data) return <div>Error: {error}</div>;

    const totalProductos = data.reduce(
        (acc, row) => acc + Number(row.total_unidades),
        0
    );

    return (
        <div className="p-8">
            <h1 className="text-2xl font-bold">
                Reporte 3 - Productos más vendidos por categoría
            </h1>

            <p className="text-gray-600">
                Muestra los productos con mayores unidades vendidas filtrados por categoría
                con paginacion.
            </p>

            <h3 className="text-xl font-semibold mt-4">
                KPI: Total unidades vendidas: {totalProductos}
            </h3>

            <form method="get" className="mt-6 p-4 border rounded bg-gray-50">
                <p className="font-semibold mb-3">Filtros y Paginación:</p>
                <div className="flex gap-4 items-center flex-wrap">
                    <div className="flex flex-col">
                        <label htmlFor="categoria" className="text-sm mb-1">
                            Categoría:
                        </label>
                        <input
                            id="categoria"
                            name="categoria"
                            type="text"
                            defaultValue={params.categoria || ""}
                            placeholder="Ej: Electrónica"
                            className="px-3 py-2 border rounded w-40"
                        />
                    </div>

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
                        Aplicar Filtros
                    </button>
                </div>
            </form>

            {(params.categoria) && (
                <div className="mt-4 p-3 rounded">
                    <ul className="text-sm mt-1">
                        {params.categoria && <li>Categoría: {params.categoria}</li>}
                    </ul>
                </div>
            )}

            <table className="mt-6 border-collapse border w-full">
                <thead>
                    <tr className="bg-green-200">
                        <th className="border px-4 py-2">Producto</th>
                        <th className="border px-4 py-2">Categoría</th>
                        <th className="border px-4 py-2">Unidades</th>
                        <th className="border px-4 py-2">Ventas Totales</th>
                    </tr>
                </thead>

                <tbody>
                    {data.length === 0 ? (
                        <tr>
                            <td colSpan={4} className="border px-4 py-2 text-center text-gray-500">
                                No se encontraron productos con los filtros aplicados
                            </td>
                        </tr>
                    ) : (
                        data.map((p) => (
                            <tr key={p.categoria + p.producto}>
                                <td className="border px-4 py-2">{p.producto}</td>
                                <td className="border px-4 py-2">{p.categoria}</td>
                                <td className="border px-4 py-2">{p.total_unidades}</td>
                                <td className="border px-4 py-2">${p.total_ventas}</td>
                            </tr>
                        ))
                    )}
                </tbody>
            </table>
        </div>  
    );
}