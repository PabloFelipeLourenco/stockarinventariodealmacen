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

## Primeros pasos

1. Descomprime este zip en una carpeta nueva y ábrela con tu editor.
2. En una terminal, dentro de esa carpeta, ejecuta:
   ```
   flutter create .
   ```
   Esto crea `android/`, `ios/`, `windows/`, `linux/`, `macos/` y `web/` sin tocar
   `lib/` ni `pubspec.yaml`, que ya están hechos.
3. Instala las dependencias:
   ```
   flutter pub get
   ```
4. Añade los permisos de cámara y micrófono (ver más abajo).
5. Si vas a ejecutar en Chrome, prepara también la base de datos web (ver más abajo).

Las clases de idioma (`AppLocalizations`) se generan solas a partir de los ficheros
`.arb` de `lib/l10n/` gracias a `generate: true` en el `pubspec.yaml`, y se importan
como `package:stockar/l10n/app_localizations.dart`.

## Permisos que hay que añadir a mano

**Android** (`android/app/src/main/AndroidManifest.xml`, dentro de `<manifest>`):

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

**iOS** (`ios/Runner/Info.plist`, dentro de `<dict>`):

```xml
<key>NSCameraUsageDescription</key>
<string>StockAR usa la cámara para la etiqueta de realidad aumentada y para comprobar que miras la pantalla.</string>
<key>NSMicrophoneUsageDescription</key>
<string>StockAR usa el micrófono para reconocer tus órdenes de voz.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>StockAR convierte tu voz en texto para registrar movimientos.</string>
```

## Ejecutar en Chrome (web)

Esta app está pensada para Android/iOS/Windows/Linux (es lo único que pide el
enunciado), pero también puede ejecutarse en Chrome gracias al paquete
`sqflite_common_ffi_web`, que simula SQLite dentro del propio navegador con
WebAssembly y guarda los datos en el almacenamiento del navegador (IndexedDB).

Pasos extra, solo para web (hazlos una vez, después de `flutter pub get`):

```
dart run sqflite_common_ffi_web:setup
```

Esto copia dos ficheros (`sqlite3.wasm` y `sqflite_sw.js`) dentro de la carpeta
`web/` del proyecto. Sin ellos, la base de datos no arranca en el navegador.

Para que los datos no desaparezcan cada vez que ejecutas la app (el navegador guarda
los datos atados al puerto en el que se sirve la página), arranca siempre con el
mismo puerto:

```
flutter run -d chrome --web-port=5000
```

### Lo que SÍ funciona en Chrome

Base de datos y las 10 pantallas, reconocimiento de voz (`speech_to_text` usa la API
de voz del propio Chrome), texto a voz (`flutter_tts`), la cámara para la etiqueta de
realidad aumentada y los componentes propios.

### Lo que NO puede funcionar en ningún navegador (no es un fallo del código)

La detección de cara (RA2.e) usa Google ML Kit, y **ML Kit solo existe para Android e
iOS**: su propia documentación lo dice explícitamente. En la pantalla de "Nuevo
movimiento por voz" verás un aviso en naranja explicándolo; la voz sigue funcionando
igual. Para demostrar esa parte concreta tendrás que enseñarla en un emulador o
dispositivo Android. El acelerómetro (agitar para deshacer) sí tiene soporte web, pero
un ordenador de escritorio normalmente no tiene ese sensor.

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

## Cómo probar cada parte

- **App completa**: `flutter run` desde la raíz del proyecto.
- **Tests y cobertura del paquete de componentes**:
  ```
  cd packages/componentes_stockar
  flutter test --coverage
  ```
  La primera vez hay que generar la imagen del test golden:
  ```
  flutter test --update-goldens
  ```
- **Catálogo Widgetbook**:
  ```
  cd widgetbook
  flutter pub get
  flutter run -d chrome
  ```
- **Documentación de la API del paquete**:
  ```
  cd packages/componentes_stockar
  dart doc
  ```

## Lo que falta por hacer (son cosas que solo puede hacer el alumno)

- [ ] Capturas de `flutter doctor`, del editor visual, del emulador/dispositivo y de
      la base de datos abierta con DB Browser for SQLite.
- [ ] Hacer commits de Git **frecuentes** a medida que avanzas, no uno solo al final.
- [ ] Rellenar `memoria.md` con tus propias capturas.
- [ ] Generar el informe de cobertura (`lcov`) y comprobar que llega al 70 %.

## Solución de problemas

**`Couldn't resolve the package 'flutter_gen'`**: en `l10n.yaml` debe estar
`synthetic-package: false`, y los imports de `AppLocalizations` deben ser
`package:stockar/l10n/app_localizations.dart`, nunca `package:flutter_gen/...`.

**`Unable to find suitable Visual Studio toolchain`** (al ejecutar en Windows): te
falta el componente de C++ de Visual Studio. Abre "Visual Studio Installer" → tu
instalación → "Modificar" → marca la carga de trabajo "Desarrollo para el escritorio
con C++" → instala. Comprueba después con `flutter doctor`.

**No aparece ningún producto / los desplegables de categoría o proveedor están
vacíos**: en Chrome, asegúrate de haber ejecutado
`dart run sqflite_common_ffi_web:setup` (ver arriba). La app también te dirá el
motivo con un mensaje en rojo en el Panel y en Productos si la base de datos no carga.

**Error de compilación con cosas como `<<<<<<< HEAD`, `=======` o `>>>>>>>` en medio
del código**: eso es un conflicto de Git sin resolver que se quedó dentro de un
fichero al hacer un `merge`. Antes de hacer commit después de resolver un merge,
busca en todo el proyecto si queda algún rastro, por ejemplo con la búsqueda global
de VS Code (`Ctrl+Shift+F`) escribiendo `<<<<<<<`. Si usas VS Code, cuando abre un
fichero con conflictos te muestra botones de "Accept Current Change / Incoming Change
/ Both Changes" encima de cada bloque: haz clic en uno de ellos en lugar de editar las
marcas a mano, así es mucho más difícil dejarte alguna sin resolver. Esto pasa muy a
menudo en archivos que genera Flutter (`pubspec.lock`, y todo lo de `android/`,
`ios/`, `windows/`, etc.) precisamente porque dos ordenadores los generan de forma
distinta; por eso este proyecto ya no los lleva en el zip, para que no vuelva a pasar.
