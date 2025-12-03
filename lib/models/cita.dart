import 'package:cloud_firestore/cloud_firestore.dart';

enum EstadoCita {
  activa,
  cancelada,
  completada,
  eliminada,
}

class Cita {
  final String? id;
  final String nombreUsuario;
  final String paciente;
  final String medico;
  final String? medicoId;
  final String motivo;
  final DateTime fecha;
  final DateTime horaInicio;
  final DateTime horaFin;
  final DateTime? creadoEn;
  
  // Campos para borrado lógico
  final String estado; // "activa", "cancelada", "completada", "eliminada"
  final bool eliminado;
  final DateTime? fechaCancelacion;
  final String razonCancelacion;
  final String? eliminadoPor;
  final DateTime? fechaEliminacion;
  
  // Campos para estadísticas
  final int duracionMinutos;
  final String tipoCita;

  Cita({
    this.id,
    required this.nombreUsuario,
    required this.paciente,
    required this.medico,
    this.medicoId,
    required this.motivo,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    this.creadoEn,
    this.estado = 'activa',
    this.eliminado = false,
    this.fechaCancelacion,
    this.razonCancelacion = '',
    this.eliminadoPor,
    this.fechaEliminacion,
    this.duracionMinutos = 30,
    this.tipoCita = 'consulta',
  });

  factory Cita.fromFirestore(Map<String, dynamic> data, String id) {
    return Cita(
      id: id,
      nombreUsuario: data['nombreUsuario'] ?? '',
      paciente: data['paciente'] ?? '',
      medico: data['medico'] ?? '',
      medicoId: data['medicoId'],
      motivo: data['motivo'] ?? '',
      fecha: (data['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
      horaInicio: (data['horaInicio'] as Timestamp?)?.toDate() ?? DateTime.now(),
      horaFin: (data['horaFin'] as Timestamp?)?.toDate() ?? DateTime.now(),
      creadoEn: (data['creadoEn'] as Timestamp?)?.toDate(),
      estado: data['estado'] ?? 'activa',
      eliminado: data['eliminado'] ?? false,
      fechaCancelacion: (data['fechaCancelacion'] as Timestamp?)?.toDate(),
      razonCancelacion: data['razonCancelacion'] ?? '',
      eliminadoPor: data['eliminadoPor'],
      fechaEliminacion: (data['fechaEliminacion'] as Timestamp?)?.toDate(),
      duracionMinutos: data['duracionMinutos'] ?? 30,
      tipoCita: data['tipoCita'] ?? 'consulta',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombreUsuario': nombreUsuario,
      'paciente': paciente,
      'medico': medico,
      if (medicoId != null) 'medicoId': medicoId,
      'motivo': motivo,
      'fecha': Timestamp.fromDate(fecha),
      'horaInicio': Timestamp.fromDate(horaInicio),
      'horaFin': Timestamp.fromDate(horaFin),
      'creadoEn': FieldValue.serverTimestamp(),
      'estado': estado,
      'eliminado': eliminado,
      if (fechaCancelacion != null) 'fechaCancelacion': Timestamp.fromDate(fechaCancelacion!),
      'razonCancelacion': razonCancelacion,
      if (eliminadoPor != null) 'eliminadoPor': eliminadoPor,
      if (fechaEliminacion != null) 'fechaEliminacion': Timestamp.fromDate(fechaEliminacion!),
      'duracionMinutos': duracionMinutos,
      'tipoCita': tipoCita,
    };
  }
  
  bool get estaActiva => estado == 'activa' && !eliminado;
  bool get estaCancelada => estado == 'cancelada' || eliminado;
}

