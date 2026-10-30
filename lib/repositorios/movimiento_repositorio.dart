import '../bd/ayudante_bd.dart';
import '../modelos/movimiento.dart';

class MovimientoRepositorio {
  final AyudanteBD _ayudanteBD = AyudanteBD();

  Future<int> insertar(Movimiento movimiento) async {
    final db = await _ayudanteBD.bd;
    return await db.insert('movimiento', movimiento.toMap());
  }

  // JOIN con producto para poder mostrar el nombre del producto en la
  // lista de movimientos, en vez de solo su id.
  Future<List<Map<String, dynamic>>> obtenerTodosConProducto() async {
    final db = await _ayudanteBD.bd;
    return await db.rawQuery('''
      SELECT m.id, m.tipo, m.unidades, m.fecha, p.nombre AS producto_nombre
      FROM movimiento m
      JOIN producto p ON p.id = m.producto_id
      ORDER BY m.fecha DESC
    ''');
  }

  Future<Movimiento?> obtenerUltimo() async {
    final db = await _ayudanteBD.bd;
    final filas = await db.query('movimiento', orderBy: 'id DESC', limit: 1);
    if (filas.isEmpty) return null;
    return Movimiento.fromMap(filas.first);
  }

  Future<int> eliminar(int id) async {
    final db = await _ayudanteBD.bd;
    return await db.delete('movimiento', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> obtenerStockDeProducto(int productoId) async {
    final db = await _ayudanteBD.bd;
    final filas = await db.rawQuery('''
      SELECT COALESCE(SUM(CASE WHEN tipo = 'entrada' THEN unidades ELSE -unidades END), 0) AS stock
      FROM movimiento
      WHERE producto_id = ?
    ''', [productoId]);
    return (filas.first['stock'] as int?) ?? 0;
  }
}
