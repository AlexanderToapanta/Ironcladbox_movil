import 'package:flutter/material.dart';

import 'athletes_view.dart';
import 'exercises_view.dart';
import 'memberships_view.dart';
import 'profile_view.dart';
import 'progress_view.dart';
import 'trainers_view.dart';
import 'wods_view.dart';
import 'widgets/molecules/ironclad_section_header.dart';

class DashboardHomeView extends StatelessWidget {
  final String role;

  const DashboardHomeView({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final tiles = _tilesForRole(role);

    return ListView(
      children: [
        IroncladSectionHeader(
          title: 'Bienvenido',
          subtitle: 'Accesos rápidos para ${role.toLowerCase()}',
          icon: Icons.dashboard_customize,
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: tiles.length,
            itemBuilder: (context, index) {
              final tile = tiles[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => tile.page),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(tile.icon, color: const Color(0xFFFF3B30), size: 40),
                        const SizedBox(height: 12),
                        Text(
                          tile.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HomeTile {
  final String title;
  final IconData icon;
  final Widget page;

  const _HomeTile({required this.title, required this.icon, required this.page});
}

List<_HomeTile> _tilesForRole(String role) {
  final normalized = role.toLowerCase();

  if (normalized == 'admin' || normalized == 'administrador') {
    return const [
      _HomeTile(title: 'Atletas', icon: Icons.groups, page: AthletesView()),
      _HomeTile(title: 'Entrenadores', icon: Icons.badge, page: TrainersView()),
      _HomeTile(title: 'Membresías', icon: Icons.card_membership, page: MembershipsView()),
      _HomeTile(title: 'WODs', icon: Icons.fitness_center, page: WodsView()),
      _HomeTile(title: 'Ejercicios', icon: Icons.sports_gymnastics, page: ExercisesView()),
      _HomeTile(title: 'Perfil', icon: Icons.person, page: ProfileView()),
    ];
  }

  if (normalized == 'trainer' || normalized == 'entrenador') {
    return const [
      _HomeTile(title: 'Atletas', icon: Icons.groups, page: AthletesView()),
      _HomeTile(title: 'WODs', icon: Icons.fitness_center, page: WodsView()),
      _HomeTile(title: 'Ejercicios', icon: Icons.sports_gymnastics, page: ExercisesView()),
      _HomeTile(title: 'Perfil', icon: Icons.person, page: ProfileView()),
    ];
  }

  return const [
    _HomeTile(title: 'WODs', icon: Icons.fitness_center, page: WodsView()),
    _HomeTile(title: 'Progreso', icon: Icons.show_chart, page: ProgressView()),
    _HomeTile(title: 'Perfil', icon: Icons.person, page: ProfileView()),
  ];
}
