import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/backend_viewmodels.dart';
import 'widgets/atoms/ironclad_empty_state.dart';
import 'widgets/atoms/ironclad_loading_indicator.dart';
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
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Card(
                      child: ListTile(
                        leading: const Icon(Icons.person, color: Color(0xFFFF3B30)),
                        title: Text('${athlete.nombre ?? '-'} ${athlete.apellido ?? ''}'),
                        subtitle: Text('${athlete.email ?? '-'}\n${athlete.membershipName ?? 'Sin membresía'}'),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Detalle atleta'),
                                content: Text('Peso: ${athlete.peso ?? '-'}\nAltura: ${athlete.altura ?? '-'}\nEstado: ${athlete.estado ?? '-'}'),
                              ),
                            );
                          },
                        ),
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