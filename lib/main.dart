import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:stockar/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'tema.dart';
import 'controladores/productos_controlador.dart';
import 'controladores/movimientos_controlador.dart';

import 'pantallas/panel_pantalla.dart';
import 'pantallas/productos_pantalla.dart';
import 'pantallas/ficha_producto_pantalla.dart';
import 'pantallas/alta_producto_pantalla.dart';
import 'pantallas/categorias_pantalla.dart';
import 'pantallas/proveedores_pantalla.dart';
import 'pantallas/movimientos_pantalla.dart';
import 'pantallas/nuevo_movimiento_voz_pantalla.dart';
import 'pantallas/alertas_stock_pantalla.dart';
import 'pantallas/ajustes_pantalla.dart';

void main() {
  runApp(const StockArApp());
}

// Guardamos aqui el idioma y el tema elegidos por el usuario, para poder
// cambiarlos desde la pantalla de Ajustes sin reiniciar la app.
class PreferenciasApp extends ChangeNotifier {
  Locale _idioma = const Locale('es');
  ThemeMode _modoTema = ThemeMode.system;

  Locale get idioma => _idioma;
  ThemeMode get modoTema => _modoTema;

  void cambiarIdioma(Locale nuevoIdioma) {
    _idioma = nuevoIdioma;
    notifyListeners();
  }

  void cambiarModoTema(ThemeMode nuevoModo) {
    _modoTema = nuevoModo;
    notifyListeners();
  }
}

class StockArApp extends StatelessWidget {
  const StockArApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PreferenciasApp()),
        ChangeNotifierProvider(create: (_) => ProductosControlador()..cargarTodo()),
        ChangeNotifierProvider(create: (_) => MovimientosControlador()..cargarTodo()),
      ],
      child: Consumer<PreferenciasApp>(
        builder: (context, preferencias, _) {
          return MaterialApp(
            title: 'StockAR',
            debugShowCheckedModeBanner: false,
            theme: temaClaro,
            darkTheme: temaOscuro,
            themeMode: preferencias.modoTema,
            locale: preferencias.idioma,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            // 10 pantallas principales, con navegacion por nombre de ruta.
            initialRoute: '/',
            routes: {
              '/': (context) => const PanelPantalla(),
              '/productos': (context) => const ProductosPantalla(),
              '/ficha-producto': (context) => const FichaProductoPantalla(),
              '/alta-producto': (context) => const AltaProductoPantalla(),
              '/categorias': (context) => const CategoriasPantalla(),
              '/proveedores': (context) => const ProveedoresPantalla(),
              '/movimientos': (context) => const MovimientosPantalla(),
              '/nuevo-movimiento-voz': (context) => const NuevoMovimientoVozPantalla(),
              '/alertas-stock': (context) => const AlertasStockPantalla(),
              '/ajustes': (context) => const AjustesPantalla(),
            },
          );
        },
      ),
    );
  }
}
