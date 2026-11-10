import 'package:flutter/material.dart';

// Tema propio de la app, en modo claro y en modo oscuro.
// Usamos ColorScheme.fromSeed para que Material 3 genere toda la paleta
// de colores a partir de un unico color (el "seed").

final ThemeData temaClaro = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.indigo,
    brightness: Brightness.light,
  ),
);

final ThemeData temaOscuro = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.indigo,
    brightness: Brightness.dark,
  ),
);
