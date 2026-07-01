import 'package:flutter/material.dart';

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
        _DashboardTab('Inicio', Icons.dashboard, 'Dashboard de administrador'),
        _DashboardTab('Usuarios', Icons.people, 'Gestión de usuarios'),
        _DashboardTab('WOD', Icons.fitness_center, 'Gestión de WOD'),
        _DashboardTab('Clases', Icons.calendar_month, 'Gestión de clases'),
        _DashboardTab('Perfil', Icons.person, 'Perfil de administrador'),
      ];
    }

    if (role == 'entrenador' || role == 'trainer') {
      return const [
        _DashboardTab('Inicio', Icons.dashboard, 'Dashboard de entrenador'),
        _DashboardTab('WOD', Icons.fitness_center, 'Gestión de WOD'),
        _DashboardTab('Horario', Icons.schedule, 'Gestión de horarios'),
        _DashboardTab('Atletas', Icons.groups, 'Consulta de atletas'),
        _DashboardTab('Perfil', Icons.person, 'Perfil de entrenador'),
      ];
    }

    return const [
      _DashboardTab('Inicio', Icons.dashboard, 'Dashboard de atleta'),
      _DashboardTab('WOD', Icons.fitness_center, 'Consultar WOD'),
      _DashboardTab('Horario', Icons.schedule, 'Ver horarios'),
      _DashboardTab('Progreso', Icons.show_chart, 'Registrar progreso'),
      _DashboardTab('Perfil', Icons.person, 'Perfil de atleta'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _tabs;
    final selectedTab = tabs[_selectedIndex.clamp(0, tabs.length - 1)];

    return Scaffold(
      appBar: AppBar(title: Text('Dashboard - ${widget.role}')),
      body: Center(
        child: Text(selectedTab.title),
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
