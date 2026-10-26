import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:componentes_stockar/componentes_stockar.dart';

import '../controladores/productos_controlador.dart';
import 'realidad_aumentada_pantalla.dart';

class FichaProductoPantalla extends StatelessWidget {
  const FichaProductoPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final productoId = ModalRoute.of(context)!.settings.arguments as int;
    final controlador = context.watch<ProductosControlador>();
    final producto = controlador.productos.firstWhere((p) => p.id == productoId);
    final stock = controlador.stockDe(productoId);

    return Scaffold(
      appBar: AppBar(title: Text(producto.nombre)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Categoria: ${controlador.nombreCategoria(producto.categoriaId)}'),
            Text('Proveedor: ${controlador.nombreProveedor(producto.proveedorId)}'),
            Text('Stock minimo: ${producto.stockMinimo}'),
            const SizedBox(height: 24),
            // Componente propio del proyecto (RA3): barra de stock.
            StockGauge(
              stockActual: stock,
              stockMinimo: producto.stockMinimo,
              onLowStock: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Atencion: este producto esta bajo minimos')),
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.view_in_ar),
              label: const Text('Ver etiqueta en la estanteria'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RealidadAumentadaPantalla(
                      nombreProducto: producto.nombre,
                      stock: stock,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Editar'),
              onPressed: () => Navigator.pushNamed(context, '/alta-producto', arguments: producto.id),
            ),
          ],
        ),
      ),
    );
  }
}
