import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;

  Future<void> _recargarFormulario() async {
    await Future.delayed(const Duration(milliseconds: 700));
    setState(() {
      emailController.clear();
      passwordController.clear();
      _obscurePassword = true;
      _rememberMe = false;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _showCupertinoError(String title, String message) async {
    if (!mounted) return;
    await showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(message),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  Future<void> _signIn() async {
    final email = emailController.text.trim();
    final pass = passwordController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      await _showCupertinoError('Campos incompletos', 'Ingresa correo y contraseña');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.home);

    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'user-not-found') message = 'Usuario no encontrado';
      else if (e.code == 'wrong-password') message = 'Contraseña incorrecta';
      else message = e.message ?? 'Error desconocido';

      await _showCupertinoError('Error de autenticación', message);
    } catch (e) {
      await _showCupertinoError('Error', e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onDoubleTapImage() {
    showCupertinoDialog(
      context: context,
      builder: (_) => const CupertinoAlertDialog(
        title: Text('👋 Bienvenido'),
        content: Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(''),
        ),
        actions: [
          CupertinoDialogAction(child: Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark = brightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: isDark
          ? CupertinoColors.systemBackground
          : CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            CupertinoSliverNavigationBar(
              largeTitle: const Text(''),
              backgroundColor: isDark
                  ? CupertinoColors.systemBackground
                  : CupertinoColors.systemGroupedBackground,
            ),

            CupertinoSliverRefreshControl(
              onRefresh: _recargarFormulario,
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Título principal
                    const Text(
                      'Sistema de Citas Médicas',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(height: 32),

                    // Imagen
                    GestureDetector(
                      onDoubleTap: _onDoubleTapImage,
                      child: Container(
                        height: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://kffhealthnews.org/wp-content/uploads/sites/2/2018/03/telemedicine.jpg?w=1024',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Formulario
                    Container(
                      padding: const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        color: isDark
                            ? CupertinoColors.secondarySystemBackground
                            : CupertinoColors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(
                              color: CupertinoColors.systemGrey.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Campo email
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: CupertinoColors.systemGrey5,
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: CupertinoTextField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              placeholder: 'Correo electrónico',
                              placeholderStyle: TextStyle(
                                color: CupertinoColors.systemGrey,
                                fontWeight: FontWeight.w400,
                              ),
                              prefix: const Padding(
                                padding: EdgeInsets.only(left: 16, right: 8),
                                child: Icon(CupertinoIcons.mail_solid, 
                                    size: 20, 
                                    color: CupertinoColors.systemGrey),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                              decoration: const BoxDecoration(
                                color: CupertinoColors.transparent,
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),

                          // Campo contraseña
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: CupertinoColors.systemGrey5,
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: CupertinoTextField(
                              controller: passwordController,
                              obscureText: _obscurePassword,
                              placeholder: 'Contraseña',
                              placeholderStyle: TextStyle(
                                color: CupertinoColors.systemGrey,
                                fontWeight: FontWeight.w400,
                              ),
                              prefix: const Padding(
                                padding: EdgeInsets.only(left: 16, right: 8),
                                child: Icon(CupertinoIcons.lock_fill, 
                                    size: 20, 
                                    color: CupertinoColors.systemGrey),
                              ),
                              suffix: GestureDetector(
                                onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Icon(
                                    _obscurePassword
                                        ? CupertinoIcons.eye_slash
                                        : CupertinoIcons.eye,
                                    size: 18,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                              decoration: const BoxDecoration(
                                color: CupertinoColors.transparent,
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),

                          // Recordarme
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Recordarme',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: CupertinoColors.systemGrey,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                CupertinoSwitch(
                                  value: _rememberMe,
                                  onChanged: (v) => setState(() => _rememberMe = v),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Botón iniciar sesión
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton.filled(
                        onPressed: _isLoading ? null : _signIn,
                        borderRadius: BorderRadius.circular(12),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: _isLoading
                            ? const CupertinoActivityIndicator()
                            : const Text(
                                'Iniciar sesión',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Enlaces secundarios
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            showCupertinoDialog(
                              context: context,
                              builder: (_) => const CupertinoAlertDialog(
                                title: Text('Recuperar contraseña'),
                                content: Text('Función de recuperar contraseña (próximamente)'),
                                actions: [
                                  CupertinoDialogAction(
                                    child: Text('Aceptar'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Text(
                            '¿Olvidó su contraseña?',
                            style: TextStyle(
                              color: CupertinoColors.systemBlue,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),

                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            showCupertinoDialog(
                              context: context,
                              builder: (_) => const CupertinoAlertDialog(
                                title: Text('Registro'),
                                content: Text('Registro de nueva cuenta (próximamente)'),
                                actions: [
                                  CupertinoDialogAction(
                                    child: Text('Aceptar'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Text(
                            'Crear cuenta',
                            style: TextStyle(
                              color: CupertinoColors.systemBlue,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Ayuda
                    Center(
                      child: Column(
                        children: [
                          Text(
                            '¿Necesitas ayuda?',
                            style: TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.systemGrey,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _isLoading
                              ? const CupertinoActivityIndicator(radius: 10)
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}