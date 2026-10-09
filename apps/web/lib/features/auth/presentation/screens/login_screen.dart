import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController(), _password = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _ocultar = true;
  Future<void> _enviar() async {
    final auth = context.read<AuthProvider>();
    if (auth.bloqueado ||
        auth.estaCargando ||
        !_form.currentState!.validate()) {
      return;
    }
    await auth.iniciarSesion(_email.text, _password.text);
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    final compact = MediaQuery.sizeOf(context).width < 400;
    final form = Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Card(
            elevation: 3,
            child: Padding(
              padding: EdgeInsets.all(compact ? 24 : 36),
              child: Form(
                key: _form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      size: 56,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'EcoLogística Huancayo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Inicia sesión para acceder a tu espacio de trabajo',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _email,
                      enabled: !auth.estaCargando,
                      autofillHints: const [AutofillHints.username],
                      keyboardType: TextInputType.emailAddress,
                      onChanged: auth.actualizarCorreo,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                              .hasMatch(v?.trim() ?? '')
                          ? null
                          : 'Ingresa un correo válido',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      enabled: !auth.estaCargando,
                      obscureText: _ocultar,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _enviar(),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          tooltip: _ocultar
                              ? 'Mostrar contraseña'
                              : 'Ocultar contraseña',
                          onPressed: () => setState(() => _ocultar = !_ocultar),
                          icon: Icon(
                            _ocultar
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? 'La contraseña es obligatoria'
                          : null,
                    ),
                    if (auth.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Semantics(
                          liveRegion: true,
                          child: Text(
                            auth.error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ),
                    if (auth.bloqueado)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          'Inténtalo de nuevo en ${auth.contador}',
                          key: const Key('login-countdown'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed:
                          auth.bloqueado ||
                              auth.estaCargando ||
                              auth.restaurando
                          ? null
                          : _enviar,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: auth.estaCargando || auth.restaurando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Iniciar sesión'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Acceso para administradores y repartidores',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: wide
            ? Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF103C30), Color(0xFF1B6D53)],
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(56),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 500),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.eco_rounded,
                                  color: Color(0xFF8DE1B9),
                                  size: 64,
                                ),
                                SizedBox(height: 32),
                                Text(
                                  'Tu operación,\nun solo lugar.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 46,
                                    fontWeight: FontWeight.w800,
                                    height: 1.15,
                                  ),
                                ),
                                SizedBox(height: 24),
                                Text(
                                  'Organiza la flota, gestiona a tu equipo y consulta tus pedidos con información centralizada.',
                                  style: TextStyle(
                                    color: Color(0xFFD0E8DD),
                                    fontSize: 18,
                                    height: 1.6,
                                  ),
                                ),
                                SizedBox(height: 40),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      color: Color(0xFF8DE1B9),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Acceso según tu rol',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.devices_outlined,
                                      color: Color(0xFF8DE1B9),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Una Web adaptable a tus dispositivos',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: form),
                ],
              )
            : form,
      ),
    );
  }
}
