// Modelo de la tabla "movimiento". Cada fila es una entrada o una salida
// de unidades de un producto.
class Movimiento {
  int? id;
  int productoId;
  String tipo; // 'entrada' o 'salida'
  int unidades;
  String fecha; // fecha en formato ISO8601, ej: 2026-10-20T10:00:00.000

  Movimiento({
    this.id,
    required this.productoId,
    required this.tipo,
    required this.unidades,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'producto_id': productoId,
      'tipo': tipo,
      'unidades': unidades,
      'fecha': fecha,
    };
  }

  factory Movimiento.fromMap(Map<String, dynamic> mapa) {
    return Movimiento(
      id: mapa['id'] as int?,
      productoId: mapa['producto_id'] as int,
      tipo: mapa['tipo'] as String,
      unidades: mapa['unidades'] as int,
      fecha: mapa['fecha'] as String,
    );
  }
}
