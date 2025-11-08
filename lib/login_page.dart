import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _obscurePassword = true;

  /// Recarga del formulario 
  Future<void> _recargarFormulario() async {
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      emailController.clear();
      passwordController.clear();
      _obscurePassword = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("🔄 Formulario recargado")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      /// TAP en cualquier lugar → Cerrar teclado
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: _recargarFormulario, // Pull-to-Refresh
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Sistema de Citas Médicas',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  /// GESTO: Doble Tap sobre la imagen
                  Center(
                    child: GestureDetector(
                      onDoubleTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("👋 Bienvenido a DoctorAppointmentApp")),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          'https://kffhealthnews.org/wp-content/uploads/sites/2/2018/03/telemedicine.jpg?w=1024',
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.medical_services, size: 50, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Imagen no disponible', style: TextStyle(color: Colors.grey)),
                              ],
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu correo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Contraseña",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Por favor ingresa tu contraseña";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('🔐 Función de recuperar contraseña')),
                      );
                    },
                    child: const Text(
                      '¿Olvidó su contraseña?',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          UserCredential userCredential =
                              await _auth.signInWithEmailAndPassword(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Bienvenido ${userCredential.user!.email}")),
                          );

                          Navigator.pushReplacementNamed(context, Routes.home);

                        } on FirebaseAuthException catch (e) {
                          String message = "";
                          if (e.code == 'user-not-found') {
                            message = "Usuario no encontrado";
                          } else if (e.code == 'wrong-password') {
                            message = "Contraseña incorrecta";
                          } else {
                            message = e.message!;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(message)),
                          );
                        }
                      }
                    },
                    child: const Text("Iniciar sesión"),
                  ),

                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('🆕 Registro de nueva cuenta (próximamente)')),
                      );
                    },
                    child: const Text('Crear una cuenta nueva'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
