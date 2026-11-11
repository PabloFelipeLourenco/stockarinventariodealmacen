# StockAR — inventario de almacén

Proyecto de curso del módulo **Desarrollo de interfaces** (2º DAM), basado en la ficha
"StockAR — inventario de almacén" (proyecto 4 de la lista de 10).

## Qué es

Una app de Flutter para llevar el control de existencias de un almacén: productos,
categorías, proveedores y movimientos de entrada/salida, con una base de datos SQLite,
un registro de movimientos por voz, una alerta de stock bajo y una "etiqueta virtual"
con la cámara a modo de realidad aumentada.

## ⚠️ Importante: este zip solo trae el código fuente

A propósito **no incluye** las carpetas `android/`, `ios/`, `windows/`, `linux/`,
`macos/` ni `web/`: son carpetas que genera el propio Flutter y, si se llevan a Git y
dos personas o dos ordenadores las generan por separado, es muy fácil que una fusión
(`merge`) choque y deje el proyecto roto (esto es justo lo que te pasó: tu último
`merge` dejó marcas de conflicto de Git sin resolver en más de una decena de esos
ficheros generados, además de en `pubspec.lock` y `.gitignore`). Genera esas carpetas
tú mismo, limpias, con los pasos de abajo.

## Estructura del proyecto

```
lib/
  main.dart                 Arranque de la app, tema, idioma y rutas
  tema.dart                 ThemeData claro/oscuro (Material 3)
  modelos/                  Categoria, Proveedor, Producto, Movimiento
  bd/ayudante_bd.dart        DatabaseHelper (singleton) + datos de ejemplo
  repositorios/             CRUD + consultas JOIN y de agregado
  controladores/            ChangeNotifier (la "C" de MVC)
  pantallas/                Las 10 pantallas + la de realidad aumentada
  l10n/                     app_es.arb, app_en.arb y las clases generadas
packages/componentes_stockar/   Paquete propio: StockGauge y QuantityStepper
widgetbook/                 Catálogo de los componentes propios
```
