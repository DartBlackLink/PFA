import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecologistica/features/auth/presentation/providers/auth_provider.dart';
import 'package:ecologistica/features/auth/presentation/screens/login_screen.dart';

void main() {
  for (final size in [
    const Size(360, 640),
    const Size(768, 1024),
    const Size(1440, 900),
    const Size(1200, 500),
  ]) {
    testWidgets('Login adaptable ${size.width} x ${size.height}', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final auth = AuthProvider(
        apiUrl: 'http://test/api/v1',
        client: MockClient((r) async => http.Response('{}', 401)),
      );
      await auth.ready;
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: auth,
          child: const MaterialApp(home: LoginScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), null);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(
        find.text('Tu operación,\nun solo lugar.'),
        size.width >= 1000 ? findsOneWidget : findsNothing,
      );
      await tester.ensureVisible(find.byType(FilledButton));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.text('Ingresa un correo válido'), findsOneWidget);
      expect(find.text('La contraseña es obligatoria'), findsOneWidget);
      expect(tester.takeException(), null);
      await tester.pumpWidget(const SizedBox.shrink());
      auth.dispose();
    });
  }
}
