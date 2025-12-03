class HorarioDia {
  final String inicio;
  final String fin;

  HorarioDia({required this.inicio, required this.fin});

  factory HorarioDia.fromFirestore(Map<String, dynamic> data) {
    return HorarioDia(
      inicio: data['inicio'] ?? '08:00',
      fin: data['fin'] ?? '17:00',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'inicio': inicio,
      'fin': fin,
    };
  }
}

class HorarioSemanal {
  final HorarioDia? lunes;
  final HorarioDia? martes;
  final HorarioDia? miercoles;
  final HorarioDia? jueves;
  final HorarioDia? viernes;
  final HorarioDia? sabado;
  final HorarioDia? domingo;

  HorarioSemanal({
    this.lunes,
    this.martes,
    this.miercoles,
    this.jueves,
    this.viernes,
    this.sabado,
    this.domingo,
  });

  factory HorarioSemanal.fromFirestore(Map<String, dynamic> data) {
    return HorarioSemanal(
      lunes: data['lunes'] != null ? HorarioDia.fromFirestore(data['lunes']) : null,
      martes: data['martes'] != null ? HorarioDia.fromFirestore(data['martes']) : null,
      miercoles: data['miercoles'] != null ? HorarioDia.fromFirestore(data['miercoles']) : null,
      jueves: data['jueves'] != null ? HorarioDia.fromFirestore(data['jueves']) : null,
      viernes: data['viernes'] != null ? HorarioDia.fromFirestore(data['viernes']) : null,
      sabado: data['sabado'] != null ? HorarioDia.fromFirestore(data['sabado']) : null,
      domingo: data['domingo'] != null ? HorarioDia.fromFirestore(data['domingo']) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (lunes != null) 'lunes': lunes!.toFirestore(),
      if (martes != null) 'martes': martes!.toFirestore(),
      if (miercoles != null) 'miercoles': miercoles!.toFirestore(),
      if (jueves != null) 'jueves': jueves!.toFirestore(),
      if (viernes != null) 'viernes': viernes!.toFirestore(),
      if (sabado != null) 'sabado': sabado!.toFirestore(),
      if (domingo != null) 'domingo': domingo!.toFirestore(),
    };
  }

  String getHorarioGeneral() {
    final dias = <String>[];
    if (lunes != null) dias.add('Lun');
    if (martes != null) dias.add('Mar');
    if (miercoles != null) dias.add('Mié');
    if (jueves != null) dias.add('Jue');
    if (viernes != null) dias.add('Vie');
    if (sabado != null) dias.add('Sáb');
    if (domingo != null) dias.add('Dom');

    if (dias.isEmpty) return 'Sin horario';
    
    final horario = lunes ?? martes ?? miercoles ?? jueves ?? viernes;
    if (horario == null) return 'Sin horario';
    
    return '${dias.join('-')}: ${horario.inicio}-${horario.fin}';
  }
}

class Medico {
  final String? id;
  final String nombre;
  final String especialidad;
  final String especialidadId;
  final String descripcion;
  final String experiencia;
  final double calificacion;
  final String telefono;
  final String email;
  final HorarioSemanal horario;
  final List<dynamic> disponibilidad;

  Medico({
    this.id,
    required this.nombre,
    required this.especialidad,
    required this.especialidadId,
    required this.descripcion,
    required this.experiencia,
    required this.calificacion,
    required this.telefono,
    required this.email,
    required this.horario,
    required this.disponibilidad,
  });

  factory Medico.fromFirestore(Map<String, dynamic> data, String id) {
    return Medico(
      id: id,
      nombre: data['nombre'] ?? '',
      especialidad: data['especialidad'] ?? '',
      especialidadId: data['especialidadId'] ?? '',
      descripcion: data['descripcion'] ?? '',
      experiencia: data['experiencia'] ?? '0 años',
      calificacion: (data['calificacion'] ?? 0.0).toDouble(),
      telefono: data['telefono'] ?? '',
      email: data['email'] ?? '',
      horario: HorarioSemanal.fromFirestore(data['horario'] ?? {}),
      disponibilidad: data['disponibilidad'] ?? [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'especialidad': especialidad,
      'especialidadId': especialidadId,
      'descripcion': descripcion,
      'experiencia': experiencia,
      'calificacion': calificacion,
      'telefono': telefono,
      'email': email,
      'horario': horario.toFirestore(),
      'disponibilidad': disponibilidad,
    };
  }
}

