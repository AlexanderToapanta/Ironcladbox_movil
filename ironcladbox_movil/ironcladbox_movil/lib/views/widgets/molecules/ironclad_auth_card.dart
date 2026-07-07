import 'package:flutter/material.dart';

import '../atoms/ironclad_brand_mark.dart';

class IroncladAuthCard extends StatelessWidget {
  final Widget child;

  const IroncladAuthCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const IroncladBrandMark(),
            const SizedBox(height: 6),
            Text(
              'Accede a tu panel con el estilo de la marca',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 28),
            child,
          ],
        ),
      ),
    );
  }
}