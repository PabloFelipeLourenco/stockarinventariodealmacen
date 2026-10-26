import 'package:flutter/material.dart';
import 'package:stockar/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../controladores/productos_controlador.dart';

class PanelPantalla extends StatelessWidget {
  const PanelPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context)!;
    final controlador = context.watch<ProductosControlador>();

    return Scaffold(
      appBar: AppBar(title: Text(textos.panel)),
      drawer: _menuLateral(context, textos),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warehouse, size: 80, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            if (controlador.error != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'No se ha podido cargar la base de datos:\n${controlador.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ] else ...[
              Text(
                textos.numeroDeProductos(controlador.productos.length),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(textos.ultimaActualizacion(DateTime.now())),
            ],
            const SizedBox(height: 24),
            const Text('Usa el menu de la izquierda para navegar'),
          ],
        ),
      ),
    );
  }

  Widget _menuLateral(BuildContext context, AppLocalizations textos) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
            child: Text(
              'StockAR',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2),
            title: Text(textos.productos),
            onTap: () => Navigator.pushNamed(context, '/productos'),
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: Text(textos.categorias),
            onTap: () => Navigator.pushNamed(context, '/categorias'),
          ),
          ListTile(
            leading: const Icon(Icons.local_shipping),
            title: Text(textos.proveedores),
            onTap: () => Navigator.pushNamed(context, '/proveedores'),
          ),
          ListTile(
            leading: const Icon(Icons.swap_vert),
            title: Text(textos.movimientos),
            onTap: () => Navigator.pushNamed(context, '/movimientos'),
          ),
          ListTile(
            leading: const Icon(Icons.mic),
            title: Text(textos.nuevoMovimientoVoz),
            onTap: () => Navigator.pushNamed(context, '/nuevo-movimiento-voz'),
          ),
          ListTile(
            leading: const Icon(Icons.warning_amber),
            title: Text(textos.alertasStock),
            onTap: () => Navigator.pushNamed(context, '/alertas-stock'),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(textos.ajustes),
            onTap: () => Navigator.pushNamed(context, '/ajustes'),
          ),
        ],
      ),
    );
  }
}
