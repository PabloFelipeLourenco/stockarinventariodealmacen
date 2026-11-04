// Modelo de la tabla "categoria".
class Categoria {
  int? id;
  String nombre;

  Categoria({this.id, required this.nombre});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }

  factory Categoria.fromMap(Map<String, dynamic> mapa) {
    return Categoria(
      id: mapa['id'] as int?,
      nombre: mapa['nombre'] as String,
    );
  }
}
