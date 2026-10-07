import 'package:flutter/material.dart';

/// Modal estándar para mostrar errores o notificaciones al usuario
/// sin recargar la página, respetando la regla de UX y Modales.
class ModalAlerta {
  static void mostrarError(
    BuildContext context,
    String titulo,
    String mensaje,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false, // Obliga al usuario a interactuar
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 8),
              Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Entendido',
                style: TextStyle(color: Color(0xFF1E88E5)),
              ),
            ),
          ],
        );
      },
    );
  }
}
