import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../viewmodels/backend_viewmodels.dart';
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
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _pesoController = TextEditingController();
  final _alturaController = TextEditingController();

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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMembershipId == null) {
      setState(() {
        _errorMessage = 'Selecciona una membresía';
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
        membershipId: _selectedMembershipId,
        weight: double.tryParse(_pesoController.text.trim()),
        height: double.tryParse(_alturaController.text.trim()),
        role: 'ATLETA',
      );

      if (!mounted) return;

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ),
      );

      // Redirigir al Login
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
                                  label: 'Nombre',
                                  icon: Icons.person_outline,
                                  validator: (value) => value == null || value.isEmpty ? 'Ingresa tu nombre' : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: IroncladFormField(
                                  controller: _apellidoController,
                                  label: 'Apellido',
                                  icon: Icons.person_outline,
                                  validator: (value) => value == null || value.isEmpty ? 'Ingresa tu apellido' : null,
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
                            validator: (value) => value == null || value.isEmpty ? 'Ingresa tu correo' : null,
                          ),
                          const SizedBox(height: 16),
                          IroncladFormField(
                            controller: _telefonoController,
                            label: 'Teléfono',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (value) => value == null || value.isEmpty ? 'Ingresa tu teléfono' : null,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: IroncladFormField(
                                  controller: _passwordController,
                                  label: 'Contraseña',
                                  icon: Icons.lock_outline,
                                  obscureText: true,
                                  validator: (value) => value == null || value.length < 8 ? 'Mínimo 8 caracteres' : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: IroncladFormField(
                                  controller: _confirmPasswordController,
                                  label: 'Confirmar',
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
                                  label: 'Peso (kg)',
                                  icon: Icons.monitor_weight_outlined,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: (value) => null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: IroncladFormField(
                                  controller: _alturaController,
                                  label: 'Altura (m)',
                                  icon: Icons.height_outlined,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: (value) => null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Selecciona tu membresía',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 12),
                          if (membershipsViewModel.isLoading && memberships.isEmpty)
                            const IroncladLoadingIndicator(message: 'Cargando membresías...')
                          else if (memberships.isEmpty)
                            IroncladEmptyState(
                              icon: Icons.card_membership,
                              title: 'Sin membresías',
                              message: 'No hay membresías disponibles en este momento.',
                            )
 else
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: memberships
                                  .map(
                                    (membership) => FilterChip(
                                      label: Text(
                                        membership.precio == null
                                            ? membership.nombre
                                            : '${membership.nombre} - \$${membership.precio!.toStringAsFixed(2)}',
                                      ),
                                      selected: _selectedMembershipId == membership.id,
                                      onSelected: (_) {
                                        setState(() {
                                          _selectedMembershipId = membership.id;
                                        });
                                      },
                                    ),
                                  )
                                  .toList(),
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
}