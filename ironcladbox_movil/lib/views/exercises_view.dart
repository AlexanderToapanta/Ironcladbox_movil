import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../core/config/api_config.dart';
import '../models/backend_api_models.dart';
import '../viewmodels/backend_viewmodels.dart';
import '../viewmodels/login_viewmodel.dart';
import 'widgets/atoms/ironclad_empty_state.dart';
import 'widgets/atoms/ironclad_loading_indicator.dart';
import 'widgets/atoms/ironclad_form_field.dart';
import 'widgets/molecules/ironclad_section_header.dart';

class ExercisesView extends StatefulWidget {
  const ExercisesView({super.key});

  @override
  State<ExercisesView> createState() => _ExercisesViewState();
}

class _ExercisesViewState extends State<ExercisesView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExercisesViewModel>().loadAll();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _canManageExercises(String role) {
    final r = role.toLowerCase();
    return r == 'admin' || r == 'administrador' || r == 'trainer' || r == 'entrenador';
  }

  void _navigateToForm({ExerciseDto? exercise}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseFormPage(
          exercise: exercise,
          onSaved: () => context.read<ExercisesViewModel>().loadAll(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<LoginViewModel>().currentRole;
    final canManage = _canManageExercises(role);

    return Scaffold(
      appBar: AppBar(title: const Text('Ejercicios')),
      body: Consumer<ExercisesViewModel>(
        builder: (context, vm, _) {
          final filteredItems = vm.items
              .where((e) => e.nombre.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();

          return ListView(
            children: [
              const IroncladSectionHeader(
                  title: 'Biblioteca de Ejercicios',
                  subtitle: 'Guía de movimientos y técnicas',
                  icon: Icons.sports_gymnastics),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Buscar ejercicio...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = "");
                            })
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              if (vm.isLoading && vm.items.isEmpty)
                const IroncladLoadingIndicator(message: 'Cargando ejercicios...'),
              if (!vm.isLoading && filteredItems.isEmpty)
                const IroncladEmptyState(
                    icon: Icons.search_off,
                    title: 'Sin resultados',
                    message: 'No se encontraron ejercicios con ese nombre.'),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final exercise = filteredItems[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 3,
                              child: exercise.imagenUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: exercise.imagenUrl!.startsWith('http')
                                          ? exercise.imagenUrl!
                                          : '${ApiConfig.baseUrl}${exercise.imagenUrl}',
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                          color: Colors.white10,
                                          child: const Center(
                                              child: CircularProgressIndicator(strokeWidth: 2))),
                                      errorWidget: (context, url, error) => const Icon(
                                          Icons.fitness_center,
                                          size: 40,
                                          color: Colors.white24),
                                    )
                                  : const Icon(Icons.fitness_center,
                                      size: 40, color: Colors.white24),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(exercise.nombre,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 13),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Text(exercise.descripcion ?? 'Sin descripción',
                                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (canManage)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.black54,
                                  child: IconButton(
                                    icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                                    padding: EdgeInsets.zero,
                                    onPressed: () => _navigateToForm(exercise: exercise),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.black54,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete, size: 16, color: Color(0xFFFF3B30)),
                                    padding: EdgeInsets.zero,
                                    onPressed: () => _confirmDelete(exercise),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
      floatingActionButton: canManage
          ? FloatingActionButton(
              heroTag: 'fab_exercises',
              onPressed: () => _navigateToForm(),
              backgroundColor: const Color(0xFFFF3B30),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  void _confirmDelete(ExerciseDto exercise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Ejercicio'),
        content: Text('¿Deseas eliminar "${exercise.nombre}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('NO')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await context.read<ExercisesViewModel>().delete(exercise.id!);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('SÍ, ELIMINAR'),
          ),
        ],
      ),
    );
  }
}

class ExerciseFormPage extends StatefulWidget {
  final ExerciseDto? exercise;
  final VoidCallback onSaved;

  const ExerciseFormPage({super.key, this.exercise, required this.onSaved});

  @override
  State<ExerciseFormPage> createState() => _ExerciseFormPageState();
}

class _ExerciseFormPageState extends State<ExerciseFormPage> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  File? _pickedFile;
  bool _deleteCurrentImage = false;
  bool _isSaving = false;

  bool get _isEdit => widget.exercise != null;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.exercise?.nombre ?? '';
    _descController.text = widget.exercise?.descripcion ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image != null) {
        setState(() {
          _pickedFile = File(image.path);
          _deleteCurrentImage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre es requerido')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final payload = {
        'nombre': _nameController.text.trim(),
        'descripcion': _descController.text.trim(),
      };

      if (_isEdit) {
        await context.read<ExercisesViewModel>().update(
              widget.exercise!.id!,
              payload,
              imageFile: _pickedFile,
              deleteImage: _deleteCurrentImage,
            );
      } else {
        await context.read<ExercisesViewModel>().create(
              payload,
              imageFile: _pickedFile,
            );
      }

      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(_isEdit ? 'Editar Ejercicio' : 'Nuevo Ejercicio',
            style: const TextStyle(color: Colors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!_isSaving)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white54),
              onPressed: () => Navigator.pop(context),
            ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nombre del Ejercicio *', style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Descripción', style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 5,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 32),
                const Text('Imagen (opcional)',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                _buildImageArea(ex),
                const SizedBox(height: 20),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3B30),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(_isEdit ? 'GUARDAR CAMBIOS' : 'CREAR EJERCICIO',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
          if (_isSaving)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFFF3B30)),
                    SizedBox(height: 16),
                    Text('Guardando ejercicio...', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageArea(ExerciseDto? ex) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              if (_pickedFile != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_pickedFile!, height: 180, width: double.infinity, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => setState(() => _pickedFile = null),
                        ),
                      ),
                    ),
                  ],
                )
              else if (_isEdit && ex?.imagenUrl != null && !_deleteCurrentImage)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: ex!.imagenUrl!.startsWith('http') ? ex.imagenUrl! : '${ApiConfig.baseUrl}${ex.imagenUrl}',
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                          onPressed: () => setState(() => _deleteCurrentImage = true),
                        ),
                      ),
                    ),
                  ],
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text('Sin archivos seleccionados', style: TextStyle(color: Colors.white24)),
                ),
              
              const Divider(height: 1, color: Colors.white12),
              
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: _isSaving ? null : _pickImage,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE0E0E0), foregroundColor: Colors.black),
                      child: const Text('Seleccionar archivo'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text('Formatos: JPG, PNG, GIF, WEBP. Máximo 5MB',
            style: TextStyle(color: Colors.white24, fontSize: 11)),
      ],
    );
  }
}
