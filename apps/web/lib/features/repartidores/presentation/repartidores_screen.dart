import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../auth/presentation/providers/auth_provider.dart';

class RepartidoresScreen extends StatefulWidget {
  const RepartidoresScreen({super.key});
  @override
  State<RepartidoresScreen> createState() => _RepartidoresScreenState();
}

class _RepartidoresScreenState extends State<RepartidoresScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;
  String _search = '';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiClient(context.read<AuthProvider>())
          .request('/drivers/?limit=1000');
      if (mounted) {
        setState(() => _items = (data as List).cast<Map<String, dynamic>>());
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _edit([Map<String, dynamic>? item]) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DriverForm(item: item),
    );
    if (saved == true && mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _items
        .where(
          (e) => '${e['nombre']} ${e['dni']} ${e['licencia']}'
              .toLowerCase()
              .contains(_search.toLowerCase()),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 20,
          runSpacing: 12,
          children: [
            const Text(
              'Repartidores',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            FilledButton.icon(
              onPressed: () => _edit(),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Nuevo repartidor'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Identidad, disponibilidad y acceso de cada conductor.'),
        const SizedBox(height: 20),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Buscar por nombre, DNI o licencia',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: (s) => setState(() => _search = s),
        ),
        const SizedBox(height: 16),
        if (_loading) const LinearProgressIndicator(),
        if (_error != null)
          Card(
            child: ListTile(
              title: Text(_error!),
              trailing: TextButton(
                onPressed: _load,
                child: const Text('Reintentar'),
              ),
            ),
          ),
        if (!_loading && visible.isEmpty && _error == null)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('No hay repartidores que coincidan con la búsqueda.'),
          ),
        ...visible.map(
          (e) => Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(e['nombre'].toString()),
              subtitle: Text(
                'DNI: ${e['dni']} · Licencia: ${e['licencia']} (${e['categoria_licencia']})\nContacto: ${e['contacto'] ?? 'Completar'}\nHorario: ${e['disponible_desde'] ?? 'Completar'} — ${e['disponible_hasta'] ?? 'Completar'}\n${e['correo'] ?? ''} · ${e['estado']}',
              ),
              isThreeLine: false,
              trailing: IconButton(
                tooltip: 'Editar repartidor',
                onPressed: () => _edit(e),
                icon: const Icon(Icons.edit_outlined),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
            label: const Text('Actualizar'),
          ),
        ),
      ],
    );
  }
}

class _DriverForm extends StatefulWidget {
  const _DriverForm({this.item});
  final Map<String, dynamic>? item;
  @override
  State<_DriverForm> createState() => _DriverFormState();
}

class _DriverFormState extends State<_DriverForm> {
  final _form = GlobalKey<FormState>();
  final Map<String, TextEditingController> _fields = {};
  bool _saving = false;
  String? _error;
  String _estado = 'ACTIVO';
  static const labels = {
    'nombre': 'Nombre completo',
    'dni': 'DNI (8 dígitos)',
    'licencia': 'Número de licencia',
    'categoria_licencia': 'Categoría de licencia',
    'anios_experiencia': 'Años de experiencia',
    'contacto': 'Teléfono de contacto',
    'disponible_desde': 'Disponible desde (HH:mm)',
    'disponible_hasta': 'Disponible hasta (HH:mm)',
    'origen_latitud': 'Latitud de partida',
    'origen_longitud': 'Longitud de partida',
    'correo': 'Correo de acceso',
    'password': 'Contraseña (vacío para conservar al editar)',
  };
  @override
  void initState() {
    super.initState();
    for (final k in labels.keys) {
      var value = widget.item?[k]?.toString() ?? '';
      if (k == 'password') value = '';
      if (k.startsWith('disponible_') && value.length >= 5) {
        value = value.substring(0, 5);
      }
      _fields[k] = TextEditingController(text: value);
    }
    _estado = widget.item?['estado']?.toString() ?? 'ACTIVO';
  }

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  String? _validate(String k, String? value) {
    final v = value?.trim() ?? '';
    if (k == 'password') {
      return v.isEmpty && widget.item != null
          ? null
          : v.length < 8
          ? 'Mínimo 8 caracteres'
          : null;
    }
    if (v.isEmpty) return 'Campo obligatorio';
    if (k == 'dni' && !RegExp(r'^\d{8}$').hasMatch(v)) {
      return 'DNI de 8 dígitos';
    }
    if (k == 'correo' && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
      return 'Correo inválido';
    }
    if (k == 'anios_experiencia' &&
        (int.tryParse(v) == null || int.parse(v) < 0 || int.parse(v) > 70)) {
      return 'Ingresa un entero entre 0 y 70';
    }
    if (k.startsWith('disponible_') &&
        !RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(v)) {
      return 'Usa HH:mm, por ejemplo 08:00';
    }
    if (k.startsWith('origen_')) {
      final n = double.tryParse(v);
      final max = k.endsWith('latitud') ? 90 : 180;
      if (n == null || !n.isFinite || n.abs() > max) {
        return 'Coordenada fuera de rango';
      }
    }
    return null;
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_fields['disponible_desde']!.text.compareTo(
          _fields['disponible_hasta']!.text,
        ) >=
        0) {
      setState(
        () => _error = 'El inicio de disponibilidad debe ser anterior al fin.',
      );
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final body = <String, dynamic>{
      for (final e in _fields.entries)
        if (e.key != 'password') e.key: e.value.text.trim(),
      'estado': _estado,
    };
    body['anios_experiencia'] = int.parse(_fields['anios_experiencia']!.text);
    body['origen_latitud'] = double.parse(_fields['origen_latitud']!.text);
    body['origen_longitud'] = double.parse(_fields['origen_longitud']!.text);
    if (_fields['password']!.text.isNotEmpty) {
      body['password'] = _fields['password']!.text;
    }
    try {
      await ApiClient(context.read<AuthProvider>()).request(
        widget.item == null
            ? '/drivers/'
            : '/drivers/${widget.item!['repartidor_id']}',
        method: widget.item == null ? 'POST' : 'PUT',
        body: body,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.item == null ? 'Nuevo repartidor' : 'Editar repartidor'),
    content: SizedBox(
      width: 550,
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...labels.entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: TextFormField(
                    controller: _fields[e.key],
                    enabled: !_saving,
                    obscureText: e.key == 'password',
                    decoration: InputDecoration(
                      labelText: e.value,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => _validate(e.key, v),
                  ),
                ),
              ),
              DropdownButtonFormField<String>(
                initialValue: _estado,
                decoration: const InputDecoration(labelText: 'Estado'),
                items: const [
                  DropdownMenuItem(value: 'ACTIVO', child: Text('Activo')),
                  DropdownMenuItem(value: 'INACTIVO', child: Text('Inactivo')),
                ],
                onChanged: _saving ? null : (v) => setState(() => _estado = v!),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.of(context).pop(false),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: _saving ? null : _save,
        child: Text(_saving ? 'Guardando…' : 'Guardar'),
      ),
    ],
  );
}
