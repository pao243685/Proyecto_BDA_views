export default function Home() {
  const reports = [
    { id: 1, name: "Usuarios frecuentes y gasto total" },
    { id: 2, name: "Categorías con más ventas (con filtro)" },
    { id: 3, name: "Productos más vendidos (paginación)" },
    { id: 4, name: "Productos sin ventas último mes" },
    { id: 5, name: "Ventas totales por categoría" },
  ];

  return (
    <main className="p-8">
      <h1 className="text-3xl font-bold mb-4">Dashaaaaboard</h1>
      <p className="text-gray-700 mb-6">Selecciona un reporte para visualizar datos.</p>

      <ul className="space-y-3">
        {reports.map((r) => (
          <li key={r.id}>
            <a className="text-blue-600 underline" href={`/reports/${r.id}`}>
              {r.name}
            </a>
          </li>
        ))}
      </ul>
    </main>
  );
}
