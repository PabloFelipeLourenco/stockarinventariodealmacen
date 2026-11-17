import 'package:flutter/foundation.dart';
import '../modelos/movimiento.dart';
import '../repositorios/movimiento_repositorio.dart';

class MovimientosControlador extends ChangeNotifier {
  final MovimientoRepositorio _repo = MovimientoRepositorio();

  List<Map<String, dynamic>> movimientos = [];
  Movimiento? ultimoMovimiento;
  String? error;

  Future<void> cargarTodo() async {
    try {
      movimientos = await _repo.obtenerTodosConProducto();
      ultimoMovimiento = await _repo.obtenerUltimo();
      error = null;
    } catch (e) {
      error = e.toString();
    }
    notifyListeners();
  }

  Future<void> registrarMovimiento(Movimiento movimiento) async {
    await _repo.insertar(movimiento);
    await cargarTodo();
  }

  // La usamos cuando el usuario agita el movil: borra el ultimo
  // movimiento registrado. Devuelve true si se ha podido deshacer.
  Future<bool> deshacerUltimo() async {
    if (ultimoMovimiento == null || ultimoMovimiento!.id == null) return false;
    await _repo.eliminar(ultimoMovimiento!.id!);
    await cargarTodo();
    return true;
  }
}
