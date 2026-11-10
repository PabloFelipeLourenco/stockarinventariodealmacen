import '../bd/ayudante_bd.dart';
import '../modelos/categoria.dart';

class CategoriaRepositorio {
  final AyudanteBD _ayudanteBD = AyudanteBD();

  Future<int> insertar(Categoria categoria) async {
    final db = await _ayudanteBD.bd;
    return await db.insert('categoria', categoria.toMap());
  }

  Future<List<Categoria>> obtenerTodos() async {
    final db = await _ayudanteBD.bd;
    final filas = await db.query('categoria', orderBy: 'nombre');
    return filas.map((fila) => Categoria.fromMap(fila)).toList();
  }

  Future<int> eliminar(int id) async {
    final db = await _ayudanteBD.bd;
    return await db.delete('categoria', where: 'id = ?', whereArgs: [id]);
  }
}
