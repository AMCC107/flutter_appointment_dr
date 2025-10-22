import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String userName = "Usuario";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
      if (doc.exists && doc.data()!.containsKey('nombre')) {
        setState(() {
          userName = doc['nombre'];
        });
      }
    }
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.pushNamed(context, Routes.messages);
    } else if (index == 2) {
      Navigator.pushNamed(context, Routes.settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text("Menú Principal"),
        backgroundColor: Colors.teal,
        elevation: 3,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "¡Hola, $userName! ¿En qué podemos ayudarte?",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _mainOptionCard(
                  context,
                  icon: Icons.calendar_today,
                  title: "Agendar una Cita",
                  onTap: () {
                    // Aquí se mostrarían las citas desde la colección "citas"
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Próximamente: Agendar Cita")),
                    );
                  },
                ),
                _mainOptionCard(
                  context,
                  icon: Icons.health_and_safety,
                  title: "Consejos Médicos",
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 25),
            const Text(
              "Consejos Médicos Rápidos:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.teal),
            ),
            const SizedBox(height: 10),
            const Text(
              "• Para aliviar un dolor de cabeza leve, hidrátate y descansa en un lugar tranquilo.\n"
              "• Si tienes dolor muscular, aplica compresas tibias y realiza estiramientos suaves.\n"
              "• Para molestias estomacales, evita comidas grasosas y bebe agua con pequeños sorbos.\n"
              "• En caso de resfriado leve, descansa bien y toma líquidos calientes.\n"
              "• Si sientes mareo, recuéstate y respira profundamente hasta que pase.",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),

            const SizedBox(height: 25),
            const Text(
              "Especialistas disponibles:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.teal),
            ),
            const SizedBox(height: 10),
            _buildSpecialistsList(),

            const SizedBox(height: 25),
            const Text(
              "Recomendaciones del día:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.teal),
            ),
            const SizedBox(height: 10),
            _recommendationCard(),
          ],
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

  Widget _mainOptionCard(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(20),
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
          children: [
            Icon(icon, size: 40, color: Colors.teal[800]),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialistsList() {
    final specialists = [
      "Cardiólogo",
      "Pediatra",
      "Dermatólogo",
      "Ginecólogo",
      "Traumatólogo",
    ];
    return Column(
      children: specialists
          .map((s) => ListTile(
                leading: const Icon(Icons.local_hospital, color: Colors.teal),
                title: Text(s, style: const TextStyle(fontSize: 16)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ))
          .toList(),
    );
  }

  Widget _recommendationCard() {
    return Card(
      elevation: 4,
      color: Colors.teal[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "Recuerda revisar tus próximas citas y mantener tus datos médicos actualizados para recibir una mejor atención.",
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
    );
  }
}
