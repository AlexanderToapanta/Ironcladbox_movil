import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/backend_api_models.dart';
import '../viewmodels/backend_viewmodels.dart';
import 'widgets/atoms/ironclad_empty_state.dart';
import 'widgets/atoms/ironclad_loading_indicator.dart';
import 'widgets/atoms/ironclad_form_field.dart';
import 'widgets/molecules/ironclad_section_header.dart';

class MembershipsView extends StatefulWidget {
  const MembershipsView({super.key});

  @override
  State<MembershipsView> createState() => _MembershipsViewState();
}

class _MembershipsViewState extends State<MembershipsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MembershipsViewModel>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Membresías')),
      body: Consumer<MembershipsViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading && vm.items.isEmpty) return const IroncladLoadingIndicator(message: 'Cargando...');
          if (vm.errorMessage.isNotEmpty && vm.items.isEmpty) {
            return IroncladEmptyState(icon: Icons.card_membership, title: 'Error', message: vm.errorMessage, onAction: vm.loadAll, actionLabel: 'Reintentar');
          }
          if (vm.items.isEmpty) {
            return const IroncladEmptyState(icon: Icons.card_membership, title: 'Sin planes', message: 'No hay membresías creadas.');
          }

          return RefreshIndicator(
            onRefresh: vm.loadAll,
            child: ListView(
              children: [
                const IroncladSectionHeader(title: 'Gestión de Planes', subtitle: 'Configuración de membresías del box', icon: Icons.card_membership),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: vm.items.length,
                  itemBuilder: (context, index) {
                    final membership = vm.items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(backgroundColor: Color(0xFFFF3B30), child: Icon(Icons.star, color: Colors.white)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(membership.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        Text('\$${membership.precio?.toStringAsFixed(2)} - ${membership.duracionDias} días', style: const TextStyle(color: Colors.orangeAccent, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                  IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showAddEditDialog(membership: membership)),
                                  IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _confirmDelete(membership)),
                                ],
                              ),
                              if (membership.descripcion != null && membership.descripcion!.isNotEmpty) ...[
                                const Divider(height: 20),
                                Text(
                                  membership.descripcion!,
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                              ],
                              if (membership.beneficios != null && membership.beneficios!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                const Text('Beneficios:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                                const SizedBox(height: 4),
                                Text(
                                  membership.beneficios!,
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: const Color(0xFFFF3B30),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddEditDialog({MembershipDto? membership}) {
    final isEdit = membership != null;
    final nameController = TextEditingController(text: membership?.nombre);
    final descController = TextEditingController(text: membership?.descripcion);
    final priceController = TextEditingController(text: membership?.precio?.toString());
    final durationController = TextEditingController(text: membership?.duracionDias?.toString());
    final beneficiosController = TextEditingController(text: membership?.beneficios);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(isEdit ? 'Editar Membresía' : 'Nueva Membresía', style: const TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IroncladFormField(
                controller: nameController,
                label: 'Nombre *',
                icon: Icons.title,
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              IroncladFormField(
                controller: descController,
                label: 'Descripción *',
                icon: Icons.description,
                keyboardType: TextInputType.multiline,
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: IroncladFormField(
                      controller: priceController,
                      label: 'Precio (\$) *',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: IroncladFormField(
                      controller: durationController,
                      label: 'Duración (días) *',
                      icon: Icons.timer,
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              IroncladFormField(
                controller: beneficiosController,
                label: 'Beneficios (uno por línea) *',
                icon: Icons.list,
                keyboardType: TextInputType.multiline,
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3B30)),
            onPressed: () async {
              if (nameController.text.isEmpty || descController.text.isEmpty || beneficiosController.text.isEmpty) return;

              final payload = {
                'nombre': nameController.text.trim(),
                'descripcion': descController.text.trim(),
                'precio': double.tryParse(priceController.text) ?? 0.0,
                'duracion_dias': int.tryParse(durationController.text) ?? 30,
                'beneficios': beneficiosController.text.trim(),
              };
              if (isEdit) {
                await context.read<MembershipsViewModel>().update(membership.id!, payload);
              } else {
                await context.read<MembershipsViewModel>().create(payload);
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text('GUARDAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(MembershipDto membership) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Membresía'),
        content: Text('¿Deseas eliminar "${membership.nombre}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('NO')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await context.read<MembershipsViewModel>().delete(membership.id!);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('SÍ, ELIMINAR'),
          ),
        ],
      ),
    );
  }
}
