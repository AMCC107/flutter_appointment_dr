import 'package:flutter/material.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'messages_page.dart';
import 'settings_page.dart';
import 'privacy_page.dart';
import 'about_page.dart';
import 'citas_page.dart';
import 'dashboard_page.dart';
import 'screens/graphics_page.dart';
import 'pages/especialistas_page.dart';
import 'pages/medico_detalle_page.dart';
import 'models/especialidad.dart';
import 'models/medico.dart';

class Routes {
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String messages = '/messages';
  static const String settings = '/settings';
  static const String privacy = '/privacy';
  static const String about = '/about';
  static const String citas = '/citas';
  static const String dashboard = '/dashboard';
  static const String graphics = '/graphics';
  static const String especialistas = '/especialistas';
  static const String medicoDetalle = '/medico-detalle';

  
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case citas:
        final medico = routeSettings.arguments as Medico?;
        return MaterialPageRoute(
          builder: (_) => CitasPage(medicoSeleccionado: medico),
        );
      case especialistas:
        final especialidad = routeSettings.arguments as Especialidad;
        return MaterialPageRoute(
          builder: (_) => EspecialistasPage(especialidad: especialidad),
        );
      case medicoDetalle:
        final medico = routeSettings.arguments as Medico;
        return MaterialPageRoute(
          builder: (_) => MedicoDetallePage(medico: medico),
        );
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardPage());
      case graphics:
        return MaterialPageRoute(builder: (_) => const GraphicsPage());
      case messages:
        return MaterialPageRoute(builder: (_) => const MessagesPage());
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case privacy:
        return MaterialPageRoute(builder: (_) => const PrivacyPage());
      case about:
        return MaterialPageRoute(builder: (_) => const AboutPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${routeSettings.name}'),
            ),
          ),
        );
    }
  }
}