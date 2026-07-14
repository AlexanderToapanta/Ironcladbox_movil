import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../services/auth_service.dart';
import '../viewmodels/backend_viewmodels.dart';
import '../core/validators.dart';
import 'login_view.dart';
import 'widgets/atoms/ironclad_background.dart';
import 'widgets/atoms/ironclad_empty_state.dart';
import 'widgets/atoms/ironclad_form_field.dart';
import 'widgets/atoms/ironclad_loading_indicator.dart';
import 'widgets/atoms/ironclad_primary_button.dart';
import 'widgets/atoms/ironclad_status_banner.dart';
import 'widgets/molecules/ironclad_auth_card.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _pesoController = TextEditingController();
  final _alturaController = TextEditingController();
  DateTime? _fechaNacimiento;

  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _errorMessage = '';
  int? _selectedMembershipId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MembershipsViewModel>().loadAll();
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    super.dispose();
  }

  Future<void> _selectFechaNacimiento() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _fechaNacimiento) {
      setState(() {
        _fechaNacimiento = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMembershipId == null) {
      setState(() {
        _errorMessage = 'Selecciona una membresía';
      });
      return;
    }
    if (_fechaNacimiento == null) {
      setState(() {
        _errorMessage = 'Ingresa tu fecha de nacimiento';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final successMessage = await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nombreController.text.trim(),
        lastName: _apellidoController.text.trim(),
        phone: _telefonoController.text.trim(),
        address: _direccionController.text.trim(),
        birthDate: _fechaNacimiento,
        membershipId: _selectedMembershipId,
        weight: double.tryParse(_pesoController.text.trim()),
        height: double.tryParse(_alturaController.text.trim()),
        role: 'ATLETA',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginView()),
        (route) => false,
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IroncladBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Consumer<MembershipsViewModel>(
                builder: (context, membershipsViewModel, child) {
                  final memberships = membershipsViewModel.items;

                  return IroncladAuthCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: IroncladFormField(
                                  controller: _nombreController,
                                  label: 'Nom...',
                                  icon: Icons.person_outline,
                                  validator: AppValidators.required,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: IroncladFormField(
                                  controller: _apellidoController,
                                  label: 'Apell...',
                                  icon: Icons.person_outline,
                                  validator: AppValidators.required,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          IroncladFormField(
                            controller: _emailController,
                            label: 'Correo',
                            icon: Icons.mail_outline,
                            keyboardType: TextInputType.emailAddress,
                            validator: AppValidators.email,
                          ),
                          const SizedBox(height: 16),
                          IroncladFormField(
                            controller: _telefonoController,
                            label: 'Teléfono',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: AppValidators.phone,
                          ),
                          const SizedBox(height: 16),
                          IroncladFormField(
                            controller: _direccionController,
                            label: 'Dirección',
                            icon: Icons.location_on_outlined,
                            validator: AppValidators.required,
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: _selectFechaNacimiento,
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Fecha de Nacimiento',
                                prefixIcon: const Icon(Icons.cake_outlined),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                _fechaNacimiento == null
                                    ? 'Seleccionar fecha'
                                    : DateFormat('dd/MM/yyyy').format(_fechaNacimiento!),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: IroncladFormField(
                                  controller: _passwordController,
                                  label: 'Cont...',
                                  icon: Icons.lock_outline,
                                  obscureText: true,
                                  validator: AppValidators.password,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: IroncladFormField(
                                  controller: _confirmPasswordController,
                                  label: 'Confir...',
                                  icon: Icons.lock_outline,
                                  obscureText: true,
                                  validator: (value) => value != _passwordController.text ? 'No coincide' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: IroncladFormField(
                                  controller: _pesoController,
                                  label: 'Peso...',
                                  icon: Icons.monitor_weight_outlined,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: AppValidators.peso,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: IroncladFormField(
                                  controller: _alturaController,
                                  label: 'Altur...',
                                  icon: Icons.height_outlined,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: AppValidators.altura,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const Icon(Icons.card_membership, color: Color(0xFFFF3B30)),
                              const SizedBox(width: 8),
                              Text(
                                'Selecciona tu membresía',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (membershipsViewModel.isLoading && memberships.isEmpty)
                            const IroncladLoadingIndicator(message: 'Cargando membresías...')
                          else if (memberships.isEmpty)
                            const IroncladEmptyState(
                              icon: Icons.card_membership,
                              title: 'Sin membresías',
                              message: 'No hay membresías disponibles en este momento.',
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: memberships.length,
                              itemBuilder: (context, index) {
                                final membership = memberships[index];
                                final isSelected = _selectedMembershipId == membership.id;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedMembershipId = membership.id;
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1A1A1A),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected ? const Color(0xFFFF3B30) : Colors.transparent,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          membership.nombre.toUpperCase(),
                                          style: const TextStyle(
                                            color: Color(0xFFFF3B30),
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Bebas Neue',
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '\$${membership.precio?.toStringAsFixed(2) ?? '0.00'}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 32,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${membership.duracionDias ?? 0} días',
                                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                                        ),
                                        const SizedBox(height: 12),
                                        if (membership.descripcion != null)
                                          Text(
                                            membership.descripcion!,
                                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                                          ),
                                        const SizedBox(height: 12),
                                        const Divider(color: Colors.white10),
                                        const SizedBox(height: 8),
                                        _buildBenefit('Acceso ilimitado'),
                                        _buildBenefit('Asesoría inicial'),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          const SizedBox(height: 20),
                          if (_errorMessage.isNotEmpty) ...[
                            IroncladStatusBanner(message: _errorMessage),
                            const SizedBox(height: 16),
                          ],
                          IroncladPrimaryButton(
                            label: 'Registrarme',
                            icon: Icons.person_add_alt_1,
                            isLoading: _isLoading,
                            onPressed: _submit,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check, color: Color(0xFFFF3B30), size: 14),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12))),
        ],
      ),
    );
  }
}
