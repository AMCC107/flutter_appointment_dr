import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacidad')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Tu privacidad es importante. Esta aplicación almacena únicamente la información necesaria para brindarte un mejor servicio. Tus datos no serán compartidos con terceros sin tu consentimiento.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}


