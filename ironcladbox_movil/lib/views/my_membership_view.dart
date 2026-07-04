import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../viewmodels/backend_viewmodels.dart';
import '../viewmodels/login_viewmodel.dart';
import '../services/auth_service.dart';
import 'widgets/atoms/ironclad_loading_indicator.dart';
import 'widgets/atoms/ironclad_empty_state.dart';
import 'login_view.dart';

class MyMembershipView extends StatefulWidget {
  const MyMembershipView({super.key});

  @override
  State<MyMembershipView> createState() => _MyMembershipViewState();
}

class _MyMembershipViewState extends State<MyMembershipView> {
  int? _selectedMembershipId;
  bool _loadingData = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _loadingData = true);
    await context.read<AthletesViewModel>().loadMyMembership();
    await context.read<MembershipsViewModel>().loadAll();
    if (mounted) setState(() => _loadingData = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer2<AthletesViewModel, MembershipsViewModel>(
        builder: (context, athletesVm, membershipsVm, child) {
          if (_loadingData || athletesVm.isLoading || membershipsVm.isLoading) {
            return const IroncladLoadingIndicator(message: 'Cargando información...');
          }

          final athleteData = athletesVm.selectedItem;
          final allMemberships = membershipsVm.items;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            children: [
              const Text(
                'MEMBRESÍA ACTUAL',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Bebas Neue',
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Estado:', 'Activa', isStatus: true, statusValue: true),
                    const SizedBox(height: 20),
                    _buildInfoRow('Membresía:', athleteData?.membershipName ?? 'Ninguna'),
                    const SizedBox(height: 20),
                    _buildInfoRow(
                      'Inicio:',
                      athleteData?.fechaInicioMembresia != null
                          ? DateFormat('dd/MM/yyyy').format(athleteData!.fechaInicioMembresia!.toLocal())
                          : '-',
                    ),
                    const SizedBox(height: 20),
                    _buildInfoRow(
                      'Fin:',
                      athleteData?.fechaFinMembresia != null
                          ? DateFormat('dd/MM/yyyy').format(athleteData!.fechaFinMembresia!.toLocal())
                          : '-',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              const Text(
                'CAMBIAR O CANCELAR MEMBRESÍA',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Bebas Neue',
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Selecciona una nueva membresía',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                dropdownColor: const Color(0xFF1A1A1A),
                value: _selectedMembershipId,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                items: allMemberships.map((m) {
                  return DropdownMenuItem(
                    value: m.id,
                    child: Text(
                      '${m.nombre} - \$${m.precio?.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedMembershipId = val),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFF3B30)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFF3B30)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFF3B30), width: 2),
                  ),
                ),
                hint: const Text('Seleccionar membresía...', style: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedMembershipId == null ? null : _submitChange,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF3B30),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 6,
                      ),
                      child: const Text('CAMBIAR MEMBRESÍA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _confirmCancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF37474F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 6,
                      ),
                      child: const Text('CANCELAR MEMBRESÍA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Si cancelas tu membresía, no podrás iniciar sesión hasta que tengas una nueva membresía activa.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 60),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isStatus = false, bool statusValue = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        if (isStatus)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: statusValue ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusValue ? Colors.green : Colors.red, width: 1.5),
            ),
            child: Text(
              value.toUpperCase(),
              style: TextStyle(
                color: statusValue ? Colors.green : Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
      ],
    );
  }

  Future<void> _submitChange() async {
    if (_selectedMembershipId == null) return;
    try {
      await context.read<AthletesViewModel>().updateMyMembership({'id_membresia': _selectedMembershipId});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud enviada. Tu cuenta se cerrará por seguridad.'),
            backgroundColor: Colors.orange,
          ),
        );
        
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          await context.read<LoginViewModel>().logout();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginView()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _confirmCancel() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Confirmar', style: TextStyle(color: Colors.white)),
        content: const Text('¿Deseas cancelar tu membresía actual?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('VOLVER', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await context.read<AthletesViewModel>().cancelMyMembership();
                if (mounted) {
                  Navigator.pop(context);
                  _loadData();
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('SÍ, CANCELAR'),
          ),
        ],
      ),
    );
  }
}
