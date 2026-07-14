import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/backend_api_models.dart';
import '../viewmodels/backend_viewmodels.dart';
import '../services/auth_service.dart';
import '../core/validators.dart';
import 'widgets/atoms/ironclad_empty_state.dart';
import 'widgets/atoms/ironclad_loading_indicator.dart';
import 'widgets/atoms/ironclad_form_field.dart';
import 'widgets/molecules/ironclad_section_header.dart';

class TrainersView extends StatefulWidget {
  const TrainersView({super.key});

  @override
  State<TrainersView> createState() => _TrainersViewState();
}

class _TrainersViewState extends State<TrainersView> {
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrainersViewModel>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrenadores')),
      body: Consumer<TrainersViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading && vm.items.isEmpty) return const IroncladLoadingIndicator(message: 'Cargando entrenadores...');
          if (vm.errorMessage.isNotEmpty && vm.items.isEmpty) {
            return IroncladEmptyState(icon: Icons.badge, title: 'Error', message: vm.errorMessage, onAction: vm.loadAll, actionLabel: 'Reintentar');
          }
          if (vm.items.isEmpty) {
            return const IroncladEmptyState(icon: Icons.badge, title: 'Sin entrenadores', message: 'No hay entrenadores para mostrar.');
          }

          final filtered = _searchQuery.isEmpty
              ? vm.items
              : vm.items.where((t) {
                  final name = '${t.nombre ?? ''} ${t.apellido ?? ''}'.toLowerCase();
                  final email = (t.email ?? '').toLowerCase();
                  final esp = (t.especialidad ?? '').toLowerCase();
                  final q = _searchQuery.toLowerCase();
                  return name.contains(q) || email.contains(q) || esp.contains(q);
                }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: const InputDecoration(
                    hintText: 'Buscar por nombre, email o especialidad...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                    filled: true,
                    fillColor: Color(0x0DFFFFFF),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: vm.loadAll,
                  child: ListView(
                    children: [
                      const IroncladSectionHeader(title: 'Gestion de entrenadores', subtitle: 'Lista de equipo tecnico', icon: Icons.badge),
                      if (filtered.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('Sin resultados', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                        ),
                      ...filtered.map(
                        (trainer) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Card(
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: trainer.activo == true ? Colors.green : Colors.grey,
                                child: const Icon(Icons.person, color: Colors.white),
                              ),
                              title: Text('${trainer.nombre ?? '-'} ${trainer.apellido ?? ''}'),
                              subtitle: Row(
                                children: [
                                  Expanded(child: Text(trainer.especialidad ?? 'Especialidad no definida', style: const TextStyle(fontSize: 12))),
                                  Text('${trainer.aniosExperiencia ?? 0} anios', style: const TextStyle(color: Colors.orangeAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Email: ${trainer.email ?? '-'}'),
                                      Text('Telefono: ${trainer.telefono ?? '-'}'),
                                      Text('Direccion: ${trainer.direccion ?? '-'}'),
                                      if (trainer.fechaNacimiento != null)
                                        Text('F. Nacimiento: ${DateFormat('dd/MM/yyyy').format(trainer.fechaNacimiento!.toLocal())}'),
                                      if (trainer.certificaciones != null && trainer.certificaciones!.isNotEmpty)
                                        Text('Certificaciones: ${trainer.certificaciones}'),
                                      if (trainer.biografia != null && trainer.biografia!.isNotEmpty)
                                        Text('Biografia: ${trainer.biografia}'),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () => _showEditTrainerDialog(trainer),
                                            tooltip: 'Editar',
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              trainer.activo == true ? Icons.block : Icons.check_circle_outline,
                                              color: trainer.activo == true ? Colors.red : Colors.green,
                                            ),
                                            onPressed: () => vm.updateStatus(trainer.id!, {'activo': !(trainer.activo ?? false)}),
                                            tooltip: trainer.activo == true ? 'Desactivar' : 'Activar',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_forever, color: Colors.red),
                                            onPressed: () => _confirmDelete(trainer),
                                            tooltip: 'Eliminar',
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_trainers',
        onPressed: _showAddTrainerDialog,
        backgroundColor: const Color(0xFFFF3B30),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  void _showAddTrainerDialog() {
    final scaffoldContext = context;
    final nameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final specialtyController = TextEditingController();
    final expController = TextEditingController();
    final certController = TextEditingController();
    final bioController = TextEditingController();
    DateTime? birthDate;

    showDialog(
      context: context,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        return StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nuevo Entrenador'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IroncladFormField(
                  controller: nameController,
                  label: 'Nombre',
                  icon: Icons.person,
                  validator: AppValidators.minLength(2),
                ),
                const SizedBox(height: 12),
                IroncladFormField(
                  controller: lastNameController,
                  label: 'Apellido',
                  icon: Icons.person,
                  validator: AppValidators.required,
                ),
                const SizedBox(height: 12),
                IroncladFormField(
                  controller: emailController,
                  label: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: AppValidators.email,
                ),
                const SizedBox(height: 12),
                IroncladFormField(
                  controller: phoneController,
                  label: 'Telefono',
                  icon: Icons.phone,
                  validator: AppValidators.phone,
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setDialogState(() => birthDate = picked);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Fecha de Nacimiento',
                      prefixIcon: const Icon(Icons.cake),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(birthDate == null ? 'Seleccionar' : DateFormat('dd/MM/yyyy').format(birthDate!)),
                  ),
                ),
                const SizedBox(height: 12),
                IroncladFormField(
                  controller: addressController,
                  label: 'Direccion',
                  icon: Icons.location_on,
                  validator: AppValidators.required,
                ),
                const SizedBox(height: 12),
                IroncladFormField(
                  controller: specialtyController,
                  label: 'Especialidad',
                  icon: Icons.star,
                  validator: AppValidators.required,
                ),
                const SizedBox(height: 12),
                IroncladFormField(
                  controller: expController,
                  label: 'Anios de Experiencia',
                  icon: Icons.history,
                  keyboardType: TextInputType.number,
                  validator: AppValidators.experiencia,
                ),
                const SizedBox(height: 12),
                IroncladFormField(
                  controller: certController,
                  label: 'Certificaciones',
                  icon: Icons.card_membership,
                ),
                const SizedBox(height: 12),
                IroncladFormField(
                  controller: bioController,
                  label: 'Biografia',
                  icon: Icons.description,
                ),
              ],
            ),
          ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                if (birthDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona la fecha de nacimiento'), backgroundColor: Colors.red));
                  return;
                }
                final edadErr = AppValidators.fechaNacimiento(birthDate);
                if (edadErr != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(edadErr), backgroundColor: Colors.red));
                  return;
                }
                final vm = context.read<TrainersViewModel>();
                await vm.create({
                  'nombre': nameController.text.trim(),
                  'apellido': lastNameController.text.trim(),
                  'email': emailController.text.trim(),
                  'telefono': phoneController.text.trim(),
                  'fecha_nacimiento': DateFormat('yyyy-MM-dd').format(birthDate!),
                  'especialidad': specialtyController.text.trim(),
                  'anios_experiencia': int.tryParse(expController.text.trim()) ?? 0,
                  'certificaciones': certController.text.trim(),
                  'biografia': bioController.text.trim(),
                  'direccion': addressController.text.trim(),
                });
                
                if (!mounted) return;
                Navigator.pop(context);

                if (vm.errorMessage.isEmpty) {
                  final generatedPassword = '${birthDate!.day.toString().padLeft(2, '0')}${birthDate!.month.toString().padLeft(2, '0')}${birthDate!.year}';
                  await showDialog(
                    context: scaffoldContext,
                    builder: (ctx) => AlertDialog(
                      title: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Entrenador creado'),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('La contraseña se generó a partir de la fecha de nacimiento:', style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('CONTRASEÑA', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1.5)),
                                const SizedBox(height: 4),
                                Text(generatedPassword, style: const TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: 2)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Fecha de nacimiento: ${DateFormat('dd/MM/yyyy').format(birthDate!)}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 16),
                          const Text('Comparte esta contraseña con el usuario para que pueda iniciar sesión.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3B30)),
                          child: const Text('Entendido', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                } else {
                  if (scaffoldContext.mounted) {
                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(SnackBar(
                      content: Text(vm.errorMessage),
                      backgroundColor: Colors.red));
                  }
                }
                vm.clearError();
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      );
      },
    );
  }

  void _showEditTrainerDialog(TrainerDto trainer) {
    final nameController = TextEditingController(text: trainer.nombre);
    final lastNameController = TextEditingController(text: trainer.apellido);
    final emailController = TextEditingController(text: trainer.email);
    final phoneController = TextEditingController(text: trainer.telefono);
    final addressController = TextEditingController(text: trainer.direccion);
    final specialtyController = TextEditingController(text: trainer.especialidad);
    final expController = TextEditingController(text: trainer.aniosExperiencia?.toString());
    final certController = TextEditingController(text: trainer.certificaciones);
    final bioController = TextEditingController(text: trainer.biografia);

    showDialog(
      context: context,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        return AlertDialog(
        title: const Text('Editar Entrenador'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IroncladFormField(
                controller: nameController,
                label: 'Nombre',
                icon: Icons.person,
                validator: AppValidators.minLength(2),
              ),
              const SizedBox(height: 12),
              IroncladFormField(
                controller: lastNameController,
                label: 'Apellido',
                icon: Icons.person,
                validator: AppValidators.required,
              ),
              const SizedBox(height: 12),
              IroncladFormField(
                controller: emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: AppValidators.email,
              ),
              const SizedBox(height: 12),
              IroncladFormField(
                controller: phoneController,
                label: 'Telefono',
                icon: Icons.phone,
                validator: AppValidators.phone,
              ),
              const SizedBox(height: 12),
              IroncladFormField(
                controller: addressController,
                label: 'Direccion',
                icon: Icons.location_on,
                validator: AppValidators.required,
              ),
              const SizedBox(height: 12),
              IroncladFormField(
                controller: specialtyController,
                label: 'Especialidad',
                icon: Icons.star,
                validator: AppValidators.required,
              ),
              const SizedBox(height: 12),
              IroncladFormField(
                controller: expController,
                label: 'Anios de Experiencia',
                icon: Icons.history,
                keyboardType: TextInputType.number,
                validator: AppValidators.experiencia,
              ),
              const SizedBox(height: 12),
              IroncladFormField(
                controller: certController,
                label: 'Certificaciones',
                icon: Icons.card_membership,
              ),
              const SizedBox(height: 12),
              IroncladFormField(
                controller: bioController,
                label: 'Biografia',
                icon: Icons.description,
              ),
            ],
          ),
        ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              await context.read<TrainersViewModel>().update(trainer.id!, {
                'nombre': nameController.text.trim(),
                'apellido': lastNameController.text.trim(),
                'email': emailController.text.trim(),
                'telefono': phoneController.text.trim(),
                'direccion': addressController.text.trim(),
                'especialidad': specialtyController.text.trim(),
                'anios_experiencia': int.tryParse(expController.text),
                'certificaciones': certController.text.trim(),
                'biografia': bioController.text.trim(),
              });
              final vm = context.read<TrainersViewModel>();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(vm.errorMessage.isNotEmpty ? vm.errorMessage : 'Entrenador actualizado'),
                  backgroundColor: vm.errorMessage.isNotEmpty ? Colors.red : Colors.green));
                Navigator.pop(context);
              }
              vm.clearError();
            },
            child: const Text('Guardar'),
          ),
        ],
      );
      },
    );
  }

  void _confirmDelete(TrainerDto trainer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminacion'),
        content: Text('Estas seguro de eliminar a ${trainer.nombre}? Esta accion no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              await context.read<TrainersViewModel>().delete(trainer.id!);
              final vm = context.read<TrainersViewModel>();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(vm.errorMessage.isNotEmpty ? vm.errorMessage : 'Entrenador eliminado'),
                  backgroundColor: vm.errorMessage.isNotEmpty ? Colors.red : Colors.green));
                Navigator.pop(context);
              }
              vm.clearError();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
