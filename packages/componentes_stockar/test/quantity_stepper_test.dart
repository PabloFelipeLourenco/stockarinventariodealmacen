import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:componentes_stockar/componentes_stockar.dart';

void main() {
  testWidgets('QuantityStepper muestra el valor inicial', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuantityStepper(valor: 5, onChanged: (_) {}),
        ),
      ),
    );

    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('QuantityStepper llama a onChanged al pulsar +', (tester) async {
    int? nuevoValor;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuantityStepper(
            valor: 5,
            onChanged: (valor) => nuevoValor = valor,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pump();

    expect(nuevoValor, 6);
  });

  testWidgets('QuantityStepper llama a onChanged al pulsar -', (tester) async {
    int? nuevoValor;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuantityStepper(
            valor: 5,
            onChanged: (valor) => nuevoValor = valor,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.remove_circle_outline));
    await tester.pump();

    expect(nuevoValor, 4);
  });

  testWidgets('QuantityStepper no deja bajar del minimo', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuantityStepper(valor: 0, minimo: 0, onChanged: (_) {}),
        ),
      ),
    );

    final botonMenos = tester.widget<IconButton>(find.byIcon(Icons.remove_circle_outline));
    expect(botonMenos.onPressed, isNull);
  });

  test('QuantityStepper no permite un maximo menor o igual que el minimo', () {
    expect(
      () => QuantityStepper(valor: 5, minimo: 10, maximo: 10, onChanged: (_) {}),
      throwsAssertionError,
    );
  });
}
