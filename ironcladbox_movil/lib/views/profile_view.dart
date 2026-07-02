import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'widgets/atoms/ironclad_empty_state.dart';
import 'widgets/atoms/ironclad_loading_indicator.dart';
import 'widgets/molecules/ironclad_section_header.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: authService.getProfile(),
        builder: (context, snapshot) {
          final profile = snapshot.data;

          if (snapshot.connectionState != ConnectionState.done) {
            return const IroncladLoadingIndicator(message: 'Cargando perfil...');
          }

          if (profile == null) {
            return const IroncladEmptyState(
              icon: Icons.person,
              title: 'Perfil no disponible',
              message: 'No se pudo obtener la información del usuario autenticado.',
            );
          }

          final name = '${profile['nombre'] ?? ''} ${profile['apellido'] ?? ''}'.trim();

          return ListView(
            children: [
              const IroncladSectionHeader(
                title: 'Mi cuenta',
                subtitle: 'Información del usuario autenticado',
                icon: Icons.person,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name.isEmpty ? 'Usuario' : name, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text('Email: ${profile['email'] ?? '-'}'),
                        Text('Rol: ${profile['rol_nombre'] ?? profile['rol'] ?? '-'}'),
                        if (profile['telefono'] != null) Text('Teléfono: ${profile['telefono']}'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}