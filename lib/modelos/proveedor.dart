// Modelo de la tabla "proveedor".
class Proveedor {
  int? id;
  String nombre;
  String? telefono;

  Proveedor({this.id, required this.nombre, this.telefono});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'telefono': telefono,
    };
  }

  factory Proveedor.fromMap(Map<String, dynamic> mapa) {
    return Proveedor(
      id: mapa['id'] as int?,
      nombre: mapa['nombre'] as String,
      telefono: mapa['telefono'] as String?,
    );
  }
}
