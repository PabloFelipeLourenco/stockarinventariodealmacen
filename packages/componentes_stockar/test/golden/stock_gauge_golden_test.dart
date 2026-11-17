import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:componentes_stockar/componentes_stockar.dart';

// Prueba golden: compara el aspecto del componente con una imagen de
// referencia. La primera vez hay que generar esa imagen con:
//   flutter test --update-goldens
void main() {
  testWidgets('StockGauge con stock bajo minimo (golden)', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: StockGauge(stockActual: 15, stockMinimo: 20),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(StockGauge),
      matchesGoldenFile('stock_gauge_bajo_minimo.png'),
    );
  });
}
