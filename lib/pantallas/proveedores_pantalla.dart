import 'package:flutter/material.dart';
import '../repositorios/proveedor_repositorio.dart';
import '../modelos/proveedor.dart';

class ProveedoresPantalla extends StatefulWidget {
  const ProveedoresPantalla({super.key});

  @override
  State<ProveedoresPantalla> createState() => _ProveedoresPantallaState();
}

class _ProveedoresPantallaState extends State<ProveedoresPantalla> {
  final _repo = ProveedorRepositorio();
  List<Proveedor> _proveedores = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final lista = await _repo.obtenerTodos();
    setState(() => _proveedores = lista);
  }

  void _mostrarDialogoNuevo() {
    final controladorNombre = TextEditingController();
    final controladorTelefono = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo proveedor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: controladorNombre, decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(controller: controladorTelefono, decoration: const InputDecoration(labelText: 'Telefono')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              if (controladorNombre.text.trim().isEmpty) return;
              await _repo.insertar(Proveedor(
                nombre: controladorNombre.text.trim(),
                telefono: controladorTelefono.text.trim(),
              ));
              if (context.mounted) Navigator.pop(context);
              _cargar();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proveedores')),
      body: ListView.builder(
        itemCount: _proveedores.length,
        itemBuilder: (context, indice) {
          final proveedor = _proveedores[indice];
          return ListTile(
            leading: const Icon(Icons.local_shipping),
            title: Text(proveedor.nombre),
            subtitle: Text(proveedor.telefono ?? ''),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await _repo.eliminar(proveedor.id!);
                _cargar();
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: _mostrarDialogoNuevo, child: const Icon(Icons.add)),
    );
  }
}
