import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/widgets/record_widgets.dart';

class RouteScheduleDraft {
  RouteScheduleDraft({String? initial, int? serviceMinutes})
    : serviceMinutes = serviceMinutes ?? 5 {
    final limaNow = DateTime.now().toUtc().subtract(const Duration(hours: 5));
    final value = initial == null
        ? limaNow.add(const Duration(days: 1))
        : DateTime.parse(initial).toUtc().subtract(const Duration(hours: 5));
    start = DateTime(
      value.year,
      value.month,
      value.day,
      initial == null ? 9 : value.hour,
      initial == null ? 0 : value.minute,
    );
  }
  late DateTime start;
  int serviceMinutes;
  String? get error => serviceMinutes < 0 || serviceMinutes > 120
      ? 'Indica entre 0 y 120 minutos de atención por entrega.'
      : null;
  Map<String, dynamic> get payload => {
    'inicio_planificado': DateTime.utc(
      start.year,
      start.month,
      start.day,
      start.hour,
      start.minute,
    ).add(const Duration(hours: 5)).toIso8601String(),
    'servicio_min_por_entrega': serviceMinutes,
  };
}

class RouteScheduleInput extends StatefulWidget {
  const RouteScheduleInput({
    super.key,
    required this.draft,
    this.enabled = true,
  });
  final RouteScheduleDraft draft;
  final bool enabled;
  @override
  State<RouteScheduleInput> createState() => _RouteScheduleInputState();
}

class _RouteScheduleInputState extends State<RouteScheduleInput> {
  Future<void> _date() async {
    final current = widget.draft.start;
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null && mounted) {
      setState(
        () => widget.draft.start = DateTime(
          date.year,
          date.month,
          date.day,
          current.hour,
          current.minute,
        ),
      );
    }
  }

  Future<void> _time() async {
    final current = widget.draft.start;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
    );
    if (time != null && mounted) {
      setState(
        () => widget.draft.start = DateTime(
          current.year,
          current.month,
          current.day,
          time.hour,
          time.minute,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text(
        'Salida planificada · hora de Lima (UTC−5)',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      OutlinedButton.icon(
        onPressed: widget.enabled ? _date : null,
        icon: const Icon(Icons.calendar_month),
        label: Text(
          friendlyDate(widget.draft.start.toIso8601String()).split(' ').first,
        ),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: widget.enabled ? _time : null,
        icon: const Icon(Icons.schedule),
        label: Text(
          '${widget.draft.start.hour.toString().padLeft(2, '0')}:${widget.draft.start.minute.toString().padLeft(2, '0')}',
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        initialValue: widget.draft.serviceMinutes.toString(),
        enabled: widget.enabled,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: 'Minutos de atención por entrega',
          helperText: 'Se suman al tiempo vial. Ajusta según la operación.',
          helperMaxLines: 2,
          errorText: widget.draft.error,
        ),
        onChanged: (value) => setState(
          () => widget.draft.serviceMinutes = int.tryParse(value) ?? -1,
        ),
      ),
      const SizedBox(height: 12),
      const Text(
        'El fin estimado se calcula al guardar: viaje + atención. '
        'Se valida el turno y que el repartidor y el vehículo no tengan cruces. '
        'No incluye tráfico en vivo ni retorno a la base.',
      ),
    ],
  );
}
