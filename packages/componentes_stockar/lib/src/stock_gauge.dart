import 'package:flutter/material.dart';

/// Funcion que se llama cuando el stock representado pasa a estar por
/// debajo del minimo. Se usa, por ejemplo, para avisar al usuario.
typedef AvisoStockBajo = void Function();

/// Barra que representa visualmente el stock actual de un producto
/// comparado con su stock minimo.
///
/// El color cambia segun lo cerca que este el stock actual del minimo:
/// verde si hay margen, naranja si esta cerca, y rojo si ya esta por
/// debajo del minimo (y en ese caso se llama una vez a [onLowStock]).
///
/// Ejemplo de uso:
/// ```dart
/// StockGauge(
///   stockActual: 8,
///   stockMinimo: 10,
///   onLowStock: () => print('Stock bajo!'),
/// )
/// ```
class StockGauge extends StatefulWidget {
  /// Unidades que hay actualmente en el almacen. No puede ser negativo.
  final int stockActual;

  /// Unidades minimas que se quieren tener siempre. Debe ser mayor que 0.
  final int stockMinimo;

  /// Se llama una vez cuando [stockActual] pasa a estar por debajo de
  /// [stockMinimo]. Es opcional.
  final AvisoStockBajo? onLowStock;

  const StockGauge({
    super.key,
    required this.stockActual,
    required this.stockMinimo,
    this.onLowStock,
  })  : assert(stockActual >= 0, 'El stock actual no puede ser negativo'),
        assert(stockMinimo > 0, 'El stock minimo debe ser mayor que 0');

  @override
  State<StockGauge> createState() => _StockGaugeState();
}

class _StockGaugeState extends State<StockGauge> {
  bool _avisoYaLanzado = false;

  @override
  void initState() {
    super.initState();
    _comprobarStockBajo();
  }

  @override
  void didUpdateWidget(StockGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stockActual != widget.stockActual) {
      _avisoYaLanzado = false;
      _comprobarStockBajo();
    }
  }

  void _comprobarStockBajo() {
    if (widget.stockActual < widget.stockMinimo && !_avisoYaLanzado) {
      _avisoYaLanzado = true;
      widget.onLowStock?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    // El maximo de la barra es el doble del minimo, para que se vea bien
    // tanto si hay mucho stock como si hay poco.
    final maximoBarra = widget.stockMinimo * 2;
    final proporcion = (widget.stockActual / maximoBarra).clamp(0.0, 1.0);

    Color color;
    if (widget.stockActual < widget.stockMinimo) {
      color = Colors.red;
    } else if (widget.stockActual < widget.stockMinimo * 1.3) {
      color = Colors.orange;
    } else {
      color = Colors.green;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Stock: ${widget.stockActual} / minimo ${widget.stockMinimo}'),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: proporcion,
            minHeight: 16,
            color: color,
            backgroundColor: color.withOpacity(0.2),
          ),
        ),
      ],
    );
  }
}
