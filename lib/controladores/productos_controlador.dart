import 'package:flutter/foundation.dart';
import '../modelos/producto.dart';
import '../modelos/categoria.dart';
import '../modelos/proveedor.dart';
import '../repositorios/producto_repositorio.dart';
import '../repositorios/categoria_repositorio.dart';
import '../repositorios/proveedor_repositorio.dart';

// Esto es el "controlador" del patron MVC: las pantallas (la Vista) lo
// escuchan y se repintan solas cuando algo cambia, gracias a
// ChangeNotifier y notifyListeners().
class ProductosControlador extends ChangeNotifier {
  final ProductoRepositorio _productoRepo = ProductoRepositorio();
  final CategoriaRepositorio _categoriaRepo = CategoriaRepositorio();
  final ProveedorRepositorio _proveedorRepo = ProveedorRepositorio();

  List<Producto> productos = [];
  List<Categoria> categorias = [];
  List<Proveedor> proveedores = [];
  Map<int, int> stockActual = {};
  bool cargando = false;
  String? error;

  Future<void> cargarTodo() async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      productos = await _productoRepo.obtenerTodos();
      categorias = await _categoriaRepo.obtenerTodos();
      proveedores = await _proveedorRepo.obtenerTodos();
      stockActual = await _productoRepo.obtenerStockActual();
    } catch (e) {
      // Si algo falla (por ejemplo, la base de datos no esta disponible),
      // guardamos el error para poder mostrarlo en pantalla en vez de
      // dejar la lista vacia sin explicacion.
      error = e.toString();
    }

    cargando = false;
    notifyListeners();
  }

  int stockDe(int productoId) => stockActual[productoId] ?? 0;

  String nombreCategoria(int id) {
    final encontrada = categorias.where((c) => c.id == id);
    return encontrada.isEmpty ? '' : encontrada.first.nombre;
  }

  String nombreProveedor(int id) {
    final encontrado = proveedores.where((p) => p.id == id);
    return encontrado.isEmpty ? '' : encontrado.first.nombre;
  }

  Future<void> guardarProducto(Producto producto) async {
    if (producto.id == null) {
      await _productoRepo.insertar(producto);
    } else {
      await _productoRepo.actualizar(producto);
    }
    await cargarTodo();
  }

  Future<void> borrarProducto(int id) async {
    await _productoRepo.eliminar(id);
    await cargarTodo();
  }

  List<Producto> buscar(String texto) {
    if (texto.isEmpty) return productos;
    final textoMinusculas = texto.toLowerCase();
    return productos.where((p) => p.nombre.toLowerCase().contains(textoMinusculas)).toList();
  }
}
