class Especialidad {
  final String id;
  final String nombre;
  final String descripcion;
  final String icono;
  final String color;

  Especialidad({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.icono,
    required this.color,
  });

  factory Especialidad.fromFirestore(Map<String, dynamic> data, String id) {
    return Especialidad(
      id: id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      icono: data['icono'] ?? 'medical_services',
      color: data['color'] ?? '#4CAF50',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'icono': icono,
      'color': color,
    };
  }
}

