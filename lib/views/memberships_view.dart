import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/backend_api_models.dart';
import '../viewmodels/backend_viewmodels.dart';
import '../core/validators.dart';
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
  String _searchText = '';

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
      appBar: AppBar(title: const Text('Membresias')),
      body: Consumer<MembershipsViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading && vm.items.isEmpty) return const IroncladLoadingIndicator(message: 'Cargando...');
          if (vm.errorMessage.isNotEmpty && vm.items.isEmpty) {
            return IroncladEmptyState(icon: Icons.card_membership, title: 'Error', message: vm.errorMessage, onAction: vm.loadAll, actionLabel: 'Reintentar');
          }

          final filtered = _searchText.isEmpty
              ? vm.items
              : vm.items.where((m) =>
                  m.nombre.toLowerCase().contains(_searchText.toLowerCase()) ||
                  (m.descripcion?.toLowerCase() ?? '').contains(_searchText.toLowerCase()) ||
                  m.precio.toString().contains(_searchText) ||
                  m.duracionDias.toString().contains(_searchText)).toList();

          if (vm.items.isEmpty) {
            return const IroncladEmptyState(icon: Icons.card_membership, title: 'Sin planes', message: 'No hay membresias creadas.');
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Buscar por nombre, precio o duracion...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  onChanged: (v) => setState(() => _searchText = v),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: vm.loadAll,
                  child: ListView(
                    children: [
                      const IroncladSectionHeader(title: 'Gestion de Planes', subtitle: 'Configuracion de membresias del box', icon: Icons.card_membership),
                      if (filtered.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('Sin resultados', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                        ),
                      ...filtered.map((membership) => Padding(
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
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(membership.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: (membership.activa ?? false) ? Colors.green.shade800 : Colors.grey.shade700,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  (membership.activa ?? false) ? 'Activo' : 'Inactivo',
                                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text('\$${membership.precio?.toStringAsFixed(2)} - ${membership.duracionDias} dias', style: const TextStyle(color: Colors.orangeAccent, fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                    IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showAddEditDialog(membership: membership)),
                                    IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _confirmDelete(membership)),
                                  ],
                                ),
                                if (membership.descripcion != null && membership.descripcion!.isNotEmpty) ...[
                                  const Divider(height: 20),
                                  Text(membership.descripcion!, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                ],
                                if (membership.beneficios != null && membership.beneficios!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  const Text('Beneficios:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text(membership.beneficios!, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                ],
                              ],
                            ),
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ],
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
    bool estado = membership?.activa ?? true;

    showDialog(
      context: context,
      builder: (ctx) {
        final formKey = GlobalKey<FormState>();
        return StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text(isEdit ? 'Editar Membresia' : 'Nueva Membresia', style: const TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IroncladFormField(
                  controller: nameController,
                  label: 'Nombre *',
                  icon: Icons.title,
                  validator: AppValidators.required,
                ),
                const SizedBox(height: 16),
                IroncladFormField(
                  controller: descController,
                  label: 'Descripcion *',
                  icon: Icons.description,
                  keyboardType: TextInputType.multiline,
                  validator: AppValidators.required,
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
                        validator: AppValidators.precio,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: IroncladFormField(
                        controller: durationController,
                        label: 'Duracion (dias) *',
                        icon: Icons.timer,
                        keyboardType: TextInputType.number,
                        validator: AppValidators.duracion,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                IroncladFormField(
                  controller: beneficiosController,
                  label: 'Beneficios (uno por linea) *',
                  icon: Icons.list,
                  keyboardType: TextInputType.multiline,
                  validator: AppValidators.required,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Membresia Activa', style: TextStyle(color: Colors.white)),
                    const Spacer(),
                    Switch(
                      value: estado,
                      activeColor: const Color(0xFFFF3B30),
                      onChanged: (v) => setDialogState(() => estado = v),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCELAR', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3B30)),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final payload = {
                  'nombre': nameController.text.trim(),
                  'descripcion': descController.text.trim(),
                  'precio': double.tryParse(priceController.text) ?? 0.0,
                  'duracion_dias': int.tryParse(durationController.text) ?? 30,
                  'beneficios': beneficiosController.text.trim(),
                  'estado': estado,
                };
                if (isEdit) {
                  await context.read<MembershipsViewModel>().update(membership.id!, payload);
                } else {
                  await context.read<MembershipsViewModel>().create(payload);
                }
                final vm = context.read<MembershipsViewModel>();
                if (vm.errorMessage.isNotEmpty && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.errorMessage), backgroundColor: Colors.red));
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEdit ? 'Membresia actualizada' : 'Membresia creada'), backgroundColor: Colors.green));
                }
                vm.clearError();
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('GUARDAR', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      },
    );
  }

  void _confirmDelete(MembershipDto membership) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Membresia'),
        content: Text('Deseas eliminar "${membership.nombre}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('NO')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await context.read<MembershipsViewModel>().delete(membership.id!);
              final vm = context.read<MembershipsViewModel>();
              if (vm.errorMessage.isNotEmpty && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.errorMessage), backgroundColor: Colors.red));
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Membresia eliminada'), backgroundColor: Colors.green));
              }
              vm.clearError();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('SI, ELIMINAR'),
          ),
        ],
      ),
    );
  }
}
