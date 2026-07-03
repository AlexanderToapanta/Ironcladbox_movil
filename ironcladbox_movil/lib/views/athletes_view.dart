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

class AthletesView extends StatefulWidget {
  const AthletesView({super.key});

  @override
  State<AthletesView> createState() => _AthletesViewState();
}

class _AthletesViewState extends State<AthletesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AthletesViewModel>().loadAll();
      context.read<MembershipsViewModel>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Atletas')),
      body: Consumer<AthletesViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading && vm.items.isEmpty) return const IroncladLoadingIndicator(message: 'Cargando atletas...');
          if (vm.errorMessage.isNotEmpty && vm.items.isEmpty) {
            return IroncladEmptyState(icon: Icons.groups, title: 'Error', message: vm.errorMessage, onAction: vm.loadAll, actionLabel: 'Reintentar');
          }
          if (vm.items.isEmpty) {
            return const IroncladEmptyState(icon: Icons.groups, title: 'Sin atletas', message: 'No hay atletas para mostrar.');
          }

          return RefreshIndicator(
            onRefresh: vm.loadAll,
            child: ListView(
              children: [
                const IroncladSectionHeader(title: 'Gestión de atletas', subtitle: 'Lista sincronizada con la base de datos', icon: Icons.groups),
                ...vm.items.map(
                  (athlete) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Card(
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: (athlete.activo == true) ? Colors.green : Colors.grey,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text('${athlete.nombre ?? '-'} ${athlete.apellido ?? ''}'),
                        subtitle: Text(athlete.membershipName ?? 'Sin membresía'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Email: ${athlete.email ?? '-'}'),
                                Text('Teléfono: ${athlete.telefono ?? '-'}'),
                                Text('Dirección: ${athlete.direccion ?? '-'}'),
                                if (athlete.fechaNacimiento != null)
                                  Text('F. Nacimiento: ${DateFormat('dd/MM/yyyy').format(athlete.fechaNacimiento!.toLocal())}'),
                                if (athlete.fechaInicioMembresia != null)
                                  Text('Inicio Membresía: ${DateFormat('dd/MM/yyyy').format(athlete.fechaInicioMembresia!.toLocal())}'),
                                if (athlete.fechaFinMembresia != null)
                                  Text('Fin Membresía: ${DateFormat('dd/MM/yyyy').format(athlete.fechaFinMembresia!.toLocal())}'),
                                const Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _showEditAthleteDialog(athlete),
                                      tooltip: 'Editar',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.card_membership, color: Colors.orange),
                                      onPressed: () => _showChangeMembershipDialog(athlete),
                                      tooltip: 'Cambiar Membresía',
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        (athlete.activo == true) ? Icons.block : Icons.check_circle_outline,
                                        color: (athlete.activo == true) ? Colors.red : Colors.green,
                                      ),
                                      onPressed: () => vm.updateStatus(athlete.id!, {'activo': !(athlete.activo ?? false)}),
                                      tooltip: (athlete.activo == true) ? 'Desactivar' : 'Activar',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                                      onPressed: () => _confirmDelete(athlete),
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
        onPressed: _showAddAthleteDialog,
        backgroundColor: const Color(0xFFFF3B30),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  void _showAddAthleteDialog() {
    final nameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    DateTime? birthDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nuevo Atleta'),
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
                      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
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
                  controller: phoneController,
                  label: 'Teléfono',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                IroncladFormField(
                  controller: addressController,
                  label: 'Dirección',
                  icon: Icons.location_on,
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (birthDate == null) return;
                
                final password = DateFormat('ddMMyyyy').format(birthDate!);
                
                await AuthService().register(
                  email: emailController.text.trim(),
                  password: password,
                  name: nameController.text.trim(),
                  lastName: lastNameController.text.trim(),
                  phone: phoneController.text.trim(),
                  address: addressController.text.trim(),
                  birthDate: birthDate,
                  role: 'ATLETA',
                );
                
                if (mounted) {
                  Navigator.pop(context);
                  context.read<AthletesViewModel>().loadAll();
                }
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAthleteDialog(AthleteDto athlete) {
    final nameController = TextEditingController(text: athlete.nombre);
    final lastNameController = TextEditingController(text: athlete.apellido);
    final phoneController = TextEditingController(text: athlete.telefono);
    final addressController = TextEditingController(text: athlete.direccion);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Atleta'),
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
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await context.read<AthletesViewModel>().update(athlete.id!, {
                'nombre': nameController.text.trim(),
                'apellido': lastNameController.text.trim(),
                'telefono': phoneController.text.trim(),
                'direccion': addressController.text.trim(),
              });
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showChangeMembershipDialog(AthleteDto athlete) {
    final memberships = context.read<MembershipsViewModel>().items;
    int? selectedId = athlete.membershipId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('Asignar/Cambiar Membresía', style: TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Atleta:', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text('${athlete.nombre} ${athlete.apellido}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              const Text('Membresía *', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                dropdownColor: const Color(0xFF2A2A2A),
                value: selectedId,
                style: const TextStyle(color: Colors.white),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Seleccionar membresía...', style: TextStyle(color: Colors.grey))),
                  ...memberships.map((m) => DropdownMenuItem(
                        value: m.id,
                        child: Text(
                          '${m.nombre} - \$${m.precio?.toStringAsFixed(2)} (${m.duracionDias} días)',
                          style: const TextStyle(fontSize: 13, color: Colors.white),
                        ),
                      )),
                ],
                onChanged: (val) => setDialogState(() => selectedId = val),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFFF3B30)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFFF3B30), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (selectedId != null) ...[
                const Text('Periodo de vigencia:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text(
                  'Activación hoy: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                Text(
                  'Duración: ${memberships.firstWhere((m) => m.id == selectedId).duracionDias} días',
                  style: const TextStyle(fontSize: 12, color: Colors.orangeAccent),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR', style: TextStyle(color: Colors.white70))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3B30)),
              onPressed: () async {
                if (selectedId != null) {
                  final today = DateTime.now();
                  final payload = {
                    'id_membresia': selectedId,
                    'fecha_inicio_membresia': today.toIso8601String().split('T').first,
                    'activo': true,
                  };
                  await context.read<AthletesViewModel>().updateMembership(athlete.id!, payload);
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('ACTUALIZAR', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(AthleteDto athlete) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de eliminar a ${athlete.nombre}? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              await context.read<AthletesViewModel>().delete(athlete.id!);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
