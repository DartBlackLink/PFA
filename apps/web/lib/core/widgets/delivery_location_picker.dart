import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../network/api_client.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

class DeliveryLocation {
  const DeliveryLocation(this.address, this.point);
  final String address;
  final LatLng point;
}

typedef LocationLookup = Future<List<Map<String, dynamic>>> Function(
  String path,
);

class DeliveryLocationPicker extends StatefulWidget {
  const DeliveryLocationPicker({
    super.key,
    required this.onChanged,
    this.lookup,
    this.showMap = true,
  });
  final ValueChanged<DeliveryLocation?> onChanged;
  final LocationLookup? lookup;
  final bool showMap;
  @override
  State<DeliveryLocationPicker> createState() => _DeliveryLocationPickerState();
}

class _DeliveryLocationPickerState extends State<DeliveryLocationPicker> {
  final _query = TextEditingController();
  final _address = TextEditingController();
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();
  final _map = MapController();
  LatLng? _point;
  List<Map<String, dynamic>> _results = [];
  String? _message;
  String? _mapError;
  bool _busy = false, _confirmed = false, _mapReady = false;
  int _revision = 0;

  @override
  void dispose() {
    for (final c in [_query, _address, _latitude, _longitude]) {
      c.dispose();
    }
    _map.dispose();
    super.dispose();
  }

  void _invalidate() {
    _confirmed = false;
    widget.onChanged(null);
  }

  void _setPoint(LatLng point, {String? address, bool center = false}) {
    setState(() {
      _revision++;
      _invalidate();
      _point = point;
      _latitude.text = point.latitude.toStringAsFixed(7);
      _longitude.text = point.longitude.toStringAsFixed(7);
      if (address != null) {
        _address.text = address;
      }
      _message = null;
      _results = [];
    });
    if (center && _mapReady) {
      _map.move(point, 17);
    }
  }

