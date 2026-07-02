import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/backend_viewmodels.dart';
import 'widgets/atoms/ironclad_empty_state.dart';
import 'widgets/atoms/ironclad_loading_indicator.dart';
import 'widgets/molecules/ironclad_section_header.dart';

class ProgressView extends StatefulWidget {
  const ProgressView({super.key});

  @override
  State<ProgressView> createState() => _ProgressViewState();
}

class _ProgressViewState extends State<ProgressView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressViewModel>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progreso')),
      body: Consumer<ProgressViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading && vm.items.isEmpty) return const IroncladLoadingIndicator(message: 'Cargando progreso...');
          if (vm.errorMessage.isNotEmpty && vm.items.isEmpty) {
            return IroncladEmptyState(icon: Icons.show_chart, title: 'Error', message: vm.errorMessage, onAction: vm.loadAll, actionLabel: 'Reintentar');
          }
          if (vm.items.isEmpty) {
            return const IroncladEmptyState(icon: Icons.show_chart, title: 'Sin progreso', message: 'Aún no hay marcas registradas.');
          }

          return RefreshIndicator(
            onRefresh: vm.loadAll,
            child: ListView(
              children: [
                const IroncladSectionHeader(title: 'Registro de marcas', subtitle: 'Últimos ejercicios con progreso', icon: Icons.show_chart),
                ...vm.items.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Card(
                      child: ListTile(
                        leading: const Icon(Icons.trending_up, color: Color(0xFFFF3B30)),
                        title: Text(entry.exerciseName ?? 'Ejercicio'),
                        subtitle: Text('Marca: ${entry.marcaMaxima ?? '-'}'),
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