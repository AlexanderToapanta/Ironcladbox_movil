import 'package:flutter/material.dart';

class IroncladBackground extends StatelessWidget {
  final Widget child;

  const IroncladBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A1A1A),
            Color(0xFF000000),
          ],
        ),
      ),
      child: SafeArea(
        child: child,
      ),
    );
  }
}
