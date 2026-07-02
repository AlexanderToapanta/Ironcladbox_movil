import 'package:flutter/material.dart';

class IroncladBrandMark extends StatelessWidget {
  final bool compact;

  const IroncladBrandMark({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 44.0 : 56.0;
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
          color: Colors.white,
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.fitness_center,
          size: iconSize,
          color: const Color(0xFFFF3B30),
        ),
        SizedBox(height: compact ? 8 : 12),
        Text(
          'IRONCLAD BOX',
          textAlign: TextAlign.center,
          style: titleStyle?.copyWith(fontSize: compact ? 22 : 28),
        ),
      ],
    );
  }
}