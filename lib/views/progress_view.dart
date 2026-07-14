import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/backend_api_models.dart';
import '../viewmodels/backend_viewmodels.dart';
import '../viewmodels/login_viewmodel.dart';
import '../core/validators.dart';
import 'widgets/atoms/ironclad_empty_state.dart';
import 'widgets/atoms/ironclad_loading_indicator.dart';
import 'widgets/atoms/ironclad_form_field.dart';

class ProgressView extends StatefulWidget {
  const ProgressView({super.key});

  @override
  State<ProgressView> createState() => _ProgressViewState();
}

class _ProgressViewState extends State<ProgressView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressViewModel>().loadAll();
      context.read<ExercisesViewModel>().loadAll();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111113),
      body: Consumer2<ProgressViewModel, ExercisesViewModel>(
        builder: (context, progressVm, exercisesVm, _) {
          if ((progressVm.isLoading || exercisesVm.isLoading) && exercisesVm.items.isEmpty) {
            return const IroncladLoadingIndicator(message: 'Cargando tu progreso...');
          }

          final allExercises = exercisesVm.items;
          // Solo contamos progresos con marca > 0
          final myProgressList = progressVm.items.where((p) => p.marcaMaxima != null && p.marcaMaxima! > 0).toList();

          // Filtrar ejercicios por búsqueda
          final filteredExercises = allExercises.where((e) => 
            e.nombre.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 60, 24, 16),
                  child: Text(
                    'MI PROGRESO',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Bebas Neue',
                      letterSpacing: 1.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              // Estadísticas rápidas
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      _buildStatCard('Ejercicios Registrados', myProgressList.length.toString(), Icons.fitness_center),
                      const SizedBox(width: 12),
                      _buildStatCard('Promedio de Marcas', '${_calculateAverage(myProgressList)} lb', Icons.show_chart),
                      const SizedBox(width: 12),
                      _buildStatCard('Marca Más Alta', '${_calculateMax(myProgressList)} lb', Icons.emoji_events),
                    ],
                  ),
                ),
              ),

              // Buscador
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Buscar ejercicio...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFFFF3B30), size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),

              if (filteredExercises.isEmpty)
                const SliverFillRemaining(
                  child: IroncladEmptyState(
                    icon: Icons.search_off,
                    title: 'Sin resultados',
                    message: 'No encontramos ejercicios con ese nombre.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.70, // Ajustado para evitar overflow
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final exercise = filteredExercises[index];
                        
                        // Buscamos la marca comparando id de ejercicio (de forma robusta)
                        final progress = progressVm.items.firstWhere(
                          (p) => p.exerciseId == exercise.id || (p.exerciseName?.toLowerCase() == exercise.nombre.toLowerCase()),
                          orElse: () => const ProgressDto(),
                        );

                        return _buildExerciseProgressCard(exercise, progress);
                      },
                      childCount: filteredExercises.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF3B30), Color(0xFFC41E3A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF3B30).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white24, size: 24),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildExerciseProgressCard(ExerciseDto exercise, ProgressDto progress) {
    // Verificamos si realmente hay una marca (no basta con que progress no sea nulo)
    final bool hasMark = progress.marcaMaxima != null && progress.marcaMaxima! > 0;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header del ejercicio
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.fitness_center, color: Colors.white24, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    exercise.nombre,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.descripcion ?? 'Sin descripción',
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // MARCA PERSONAL
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(8),
                      border: const Border(left: BorderSide(color: Color(0xFFFF3B30), width: 3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('MARCA PERSONAL', style: TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            hasMark ? '${progress.marcaMaxima} lb' : '---',
                            style: TextStyle(
                              color: hasMark ? const Color(0xFFFF3B30) : Colors.white24,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (hasMark)
                          Text(
                            progress.fechaActualizacion != null 
                              ? 'Actualizado: ${DateFormat('d/M/yyyy').format(progress.fechaActualizacion!.toLocal())}'
                              : 'Actualizado: ${DateFormat('d/M/yyyy').format(DateTime.now())}',
                            style: const TextStyle(color: Colors.white24, fontSize: 8),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 34,
                    child: ElevatedButton(
                      onPressed: () => _showMarkDialog(exercise, progress),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF3B30),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        hasMark ? 'Actualizar Marca' : 'Registra marca',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMarkDialog(ExerciseDto exercise, ProgressDto progress) {
    final controller = TextEditingController(text: progress.marcaMaxima?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Column(
          children: [
            const Icon(Icons.fitness_center, color: Colors.white, size: 40),
            const SizedBox(height: 8),
            Text(
              progress.id != null ? 'Actualizar Marca' : 'Registrar Primera Marca',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              exercise.nombre,
              style: const TextStyle(color: Color(0xFFFF3B30), fontSize: 16, fontFamily: 'Bebas Neue'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Marca Máxima (lb)', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 8),
            IroncladFormField(
              controller: controller,
              label: 'Ej: 135.5',
              icon: Icons.monitor_weight_outlined,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: AppValidators.marca,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final double? val = double.tryParse(controller.text);
              if (val != null) {
                final vm = context.read<ProgressViewModel>();
                await vm.updateMark({
                  'id_ejercicio': exercise.id,
                  'marca_maxima': val,
                });
                if (mounted) {
                  Navigator.pop(context);
                  final prevMark = progress.marcaMaxima ?? 0;
                  String msg = 'Marca registrada exitosamente!';
                  if (prevMark > 0) {
                    if (val > prevMark) {
                      msg = 'Nuevo récord personal! +${(val - prevMark).toStringAsFixed(1)} lb. Sigue mejorando!';
                    } else if (val < prevMark) {
                      msg = 'No te desanimes! Sigue entrenando, volverás más fuerte.';
                    } else {
                      msg = 'Mantienes tu marca! La consistencia es clave.';
                    }
                  } else {
                    msg = 'Primera marca registrada! A superarte cada día!';
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(msg), backgroundColor: const Color(0xFF06D6A0), duration: const Duration(seconds: 4)),
                    );
                  }
                  vm.loadAll();
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3B30)),
            child: const Text('Guardar Marca'),
          ),
        ],
      ),
    );
  }

  String _calculateAverage(List<ProgressDto> progress) {
    if (progress.isEmpty) return '0';
    final double sum = progress.fold(0, (prev, p) => prev + (p.marcaMaxima ?? 0));
    return (sum / progress.length).toStringAsFixed(1);
  }

  String _calculateMax(List<ProgressDto> progress) {
    if (progress.isEmpty) return '0';
    final double max = progress.fold(0, (prev, p) => (p.marcaMaxima ?? 0) > prev ? p.marcaMaxima! : prev);
    return max.toStringAsFixed(1);
  }
}
