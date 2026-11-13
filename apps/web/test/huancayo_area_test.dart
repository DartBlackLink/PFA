import 'package:flutter_test/flutter_test.dart';
import 'package:ecologistica/core/config/operation_area.dart';

void main() {
  test('Huancayo y alrededores habilitados conservan America/Lima', () {
    for (final p in [
      [-12.0675, -75.2103],
      [-12.05, -75.21],
      [-12.09, -75.21],
      [-12.047, -75.25],
      [-11.99, -75.235],
      [-12.10, -75.22],
      [-12.14, -75.23],
      [-12.141, -75.147],
    ]) {
      expect(OperationArea.contains(p[0], p[1]), isTrue);
    }
    expect(OperationArea.timezone, 'America/Lima');
  });
  test('Lima no es un destino de Huancayo aunque comparta zona horaria', () {
    expect(OperationArea.contains(-12.0519, -77.0346), isFalse);
    expect(OperationArea.contains(double.nan, -75.21), isFalse);
    expect(OperationArea.contains(null, null), isFalse);
  });
}
