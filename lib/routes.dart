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

  
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case citas:
        return MaterialPageRoute(builder: (_) => const CitasPage());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardPage());
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