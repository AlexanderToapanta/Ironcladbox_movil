import 'package:flutter/material.dart';

import '../core/config/api_config.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'widgets/atoms/ironclad_empty_state.dart';
import 'widgets/atoms/ironclad_loading_indicator.dart';
import 'widgets/atoms/ironclad_form_field.dart';
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
                child: Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(name.isEmpty ? 'Usuario' : name, style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 8),
                            Text('Email: ${profile['email'] ?? '-'}'),
                            Text('Rol: ${profile['rol_nombre'] ?? profile['rol'] ?? '-'}'),
                            if (profile['telefono'] != null) Text('Teléfono: ${profile['telefono']}'),
                            if (profile['direccion'] != null) Text('Dirección: ${profile['direccion']}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showChangePasswordDialog(context),
                      icon: const Icon(Icons.lock_reset),
                      label: const Text('Cambiar Contraseña'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IroncladFormField(
              controller: oldPasswordController,
              label: 'Contraseña Actual',
              icon: Icons.lock_outline,
              obscureText: true,
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            IroncladFormField(
              controller: newPasswordController,
              label: 'Nueva Contraseña',
              icon: Icons.lock,
              obscureText: true,
              validator: (v) => v == null || v.length < 8 ? 'Mínimo 8 caracteres' : null,
            ),
            const SizedBox(height: 12),
            IroncladFormField(
              controller: confirmPasswordController,
              label: 'Confirmar Nueva',
              icon: Icons.lock,
              obscureText: true,
              validator: (v) => v != newPasswordController.text ? 'No coincide' : null,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Las contraseñas no coinciden')));
                return;
              }
              
              try {
                // Assuming an endpoint exists for this in the backend
                await ApiService().post(ApiConfig.changePassword, data: {
                  'oldPassword': oldPasswordController.text,
                  'newPassword': newPasswordController.text,
                });
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contraseña actualizada correctamente')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }
}
