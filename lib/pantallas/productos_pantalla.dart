import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../controladores/productos_controlador.dart';
import '../modelos/producto.dart';

class ProductosPantalla extends StatefulWidget {
  const ProductosPantalla({super.key});

  @override
  State<ProductosPantalla> createState() => _ProductosPantallaState();
}

class _ProductosPantallaState extends State<ProductosPantalla> {
  String _textoBusqueda = '';

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<ProductosControlador>();
    final lista = controlador.buscar(_textoBusqueda);

    // Atajo de teclado para escritorio: Ctrl + N abre el formulario de
    // alta de producto. Lo hemos copiado de la documentacion de Flutter
    // sobre Shortcuts y Actions.
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN): const ActivateIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (intent) {
              Navigator.pushNamed(context, '/alta-producto');
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            appBar: AppBar(title: const Text('Productos')),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Buscar producto',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (texto) {
                      setState(() => _textoBusqueda = texto);
                    },
                  ),
                ),
                Expanded(
                  child: controlador.cargando
                      ? const Center(child: CircularProgressIndicator())
                      : controlador.error != null
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  'No se han podido cargar los productos:\n${controlador.error}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            )
                          : ListView.builder(
                          itemCount: lista.length,
                          itemBuilder: (context, indice) => _filaProducto(context, controlador, lista[indice]),
                        ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, '/alta-producto'),
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ),
    );
  }

  Widget _filaProducto(BuildContext context, ProductosControlador controlador, Producto producto) {
    final stock = controlador.stockDe(producto.id!);
    final bajoMinimo = stock < producto.stockMinimo;

    // Dismissible: deslizar para borrar (el evento de GestureDetector que
    // pide el enunciado como ejemplo).
    return Dismissible(
      key: ValueKey(producto.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direccion) => controlador.borrarProducto(producto.id!),
      child: GestureDetector(
        // Pulsacion larga en movil, clic derecho en escritorio: los dos
        // abren el mismo menu contextual (editar / borrar).
        onLongPress: () => _abrirMenuContextual(context, producto, const Offset(100, 300)),
        onSecondaryTapDown: (detalles) => _abrirMenuContextual(context, producto, detalles.globalPosition),
        child: ListTile(
          leading: Icon(Icons.inventory_2, color: bajoMinimo ? Colors.red : null),
          title: Text(producto.nombre),
          subtitle: Text('Stock: $stock · Minimo: ${producto.stockMinimo}'),
          onTap: () => Navigator.pushNamed(context, '/ficha-producto', arguments: producto.id),
        ),
      ),
    );
  }

  void _abrirMenuContextual(BuildContext context, Producto producto, Offset posicion) async {
    final opcion = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(posicion.dx, posicion.dy, posicion.dx, posicion.dy),
      items: const [
        PopupMenuItem(value: 'editar', child: Text('Editar')),
        PopupMenuItem(value: 'borrar', child: Text('Borrar')),
      ],
    );

    if (!context.mounted) return;

    if (opcion == 'editar') {
      Navigator.pushNamed(context, '/alta-producto', arguments: producto.id);
    } else if (opcion == 'borrar') {
      context.read<ProductosControlador>().borrarProducto(producto.id!);
    }
  }
}
