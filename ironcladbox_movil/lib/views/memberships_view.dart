import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/backend_viewmodels.dart';
import 'widgets/atoms/ironclad_empty_state.dart';
import 'widgets/atoms/ironclad_loading_indicator.dart';
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
          if (vm.isLoading && vm.items.isEmpty) {
            return const IroncladLoadingIndicator(message: 'Cargando membresías...');
          }

          if (vm.errorMessage.isNotEmpty && vm.items.isEmpty) {
            return IroncladEmptyState(
              icon: Icons.card_membership,
              title: 'Error',
              message: vm.errorMessage,
              onAction: vm.loadAll,
              actionLabel: 'Reintentar',
            );
          }

          if (vm.items.isEmpty) {
            return const IroncladEmptyState(
              icon: Icons.card_membership,
              title: 'Sin membresías',
              message: 'No hay membresías cargadas.',
            );
          }

          return RefreshIndicator(
            onRefresh: vm.loadAll,
            child: ListView(
              children: [
                const IroncladSectionHeader(
                  title: 'Planes disponibles',
                  subtitle: 'Planes cargados desde la base de datos',
                  icon: Icons.card_membership,
                ),
                ...vm.items.map(
                  (membership) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Card(
                      child: ListTile(
                        leading: const Icon(Icons.workspace_premium, color: Color(0xFFFF3B30)),
                        title: Text(membership.nombre),
                        subtitle: Text(membership.descripcion ?? 'Sin descripción'),
                        trailing: Text(membership.precio != null ? '\$${membership.precio}' : '-'),
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