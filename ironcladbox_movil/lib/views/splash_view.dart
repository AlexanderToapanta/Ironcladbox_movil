import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/splash_viewmodel.dart';
import 'dashboard_view.dart';
import 'login_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  bool _navigationHandled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SplashViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SplashViewModel>(
      builder: (context, viewModel, child) {
        if (!viewModel.isLoading && !_navigationHandled) {
          _navigationHandled = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => viewModel.hasSession
                    ? DashboardView(role: viewModel.role)
                    : const LoginView(),
              ),
            );
          });
        }

        return Scaffold(
          body: Center(
            child: viewModel.isLoading
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Verificando sesión...'),
                    ],
                  )
                : Text(
                    viewModel.errorMessage.isEmpty
                        ? 'Cargando...'
                        : viewModel.errorMessage,
                  ),
          ),
        );
      },
    );
  }
}
