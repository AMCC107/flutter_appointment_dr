import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String userName = "Usuario";
  String userRole = ""; // VACÍO para detectar carga real
  int _recommendationIndex = 0;

  final List<String> _recomendaciones = [
    "Para aliviar un dolor de cabeza leve, hidrátate y descansa en un lugar tranquilo.",
    "Si tienes dolor muscular, aplica compresas tibias y realiza estiramientos suaves.",
    "Para molestias estomacales, evita comidas grasosas y bebe agua con pequeños sorbos.",
    "En caso de resfriado leve, descansa bien y toma líquidos calientes.",
    "Si sientes mareo, recuéstate y respira profundamente hasta que pase.",
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Cargar datos reales desde Firestore
  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snap = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();

    if (snap.exists) {
      final data = snap.data()!;
      setState(() {
        userName = data['nombre'] ?? "Usuario";
        userRole = data['rol'] ?? "paciente";
      });
    }

    // Guardar rol en SharedPreferences 
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', userRole);
  }

  /// Recargar todo con pull-to-refresh
  Future<void> _refreshData() async {
    await _loadUserData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Datos actualizados")),
    );
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    if (index == 1) Navigator.pushNamed(context, Routes.messages);
    if (index == 2) Navigator.pushNamed(context, Routes.settings);
  }

  @override
  Widget build(BuildContext context) {
 
    if (userRole.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.teal)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text("Menú Principal"),
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: false,
      ),

      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.teal,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Text("¡Hola, $userName!",
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal)),
              const SizedBox(height: 6),
              Text(
                userRole == "medico"
                    ? "Panel de control médico"
                    : "¿En qué podemos ayudarte?",
                style: TextStyle(
                    fontSize: 16, color: Colors.teal[700], fontStyle: FontStyle.italic),
              ),
              Chip(
                label: Text(
                  userRole.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                backgroundColor: userRole == 'medico' ? Colors.red : Colors.green,
              ),

              const SizedBox(height: 30),

           
              Column(
                children: [
                 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                   
                      if (userRole == "medico")
                        _mainOptionCard(
                          icon: Icons.dashboard,
                          title: "Ver Citas",
                          onTap: () {
                            Navigator.pushNamed(context, Routes.dashboard);
                          },
                        ),

                    
                      if (userRole == "paciente")
                        _mainOptionCard(
                          icon: Icons.calendar_today,
                          title: "Agendar Cita",
                          onTap: () {
                            Navigator.pushNamed(context, Routes.citas);
                          },
                        ),

                     
                      if (userRole == "medico" || userRole == "paciente")
                        const SizedBox(width: 20),

                     
                      _mainOptionCard(
                        icon: Icons.health_and_safety,
                        title: "Consejos Médicos",
                        onTap: () {
                          setState(() {
                            _recommendationIndex =
                                (_recommendationIndex + 1) % _recomendaciones.length;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_recomendaciones[_recommendationIndex]),
                              backgroundColor: Colors.teal,
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              
              if (userRole == "medico") _buildDoctorQuickActions(),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Mensajes'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configuración'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: _onItemTapped,
      ),
    );
  }

 
  Widget _mainOptionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140, 
        height: 140, 
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.teal[100],
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.teal[800]),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

 
  Widget _buildDoctorQuickActions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _quickActionItem(
                  icon: Icons.today,
                  label: "Citas Hoy",
                  onTap: () => Navigator.pushNamed(context, Routes.dashboard)),
              _quickActionItem(
                  icon: Icons.people,
                  label: "Pacientes",
                  onTap: () => Navigator.pushNamed(context, Routes.dashboard)),
              _quickActionItem(
                  icon: Icons.bar_chart,
                  label: "Estadísticas",
                  onTap: () => Navigator.pushNamed(context, Routes.graphics)),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Accede al Dashboard para ver estadísticas completas",
            style: TextStyle(
                fontSize: 12, color: Colors.teal, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _quickActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.teal,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 5),
          Text(label,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}