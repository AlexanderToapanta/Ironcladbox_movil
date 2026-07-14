import 'package:flutter/material.dart';

class AppValidators {
  static String? required(String? v) {
    if (v == null || v.trim().isEmpty) return 'Este campo es requerido';
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'El email es requerido';
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(v.trim())) return 'Ingresa un email válido';
    return null;
  }

  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return 'El teléfono es requerido';
    final digits = v.replaceAll(RegExp(r'[\D]'), '');
    if (digits.length < 7 || digits.length > 15) return 'Ingresa un teléfono válido (7-15 dígitos)';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'La contraseña es requerida';
    if (v.length < 8) return 'Mínimo 8 caracteres';
    return null;
  }

  static String? Function(String?) minLength(int min) {
    return (String? v) {
      if (v == null || v.trim().isEmpty) return 'Este campo es requerido';
      if (v.trim().length < min) return 'Mínimo $min caracteres';
      return null;
    };
  }

  static String? positiveNumber(String? v, {String label = 'valor', double max = 999999}) {
    if (v == null || v.trim().isEmpty) return 'Ingresa un $label';
    final n = double.tryParse(v.trim());
    if (n == null) return 'Ingresa un número válido';
    if (n <= 0) return 'Debe ser mayor a 0';
    if (n > max) return 'Máximo $max';
    return null;
  }

  static String? peso(String? v) => positiveNumber(v, label: 'peso', max: 350);

  static String? altura(String? v) => positiveNumber(v, label: 'altura', max: 2.5);

  static String? precio(String? v) => positiveNumber(v, label: 'precio', max: 99999);

  static String? duracion(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingresa la duración';
    final n = int.tryParse(v.trim());
    if (n == null || n < 1 || n > 365) return 'Ingresa entre 1 y 365 días';
    return null;
  }

  static String? cupo(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingresa el cupo';
    final n = int.tryParse(v.trim());
    if (n == null || n < 1 || n > 200) return 'Ingresa entre 1 y 200';
    return null;
  }

  static String? experiencia(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingresa los años de experiencia';
    final n = int.tryParse(v.trim());
    if (n == null || n < 0 || n > 50) return 'Ingresa entre 0 y 50 años';
    return null;
  }

  static String? marca(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingresa una marca';
    final n = double.tryParse(v.trim());
    if (n == null || n <= 0) return 'Ingresa un número mayor a 0';
    if (n > 9999) return 'Máximo 9999 lb';
    return null;
  }

  static String? fecha(String? v) {
    if (v == null || v.trim().isEmpty) return 'La fecha es requerida';
    final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!regex.hasMatch(v.trim())) return 'Formato: YYYY-MM-DD';
    try {
      DateTime.parse(v.trim());
      return null;
    } catch (_) {
      return 'Fecha inválida';
    }
  }

  static String? hora(String? v) {
    if (v == null || v.trim().isEmpty) return 'La hora es requerida';
    final regex = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');
    if (!regex.hasMatch(v.trim())) return 'Formato: HH:MM (00:00-23:59)';
    return null;
  }

  static String? fechaNacimiento(DateTime? date) {
    if (date == null) return 'La fecha de nacimiento es requerida';
    final age = DateTime.now().difference(date).inDays ~/ 365;
    if (age < 12) return 'Debes tener al menos 12 años';
    if (age > 100) return 'Fecha de nacimiento inválida';
    return null;
  }

  static Future<bool> showImcWarning(BuildContext context, double peso, double altura) async {
    if (altura <= 0) return true;
    final imc = peso / (altura * altura);
    String msg;
    if (imc < 12) {
      msg = 'Tu IMC es ${imc.toStringAsFixed(1)} (Extremadamente bajo). ¿Estás seguro que los datos son correctos?';
    } else if (imc < 16) {
      msg = 'Tu IMC es ${imc.toStringAsFixed(1)} (Muy bajo). ¿Estás seguro que los datos son correctos?';
    } else if (imc > 45) {
      msg = 'Tu IMC es ${imc.toStringAsFixed(1)} (Extremo). ¿Estás seguro que los datos son correctos?';
    } else if (imc > 40) {
      msg = 'Tu IMC es ${imc.toStringAsFixed(1)} (Obesidad severa). ¿Estás seguro que los datos son correctos?';
    } else {
      return true;
    }
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Verificar datos'),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Corregir')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sí, continuar')),
        ],
      ),
    );
    return result ?? false;
  }
}
