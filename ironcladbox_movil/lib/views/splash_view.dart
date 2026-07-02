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
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1C1C1E), Color(0xFF111113), Color(0xFFFF3B30)],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
            child: Container(
              color: Colors.black.withValues(alpha: 0.35),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.fitness_center,
                      size: 72,
                      color: Color(0xFFFF3B30),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'IRONCLAD BOX',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 24),
                    if (viewModel.isLoading) ...[
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Color(0xFFFF3B30),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Verificando sesión...',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ] else ...[
                      Text(
                        viewModel.errorMessage.isEmpty
                            ? 'Cargando...'
                            : viewModel.errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
