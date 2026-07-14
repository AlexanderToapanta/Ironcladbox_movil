import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/backend_api_models.dart';
import '../viewmodels/backend_viewmodels.dart';
import '../core/validators.dart';
import 'widgets/atoms/ironclad_empty_state.dart';
import 'widgets/atoms/ironclad_loading_indicator.dart';
import 'widgets/atoms/ironclad_form_field.dart';
import 'widgets/molecules/ironclad_section_header.dart';

class ClassesView extends StatefulWidget {
  const ClassesView({super.key});

  @override
  State<ClassesView> createState() => _ClassesViewState();
}

class _ClassesViewState extends State<ClassesView> {
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClassesViewModel>().loadAll();
      context.read<TrainersViewModel>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clases')),
      body: Consumer<ClassesViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading && vm.items.isEmpty) return const IroncladLoadingIndicator(message: 'Cargando clases...');
          if (vm.errorMessage.isNotEmpty && vm.items.isEmpty) {
            return IroncladEmptyState(icon: Icons.school, title: 'Error', message: vm.errorMessage, onAction: vm.loadAll, actionLabel: 'Reintentar');
          }
          if (vm.items.isEmpty) return const IroncladEmptyState(icon: Icons.school, title: 'Sin clases', message: 'No hay clases programadas.');

          final filtered = _searchText.isEmpty ? vm.items : vm.items.where((c) {
            final name = c.nombre.toLowerCase();
            final trainer = (c.entrenadorNombre ?? '').toLowerCase();
            final q = _searchText.toLowerCase();
            return name.contains(q) || trainer.contains(q);
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  onChanged: (v) => setState(() => _searchText = v),
                  decoration: const InputDecoration(
                    hintText: 'Buscar por nombre o entrenador...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                    filled: true, fillColor: Color(0x0DFFFFFF),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: vm.loadAll,
                  child: ListView(children: [
                    const IroncladSectionHeader(title: 'Gestion de Clases', subtitle: 'Programacion de clases del box', icon: Icons.school),
                    ...filtered.map((c) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Card(
                        color: c.estado == 'CANCELADA' ? Colors.red.shade900.withOpacity(0.3) : null,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: c.estado == 'CANCELADA' ? Colors.grey : Colors.green,
                            child: Icon(c.estado == 'CANCELADA' ? Icons.cancel : Icons.school, color: Colors.white),
                          ),
                          title: Text(c.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(c.descripcion ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text('${c.fecha != null ? DateFormat('dd/MM/yyyy').format(c.fecha!.toLocal()) : '-'}  ${c.hora ?? ''}  |  ${c.entrenadorNombre ?? 'Sin entrenador'}  |  ${c.inscritos ?? 0}/${c.cupoMaximo ?? 20}'),
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(color: c.estado == 'CANCELADA' ? Colors.red : Colors.green, borderRadius: BorderRadius.circular(8)),
                              child: Text(c.estado ?? 'ACTIVA', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ]),
                          trailing: PopupMenuButton<String>(
                            onSelected: (action) {
                              switch(action) {
                                case 'edit': _showAddEditDialog(classItem: c); break;
                                case 'cancel': vm.delete(c.id!); break;
                                case 'reactivate': vm.reactivate(c.id!); break;
                                case 'delete': _confirmPermanentDelete(c); break;
                              }
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(value: 'edit', child: Text('Editar')),
                              if (c.estado != 'CANCELADA') const PopupMenuItem(value: 'cancel', child: Text('Cancelar', style: TextStyle(color: Colors.orange))),
                              if (c.estado == 'CANCELADA') const PopupMenuItem(value: 'reactivate', child: Text('Reactivar', style: TextStyle(color: Colors.green))),
                              if (c.estado == 'CANCELADA') const PopupMenuItem(value: 'delete', child: Text('Eliminar Permanentemente', style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        ),
                      ),
                    )),
                  ]),
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

  void _showAddEditDialog({ClassDto? classItem}) {
    final isEdit = classItem != null;
    final nameCtrl = TextEditingController(text: classItem?.nombre);
    final descCtrl = TextEditingController(text: classItem?.descripcion);
    final fechaCtrl = TextEditingController(text: classItem?.fecha != null ? DateFormat('yyyy-MM-dd').format(classItem!.fecha!.toLocal()) : DateFormat('yyyy-MM-dd').format(DateTime.now()));
    final horaCtrl = TextEditingController(text: classItem?.hora != null ? classItem!.hora!.substring(0,5) : '07:00');
    final cupoCtrl = TextEditingController(text: (classItem?.cupoMaximo ?? 20).toString());
    int? entrenadorId = classItem?.entrenadorId;
    final trainers = context.read<TrainersViewModel>().items;

    showDialog(
      context: context,
      builder: (ctx) {
        final formKey = GlobalKey<FormState>();
        return StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text(isEdit ? 'Editar Clase' : 'Nueva Clase', style: const TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
              IroncladFormField(controller: nameCtrl, label: 'Nombre *', icon: Icons.title, validator: AppValidators.required),
              const SizedBox(height: 12),
              IroncladFormField(controller: descCtrl, label: 'Descripcion', icon: Icons.description),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: IroncladFormField(controller: fechaCtrl, label: 'Fecha *', icon: Icons.calendar_today, validator: AppValidators.fecha)),
                const SizedBox(width: 12),
                Expanded(child: IroncladFormField(controller: horaCtrl, label: 'Hora *', icon: Icons.access_time, validator: AppValidators.hora)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: IroncladFormField(controller: cupoCtrl, label: 'Cupo *', icon: Icons.people, keyboardType: TextInputType.number, validator: AppValidators.cupo)),
                const SizedBox(width: 12),
                Expanded(child: DropdownButtonFormField<int>(
                  value: entrenadorId,
                  validator: (v) => v == null ? 'Selecciona un entrenador' : null,
                  decoration: const InputDecoration(labelText: 'Entrenador *', prefixIcon: Icon(Icons.person)),
                  items: trainers.map((t) => DropdownMenuItem(value: t.id, child: Text('${t.nombre} ${t.apellido}', style: const TextStyle(fontSize: 12)))).toList(),
                  onChanged: (v) => setDialogState(() => entrenadorId = v),
                )),
              ]),
            ]),
          ),),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3B30)),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final payload = {
                  'nombre': nameCtrl.text.trim(),
                  'descripcion': descCtrl.text.trim(),
                  'fecha': fechaCtrl.text.trim(),
                  'hora': horaCtrl.text.trim() + ':00',
                  'cupo_maximo': int.tryParse(cupoCtrl.text) ?? 20,
                  'id_entrenador': entrenadorId,
                };
                final vm = context.read<ClassesViewModel>();
                if (isEdit) { await vm.update(classItem!.id!, payload); } else { await vm.create(payload); }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      },
    );
  }

  void _confirmPermanentDelete(ClassDto c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Permanentemente'),
        content: Text('Eliminar "${c.nombre}" definitivamente?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await context.read<ClassesViewModel>().deletePermanently(c.id!);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
