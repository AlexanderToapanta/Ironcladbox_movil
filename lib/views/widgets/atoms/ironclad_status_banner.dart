import 'package:flutter/material.dart';

class IroncladStatusBanner extends StatelessWidget {
  final String message;
  final bool isError;

  const IroncladStatusBanner({
    super.key,
    required this.message,
    this.isError = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError 
            ? const Color(0xFFFF3B30).withOpacity(0.1)
            : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError 
              ? const Color(0xFFFF3B30).withOpacity(0.3)
              : Colors.green.withOpacity(0.3),
        ),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isError ? const Color(0xFFFF3B30) : Colors.green,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
