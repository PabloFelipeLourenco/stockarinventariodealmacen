import '../bd/ayudante_bd.dart';
import '../modelos/proveedor.dart';

class ProveedorRepositorio {
  final AyudanteBD _ayudanteBD = AyudanteBD();

  Future<int> insertar(Proveedor proveedor) async {
    final db = await _ayudanteBD.bd;
    return await db.insert('proveedor', proveedor.toMap());
  }

  Future<List<Proveedor>> obtenerTodos() async {
    final db = await _ayudanteBD.bd;
    final filas = await db.query('proveedor', orderBy: 'nombre');
    return filas.map((fila) => Proveedor.fromMap(fila)).toList();
  }

  Future<int> eliminar(int id) async {
    final db = await _ayudanteBD.bd;
    return await db.delete('proveedor', where: 'id = ?', whereArgs: [id]);
  }
}
