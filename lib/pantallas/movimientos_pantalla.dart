import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../controladores/movimientos_controlador.dart';
import '../controladores/productos_controlador.dart';
import '../modelos/movimiento.dart';

class MovimientosPantalla extends StatefulWidget {
  const MovimientosPantalla({super.key});

  @override
  State<MovimientosPantalla> createState() => _MovimientosPantallaState();
}

class _MovimientosPantallaState extends State<MovimientosPantalla> {
  StreamSubscription<AccelerometerEvent>? _suscripcionAcelerometro;
  DateTime _ultimaAgitacion = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    // Escuchamos el acelerometro para detectar cuando se agita el movil.
    // Si la suma de los tres ejes supera un umbral, lo tomamos como una
    // agitacion (es una forma muy sencilla de hacerlo, pero funciona).
    _suscripcionAcelerometro = accelerometerEventStream().listen((evento) {
      final fuerza = evento.x.abs() + evento.y.abs() + evento.z.abs();
      final ahora = DateTime.now();
      if (fuerza > 30 && ahora.difference(_ultimaAgitacion) > const Duration(seconds: 2)) {
        _ultimaAgitacion = ahora;
        _confirmarDeshacer();
      }
    });
  }

  @override
  void dispose() {
    _suscripcionAcelerometro?.cancel();
    super.dispose();
  }

  void _confirmarDeshacer() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hemos notado que agitas el movil'),
        content: const Text('¿Quieres deshacer el ultimo movimiento registrado?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Si, deshacer')),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      final deshecho = await context.read<MovimientosControlador>().deshacerUltimo();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(deshecho ? 'Movimiento deshecho' : 'No hay movimientos que deshacer')),
        );
      }
    }
  }

  // Alternativa tactil al registro por voz: un formulario sencillo.
  void _mostrarDialogoNuevoMovimiento() {
    final productosControlador = context.read<ProductosControlador>();
    int? productoId = productosControlador.productos.isNotEmpty ? productosControlador.productos.first.id : null;
    String tipo = 'entrada';
    final controladorUnidades = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, actualizar) => AlertDialog(
          title: const Text('Nuevo movimiento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: productoId,
                decoration: const InputDecoration(labelText: 'Producto'),
                items: productosControlador.productos
                    .map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombre)))
                    .toList(),
                onChanged: (valor) => actualizar(() => productoId = valor),
              ),
              DropdownButtonFormField<String>(
                value: tipo,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: const [
                  DropdownMenuItem(value: 'entrada', child: Text('Entrada')),
                  DropdownMenuItem(value: 'salida', child: Text('Salida')),
                ],
                onChanged: (valor) => actualizar(() => tipo = valor ?? 'entrada'),
              ),
              TextField(
                controller: controladorUnidades,
                decoration: const InputDecoration(labelText: 'Unidades'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            TextButton(
              onPressed: () async {
                final unidades = int.tryParse(controladorUnidades.text) ?? 0;
                if (productoId == null || unidades <= 0) return;

                await context.read<MovimientosControlador>().registrarMovimiento(Movimiento(
                      productoId: productoId!,
                      tipo: tipo,
                      unidades: unidades,
                      fecha: DateTime.now().toIso8601String(),
                    ));
                await productosControlador.cargarTodo();
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<MovimientosControlador>();

    return Scaffold(
      appBar: AppBar(title: const Text('Movimientos')),
      body: ListView.builder(
        itemCount: controlador.movimientos.length,
        itemBuilder: (context, indice) {
          final movimiento = controlador.movimientos[indice];
          final esEntrada = movimiento['tipo'] == 'entrada';
          return ListTile(
            leading: Icon(
              esEntrada ? Icons.arrow_downward : Icons.arrow_upward,
              color: esEntrada ? Colors.green : Colors.red,
            ),
            title: Text(movimiento['producto_nombre'] as String),
            subtitle: Text('${movimiento['tipo']} de ${movimiento['unidades']} unidades'),
            trailing: Text((movimiento['fecha'] as String).substring(0, 10)),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'manual',
            icon: const Icon(Icons.edit),
            label: const Text('Manual'),
            onPressed: _mostrarDialogoNuevoMovimiento,
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'voz',
            icon: const Icon(Icons.mic),
            label: const Text('Por voz'),
            onPressed: () => Navigator.pushNamed(context, '/nuevo-movimiento-voz'),
          ),
        ],
      ),
    );
  }
}
