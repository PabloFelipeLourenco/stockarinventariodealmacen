import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:componentes_stockar/componentes_stockar.dart';

void main() {
  testWidgets('StockGauge muestra el stock actual y el minimo', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StockGauge(stockActual: 25, stockMinimo: 10),
        ),
      ),
    );

    expect(find.text('Stock: 25 / minimo 10'), findsOneWidget);
  });

  testWidgets('StockGauge llama a onLowStock cuando el stock esta por debajo del minimo', (tester) async {
    var avisado = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StockGauge(
            stockActual: 2,
            stockMinimo: 10,
            onLowStock: () => avisado = true,
          ),
        ),
      ),
    );

    expect(avisado, isTrue);
  });

  testWidgets('StockGauge NO llama a onLowStock si el stock esta por encima del minimo', (tester) async {
    var avisado = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StockGauge(
            stockActual: 50,
            stockMinimo: 10,
            onLowStock: () => avisado = true,
          ),
        ),
      ),
    );

    expect(avisado, isFalse);
  });

  test('StockGauge no permite un stock minimo de 0 o negativo', () {
    expect(
      () => StockGauge(stockActual: 5, stockMinimo: 0),
      throwsAssertionError,
    );
  });

  test('StockGauge no permite un stock actual negativo', () {
    expect(
      () => StockGauge(stockActual: -1, stockMinimo: 10),
      throwsAssertionError,
    );
  });
}
