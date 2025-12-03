import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

/// Script de migración para actualizar citas existentes con campos de borrado lógico
/// Ejecutar desde la app o como script independiente
Future<void> migrarCitasExistentes() async {
  print('🔄 Iniciando migración de citas existentes...\n');
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('citas').get();
    
    if (snapshot.docs.isEmpty) {
      print('ℹ️ No hay citas para migrar.');
      return;
    }

    print('📋 Encontradas ${snapshot.docs.length} citas para migrar.\n');
    
    int actualizadas = 0;
    int conErrores = 0;
    final ahora = DateTime.now();

    for (var doc in snapshot.docs) {
      try {
        final data = doc.data();
        final updates = <String, dynamic>{};
        
        // Verificar si ya tiene los campos nuevos
        bool necesitaActualizacion = false;

        // Agregar campo 'eliminado' si no existe
        if (!data.containsKey('eliminado')) {
          updates['eliminado'] = false;
          necesitaActualizacion = true;
        }

        // Agregar campo 'estado' si no existe
        if (!data.containsKey('estado')) {
          final fecha = (data['fecha'] as Timestamp?)?.toDate();
          if (fecha != null && fecha.isBefore(ahora)) {
            updates['estado'] = 'completada';
          } else {
            updates['estado'] = 'activa';
          }
          necesitaActualizacion = true;
        }

        // Agregar campo 'duracionMinutos' si no existe
        if (!data.containsKey('duracionMinutos')) {
          updates['duracionMinutos'] = 30;
          necesitaActualizacion = true;
        }

        // Agregar campo 'tipoCita' si no existe
        if (!data.containsKey('tipoCita')) {
          updates['tipoCita'] = 'consulta';
          necesitaActualizacion = true;
        }

        // Agregar campo 'razonCancelacion' si no existe
        if (!data.containsKey('razonCancelacion')) {
          updates['razonCancelacion'] = '';
          necesitaActualizacion = true;
        }

        if (necesitaActualizacion) {
          await firestore.collection('citas').doc(doc.id).update(updates);
          actualizadas++;
          print('  ✓ Cita ${doc.id} actualizada');
        } else {
          print('  ⊙ Cita ${doc.id} ya estaba actualizada');
        }
      } catch (e) {
        conErrores++;
        print('  ✗ Error en cita ${doc.id}: $e');
      }
    }

    print('\n✅ Migración completada:');
    print('   - Citas actualizadas: $actualizadas');
    print('   - Citas con errores: $conErrores');
    print('   - Total procesadas: ${snapshot.docs.length}');
  } catch (e) {
    print('\n❌ Error durante la migración:');
    print('   $e');
    rethrow;
  }
}

/// Función main para ejecutar como script independiente
Future<void> main() async {
  await migrarCitasExistentes();
}

