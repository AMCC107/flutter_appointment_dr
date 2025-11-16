import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String? _userRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('usuarios').doc(user.uid).get();
      setState(() {
        _userRole = doc.data()?['rol'] ?? 'paciente';
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userRole != 'medico') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          backgroundColor: Colors.redAccent,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Acceso Denegado',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Solo los usuarios con rol de médico pueden acceder a esta página.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Dashboard Médico'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('citas').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final citas = snapshot.data!.docs;
          final now = DateTime.now();

          // Calcular estadísticas
          final totalCitas = citas.length;
          final citasPendientes = citas.where((cita) {
            final data = cita.data() as Map<String, dynamic>;
            final fechaCita = (data['fecha'] as Timestamp?)?.toDate();
            return fechaCita != null && fechaCita.isAfter(now);
          }).length;

          // Obtener pacientes únicos
          final pacientesUnicos = <String>{};
          for (var cita in citas) {
            final data = cita.data() as Map<String, dynamic>;
            final paciente = data['paciente']?.toString() ?? '';
            if (paciente.isNotEmpty) {
              pacientesUnicos.add(paciente);
            }
          }
          final totalPacientes = pacientesUnicos.length;

          return SingleChildScrollView( 
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumen General',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 8), 
                const Text(
                  'Estadísticas en tiempo real',
                  style: TextStyle(
                    fontSize: 14, 
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20), 
                
                // Grid de indicadores
                GridView.count(
                  shrinkWrap: true, 
                  physics: const NeverScrollableScrollPhysics(), 
                  crossAxisCount: 2,
                  crossAxisSpacing: 12, 
                  mainAxisSpacing: 12, 
                  childAspectRatio: 1.0, 
                  children: [
                    _buildStatCard(
                      title: 'Total de Citas',
                      value: totalCitas.toString(),
                      icon: Icons.calendar_today,
                      color: Colors.blue,
                      subtitle: 'Citas creadas',
                    ),
                    _buildStatCard(
                      title: 'Citas Pendientes',
                      value: citasPendientes.toString(),
                      icon: Icons.access_time,
                      color: Colors.orange,
                      subtitle: 'Próximas citas',
                    ),
                    _buildStatCard(
                      title: 'Total Pacientes',
                      value: totalPacientes.toString(),
                      icon: Icons.people,
                      color: Colors.green,
                      subtitle: 'Pacientes únicos',
                    ),
                    _buildStatCard(
                      title: 'Citas Hoy',
                      value: _getCitasHoy(citas).toString(),
                      icon: Icons.today,
                      color: Colors.purple,
                      subtitle: 'Citas para hoy',
                    ),
                  ],
                ),
                
                const SizedBox(height: 24), 
                
                // Lista de próximas citas
                _buildProximasCitas(citas),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
      child: Padding(
        padding: const EdgeInsets.all(12.0), 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10), 
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24), 
            ),
            const SizedBox(height: 8), 
            Text(
              value,
              style: const TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2), 
            Text(
              title,
              style: TextStyle(
                fontSize: 12, 
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2), 
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10, 
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProximasCitas(List<QueryDocumentSnapshot> citas) {
    final now = DateTime.now();
    final citasFuturas = citas.where((cita) {
      final data = cita.data() as Map<String, dynamic>;
      final fechaCita = (data['fecha'] as Timestamp?)?.toDate();
      return fechaCita != null && fechaCita.isAfter(now);
    }).toList();

    // Ordenar por fecha más próxima
    citasFuturas.sort((a, b) {
      final fechaA = (a.data() as Map<String, dynamic>)['fecha'] as Timestamp;
      final fechaB = (b.data() as Map<String, dynamic>)['fecha'] as Timestamp;
      return fechaA.compareTo(fechaB);
    });

    final proximasCitas = citasFuturas.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Próximas Citas',
          style: TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 12), 
        if (proximasCitas.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Icon(Icons.event_available, size: 48, color: Colors.grey), 
                SizedBox(height: 8),
                Text(
                  'No hay citas programadas',
                  style: TextStyle(fontSize: 14, color: Colors.grey), 
                ),
              ],
            ),
          )
        else
          Column(
            children: proximasCitas.map((cita) {
              final data = cita.data() as Map<String, dynamic>;
              final fecha = (data['fecha'] as Timestamp?)?.toDate();
              final inicio = (data['horaInicio'] as Timestamp?)?.toDate();
              final fin = (data['horaFin'] as Timestamp?)?.toDate();

              return Card(
                margin: const EdgeInsets.only(bottom: 8), 
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), 
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, 
                    vertical: 4, 
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(6), 
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.medical_services, 
                        color: Colors.blue, size: 20), 
                  ),
                  title: Text(
                    data['motivo'] ?? 'Sin motivo',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14, 
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text('Paciente: ${data['paciente'] ?? ''}',
                          style: const TextStyle(fontSize: 12)), 
                      if (fecha != null)
                        Text('Fecha: ${fecha.toLocal().toString().split(" ")[0]}',
                            style: const TextStyle(fontSize: 12)), 
                      if (inicio != null && fin != null)
                        Text(
                          'Hora: ${inicio.hour}:${inicio.minute.toString().padLeft(2, '0')} - ${fin.hour}:${fin.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 12), 
                        ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14), 
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  int _getCitasHoy(List<QueryDocumentSnapshot> citas) {
    final now = DateTime.now();
    final hoy = DateTime(now.year, now.month, now.day);
    
    return citas.where((cita) {
      final data = cita.data() as Map<String, dynamic>;
      final fechaCita = (data['fecha'] as Timestamp?)?.toDate();
      if (fechaCita == null) return false;
      
      final fechaCitaNormalizada = DateTime(
        fechaCita.year,
        fechaCita.month,
        fechaCita.day,
      );
      
      return fechaCitaNormalizada == hoy;
    }).length;
  }
}