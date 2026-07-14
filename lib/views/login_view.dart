import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/atoms/ironclad_background.dart';
import 'widgets/atoms/ironclad_form_field.dart';
import 'widgets/atoms/ironclad_primary_button.dart';
import 'widgets/atoms/ironclad_status_banner.dart';
import 'widgets/molecules/ironclad_auth_card.dart';
import '../core/validators.dart';
import '../viewmodels/login_viewmodel.dart';
import 'dashboard_view.dart';
import 'landing_view.dart';
import 'register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final viewModel = context.read<LoginViewModel>();
    final success = await viewModel.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => DashboardView(role: viewModel.currentRole),
        ),
      );
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
              constraints: const BoxConstraints(maxWidth: 400),
              child: Consumer<LoginViewModel>(
                builder: (context, viewModel, child) {
                  return IroncladAuthCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // El encabezado ya viene incluido en IroncladAuthCard, 
                          // por lo que aquí solo ponemos los campos del formulario.
                          IroncladFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            label: 'Correo',
                            icon: Icons.mail_outline,
                            validator: AppValidators.email,
                          ),
                          const SizedBox(height: 16),
                          IroncladFormField(
                            controller: _passwordController,
                            obscureText: true,
                            label: 'Contraseña',
                            icon: Icons.lock_outline,
                            validator: AppValidators.required,
                          ),
                          const SizedBox(height: 24),
                          if (viewModel.errorMessage.isNotEmpty) ...[
                            IroncladStatusBanner(message: viewModel.errorMessage),
                            const SizedBox(height: 16),
                          ],
                          IroncladPrimaryButton(
                            label: 'Ingresar',
                            icon: Icons.login,
                            isLoading: viewModel.isLoading,
                            onPressed: _submitLogin,
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const RegisterView()),
                              );
                            },
                            child: const Text('Crear cuenta nueva', style: TextStyle(color: Color(0xFFFF3B30))),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => const LandingView()),
                                (route) => false,
                              );
                            },
                            child: const Text('Volver al Inicio', style: TextStyle(color: Color(0xFFB0B0B5), fontSize: 12)),
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
