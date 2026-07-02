import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/backend_viewmodels.dart';
import 'widgets/atoms/ironclad_empty_state.dart';
import 'widgets/atoms/ironclad_loading_indicator.dart';
import 'widgets/molecules/ironclad_section_header.dart';

class ClassesView extends StatefulWidget {
  const ClassesView({super.key});

  @override
  State<ClassesView> createState() => _ClassesViewState();
}

class _ClassesViewState extends State<ClassesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClassesViewModel>().loadAll();
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
            return IroncladEmptyState(icon: Icons.calendar_month, title: 'Error', message: vm.errorMessage, onAction: vm.loadAll, actionLabel: 'Reintentar');
          }
          if (vm.items.isEmpty) {
            return const IroncladEmptyState(icon: Icons.calendar_month, title: 'Sin clases', message: 'No hay clases registradas.');
          }

          return RefreshIndicator(
            onRefresh: vm.loadAll,
            child: ListView(
              children: [
                const IroncladSectionHeader(title: 'Clases registradas', subtitle: 'Lista sincronizada con el backend', icon: Icons.calendar_month),
                ...vm.items.map(
                  (classItem) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Card(
                      child: ListTile(
                        leading: const Icon(Icons.schedule, color: Color(0xFFFF3B30)),
                        title: Text(classItem.nombre),
                        subtitle: Text('${classItem.fecha ?? '-'} ${classItem.hora ?? ''}\n${classItem.entrenadorNombre ?? 'Sin entrenador'}'),
                        isThreeLine: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}