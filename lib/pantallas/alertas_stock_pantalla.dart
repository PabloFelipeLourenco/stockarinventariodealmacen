import 'package:flutter/material.dart';
import '../repositorios/producto_repositorio.dart';

class AlertasStockPantalla extends StatefulWidget {
  const AlertasStockPantalla({super.key});

  @override
  State<AlertasStockPantalla> createState() => _AlertasStockPantallaState();
}

class _AlertasStockPantallaState extends State<AlertasStockPantalla> {
  final _repo = ProductoRepositorio();
  List<Map<String, dynamic>> _productosBajoMinimo = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final lista = await _repo.obtenerProductosBajoMinimo();
    setState(() => _productosBajoMinimo = lista);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alertas de stock')),
      body: _productosBajoMinimo.isEmpty
          ? const Center(child: Text('No hay productos bajo minimos'))
          : RefreshIndicator(
              onRefresh: _cargar,
              child: ListView.builder(
                itemCount: _productosBajoMinimo.length,
                itemBuilder: (context, indice) {
                  final fila = _productosBajoMinimo[indice];
                  return ListTile(
                    leading: const Icon(Icons.warning_amber, color: Colors.red),
                    title: Text(fila['nombre'] as String),
                    subtitle: Text('Stock: ${fila['stock']} · Minimo: ${fila['stock_minimo']}'),
                    trailing: Text('Pedir a:\n${fila['proveedor_nombre']}', textAlign: TextAlign.right),
                  );
                },
              ),
            ),
    );
  }
}
