import 'package:flutter/material.dart';

class IroncladBackground extends StatelessWidget {
  final Widget child;

  const IroncladBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C1C1E), Color(0xFF111113), Color(0xFFFF3B30)],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      child: Container(
        color: Colors.black.withValues(alpha: 0.38),
        child: child,
      ),
    );
  }
}