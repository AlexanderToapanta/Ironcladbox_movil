import 'package:flutter/material.dart';

class IroncladBrandMark extends StatelessWidget {
  final bool compact;

  const IroncladBrandMark({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 44.0 : 64.0;
    final titleStyle = const TextStyle(
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          color: Colors.white,
          fontFamily: 'Bebas Neue',
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.fitness_center,
          size: iconSize,
          color: const Color(0xFFFF3B30),
        ),
        SizedBox(height: compact ? 4 : 8),
        Text(
          'IRONCLAD BOX',
          textAlign: TextAlign.center,
          style: titleStyle.copyWith(fontSize: compact ? 24 : 36),
        ),
      ],
    );
  }
}