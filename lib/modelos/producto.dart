// Modelo de la tabla "producto".
// Importante: aqui NO guardamos el stock. El stock se calcula sumando y
// restando las filas de la tabla "movimiento" (ver ProductoRepositorio).
class Producto {
  int? id;
  String nombre;
  int categoriaId;
  int proveedorId;
  int stockMinimo;

  Producto({
    this.id,
    required this.nombre,
    required this.categoriaId,
    required this.proveedorId,
    required this.stockMinimo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'categoria_id': categoriaId,
      'proveedor_id': proveedorId,
      'stock_minimo': stockMinimo,
    };
  }

  factory Producto.fromMap(Map<String, dynamic> mapa) {
    return Producto(
      id: mapa['id'] as int?,
      nombre: mapa['nombre'] as String,
      categoriaId: mapa['categoria_id'] as int,
      proveedorId: mapa['proveedor_id'] as int,
      stockMinimo: mapa['stock_minimo'] as int,
    );
  }
}
