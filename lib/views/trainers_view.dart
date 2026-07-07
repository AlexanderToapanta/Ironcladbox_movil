import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/backend_api_models.dart';
import '../viewmodels/backend_viewmodels.dart';
import '../services/auth_service.dart';
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

          return RefreshIndicator(
            onRefresh: vm.loadAll,
            child: ListView(
              children: [
                const IroncladSectionHeader(title: 'Gestión de entrenadores', subtitle: 'Lista de equipo técnico', icon: Icons.badge),
                ...vm.items.map(
                  (trainer) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Card(
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: trainer.activo == true ? Colors.green : Colors.grey,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text('${trainer.nombre ?? '-'} ${trainer.apellido ?? ''}'),
                        subtitle: Text(trainer.especialidad ?? 'Especialidad no definida'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Email: ${trainer.email ?? '-'}'),
                                Text('Teléfono: ${trainer.telefono ?? '-'}'),
                                Text('Dirección: ${trainer.direccion ?? '-'}'),
                                if (trainer.fechaNacimiento != null)
                                  Text('F. Nacimiento: ${DateFormat('dd/MM/yyyy').format(trainer.fechaNacimiento!.toLocal())}'),
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
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nuevo Entrenador'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IroncladFormField(
                  controller: nameController,
                  label: 'Nombre',
                  icon: Icons.person,
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                IroncladFormField(
                  controller: lastNameController,
                  label: 'Apellido',
                  icon: Icons.person,
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                IroncladFormField(
                  controller: emailController,
                  label: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
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
                  label: 'Dirección',
                  icon: Icons.location_on,
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                IroncladFormField(
                  controller: specialtyController,
                  label: 'Especialidad',
                  icon: Icons.star,
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                IroncladFormField(
                  controller: expController,
                  label: 'Años de Experiencia',
                  icon: Icons.history,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    final val = int.tryParse(v);
                    if (val == null || val < 0 || val > 50) return 'Máximo 50 años';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                IroncladFormField(
                  controller: certController,
                  label: 'Certificaciones',
                  icon: Icons.card_membership,
                  validator: (v) => null,
                ),
                const SizedBox(height: 12),
                IroncladFormField(
                  controller: bioController,
                  label: 'Biografía',
                  icon: Icons.description,
                  validator: (v) => null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final bd = birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 25));
                final vm = context.read<TrainersViewModel>();
                await vm.create({
                  'nombre': nameController.text.trim(),
                  'apellido': lastNameController.text.trim(),
                  'email': emailController.text.trim(),
                  'fecha_nacimiento': DateFormat('yyyy-MM-dd').format(bd),
                  'especialidad': specialtyController.text.trim(),
                  'anios_experiencia': int.tryParse(expController.text.trim()) ?? 0,
                  'certificaciones': certController.text.trim(),
                  'biografia': bioController.text.trim(),
                  'direccion': addressController.text.trim(),
                });
                
                if (mounted) {
                  Navigator.pop(context);
                  context.read<TrainersViewModel>().loadAll();
                }
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTrainerDialog(TrainerDto trainer) {
    final nameController = TextEditingController(text: trainer.nombre);
    final lastNameController = TextEditingController(text: trainer.apellido);
    final phoneController = TextEditingController(text: trainer.telefono);
    final addressController = TextEditingController(text: trainer.direccion);
    final specialtyController = TextEditingController(text: trainer.especialidad);
    final expController = TextEditingController(text: trainer.aniosExperiencia?.toString());
    final certController = TextEditingController(text: trainer.certificaciones);
    final bioController = TextEditingController(text: trainer.biografia);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Entrenador'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IroncladFormField(
                controller: nameController,
                label: 'Nombre',
                icon: Icons.person,
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              IroncladFormField(
                controller: lastNameController,
                label: 'Apellido',
                icon: Icons.person,
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              IroncladFormField(
                controller: phoneController,
                label: 'Teléfono',
                icon: Icons.phone,
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              IroncladFormField(
                controller: addressController,
                label: 'Dirección',
                icon: Icons.location_on,
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              IroncladFormField(
                controller: specialtyController,
                label: 'Especialidad',
                icon: Icons.star,
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              IroncladFormField(
                controller: expController,
                label: 'Años de Experiencia',
                icon: Icons.history,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  final val = int.tryParse(v);
                  if (val == null || val < 0 || val > 50) return 'Máximo 50 años';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              IroncladFormField(
                controller: certController,
                label: 'Certificaciones',
                icon: Icons.card_membership,
                validator: (v) => null,
              ),
              const SizedBox(height: 12),
              IroncladFormField(
                controller: bioController,
                label: 'Biografía',
                icon: Icons.description,
                validator: (v) => null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await context.read<TrainersViewModel>().update(trainer.id!, {
                'nombre': nameController.text.trim(),
                'apellido': lastNameController.text.trim(),
                'telefono': phoneController.text.trim(),
                'direccion': addressController.text.trim(),
                'especialidad': specialtyController.text.trim(),
                'anios_experiencia': int.tryParse(expController.text),
                'certificaciones': certController.text.trim(),
                'biografia': bioController.text.trim(),
              });
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(TrainerDto trainer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de eliminar a ${trainer.nombre}? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              await context.read<TrainersViewModel>().delete(trainer.id!);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
