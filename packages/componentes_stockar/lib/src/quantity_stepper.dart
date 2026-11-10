import 'package:flutter/material.dart';

/// Se llama cada vez que el usuario cambia el valor con los botones + o -.
typedef ValueChangedInt = ValueChanged<int>;

/// Control sencillo con un boton para restar, el numero en medio y un
/// boton para sumar. Se usa para elegir cantidades, por ejemplo el stock
/// minimo de un producto o las unidades de un movimiento.
///
/// Ejemplo de uso:
/// ```dart
/// QuantityStepper(
///   valor: cantidad,
///   minimo: 0,
///   maximo: 100,
///   onChanged: (nuevoValor) => setState(() => cantidad = nuevoValor),
/// )
/// ```
class QuantityStepper extends StatelessWidget {
  /// Valor actual mostrado.
  final int valor;

  /// Valor minimo permitido.
  final int minimo;

  /// Valor maximo permitido. Debe ser mayor que [minimo].
  final int maximo;

  /// Cuanto suma o resta cada pulsacion. Por defecto 1.
  final int step;

  /// Se llama con el nuevo valor cada vez que el usuario pulsa + o -.
  final ValueChangedInt onChanged;

  const QuantityStepper({
    super.key,
    required this.valor,
    required this.onChanged,
    this.minimo = 0,
    this.maximo = 999,
    this.step = 1,
  }) : assert(maximo > minimo, 'El maximo debe ser mayor que el minimo');

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: valor - step >= minimo ? () => onChanged(valor - step) : null,
        ),
        SizedBox(
          width: 50,
          child: Text(
            '$valor',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: valor + step <= maximo ? () => onChanged(valor + step) : null,
        ),
      ],
    );
  }
}
