import 'package:flutter/material.dart';
import 'athletes_view.dart';
import 'exercises_view.dart';
import 'memberships_view.dart';
import 'my_membership_view.dart';
import 'progress_view.dart';
import 'racha_view.dart';
import 'trainers_view.dart';
import 'wods_view.dart';

class QuickActionsView extends StatelessWidget {
  final String role;

  const QuickActionsView({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final tiles = _tilesForRole(role);

    return Scaffold(
      backgroundColor: const Color(0xFF111113),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'ACCESO RÁPIDO',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Bebas Neue',
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Navega por las secciones',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
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
                    color: const Color(0xFF1C1C1E),
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
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(tile.icon, color: const Color(0xFFFF3B30), size: 44),
                            const SizedBox(height: 12),
                            Text(
                              tile.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
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
        ),
      ),
    );
  }
}

class _QuickTile {
  final String title;
  final IconData icon;
  final Widget page;

  const _QuickTile({required this.title, required this.icon, required this.page});
}

List<_QuickTile> _tilesForRole(String role) {
  final normalized = role.toLowerCase();

  if (normalized == 'admin' || normalized == 'administrador') {
    return const [
      _QuickTile(title: 'Atletas', icon: Icons.groups, page: AthletesView()),
      _QuickTile(title: 'Entrenadores', icon: Icons.badge, page: TrainersView()),
      _QuickTile(title: 'Membresias', icon: Icons.card_membership, page: MembershipsView()),
      _QuickTile(title: 'WODs', icon: Icons.fitness_center, page: WodsView()),
      _QuickTile(title: 'Ejercicios', icon: Icons.sports_gymnastics, page: ExercisesView()),
    ];
  }

  if (normalized == 'trainer' || normalized == 'entrenador') {
    return const [
      _QuickTile(title: 'WODs', icon: Icons.fitness_center, page: WodsView()),
      _QuickTile(title: 'Mis Atletas', icon: Icons.groups, page: AthletesView()),
      _QuickTile(title: 'Ejercicios', icon: Icons.sports_gymnastics, page: ExercisesView()),
    ];
  }

  return const [
    _QuickTile(title: 'WODs', icon: Icons.fitness_center, page: WodsView()),
    _QuickTile(title: 'Racha', icon: Icons.local_fire_department, page: RachaView()),
    _QuickTile(title: 'Membresía', icon: Icons.card_membership, page: MyMembershipView()),
    _QuickTile(title: 'Progreso', icon: Icons.show_chart, page: ProgressView()),
    _QuickTile(title: 'Ejercicios', icon: Icons.sports_gymnastics, page: ExercisesView()),
  ];
}
