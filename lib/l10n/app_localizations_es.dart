// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get tituloApp => 'StockAR';

  @override
  String get panel => 'Panel';

  @override
  String get productos => 'Productos';

  @override
  String get categorias => 'Categorias';

  @override
  String get proveedores => 'Proveedores';

  @override
  String get movimientos => 'Movimientos';

  @override
  String get alertasStock => 'Alertas de stock';

  @override
  String get ajustes => 'Ajustes';

  @override
  String get nuevoMovimientoVoz => 'Nuevo movimiento por voz';

  @override
  String numeroDeProductos(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: '$cantidad productos',
      one: '1 producto',
      zero: 'No hay productos',
    );
    return '$_temp0';
  }

  @override
  String ultimaActualizacion(DateTime fecha) {
    final intl.DateFormat fechaDateFormat = intl.DateFormat.yMd(localeName);
    final String fechaString = fechaDateFormat.format(fecha);

    return 'Ultima actualizacion: $fechaString';
  }
}
