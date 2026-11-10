# componentes_stockar

Paquete propio con los componentes visuales del proyecto StockAR:

- `StockGauge`: barra que muestra el stock actual frente al minimo.
- `QuantityStepper`: selector de cantidad con botones + y -.

## Como se usa

En la app principal esta declarado como dependencia de ruta local:

```yaml
dependencies:
  componentes_stockar:
    path: packages/componentes_stockar
```

## Pruebas y cobertura

```
cd packages/componentes_stockar
flutter test --coverage
```

La primera vez que se ejecute el test golden hay que generar la imagen
de referencia con:

```
flutter test --update-goldens
```
