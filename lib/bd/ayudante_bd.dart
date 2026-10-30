import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

// Esta clase es un "singleton": en toda la app solo existe una base de
// datos abierta. La primera vez que alguien pide la base de datos, se
// crea; las siguientes veces se devuelve siempre la misma.
class AyudanteBD {
  static final AyudanteBD _instancia = AyudanteBD._interno();
  factory AyudanteBD() => _instancia;
  AyudanteBD._interno();

  static Database? _bd;

  Future<Database> get bd async {
    if (_bd != null) return _bd!;
    _bd = await _inicializarBD();
    return _bd!;
  }

  Future<Database> _inicializarBD() async {
    String ruta;

    if (kIsWeb) {
      // En el navegador no hay un sistema de ficheros real: usamos
      // sqflite_common_ffi_web, que simula SQLite con WebAssembly y
      // guarda los datos en el almacenamiento del propio navegador
      // (IndexedDB). Hace falta haber ejecutado una vez, en la raiz del
      // proyecto: dart run sqflite_common_ffi_web:setup
      databaseFactory = databaseFactoryFfiWeb;
      ruta = 'stockar.db';
    } else {
      // En el ordenador (Windows/Linux) sqflite no funciona directamente,
      // hay que usar la version "ffi". En Android/iOS no hace falta.
      if (Platform.isWindows || Platform.isLinux) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }

      final directorio = await getApplicationDocumentsDirectory();
      ruta = join(directorio.path, 'stockar.db');
    }

    return await openDatabase(
      ruta,
      version: 1,
      onConfigure: (db) async {
        // Sin esto, SQLite no comprueba las claves ajenas.
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _crearTablas,
      onUpgrade: _actualizarBD,
    );
  }

  Future<void> _crearTablas(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categoria (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE proveedor (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        telefono TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE producto (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        categoria_id INTEGER NOT NULL,
        proveedor_id INTEGER NOT NULL,
        stock_minimo INTEGER NOT NULL,
        FOREIGN KEY (categoria_id) REFERENCES categoria (id),
        FOREIGN KEY (proveedor_id) REFERENCES proveedor (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE movimiento (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        producto_id INTEGER NOT NULL,
        tipo TEXT NOT NULL,
        unidades INTEGER NOT NULL,
        fecha TEXT NOT NULL,
        FOREIGN KEY (producto_id) REFERENCES producto (id)
      )
    ''');

    await _cargarDatosDeEjemplo(db);
  }

  // Todavia no hemos cambiado la version de la base de datos, pero dejamos
  // la funcion preparada para cuando en el futuro haya que hacerlo
  // (lo pide el enunciado aunque este vacia).
  Future<void> _actualizarBD(Database db, int versionVieja, int versionNueva) async {}

  Future<void> _cargarDatosDeEjemplo(Database db) async {
    final idTornilleria = await db.insert('categoria', {'nombre': 'Tornilleria'});
    final idElectricidad = await db.insert('categoria', {'nombre': 'Electricidad'});
    final idHerramientas = await db.insert('categoria', {'nombre': 'Herramientas'});

    final idProveedor1 = await db.insert('proveedor', {'nombre': 'Ferreteria Martin', 'telefono': '910000001'});
    final idProveedor2 = await db.insert('proveedor', {'nombre': 'Suministros Lopez', 'telefono': '910000002'});

    // Al menos 10 filas en la tabla principal (producto), tal y como pide
    // el enunciado.
    final productosEjemplo = [
      {'nombre': 'Tornillo M6', 'categoria_id': idTornilleria, 'proveedor_id': idProveedor1, 'stock_minimo': 50},
      {'nombre': 'Tornillo M8', 'categoria_id': idTornilleria, 'proveedor_id': idProveedor1, 'stock_minimo': 50},
      {'nombre': 'Tuerca M6', 'categoria_id': idTornilleria, 'proveedor_id': idProveedor1, 'stock_minimo': 40},
      {'nombre': 'Arandela M6', 'categoria_id': idTornilleria, 'proveedor_id': idProveedor2, 'stock_minimo': 40},
      {'nombre': 'Cable 1.5mm', 'categoria_id': idElectricidad, 'proveedor_id': idProveedor2, 'stock_minimo': 20},
      {'nombre': 'Interruptor', 'categoria_id': idElectricidad, 'proveedor_id': idProveedor2, 'stock_minimo': 10},
      {'nombre': 'Enchufe', 'categoria_id': idElectricidad, 'proveedor_id': idProveedor2, 'stock_minimo': 10},
      {'nombre': 'Destornillador', 'categoria_id': idHerramientas, 'proveedor_id': idProveedor1, 'stock_minimo': 5},
      {'nombre': 'Martillo', 'categoria_id': idHerramientas, 'proveedor_id': idProveedor1, 'stock_minimo': 5},
      {'nombre': 'Alicates', 'categoria_id': idHerramientas, 'proveedor_id': idProveedor1, 'stock_minimo': 5},
    ];

    final idsProducto = <int>[];
    for (final p in productosEjemplo) {
      final id = await db.insert('producto', p);
      idsProducto.add(id);
    }

    // Una entrada inicial por cada producto, para que todos tengan stock.
    final ahora = DateTime.now();
    for (var i = 0; i < idsProducto.length; i++) {
      await db.insert('movimiento', {
        'producto_id': idsProducto[i],
        'tipo': 'entrada',
        'unidades': 100,
        'fecha': ahora.subtract(Duration(days: idsProducto.length - i)).toIso8601String(),
      });
    }

    // Dejamos dos productos por debajo del minimo para poder probar la
    // pantalla de alertas de stock sin tener que hacer nada mas.
    await db.insert('movimiento', {
      'producto_id': idsProducto[7], // Destornillador
      'tipo': 'salida',
      'unidades': 97,
      'fecha': ahora.toIso8601String(),
    });
    await db.insert('movimiento', {
      'producto_id': idsProducto[5], // Interruptor
      'tipo': 'salida',
      'unidades': 95,
      'fecha': ahora.toIso8601String(),
    });
  }
}
