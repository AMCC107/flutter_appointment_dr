import 'package:flutter/material.dart';
import '../models/especialidad.dart';
import '../models/medico.dart';
import '../services/firestore_service.dart';
import '../widgets/medico_card.dart';
import '../routes.dart';
import 'medico_detalle_page.dart';

class EspecialistasPage extends StatelessWidget {
  final Especialidad especialidad;

  const EspecialistasPage({
    super.key,
    required this.especialidad,
  });

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text('Especialistas - ${especialidad.nombre}'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: StreamBuilder<List<Medico>>(
        stream: firestoreService.getMedicosPorEspecialidad(especialidad.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medical_services, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay médicos disponibles',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final medicos = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: medicos.length,
            itemBuilder: (context, index) {
              final medico = medicos[index];
              return MedicoCard(
                medico: medico,
                onVerHorarios: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MedicoDetallePage(medico: medico),
                    ),
                  );
                },
                onSeleccionar: () {
                  Navigator.pushNamed(
                    context,
                    Routes.citas,
                    arguments: medico,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

