import 'dart:async';
import 'dart:js_interop';

extension type _Position(JSObject _) implements JSObject {
  external _Coordinates get coords;
}

extension type _Coordinates(JSObject _) implements JSObject {
  external double get latitude;
  external double get longitude;
  external double get accuracy;
}

@JS('navigator.geolocation.getCurrentPosition')
external void _position(
  JSFunction success,
  JSFunction failure,
  JSObject options,
);

Future<Map<String, double>> currentLocation() async {
  final result = Completer<Map<String, double>>();
  try {
    _position(
      ((_Position p) {
        if (!result.isCompleted) {
          result.complete({
            'latitud': p.coords.latitude,
            'longitud': p.coords.longitude,
            'precision_m': p.coords.accuracy,
          });
        }
      }).toJS,
      ((JSAny? error) {
        if (!result.isCompleted) {
          result.completeError(
            Exception(
              'GPS no disponible o permiso denegado. Puedes reportar sin ubicación.',
            ),
          );
        }
      }).toJS,
      {'enableHighAccuracy': true, 'timeout': 10000, 'maximumAge': 0}.jsify()!
          as JSObject,
    );
  } catch (_) {
    throw Exception(
      'Este navegador no ofrece GPS. Puedes reportar sin ubicación.',
    );
  }
  return result.future.timeout(const Duration(seconds: 12));
}
