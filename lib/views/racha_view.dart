import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/config/api_config.dart';
import '../services/api_service.dart';
import '../models/backend_api_models.dart';
import 'widgets/atoms/ironclad_loading_indicator.dart';

class RachaView extends StatefulWidget {
  const RachaView({super.key});

  @override
  State<RachaView> createState() => _RachaViewState();
}

class _RachaViewState extends State<RachaView> {
  StreakDto? _streak;
  List<Map<String, dynamic>> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final api = ApiService();
      final rachaRes = await api.get(ApiConfig.wodRacha);
      final histRes = await api.get('${ApiConfig.wod}/historial-asistencias?limit=20');

      if (rachaRes.data is Map && rachaRes.data['data'] is Map) {
        _streak = StreakDto.fromJson(Map<String, dynamic>.from(rachaRes.data['data'] as Map));
      } else {
        _streak = const StreakDto(rachaActual: 0, rachaMaxima: 0, totalAsistencias: 0, asistenciasMes: 0);
      }

      if (histRes.data is Map && histRes.data['data'] is List) {
        _history = (histRes.data['data'] as List).cast<Map<String, dynamic>>();
      }
    } catch (_) {
      _streak = const StreakDto(rachaActual: 0, rachaMaxima: 0, totalAsistencias: 0, asistenciasMes: 0);
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111113),
      body: _loading
          ? const IroncladLoadingIndicator(message: 'Cargando racha...')
          : CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 60, 24, 16),
                    child: Text(
                      'MI RACHA',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'Bebas Neue', letterSpacing: 1.5, color: Colors.white),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(child: _buildStatCard('Días Actuales', '${_streak?.rachaActual ?? 0}', Icons.local_fire_department, Colors.red)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatCard('Récord Personal', '${_streak?.rachaMaxima ?? 0}', Icons.emoji_events, Colors.amber)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatCard('Este Mes', '${_streak?.asistenciasMes ?? 0}', Icons.calendar_month, Colors.blue)),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 32, 24, 12),
                    child: Text('Historial de Asistencias', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                if (_history.isEmpty)
                  const SliverToBoxAdapter(
                    child: Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No tienes asistencias registradas aún', style: TextStyle(color: Colors.grey)))),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = _history[index];
                        final fecha = item['fecha_asistencia']?.toString().substring(0, 10) ?? '';
                        final wodTitulo = item['wod_titulo']?.toString() ?? 'N/A';
                        final tipo = item['tipo_wod']?.toString() ?? '--';
                        final hora = item['hora']?.toString().substring(0, 5) ?? '--';
                        final ent = item['entrenador_nombre']?.toString() ?? 'N/A';

                        DateTime? date;
                        try { date = DateTime.parse(fecha); } catch (_) {}
                        final formatted = date != null ? DateFormat('EEEE d/MM/yyyy', 'es').format(date) : fecha;

                        return Card(
                          color: const Color(0xFF1A1A1A),
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: ListTile(
                            leading: const Icon(Icons.check_circle, color: Color(0xFFFF3B30)),
                            title: Text(wodTitulo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            subtitle: Text('$formatted - $hora | $ent\nTipo: $tipo', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ),
                        );
                      },
                      childCount: _history.length,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withValues(alpha: 0.8), color.withValues(alpha: 0.4)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
