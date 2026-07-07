import 'package:flutter/material.dart';

class IroncladLogoutButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const IroncladLogoutButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Cerrar sesión',
      onPressed: onPressed,
      icon: const Icon(Icons.logout_outlined),
    );
  }
}