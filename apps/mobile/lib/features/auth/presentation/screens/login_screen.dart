import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/theme_controller.dart';
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
    final controller = context.watch<ThemeController?>();
    final s = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: ExcludeSemantics(
              child: CustomPaint(painter: _LoginBackdrop(dark)),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 1000;
                final compact = constraints.maxWidth < 400;
                final form = _accessForm(auth, compact);
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: wide ? 56 : 20,
                        vertical: 24,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: s.primary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.eco_rounded,
                                      color: s.onPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'EcoLogística',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -.6,
                                            color: s.onSurface,
                                          ),
                                        ),
                                        Text(
                                          'HUANCAYO',
                                          style: TextStyle(
                                            fontSize: 10,
                                            letterSpacing: 2,
                                            color: s.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: dark
                                        ? 'Activar modo claro'
                                        : 'Activar modo oscuro',
                                    onPressed: controller?.toggle,
                                    icon: Icon(
                                      dark
                                          ? Icons.light_mode_outlined
                                          : Icons.dark_mode_outlined,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: wide ? 64 : 36),
                              if (wide)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(flex: 6, child: _intro(s)),
                                    const SizedBox(width: 64),
                                    Expanded(flex: 5, child: form),
                                  ],
                                )
                              else
                                Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 460,
                                    ),
                                    child: form,
                                  ),
                                ),
                              const SizedBox(height: 32),
                              Text(
                                'EcoLogística Huancayo · Gestión de entregas',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: s.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _intro(ColorScheme s) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: s.surface,
          border: Border.all(color: s.outlineVariant),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.route_outlined, size: 16, color: s.secondary),
            const SizedBox(width: 8),
            Text(
              'CADA ENTREGA EMPIEZA AQUÍ',
              style: TextStyle(
                color: s.onSurfaceVariant,
                fontSize: 10,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      Text(
        'Tu operación,\nun solo lugar.',
        style: TextStyle(
          color: s.onSurface,
          fontSize: 46,
          height: 1.1,
          letterSpacing: -1.7,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 20),
      Text(
        'Un espacio para organizar pedidos, conectar a tu equipo y dar claridad a cada recorrido.',
        style: TextStyle(fontSize: 16, height: 1.7, color: s.onSurfaceVariant),
      ),
      const SizedBox(height: 28),
      ExcludeSemantics(
        child: SizedBox(
          height: 210,
          width: double.infinity,
          child: CustomPaint(painter: _DeliveryScene(s)),
        ),
      ),
      const SizedBox(height: 20),
      Wrap(
        spacing: 20,
        runSpacing: 12,
        children: [
          for (final item in [
            (Icons.inventory_2_outlined, 'Pedidos'),
            (Icons.groups_outlined, 'Equipo'),
            (Icons.alt_route, 'Rutas'),
          ])
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.$1, color: s.onSurfaceVariant, size: 18),
                const SizedBox(width: 8),
                Text(
                  item.$2,
                  style: TextStyle(color: s.onSurfaceVariant, fontSize: 13),
                ),
              ],
            ),
        ],
      ),
    ],
  );

  Widget _accessForm(AuthProvider auth, bool compact) {
    final s = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(compact ? 24 : 36),
      decoration: BoxDecoration(
        color: s.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: s.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark
                  ? .18
                  : .06,
            ),
            blurRadius: 36,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: s.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  color: s.onSurface,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'BIENVENIDO A ECOLOGÍSTICA',
              style: TextStyle(
                color: s.onSurfaceVariant,
                fontSize: 10,
                letterSpacing: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ingresa a tu espacio',
              style: TextStyle(
                fontSize: compact ? 25 : 29,
                letterSpacing: -.8,
                fontWeight: FontWeight.w800,
                color: s.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Usa tu cuenta de administrador o repartidor.',
              style: TextStyle(color: s.onSurfaceVariant, height: 1.6),
            ),
            const SizedBox(height: 28),
            TextFormField(
              controller: _email,
              enabled: !auth.estaCargando,
              autofillHints: const [AutofillHints.username],
              keyboardType: TextInputType.emailAddress,
              onChanged: auth.actualizarCorreo,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
              validator: (v) =>
                  RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                      .hasMatch(v?.trim() ?? '')
                  ? null
                  : 'Ingresa un correo válido',
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _password,
              enabled: !auth.estaCargando,
              obscureText: _ocultar,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) => _enviar(),
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock_outline),
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
                  child: Text(auth.error!, style: TextStyle(color: s.error)),
                ),
              ),
            if (auth.bloqueado)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Inténtalo de nuevo en ${auth.contador}',
                  key: const Key('login-countdown'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: auth.bloqueado || auth.estaCargando || auth.restaurando
                  ? null
                  : _enviar,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: auth.estaCargando || auth.restaurando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              'Iniciar sesión',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            Divider(color: s.outlineVariant),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 18,
                  color: s.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Acceso según tu rol. No compartas tus credenciales.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.6,
                      color: s.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginBackdrop extends CustomPainter {
  const _LoginBackdrop(this.dark);
  final bool dark;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = dark ? const Color(0xFF121923) : const Color(0xFFF4F6F9),
    );
    final ink = dark ? const Color(0xFF91A4BF) : const Color(0xFF8B9FB9);
    final paint = Paint()
      ..color = ink.withValues(alpha: dark ? .06 : .10)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 64) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 64) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    canvas.drawCircle(
      Offset(size.width * .08, size.height * .15),
      270,
      Paint()
        ..color = const Color(0xFFCF9F56).withValues(alpha: dark ? .045 : .07),
    );
    canvas.drawCircle(
      Offset(size.width * .95, size.height * .82),
      250,
      Paint()..color = const Color(0xFF6A8DAB).withValues(alpha: .06),
    );
  }

  @override
  bool shouldRepaint(covariant _LoginBackdrop old) => old.dark != dark;
}

