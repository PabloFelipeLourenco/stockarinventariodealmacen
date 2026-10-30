import '../bd/ayudante_bd.dart';
import '../modelos/producto.dart';

class ProductoRepositorio {
  final AyudanteBD _ayudanteBD = AyudanteBD();

  Future<int> insertar(Producto producto) async {
    final db = await _ayudanteBD.bd;
    return await db.insert('producto', producto.toMap());
  }

  Future<List<Producto>> obtenerTodos() async {
    final db = await _ayudanteBD.bd;
    final filas = await db.query('producto', orderBy: 'nombre');
    return filas.map((fila) => Producto.fromMap(fila)).toList();
  }

  Future<Producto?> obtenerPorId(int id) async {
    final db = await _ayudanteBD.bd;
    final filas = await db.query('producto', where: 'id = ?', whereArgs: [id]);
    if (filas.isEmpty) return null;
    return Producto.fromMap(filas.first);
  }

  Future<int> actualizar(Producto producto) async {
    final db = await _ayudanteBD.bd;
    return await db.update(
      'producto',
      producto.toMap(),
      where: 'id = ?',
      whereArgs: [producto.id],
    );
  }

  Future<int> eliminar(int id) async {
    final db = await _ayudanteBD.bd;
    return await db.delete('producto', where: 'id = ?', whereArgs: [id]);
  }

  // Consulta con agregado (RA de Bloque C.5): calculamos el stock actual de
  // cada producto sumando las entradas y restando las salidas registradas
  // en la tabla movimiento. Como no guardamos el stock en "producto", esta
  // es la unica forma de saberlo.
  Future<Map<int, int>> obtenerStockActual() async {
    final db = await _ayudanteBD.bd;
    final filas = await db.rawQuery('''
      SELECT producto_id,
        SUM(CASE WHEN tipo = 'entrada' THEN unidades ELSE -unidades END) AS stock
      FROM movimiento
      GROUP BY producto_id
    ''');

    final mapa = <int, int>{};
    for (final fila in filas) {
      mapa[fila['producto_id'] as int] = (fila['stock'] as int?) ?? 0;
    }
    return mapa;
  }

  // Consulta con JOIN (RA de Bloque C.5): productos cuyo stock esta por
  // debajo del minimo, junto con el nombre del proveedor al que hay que
  // pedirlos. La usa la pantalla de Alertas de stock.
  Future<List<Map<String, dynamic>>> obtenerProductosBajoMinimo() async {
    final db = await _ayudanteBD.bd;
    return await db.rawQuery('''
      SELECT p.id, p.nombre, p.stock_minimo, prov.nombre AS proveedor_nombre,
        COALESCE(SUM(CASE WHEN m.tipo = 'entrada' THEN m.unidades ELSE -m.unidades END), 0) AS stock
      FROM producto p
      JOIN proveedor prov ON prov.id = p.proveedor_id
      LEFT JOIN movimiento m ON m.producto_id = p.id
      GROUP BY p.id
      HAVING stock < p.stock_minimo
    ''');
  }
}
