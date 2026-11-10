// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tituloApp => 'StockAR';

  @override
  String get panel => 'Dashboard';

  @override
  String get productos => 'Products';

  @override
  String get categorias => 'Categories';

  @override
  String get proveedores => 'Suppliers';

  @override
  String get movimientos => 'Movements';

  @override
  String get alertasStock => 'Stock alerts';

  @override
  String get ajustes => 'Settings';

  @override
  String get nuevoMovimientoVoz => 'New voice movement';

  @override
  String numeroDeProductos(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: '$cantidad products',
      one: '1 product',
      zero: 'No products',
    );
    return '$_temp0';
  }

  @override
  String ultimaActualizacion(DateTime fecha) {
    final intl.DateFormat fechaDateFormat = intl.DateFormat.yMd(localeName);
    final String fechaString = fechaDateFormat.format(fecha);

    return 'Last update: $fechaString';
  }
}
