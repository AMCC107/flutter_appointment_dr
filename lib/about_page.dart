import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre nosotros')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'DoctorAppointment es una app de ejemplo para gestionar citas médicas. Su objetivo es demostrar autenticación, navegación y manejo básico de datos.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}


