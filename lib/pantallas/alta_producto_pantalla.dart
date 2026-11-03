import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:componentes_stockar/componentes_stockar.dart';

import '../controladores/productos_controlador.dart';
import '../modelos/producto.dart';

class AltaProductoPantalla extends StatefulWidget {
  const AltaProductoPantalla({super.key});

  @override
  State<AltaProductoPantalla> createState() => _AltaProductoPantallaState();
}

class _AltaProductoPantallaState extends State<AltaProductoPantalla> {
  final _formKey = GlobalKey<FormState>();
  final _controladorNombre = TextEditingController();

  int? _categoriaId;
  int? _proveedorId;
  int _stockMinimo = 10;
  Producto? _productoExistente;
  bool _yaCargado = false;

  // Si venimos de "Editar" (ficha_producto_pantalla pasa el id como
  // argumento), rellenamos el formulario con los datos del producto.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_yaCargado) return;
    _yaCargado = true;

    final idArgumento = ModalRoute.of(context)!.settings.arguments as int?;
    if (idArgumento != null) {
      final controlador = context.read<ProductosControlador>();
      _productoExistente = controlador.productos.firstWhere((p) => p.id == idArgumento);
      _controladorNombre.text = _productoExistente!.nombre;
      _categoriaId = _productoExistente!.categoriaId;
      _proveedorId = _productoExistente!.proveedorId;
      _stockMinimo = _productoExistente!.stockMinimo;
    }
  }

  @override
  void dispose() {
    _controladorNombre.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<ProductosControlador>();

    return Scaffold(
      appBar: AppBar(title: Text(_productoExistente == null ? 'Nuevo producto' : 'Editar producto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _controladorNombre,
                decoration: const InputDecoration(labelText: 'Nombre del producto'),
                validator: (valor) => (valor == null || valor.trim().isEmpty) ? 'El nombre es obligatorio' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _categoriaId,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: controlador.categorias.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nombre))).toList(),
                onChanged: (valor) => setState(() => _categoriaId = valor),
                validator: (valor) => valor == null ? 'Elige una categoria' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _proveedorId,
                decoration: const InputDecoration(labelText: 'Proveedor'),
                items: controlador.proveedores.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombre))).toList(),
                onChanged: (valor) => setState(() => _proveedorId = valor),
                validator: (valor) => valor == null ? 'Elige un proveedor' : null,
              ),
              const SizedBox(height: 24),
              const Text('Stock minimo'),
              const SizedBox(height: 8),
              // Componente propio del proyecto (RA3): selector de cantidad.
              QuantityStepper(
                valor: _stockMinimo,
                minimo: 0,
                maximo: 1000,
                onChanged: (nuevoValor) => setState(() => _stockMinimo = nuevoValor),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _guardar,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final producto = Producto(
      id: _productoExistente?.id,
      nombre: _controladorNombre.text.trim(),
      categoriaId: _categoriaId!,
      proveedorId: _proveedorId!,
      stockMinimo: _stockMinimo,
    );

    await context.read<ProductosControlador>().guardarProducto(producto);
    if (mounted) Navigator.pop(context);
  }
}
