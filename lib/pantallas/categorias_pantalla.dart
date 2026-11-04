import 'package:flutter/material.dart';
import '../repositorios/categoria_repositorio.dart';
import '../modelos/categoria.dart';

class CategoriasPantalla extends StatefulWidget {
  const CategoriasPantalla({super.key});

  @override
  State<CategoriasPantalla> createState() => _CategoriasPantallaState();
}

class _CategoriasPantallaState extends State<CategoriasPantalla> {
  final _repo = CategoriaRepositorio();
  List<Categoria> _categorias = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final lista = await _repo.obtenerTodos();
    setState(() => _categorias = lista);
  }

  void _mostrarDialogoNueva() {
    final controladorTexto = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva categoria'),
        content: TextField(
          controller: controladorTexto,
          decoration: const InputDecoration(labelText: 'Nombre'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              if (controladorTexto.text.trim().isEmpty) return;
              await _repo.insertar(Categoria(nombre: controladorTexto.text.trim()));
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
      appBar: AppBar(title: const Text('Categorias')),
      body: ListView.builder(
        itemCount: _categorias.length,
        itemBuilder: (context, indice) {
          final categoria = _categorias[indice];
          return ListTile(
            leading: const Icon(Icons.category),
            title: Text(categoria.nombre),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await _repo.eliminar(categoria.id!);
                _cargar();
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: _mostrarDialogoNueva, child: const Icon(Icons.add)),
    );
  }
}
