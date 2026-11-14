import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_client.dart';
import '../auth/presentation/providers/auth_provider.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key, this.api, this.onSelect});
  final ApiClient? api;
  final ValueChanged<Map<String, dynamic>>? onSelect;
  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final _search = TextEditingController();
  List<Map<String, dynamic>> _items = [];
  int _skip = 0, _total = 0;
  bool _loading = true;
  String? _error;
  ApiClient get _api => widget.api ?? ApiClient(context.read<AuthProvider>());
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.request(
        '/clients/?skip=$_skip&limit=25&q=${Uri.encodeQueryComponent(_search.text.trim())}',
      );
      if (mounted) {
        setState(() {
          _items = (data['items'] as List).cast<Map<String, dynamic>>();
          _total = data['total'];
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _edit([Map<String, dynamic>? client]) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => ClientDialog(api: _api, client: client),
    );
    if (saved == true && mounted) await _load();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 12,
        children: [
          Text(
            'Clientes y preferencias',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (widget.onSelect == null)
            FilledButton.icon(
              onPressed: _loading ? null : () => _edit(),
              icon: const Icon(Icons.person_add_alt),
              label: const Text('Nuevo cliente'),
            ),
        ],
      ),
      const SizedBox(height: 8),
      const Text(
        'Horarios preferidos y referencias asociados al cliente. La ventana obligatoria de cada pedido se confirma por separado.',
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _search,
        maxLength: 160,
        decoration: InputDecoration(
          labelText: 'Buscar cliente o contacto',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            tooltip: 'Buscar clientes',
            onPressed: _loading
                ? null
                : () {
                    _skip = 0;
                    _load();
                  },
            icon: const Icon(Icons.arrow_forward),
          ),
        ),
        onSubmitted: (_) {
          if (!_loading) {
            _skip = 0;
            _load();
          }
        },
      ),
      if (_loading) const LinearProgressIndicator(),
      if (_error != null) ...[
        Text(
          _error!,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        TextButton(onPressed: _load, child: const Text('Reintentar')),
      ],
      if (!_loading && _items.isEmpty)
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text('No se encontraron clientes.'),
        ),
      for (final item in _items)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  item['nombre'],
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${item['estado']} · ${item['contacto'] ?? 'Sin contacto'}',
                ),
                if (item['preferencia'] != null) ...[
                  Text(
                    'Horario preferido: ${item['preferencia']['hora_preferida_inicio'] ?? 'Sin definir'} — ${item['preferencia']['hora_preferida_fin'] ?? 'Sin definir'}',
                  ),
                  if (item['preferencia']['punto_referencia'] != null)
                    Text(
                      'Referencia: ${item['preferencia']['punto_referencia']}',
                    ),
                  if (item['preferencia']['restriccion_acceso'] != null)
                    Text(
                      'Acceso: ${item['preferencia']['restriccion_acceso']}',
                    ),
                ],
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (widget.onSelect != null)
                      FilledButton(
                        onPressed: item['estado'] == 'ACTIVO'
                            ? () => widget.onSelect!(item)
                            : null,
                        child: const Text('Usar este cliente'),
                      )
                    else ...[
                      TextButton.icon(
                        onPressed: () => _edit(item),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Editar datos / estado'),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final saved = await showDialog<bool>(
                            context: context,
                            builder: (_) =>
                                PreferenceDialog(api: _api, client: item),
                          );
                          if (saved == true && mounted) _load();
                        },
                        icon: const Icon(Icons.schedule),
                        label: const Text('Preferencias de entrega'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('Página ${_skip ~/ 25 + 1} · $_total clientes'),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Página anterior de clientes',
                onPressed: !_loading && _skip > 0
                    ? () {
                        _skip -= 25;
                        _load();
                      }
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              IconButton(
                tooltip: 'Página siguiente de clientes',
                onPressed: !_loading && _skip + 25 < _total
                    ? () {
                        _skip += 25;
                        _load();
                      }
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class ClientDialog extends StatefulWidget {
  const ClientDialog({super.key, required this.api, this.client});
  final ApiClient api;
  final Map<String, dynamic>? client;
  @override
  State<ClientDialog> createState() => _ClientDialogState();
}

class _ClientDialogState extends State<ClientDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(), _contact = TextEditingController();
  String _state = 'ACTIVO';
  bool _saving = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _name.text = widget.client?['nombre'] ?? '';
    _contact.text = widget.client?['contacto'] ?? '';
    _state = widget.client?['estado'] ?? 'ACTIVO';
  }

  @override
  void dispose() {
    _name.dispose();
    _contact.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.api.request(
        widget.client == null
            ? '/clients/'
            : '/clients/${widget.client!['cliente_id']}',
        method: widget.client == null ? 'POST' : 'PUT',
        body: {
          'nombre': _name.text.trim(),
          'contacto': _contact.text.trim().isEmpty
              ? null
              : _contact.text.trim(),
          'estado': _state,
        },
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.client == null ? 'Nuevo cliente' : 'Editar cliente'),
    content: SizedBox(
      width: 480,
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_error != null) Text(_error!),
              TextFormField(
                controller: _name,
                enabled: !_saving,
                maxLength: 160,
                decoration: const InputDecoration(
                  labelText: 'Nombre del cliente',
                ),
                validator: (v) => (v?.trim().length ?? 0) < 2
                    ? 'Usa al menos 2 caracteres'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contact,
                enabled: !_saving,
                maxLength: 80,
                decoration: const InputDecoration(
                  labelText: 'Contacto (opcional)',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _state,
                decoration: const InputDecoration(
                  labelText: 'Estado del cliente',
                ),
                items: ['ACTIVO', 'INACTIVO']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: _saving ? null : (s) => setState(() => _state = s!),
              ),
              const SizedBox(height: 12),
              const Text(
                'Inactivar conserva los pedidos anteriores y evita nuevas selecciones.',
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: _saving ? null : _save,
        child: const Text('Guardar datos'),
      ),
    ],
  );
}

