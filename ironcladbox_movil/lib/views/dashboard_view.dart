import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/login_viewmodel.dart';
import 'athletes_view.dart';
import 'classes_view.dart';
import 'contacts_view.dart';
import 'dashboard_home_view.dart';
import 'exercises_view.dart';
import 'memberships_view.dart';
import 'login_view.dart';
import 'profile_view.dart';
import 'progress_view.dart';
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

  List<_DashboardTab> get _tabs {
    final role = widget.role.toLowerCase();

    if (role == 'administrador' || role == 'admin') {
      return const [
        _DashboardTab('Inicio', Icons.dashboard, 'IronCladBox'),
        _DashboardTab('Atletas', Icons.groups, 'Gestión de atletas'),
        _DashboardTab('WODs', Icons.fitness_center, 'Calendario WOD'),
        _DashboardTab('Entrenadores', Icons.badge, 'Gestión de entrenadores'),
        _DashboardTab('Perfil', Icons.person, 'Perfil de administrador'),
      ];
    }

    if (role == 'entrenador' || role == 'trainer') {
      return const [
        _DashboardTab('Inicio', Icons.dashboard, 'IronCladBox'),
        _DashboardTab('WODs', Icons.fitness_center, 'Calendario WOD'),
        _DashboardTab('Atletas', Icons.groups, 'Consulta de atletas'),
        _DashboardTab('Ejercicios', Icons.sports_gymnastics, 'Gestión de ejercicios'),
        _DashboardTab('Perfil', Icons.person, 'Perfil de entrenador'),
      ];
    }

    return const [
      _DashboardTab('Inicio', Icons.dashboard, 'IronCladBox'),
      _DashboardTab('WODs', Icons.fitness_center, 'Consultar WOD'),
      _DashboardTab('Progreso', Icons.show_chart, 'Registrar progreso'),
      _DashboardTab('Perfil', Icons.person, 'Mi Perfil'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _tabs;
    final pages = _pagesForRole(widget.role);

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
      body: IndexedStack(index: _selectedIndex, children: pages),
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
      DashboardHomeView(role: 'admin'),
      AthletesView(),
      WodsView(),
      TrainersView(),
      ProfileView(),
    ];
  }

  if (normalized == 'trainer' || normalized == 'entrenador') {
    return const [
      DashboardHomeView(role: 'trainer'),
      WodsView(),
      AthletesView(),
      ExercisesView(),
      ProfileView(),
    ];
  }

  return const [
    DashboardHomeView(role: 'athlete'),
    WodsView(),
    ProgressView(),
    ProfileView(),
  ];
}
