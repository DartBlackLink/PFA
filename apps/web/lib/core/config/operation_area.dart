/// Technical operating envelope approved for Huancayo and urban surroundings.
/// It is not an administrative district boundary. Server validation prevails.
class OperationArea {
  static const south = -12.18, north = -11.94, west = -75.32, east = -75.12;
  static const latitude = -12.0675, longitude = -75.2103;
  static const name = 'Huancayo y alrededores urbanos, Junín, Perú';
  static const timezone = 'America/Lima';
  static bool contains(Object? lat, Object? lon) {
    final a = double.tryParse('$lat'), b = double.tryParse('$lon');
    return a != null &&
        b != null &&
        a.isFinite &&
        b.isFinite &&
        a >= south &&
        a <= north &&
        b >= west &&
        b <= east;
  }
}