/// Ilustración vectorial de un centro de distribución; no representa GPS real.
class _DeliveryScene extends CustomPainter {
  const _DeliveryScene(this.scheme);
  final ColorScheme scheme;
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final muted = Paint()..color = scheme.surfaceContainerHighest;
    final line = Paint()
      ..color = scheme.outlineVariant
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 5; i++) {
      final x = 22 + i * (w - 70) / 5;
      final h = [60.0, 95.0, 48.0, 80.0, 55.0][i];
      final box = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 120 - h, 48, h),
        const Radius.circular(5),
      );
      canvas.drawRRect(box, muted);
      canvas.drawRRect(box, line);
      for (var k = 0; k < 3; k++) {
        canvas.drawLine(
          Offset(x + 12, 132 - h + k * 15),
          Offset(x + 34, 132 - h + k * 15),
          line,
        );
      }
    }
    final road = Path()
      ..moveTo(18, 168)
      ..lineTo(w * .25, 168)
      ..cubicTo(w * .50, 168, w * .45, 85, w * .70, 85)
      ..lineTo(w - 20, 85);
    canvas.drawPath(
      road,
      Paint()
        ..color = scheme.outlineVariant
        ..strokeWidth = 16
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      road,
      Paint()
        ..color = scheme.secondary
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );
    for (final p in [const Offset(18, 168), Offset(w - 20, 85)]) {
      canvas.drawCircle(p, 12, Paint()..color = scheme.surface);
      canvas.drawCircle(p, 6, Paint()..color = scheme.primary);
    }
    final center = Offset(w * .43, 145);
    final truck = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 76, height: 38),
      const Radius.circular(7),
    );
    canvas.drawRRect(truck, Paint()..color = scheme.primary);
    canvas.drawRect(
      Rect.fromLTWH(center.dx + 17, center.dy - 10, 15, 13),
      Paint()..color = scheme.primaryContainer,
    );
    for (final x in [center.dx - 22, center.dx + 23]) {
      canvas.drawCircle(
        Offset(x, center.dy + 19),
        7,
        Paint()..color = scheme.onSurface,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DeliveryScene old) => old.scheme != scheme;
}
