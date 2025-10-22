
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'routes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Configuración')),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Perfil'),
            onTap: () => Navigator.pushNamed(context, Routes.profile),
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Privacidad'),
            onTap: () => Navigator.pushNamed(context, Routes.privacy),
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('Sobre nosotros'),
            onTap: () => Navigator.pushNamed(context, Routes.about),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Cerrar sesión'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, Routes.login);
            },
          ),
        ],
      ),
    );
  }
}
