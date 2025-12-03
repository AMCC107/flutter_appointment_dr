import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/medico.dart';
import '../models/cita.dart';

class CitaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Validar que la hora esté en intervalos de 30 minutos
  bool esHoraValida(TimeOfDay hora) {
    return hora.minute == 0 || hora.minute == 30;
  }

  // Validar que la hora esté dentro del horario del médico
  bool estaDentroDelHorario(DateTime fecha, TimeOfDay horaInicio, Medico medico) {
    final diaSemana = fecha.weekday; // 1 = lunes, 7 = domingo
    HorarioDia? horarioDia;

    switch (diaSemana) {
      case 1:
        horarioDia = medico.horario.lunes;
        break;
      case 2:
        horarioDia = medico.horario.martes;
        break;
      case 3:
        horarioDia = medico.horario.miercoles;
        break;
      case 4:
        horarioDia = medico.horario.jueves;
        break;
      case 5:
        horarioDia = medico.horario.viernes;
        break;
      case 6:
        horarioDia = medico.horario.sabado;
        break;
      case 7:
        horarioDia = medico.horario.domingo;
        break;
    }

    if (horarioDia == null) return false;

    final horaInicioStr = '${horaInicio.hour.toString().padLeft(2, '0')}:${horaInicio.minute.toString().padLeft(2, '0')}';
    final horaFinStr = '${(horaInicio.hour + (horaInicio.minute + 30) ~/ 60).toString().padLeft(2, '0')}:${((horaInicio.minute + 30) % 60).toString().padLeft(2, '0')}';

    return horaInicioStr.compareTo(horarioDia.inicio) >= 0 &&
           horaFinStr.compareTo(horarioDia.fin) <= 0;
  }

  // Validar que no haya solapamiento de citas del mismo paciente
  Future<bool> tieneCitaSolapadaPaciente(
    String pacienteNombre,
    DateTime fecha,
    TimeOfDay horaInicio,
    TimeOfDay horaFin,
    String? citaIdExcluir,
  ) async {
    final inicio = DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      horaInicio.hour,
      horaInicio.minute,
    );
    final fin = DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      horaFin.hour,
      horaFin.minute,
    );

    // Buscar citas del mismo paciente por nombre
    final citas = await _firestore
        .collection('citas')
        .where('paciente', isEqualTo: pacienteNombre)
        .get();

    for (var doc in citas.docs) {
      if (citaIdExcluir != null && doc.id == citaIdExcluir) continue;

      final data = doc.data();
      final fechaHoraInicio = (data['horaInicio'] as Timestamp?)?.toDate() ?? DateTime.now();
      final fechaHoraFin = (data['horaFin'] as Timestamp?)?.toDate() ?? DateTime.now();

      // Verificar solapamiento
      if (inicio.isBefore(fechaHoraFin) && fin.isAfter(fechaHoraInicio)) {
        return true;
      }
    }
    return false;
  }

  // Validar que el médico no tenga otra cita a la misma hora
  Future<bool> tieneCitaSolapadaMedico(
    String medicoId,
    DateTime fecha,
    TimeOfDay horaInicio,
    TimeOfDay horaFin,
    String? citaIdExcluir,
  ) async {
    final inicio = DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      horaInicio.hour,
      horaInicio.minute,
    );
    final fin = DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      horaFin.hour,
      horaFin.minute,
    );

    final citas = await _firestore
        .collection('citas')
        .where('medicoId', isEqualTo: medicoId)
        .get();

    for (var doc in citas.docs) {
      if (citaIdExcluir != null && doc.id == citaIdExcluir) continue;

      final data = doc.data();
      final fechaHoraInicio = (data['horaInicio'] as Timestamp?)?.toDate() ?? DateTime.now();
      final fechaHoraFin = (data['horaFin'] as Timestamp?)?.toDate() ?? DateTime.now();

      // Verificar solapamiento
      if (inicio.isBefore(fechaHoraFin) && fin.isAfter(fechaHoraInicio)) {
        return true;
      }
    }
    return false;
  }

  // Validar todas las condiciones
  Future<String?> validarCita({
    required String pacienteNombre,
    required String medicoId,
    required DateTime fecha,
    required TimeOfDay horaInicio,
    required TimeOfDay horaFin,
    required Medico medico,
    String? citaIdExcluir,
  }) async {
    // Validar hora en intervalos de 30 minutos
    if (!esHoraValida(horaInicio)) {
      return 'La hora debe ser en intervalos de 30 minutos (ej: 8:00, 8:30, 9:00)';
    }

    // Validar horario del médico
    if (!estaDentroDelHorario(fecha, horaInicio, medico)) {
      return 'La cita debe estar dentro del horario del médico';
    }

    // Validar duración de 30 minutos
    final inicio = DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      horaInicio.hour,
      horaInicio.minute,
    );
    final fin = DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      horaFin.hour,
      horaFin.minute,
    );
    if (fin.difference(inicio).inMinutes != 30) {
      return 'La cita debe tener una duración de 30 minutos';
    }

    // Validar solapamiento del paciente
    if (await tieneCitaSolapadaPaciente(pacienteNombre, fecha, horaInicio, horaFin, citaIdExcluir)) {
      return 'Ya tienes una cita agendada en este horario';
    }

    // Validar solapamiento del médico
    if (await tieneCitaSolapadaMedico(medicoId, fecha, horaInicio, horaFin, citaIdExcluir)) {
      return 'El médico ya tiene una cita agendada en este horario';
    }

    return null; // Sin errores
  }

  // ========== MÉTODOS DE BORRADO LÓGICO ==========

  /// Cancelar una cita (borrado lógico)
  Future<void> cancelarCita({
    required String citaId,
    String razon = '',
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    
    await _firestore.collection('citas').doc(citaId).update({
      'estado': 'cancelada',
      'eliminado': true,
      'fechaCancelacion': FieldValue.serverTimestamp(),
      'razonCancelacion': razon,
      'eliminadoPor': user?.uid ?? '',
      'fechaEliminacion': FieldValue.serverTimestamp(),
    });
  }

  /// Obtener solo citas activas (no eliminadas)
  Future<List<Cita>> obtenerCitasActivas() async {
    final snapshot = await _firestore
        .collection('citas')
        .where('eliminado', isEqualTo: false)
        .orderBy('fecha', descending: false)
        .get();
    
    return snapshot.docs
        .map((doc) => Cita.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  /// Obtener todas las citas incluyendo eliminadas (para admin/estadísticas)
  Future<List<Cita>> obtenerTodasLasCitas() async {
    final snapshot = await _firestore
        .collection('citas')
        .orderBy('fecha', descending: false)
        .get();
    
    return snapshot.docs
        .map((doc) => Cita.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  /// Stream de citas activas (para UI en tiempo real)
  Stream<List<Cita>> streamCitasActivas() {
    return _firestore
        .collection('citas')
        .where('eliminado', isEqualTo: false)
        .orderBy('fecha', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Cita.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Obtener estadísticas de citas
  Future<Map<String, dynamic>> obtenerEstadisticas() async {
    final todasLasCitas = await obtenerTodasLasCitas();
    
    final activas = todasLasCitas.where((c) => c.estado == 'activa' && !c.eliminado).length;
    final canceladas = todasLasCitas.where((c) => c.estado == 'cancelada' || c.eliminado).length;
    final completadas = todasLasCitas.where((c) => c.estado == 'completada').length;
    final total = todasLasCitas.length;
    
    final tasaCancelacion = total > 0 ? (canceladas / total * 100) : 0.0;
    
    // Horarios más populares
    final horarios = <int, int>{};
    for (var cita in todasLasCitas) {
      final hora = cita.horaInicio.hour;
      horarios[hora] = (horarios[hora] ?? 0) + 1;
    }
    final horarioMasPopular = horarios.entries.isNotEmpty
        ? horarios.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : null;
    
    // Médicos con más citas
    final medicosCount = <String, int>{};
    for (var cita in todasLasCitas) {
      final medico = cita.medico;
      medicosCount[medico] = (medicosCount[medico] ?? 0) + 1;
    }
    final medicoMasSolicitado = medicosCount.entries.isNotEmpty
        ? medicosCount.entries.reduce((a, b) => a.value > b.value ? a : b)
        : null;
    
    return {
      'total': total,
      'activas': activas,
      'canceladas': canceladas,
      'completadas': completadas,
      'tasaCancelacion': tasaCancelacion,
      'horarioMasPopular': horarioMasPopular,
      'medicoMasSolicitado': medicoMasSolicitado?.key,
      'citasPorMedico': medicosCount,
      'citasPorHora': horarios,
    };
  }

  /// Restaurar una cita cancelada (solo admin)
  Future<void> restaurarCita(String citaId) async {
    await _firestore.collection('citas').doc(citaId).update({
      'estado': 'activa',
      'eliminado': false,
      'fechaCancelacion': FieldValue.delete(),
      'razonCancelacion': '',
      'eliminadoPor': FieldValue.delete(),
      'fechaEliminacion': FieldValue.delete(),
    });
  }
}

