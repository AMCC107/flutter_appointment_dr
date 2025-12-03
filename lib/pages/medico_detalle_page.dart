import 'package:flutter/material.dart';
import '../models/medico.dart';
import '../routes.dart';

class MedicoDetallePage extends StatelessWidget {
  final Medico medico;

  const MedicoDetallePage({
    super.key,
    required this.medico,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text('Detalle del Médico'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta principal del médico
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.teal[100],
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.teal[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      medico.nombre,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      medico.especialidad,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStarRating(medico.calificacion),
                        const SizedBox(width: 8),
                        Text(
                          '${medico.calificacion}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Información detallada
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      Icons.description,
                      'Descripción',
                      medico.descripcion,
                    ),
                    const Divider(),
                    _buildInfoRow(
                      Icons.work,
                      'Experiencia',
                      medico.experiencia,
                    ),
                    const Divider(),
                    _buildInfoRow(
                      Icons.phone,
                      'Teléfono',
                      medico.telefono,
                    ),
                    const Divider(),
                    _buildInfoRow(
                      Icons.email,
                      'Email',
                      medico.email,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Horario semanal
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Horario Semanal',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildHorarioDia('Lunes', medico.horario.lunes),
                    _buildHorarioDia('Martes', medico.horario.martes),
                    _buildHorarioDia('Miércoles', medico.horario.miercoles),
                    _buildHorarioDia('Jueves', medico.horario.jueves),
                    _buildHorarioDia('Viernes', medico.horario.viernes),
                    _buildHorarioDia('Sábado', medico.horario.sabado),
                    _buildHorarioDia('Domingo', medico.horario.domingo),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Botón para agendar cita
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    Routes.citas,
                    arguments: medico,
                  );
                },
                icon: const Icon(Icons.calendar_today),
                label: const Text(
                  'Agendar Cita con este médico',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.teal),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHorarioDia(String dia, HorarioDia? horario) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            dia,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            horario != null
                ? '${horario.inicio} - ${horario.fin}'
                : 'Cerrado',
            style: TextStyle(
              fontSize: 16,
              color: horario != null ? Colors.black87 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor()
              ? Icons.star
              : (index < rating ? Icons.star_half : Icons.star_border),
          color: Colors.amber,
          size: 24,
        );
      }),
    );
  }
}

