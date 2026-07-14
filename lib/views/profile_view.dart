import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/config/api_config.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../core/validators.dart';
import 'widgets/atoms/ironclad_empty_state.dart';
import 'widgets/atoms/ironclad_loading_indicator.dart';
import 'widgets/atoms/ironclad_form_field.dart';
import 'widgets/molecules/ironclad_section_header.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = await AuthService().getProfile();
    if (mounted) setState(() { _profile = p; _loading = false; });
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 512, maxHeight: 512);
    if (picked == null) return;
    final mime = picked.mimeType ?? '';
    if (!['image/jpeg', 'image/png'].contains(mime)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Formato no permitido. Usa JPG o PNG'), backgroundColor: Colors.red));
      return;
    }
    final file = File(picked.path);
    final size = await file.length();
    if (size > 5 * 1024 * 1024) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La imagen no debe superar 5 MB'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _pickedImage = file);
    try {
      final api = ApiService();
      final dio = api.getDio();
      final formData = FormData();
      formData.files.add(MapEntry('profileImage', await MultipartFile.fromFile(picked.path, filename: 'profile.jpg')));
      final resp = await dio.post('/api/auth/upload-profile-image', data: formData);
      if (resp.data is Map && resp.data['success'] == true && resp.data['data'] != null) {
        _profile!['foto_perfil'] = resp.data['data']['foto_perfil'];
        if (mounted) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto actualizada'), backgroundColor: Colors.green));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: IroncladLoadingIndicator(message: 'Cargando perfil...'));
    final profile = _profile;
    if (profile == null) return const Scaffold(body: IroncladEmptyState(icon: Icons.person, title: 'Perfil no disponible', message: 'No se pudo obtener informacion.'));

    final name = '${profile['nombre'] ?? ''} ${profile['apellido'] ?? ''}'.trim();
    final fotoUrl = profile['foto_perfil'];

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        children: [
          const IroncladSectionHeader(title: 'Mi cuenta', subtitle: 'Informacion del usuario autenticado', icon: Icons.person),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(children: [
              Center(
                child: GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white12,
                        backgroundImage: _pickedImage != null
                            ? FileImage(_pickedImage!) as ImageProvider
                            : (fotoUrl != null ? NetworkImage(fotoUrl.startsWith('http') ? fotoUrl : '${ApiConfig.baseUrl}$fotoUrl') : null),
                        child: _pickedImage == null && fotoUrl == null ? const Icon(Icons.person, size: 50, color: Colors.white38) : null,
                      ),
                      Positioned(bottom: 0, right: 0, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Color(0xFFFF3B30), shape: BoxShape.circle), child: const Icon(Icons.camera_alt, color: Colors.white, size: 16))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Text(name.isEmpty ? 'Usuario' : name, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('Email: ${profile['email'] ?? '-'}'),
                    Text('Rol: ${profile['rol_nombre'] ?? profile['rol'] ?? '-'}'),
                    if (profile['telefono'] != null) Text('Telefono: ${profile['telefono']}'),
                    if (profile['direccion'] != null)
                      Text('Direccion: ${profile['direccion']}'),
                    if (profile['atleta'] != null && profile['atleta']['direccion'] != null)
                      Text('Direccion: ${profile['atleta']['direccion']}'),
                    if (profile['peso'] != null)
                      Text('Peso: ${profile['peso']} kg'),
                    if (profile['atleta'] != null && profile['atleta']['peso'] != null)
                      Text('Peso: ${profile['atleta']['peso']} kg'),
                    if (profile['altura'] != null)
                      Text('Altura: ${profile['altura']} m'),
                    if (profile['atleta'] != null && profile['atleta']['altura'] != null)
                      Text('Altura: ${profile['atleta']['altura']} m'),
                    if (profile['peso'] != null && profile['altura'] != null && (profile['altura'] as num) > 0)
                      Text('IMC: ${_calcularIMC((profile['peso'] as num).toDouble(), (profile['altura'] as num).toDouble())}'),
                    if (profile['atleta'] != null && profile['atleta']['peso'] != null && profile['atleta']['altura'] != null && (profile['atleta']['altura'] as num) > 0)
                      Text('IMC: ${_calcularIMC((profile['atleta']['peso'] as num).toDouble(), (profile['atleta']['altura'] as num).toDouble())}'),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _showChangePasswordDialog(context),
                icon: const Icon(Icons.lock_reset),
                label: const Text('Cambiar Contrasena'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  String _calcularIMC(double peso, double altura) {
    final imc = peso / (altura * altura);
    final categoria = imc < 18.5 ? 'Bajo' : imc < 25 ? 'Normal' : imc < 30 ? 'Sobrepeso' : 'Obeso';
    return '${imc.toStringAsFixed(1)} ($categoria)';
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        return AlertDialog(
        title: const Text('Cambiar Contrasena'),
        content: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
          IroncladFormField(controller: oldPasswordController, label: 'Contrasena Actual', icon: Icons.lock_outline, obscureText: true, validator: AppValidators.required),
          const SizedBox(height: 12),
          IroncladFormField(controller: newPasswordController, label: 'Nueva Contrasena', icon: Icons.lock, obscureText: true, validator: AppValidators.password),
          const SizedBox(height: 12),
          IroncladFormField(controller: confirmPasswordController, label: 'Confirmar Nueva', icon: Icons.lock, obscureText: true, validator: (v) => v != newPasswordController.text ? 'No coincide' : null),
        ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              try {
                await ApiService().post(ApiConfig.changePassword, data: {
                  'currentPassword': oldPasswordController.text,
                  'newPassword': newPasswordController.text,
                });
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contrasena actualizada correctamente'), backgroundColor: Colors.green));
                }
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
              }
            },
            child: const Text('Actualizar'),
          ),
        ],
      );
      },
    );
  }
}
