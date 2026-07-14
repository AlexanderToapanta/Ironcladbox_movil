import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/config/api_config.dart';
import '../services/api_service.dart';
import '../viewmodels/backend_viewmodels.dart';
import 'athletes_view.dart';
import 'exercises_view.dart';
import 'profile_view.dart';
import 'progress_view.dart';
import 'racha_view.dart';
import 'trainers_view.dart';
import 'memberships_view.dart';
import 'wods_view.dart';
import 'widgets/molecules/ironclad_section_header.dart';

class DashboardHomeView extends StatefulWidget {
  final String role;

  const DashboardHomeView({super.key, required this.role});

  @override
  State<DashboardHomeView> createState() => _DashboardHomeViewState();
}

class _DashboardHomeViewState extends State<DashboardHomeView> {
  Map<String, int> _stats = {};
  bool _loadingStats = true;
  List<Map<String, dynamic>> _upcomingSchedules = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final api = ApiService();
      final role = widget.role.toLowerCase();

      if (role == 'trainer' || role == 'entrenador') {
        final wodsRes = await api.get(ApiConfig.trainersMyWods);
        final athletesRes = await api.get(ApiConfig.trainersMyAthletes);
        final wods = (wodsRes.data is Map && wodsRes.data['data'] is List)
            ? (wodsRes.data['data'] as List).length
            : 0;
        final athletes = (athletesRes.data is Map && athletesRes.data['data'] is List)
            ? (athletesRes.data['data'] as List).length
            : 0;
        final allWods = context.read<WodsViewModel>().items.length;
        setState(() {
          _stats = {
            'totalAthletes': athletes,
            'myWODs': wods,
            'totalWODs': allWods > 0 ? allWods : wods,
          };
        });
      } else if (role == 'atleta') {
        final schedulesRes = await api.get(ApiConfig.wodMySchedules);
        final rachaRes = await api.get(ApiConfig.wodRacha);

        final schedules = (schedulesRes.data is Map && schedulesRes.data['data'] is List)
            ? (schedulesRes.data['data'] as List).cast<Map<String, dynamic>>()
            : <Map<String, dynamic>>[];
        final racha = (rachaRes.data is Map && rachaRes.data['data'] is Map)
            ? rachaRes.data['data'] as Map<String, dynamic>
            : <String, dynamic>{};

        final hoy = DateTime.now().toIso8601String().substring(0, 10);
        final inscritos = schedules.where((s) {
          final fecha = s['fecha']?.toString().substring(0, 10) ?? '';
          return fecha.compareTo(hoy) >= 0;
        }).length;

        final upcoming = schedules
            .where((s) {
              final fecha = s['fecha']?.toString().substring(0, 10) ?? '';
              final hora = s['hora']?.toString() ?? '';
              return '$fecha$hora'.compareTo(DateTime.now().toIso8601String().substring(0, 16).replaceAll('-', '').replaceAll(':', '')) >= 0;
            })
            .toList()
          ..sort((a, b) {
            final fa = '${a['fecha'] ?? ''}${a['hora'] ?? ''}';
            final fb = '${b['fecha'] ?? ''}${b['hora'] ?? ''}';
            return fa.compareTo(fb);
          });

        setState(() {
          _stats = {
            'myWODs': inscritos,
            'rachaActual': (racha['racha_actual'] as num?)?.toInt() ?? 0,
            'rachaMaxima': (racha['racha_maxima'] as num?)?.toInt() ?? 0,
            'totalAsistencias': (racha['total_asistencias'] as num?)?.toInt() ?? 0,
          };
          _upcomingSchedules = upcoming.take(5).toList();
        });
      } else {
        final res = await api.get(ApiConfig.adminStats);
        if (res.data is Map && res.data['data'] is Map) {
          final data = res.data['data'] as Map;
          setState(() {
            _stats = Map<String, int>.from(
              data.map((k, v) => MapEntry(k.toString(), (v as num).toInt())),
            );
          });
        }
      }
    } catch (_) {
      final models = context.read<AthletesViewModel>().items;
      final wods = context.read<WodsViewModel>().items;
      final activeModels = models.where((a) => a.activo == true).length;
      setState(() {
        _stats = {
          'totalAthletes': models.length,
          'activeAthletes': activeModels,
          'totalWODs': wods.length,
        };
      });
    }
    if (mounted) setState(() => _loadingStats = false);
  }

  @override
  Widget build(BuildContext context) {
    final tiles = _tilesForRole(widget.role);
    final isAthlete = widget.role.toLowerCase() == 'atleta';

    return ListView(
      children: [
        IroncladSectionHeader(
          title: 'Bienvenido',
          subtitle: 'Panel de ${widget.role}',
          icon: Icons.dashboard_customize,
        ),
        if (!_loadingStats) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
              ),
              itemCount: _statsCardsForRole(widget.role).length,
              itemBuilder: (context, index) {
                final cards = _statsCardsForRole(widget.role);
                final card = cards[index];
                final value = _stats[card.key] ?? 0;
                return _StatsCard(
                  title: card.title,
                  value: value,
                  icon: card.icon,
                  color: card.color,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          if (isAthlete && _upcomingSchedules.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text('Próximos WODs', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            ..._upcomingSchedules.map((s) {
              final fecha = s['fecha']?.toString().substring(0, 10) ?? '';
              final hora = s['hora']?.toString().substring(0, 5) ?? '';
              final titulo = s['titulo']?.toString() ?? 'WOD';
              final entrenador = s['entrenador_nombre']?.toString() ?? 'Sin asignar';
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.fitness_center, color: Color(0xFFFF3B30)),
                  title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('$fecha - $hora | $entrenador'),
                  trailing: const Chip(label: Text('PRÓXIMO', style: TextStyle(fontSize: 10)), backgroundColor: Color(0xFF06D6A0)),
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
        ],
      ],
    );
  }
}

class _StatsCardData {
  final String title;
  final String key;
  final IconData icon;
  final Color color;
  const _StatsCardData({required this.title, required this.key, required this.icon, required this.color});
}

List<_StatsCardData> _statsCardsForRole(String role) {
  final r = role.toLowerCase();
  if (r == 'trainer' || r == 'entrenador') {
    return const [
      _StatsCardData(title: 'Mis Atletas', key: 'totalAthletes', icon: Icons.groups, color: Color(0xFF4A90D9)),
      _StatsCardData(title: 'Mis WODs', key: 'myWODs', icon: Icons.fitness_center, color: Color(0xFFFF9500)),
      _StatsCardData(title: 'Total WODs', key: 'totalWODs', icon: Icons.calendar_month, color: Color(0xFF34C759)),
    ];
  }
  if (r == 'atleta') {
    return const [
      _StatsCardData(title: 'WODs Inscritos', key: 'myWODs', icon: Icons.fitness_center, color: Color(0xFF34C759)),
      _StatsCardData(title: 'Días de Racha', key: 'rachaActual', icon: Icons.local_fire_department, color: Color(0xFFFF3B30)),
      _StatsCardData(title: 'Récord Racha', key: 'rachaMaxima', icon: Icons.emoji_events, color: Color(0xFFFF9500)),
      _StatsCardData(title: 'Total Asistencias', key: 'totalAsistencias', icon: Icons.check_circle, color: Color(0xFF4A90D9)),
    ];
  }
  return const [
    _StatsCardData(title: 'Atletas Totales', key: 'totalAthletes', icon: Icons.groups, color: Color(0xFF4A90D9)),
    _StatsCardData(title: 'Atletas Activos', key: 'activeAthletes', icon: Icons.check_circle, color: Color(0xFF34C759)),
    _StatsCardData(title: 'WODs Programados', key: 'totalWODs', icon: Icons.fitness_center, color: Color(0xFFFF9500)),
    _StatsCardData(title: 'Entrenadores', key: 'totalTrainers', icon: Icons.badge, color: Color(0xFFAF52DE)),
    _StatsCardData(title: 'Membresias', key: 'totalMemberships', icon: Icons.card_membership, color: Color(0xFFFF3B30)),
  ];
}

class _StatsCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;

  const _StatsCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: color, size: 22),
                ),
                const Spacer(),
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
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
      _HomeTile(title: 'Membresias', icon: Icons.card_membership, page: MembershipsView()),
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
    _HomeTile(title: 'Racha', icon: Icons.local_fire_department, page: RachaView()),
    _HomeTile(title: 'Progreso', icon: Icons.show_chart, page: ProgressView()),
    _HomeTile(title: 'Perfil', icon: Icons.person, page: ProfileView()),
  ];
}
