import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:componentes_stockar/componentes_stockar.dart';

// Catalogo visual de nuestros componentes propios (RA3.a). Aqui se ven
// todos los estados de StockGauge y QuantityStepper sin tener que
// arrancar toda la app de StockAR.
void main() {
  runApp(const CatalogoWidgetbook());
}

class CatalogoWidgetbook extends StatelessWidget {
  const CatalogoWidgetbook({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetbookApp.material(
      directories: [
        WidgetbookCategory(
          name: 'Componentes StockAR',
          children: [
            WidgetbookComponent(
              name: 'StockGauge',
              useCases: [
                WidgetbookUseCase(
                  name: 'Stock con margen (verde)',
                  builder: (context) => const Padding(
                    padding: EdgeInsets.all(16),
                    child: StockGauge(stockActual: 40, stockMinimo: 20),
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Stock cerca del minimo (naranja)',
                  builder: (context) => const Padding(
                    padding: EdgeInsets.all(16),
                    child: StockGauge(stockActual: 24, stockMinimo: 20),
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Stock bajo minimo (rojo)',
                  builder: (context) => const Padding(
                    padding: EdgeInsets.all(16),
                    child: StockGauge(stockActual: 8, stockMinimo: 20),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'QuantityStepper',
              useCases: [
                WidgetbookUseCase(
                  name: 'Valor intermedio',
                  builder: (context) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: QuantityStepper(valor: 10, minimo: 0, maximo: 20, onChanged: (_) {}),
                  ),
                ),
                WidgetbookUseCase(
                  name: 'En el minimo (boton - desactivado)',
                  builder: (context) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: QuantityStepper(valor: 0, minimo: 0, maximo: 20, onChanged: (_) {}),
                  ),
                ),
                WidgetbookUseCase(
                  name: 'En el maximo (boton + desactivado)',
                  builder: (context) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: QuantityStepper(valor: 20, minimo: 0, maximo: 20, onChanged: (_) {}),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