class PreferenceDialog extends StatefulWidget {
  const PreferenceDialog({super.key, required this.api, required this.client});
  final ApiClient api;
  final Map<String, dynamic> client;
  @override
  State<PreferenceDialog> createState() => _PreferenceDialogState();
}

class _PreferenceDialogState extends State<PreferenceDialog> {
  final _form = GlobalKey<FormState>();
  final _start = TextEditingController(),
      _end = TextEditingController(),
      _reference = TextEditingController(),
      _access = TextEditingController();
  bool _saving = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    final p = widget.client['preferencia'];
    _start.text = p?['hora_preferida_inicio']?.toString().substring(0, 5) ?? '';
    _end.text = p?['hora_preferida_fin']?.toString().substring(0, 5) ?? '';
    _reference.text = p?['punto_referencia'] ?? '';
    _access.text = p?['restriccion_acceso'] ?? '';
  }

  @override
  void dispose() {
    for (final c in [_start, _end, _reference, _access]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final a = _start.text.trim(), b = _end.text.trim();
    if ((a.isEmpty != b.isEmpty) || (a.isNotEmpty && a.compareTo(b) >= 0)) {
      setState(
        () => _error =
            'Indica ambos horarios; el inicio debe ser anterior al fin.',
      );
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.api.request(
        '/clients/${widget.client['cliente_id']}/preferences',
        method: 'PUT',
        body: {
          'hora_preferida_inicio': a.isEmpty ? null : a,
          'hora_preferida_fin': b.isEmpty ? null : b,
          'punto_referencia': _reference.text.trim().isEmpty
              ? null
              : _reference.text.trim(),
          'restriccion_acceso': _access.text.trim().isEmpty
              ? null
              : _access.text.trim(),
        },
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Preferencias de entrega'),
    content: SizedBox(
      width: 500,
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.client['nombre'],
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              const Text(
                'Hora local de Huancayo (America/Lima). Deja ambos horarios vacíos para no indicar preferencia; no cruza medianoche.',
              ),
              const SizedBox(height: 16),
              if (_error != null)
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              for (final field in [
                (_start, 'Inicio preferido (HH:mm)'),
                (_end, 'Fin preferido (HH:mm)'),
              ]) ...[
                TextFormField(
                  controller: field.$1,
                  enabled: !_saving,
                  maxLength: 5,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(labelText: field.$2),
                  validator: (v) =>
                      (v?.trim().isEmpty ?? true) ||
                          RegExp(r'^([01]\d|2[0-3]):[0-5]\d$')
                              .hasMatch(v!.trim())
                      ? null
                      : 'Usa HH:mm de 00:00 a 23:59',
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _reference,
                enabled: !_saving,
                maxLength: 500,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Referencia preferida',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _access,
                enabled: !_saving,
                maxLength: 500,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Instrucciones de acceso',
                ),
              ),
              const Text(
                'Guardar vacío elimina la preferencia, sin borrar el cliente ni sus pedidos.',
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: _saving ? null : _save,
        child: const Text('Guardar preferencias'),
      ),
    ],
  );
}
