import 'package:flutter/material.dart';

class IroncladStatusBanner extends StatelessWidget {
  final String message;

  const IroncladStatusBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFF3B30).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFF3B30).withValues(alpha: 0.35)),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Color(0xFFFFB4AF)),
        textAlign: TextAlign.center,
      ),
    );
  }
}