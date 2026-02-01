import { getProductosSinVentas } from "./actions";

export default async function Reporte4Page(){
    const { ok, data, error } = await getProductosSinVentas();
    if (!ok) return <div>Error: {error}</div>;

    const totalProductosSinVentas = data!.length;

    return (
        <div className="p-8">
            <h1 className="text-2xl font-bold"> Reporte 4 - Productos sin ventas en el último mes</h1>
            <p className="text-gray-600"> Lista de productos que no han tenido ventas en los últimos 30 días </p>
            <div className="mt-4 p-4 rounded w-max">
                <h3 className="text-lg font-semibold"> KPI: Total Productos Sin Ventas:  {totalProductosSinVentas}</h3>
                
            </div>
            <table className="mt-6 border-collapse border w-full">
                <thead>
                    <tr className="bg-green-200">
                        <th className="border px-4 py-2">producto_id</th>
                        <th className="border px-4 py-2">Producto</th>
                        <th className="border px-4 py-2">Unidades vendidas</th>
                    </tr>
                </thead>
                <tbody>
                    {data!.map((p) => (
                        <tr key={p.producto_id}>
                            <td className="border px-4 py-2">{p.producto_id}</td>
                            <td className="border px-4 py-2">{p.producto}</td>
                            <td className="border px-4 py-2">{p.unidades_vendidas}</td>
                        </tr>
                    ))}
                </tbody>
            </table>
        </div>
    );
}