  Future<void> _lookup({bool reverse = false}) async {
    final q = _query.text.trim();
    if (!reverse && q.length < 3) {
      setState(
        () => _message =
            'Escribe al menos 3 caracteres y añade ciudad o distrito.',
      );
      return;
    }
    final point = _point;
    if (reverse && point == null) {
      return;
    }
    final version = _revision;
    setState(() {
      _busy = true;
      _message = null;
      _results = [];
    });
    try {
      final path = reverse
          ? '/locations/reverse?lat=${point!.latitude}&lon=${point.longitude}'
          : '/locations/search?q=${Uri.encodeQueryComponent(q)}';
      final data = widget.lookup != null
          ? await widget.lookup!(path)
          : ((await ApiClient(
              context.read<AuthProvider>(),
            ).request(path)) as List).cast<Map<String, dynamic>>();
      if (!mounted || version != _revision) {
        return;
      }
      setState(() {
        if (reverse && data.isNotEmpty) {
          _address.text = data.first['direccion'] as String;
          _invalidate();
          _message = 'Dirección aproximada del punto. Verifica número, distrito y entrada.';
        } else {
          _results = data;
          if (data.isEmpty) {
            _message = 'Sin coincidencias. Prueba con ciudad o distrito, o escribe la dirección y toca el mapa.';
          }
        }
      });
    } catch (e) {
      if (mounted && version == _revision) {
        setState(() => _message = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  void _coordinates() {
    final lat = double.tryParse(_latitude.text.trim().replaceAll(',', '.'));
    final lon = double.tryParse(_longitude.text.trim().replaceAll(',', '.'));
    if (lat == null ||
        lon == null ||
        !lat.isFinite ||
        !lon.isFinite ||
        lat < -90 ||
        lat > 90 ||
        lon < -180 ||
        lon > 180) {
      setState(
        () => _message = 'Latitud entre -90 y 90 y longitud entre -180 y 180.',
      );
      return;
    }
    _setPoint(LatLng(lat, lon), center: true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final valid =
        _point != null &&
        _address.text.trim().length >= 5 &&
        _address.text.trim().length <= 255;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Busca un lugar en Perú o marca el destino manualmente. Ajusta el punto hasta la entrada de entrega.',
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _query,
          maxLength: 200,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            labelText: 'Buscar dirección o lugar',
            hintText: 'Ej. Parque de la Identidad, Huancayo',
            counterText: '',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (_) => setState(() {
            _revision++;
            _results = [];
          }),
          onSubmitted: (_) {
            if (!_busy) {
              _lookup();
            }
          },
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _busy ? null : () => _lookup(),
          icon: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.search),
          label: Text(_busy ? 'Buscando...' : 'Buscar en el mapa'),
        ),
        for (final result in _results)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.place_outlined),
            title: Text(result['direccion'] as String),
            subtitle: const Text('Seleccionar y revisar en el mapa'),
            onTap: () => _setPoint(
              LatLng(
                (result['latitud'] as num).toDouble(),
                (result['longitud'] as num).toDouble(),
              ),
              address: result['direccion'] as String,
              center: true,
            ),
          ),
        if (_message != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              _message!,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ),
        const SizedBox(height: 8),
        if (widget.showMap)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 260,
              child: FlutterMap(
                mapController: _map,
                options: MapOptions(
                  initialCenter: const LatLng(-12.0675, -75.2103),
                  initialZoom: 13,
                  onMapReady: () => _mapReady = true,
                  onTap: (_, point) => _setPoint(point),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.ecologistica.app',
                    errorTileCallback: (_, _, _) {
                      if (_mapError == null && mounted) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(
                              () => _mapError = 'No se pudo cargar el mapa. Puedes usar coordenadas manuales.',
                            );
                          }
                        });
                      }
                    },
                  ),
                  if (_point != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _point!,
                          width: 48,
                          height: 48,
                          alignment: Alignment.topCenter,
                          child: Icon(
                            Icons.location_pin,
                            color: const Color(0xFFC62828),
                            size: 48,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            'Mapa y direcciones © OpenStreetMap contributors · Photon',
            style: TextStyle(fontSize: 11),
          ),
        ),
        if (_mapError != null)
          Text(_mapError!, style: TextStyle(color: colors.error)),
        const SizedBox(height: 12),
        TextFormField(
          controller: _address,
          maxLength: 255,
          minLines: 1,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Dirección de entrega',
            hintText: 'Calle, número o lote, distrito y ciudad',
            helperText:
                'Completa el número o lote si la búsqueda no lo incluye.',
          ),
          validator: (v) => (v?.trim().length ?? 0) < 5
              ? 'Escribe una dirección de al menos 5 caracteres.'
              : null,
          onChanged: (_) => setState(() {
            _revision++;
            _invalidate();
          }),
        ),
        TextButton.icon(
          onPressed: _busy || _point == null
              ? null
              : () => _lookup(reverse: true),
          icon: const Icon(Icons.my_location),
          label: const Text('Consultar dirección del punto'),
        ),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: const Text('Editar coordenadas manualmente'),
          children: [
            TextField(
              controller: _latitude,
              decoration: const InputDecoration(labelText: 'Latitud'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              onChanged: (_) => setState(() {
                _revision++;
                _invalidate();
                _point = null;
              }),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _longitude,
              decoration: const InputDecoration(labelText: 'Longitud'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              onChanged: (_) => setState(() {
                _revision++;
                _invalidate();
                _point = null;
              }),
            ),
            TextButton(
              onPressed: _coordinates,
              child: const Text('Aplicar coordenadas'),
            ),
          ],
        ),
        if (_point != null)
          Text(
            'Punto seleccionado: ${_point!.latitude.toStringAsFixed(7)}, ${_point!.longitude.toStringAsFixed(7)}',
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
          ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: _confirmed,
          title: const Text(
            'Confirmo que la dirección y el punto corresponden a la entrega.',
          ),
          subtitle: Text(
            valid
                ? 'Verifica el número, distrito y la entrada antes de confirmar.'
                : 'Escribe la dirección y selecciona un punto para confirmar.',
          ),
          onChanged: valid
              ? (value) => setState(() {
                  _confirmed = value ?? false;
                  widget.onChanged(
                    _confirmed
                        ? DeliveryLocation(_address.text.trim(), _point!)
                        : null,
                  );
                })
              : null,
        ),
      ],
    );
  }
}
