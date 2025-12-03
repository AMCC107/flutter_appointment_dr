import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/especialidad.dart';
import '../models/medico.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Especialidades
  Stream<List<Especialidad>> getEspecialidades() {
    return _firestore
        .collection('especialidades')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Especialidad.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<List<Especialidad>> getEspecialidadesOnce() async {
    final snapshot = await _firestore.collection('especialidades').get();
    return snapshot.docs
        .map((doc) => Especialidad.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  // Médicos
  Stream<List<Medico>> getMedicosPorEspecialidad(String especialidadId) {
    return _firestore
        .collection('medicos')
        .where('especialidadId', isEqualTo: especialidadId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Medico.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<List<Medico>> getMedicosPorEspecialidadOnce(String especialidadId) async {
    final snapshot = await _firestore
        .collection('medicos')
        .where('especialidadId', isEqualTo: especialidadId)
        .get();
    return snapshot.docs
        .map((doc) => Medico.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<Medico?> getMedicoPorId(String medicoId) async {
    final doc = await _firestore.collection('medicos').doc(medicoId).get();
    if (doc.exists) {
      return Medico.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }

  Future<List<Medico>> getAllMedicos() async {
    final snapshot = await _firestore.collection('medicos').get();
    return snapshot.docs
        .map((doc) => Medico.fromFirestore(doc.data(), doc.id))
        .toList();
  }
}

