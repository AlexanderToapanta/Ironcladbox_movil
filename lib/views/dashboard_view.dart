import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/backend_viewmodels.dart';
import 'athletes_view.dart';
import 'classes_view.dart';
import 'dashboard_home_view.dart';
import 'exercises_view.dart';
import 'login_view.dart';
import 'memberships_view.dart';
import 'my_membership_view.dart';
import 'profile_view.dart';
import 'progress_view.dart';
import 'quick_actions_view.dart';
import 'racha_view.dart';
import 'trainers_view.dart';
import 'wods_view.dart';
import 'widgets/atoms/ironclad_logout_button.dart';

class DashboardView extends StatefulWidget {
  final String role;

  const DashboardView({super.key, required this.role});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _selectedIndex = 0;
  late String _currentRole;
  bool _isOffline = false;
  StreamSubscription<void>? _reconnectSub;
  StreamSubscription<void>? _sessionExpiredSub;
  Timer? _autoRefreshTimer;
  int _refreshFailureCount = 0;

  @override
  void initState() {
    super.initState();
    _currentRole = widget.role;
    ApiService().resetSessionExpiredFlag();
    _checkUserStatus();
    _isOffline = ApiService().isOffline;
    _reconnectSub = SocketService().onReconnected.listen((_) {
      if (mounted) {
        setState(() => _isOffline = false);
        ApiService().drainQueue();
        _safeRefreshAll();
      }
    });
    _sessionExpiredSub = ApiService().onSessionExpired.listen((_) {
      if (mounted) _handleSessionExpiredEvent();
    });
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (mounted) _safeRefreshAll();
    });
  }

  Future<void> _handleSessionExpiredEvent() async {
    final isValid = await AuthService().verifyToken();
    if (!mounted) return;
    if (isValid) {
      ApiService().resetSessionExpiredFlag();
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginView()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _reconnectSub?.cancel();
    _sessionExpiredSub?.cancel();
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  void _safeRefreshAll() {
    try {
      _refreshAllViewModels();
      _refreshFailureCount = 0;
    } catch (_) {
      _refreshFailureCount++;
      if (_refreshFailureCount >= 3) {
        if (mounted) _handleSessionExpiredEvent();
      }
    }
  }

  void _refreshAllViewModels() {
    try {
      final role = _currentRole.toLowerCase();
      if (role == 'admin' || role == 'administrador') {
        context.read<AthletesViewModel>().loadAll();
        context.read<TrainersViewModel>().loadAll();
        context.read<MembershipsViewModel>().loadAll();
      }
      if (role == 'trainer' || role == 'entrenador') {
        context.read<AthletesViewModel>().loadMyAthletes();
      }
      context.read<ClassesViewModel>().loadAll();
      context.read<ExercisesViewModel>().loadAll();
      context.read<WodsViewModel>().loadByMonth(DateTime.now().year, DateTime.now().month);
      context.read<ProgressViewModel>().loadAll();
    } catch (_) {}
  }

  Future<void> _checkUserStatus() async {
    final profile = await AuthService().getProfile();
    if (profile != null) {
      final newRole = profile['rol_nombre'] ?? profile['rol'] ?? _currentRole;
      if (mounted && newRole.toLowerCase() != _currentRole.toLowerCase()) {
        setState(() { _currentRole = newRole; });
        context.read<LoginViewModel>().setRole(newRole);
      }
    }
  }

  List<_DashboardTab> get _tabs {
    final role = _currentRole.toLowerCase();

    if (role == 'administrador' || role == 'admin') {
      return const [
        _DashboardTab('Acciones', Icons.grid_view, 'Acceso Rapido'),
        _DashboardTab('Inicio', Icons.dashboard, 'IronCladBox'),
        _DashboardTab('Perfil', Icons.person, 'Mi Perfil'),
      ];
    }

    if (role == 'entrenador' || role == 'trainer') {
      return const [
        _DashboardTab('Acciones', Icons.grid_view, 'Acceso Rapido'),
        _DashboardTab('Inicio', Icons.dashboard, 'IronCladBox'),
        _DashboardTab('Perfil', Icons.person, 'Mi Perfil'),
      ];
    }

    return const [
      _DashboardTab('Acciones', Icons.grid_view, 'Acceso Rapido'),
      _DashboardTab('Inicio', Icons.dashboard, 'IronCladBox'),
      _DashboardTab('Perfil', Icons.person, 'Mi Perfil'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _tabs;
    final pages = _pagesForRole(_currentRole);

    return Scaffold(
      appBar: AppBar(
        title: const Text('IronCladBox'),
        actions: [
          IroncladLogoutButton(
            onPressed: () async {
              await context.read<LoginViewModel>().logout();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginView()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isOffline || ApiService().isOffline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: ApiService().pendingCount > 0 ? Colors.red.shade700 : Colors.orange.shade800,
              ),
              child: Row(
                children: [
                  Icon(
                    ApiService().pendingCount > 0 ? Icons.sync_problem : Icons.wifi_off,
                    color: Colors.white, size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      ApiService().pendingCount > 0
                          ? 'SIN CONEXION - ${ApiService().pendingCount} cambios pendientes - Toca para reintentar'
                          : 'Sin conexion - Mostrando datos en cache - Toca para reconectar',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ApiService().forceOnline();
                      setState(() => _isOffline = false);
                      ApiService().drainQueue();
                      _refreshAllViewModels();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh, color: Colors.white, size: 18),
                          SizedBox(width: 4),
                          Text('RECONECTAR', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(child: IndexedStack(index: _selectedIndex, children: pages)),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: tabs
            .map(
              (tab) => BottomNavigationBarItem(
                icon: Icon(tab.icon),
                label: tab.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _DashboardTab {
  final String label;
  final IconData icon;
  final String title;

  const _DashboardTab(this.label, this.icon, this.title);
}

List<Widget> _pagesForRole(String role) {
  final normalized = role.toLowerCase();

  if (normalized == 'admin' || normalized == 'administrador') {
    return const [
      QuickActionsView(role: 'admin'),
      DashboardHomeView(role: 'admin'),
      ProfileView(),
    ];
  }

  if (normalized == 'trainer' || normalized == 'entrenador') {
    return const [
      QuickActionsView(role: 'trainer'),
      DashboardHomeView(role: 'trainer'),
      ProfileView(),
    ];
  }

  return const [
    QuickActionsView(role: 'athlete'),
    DashboardHomeView(role: 'athlete'),
    ProfileView(),
  ];
}
