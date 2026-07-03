import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../models/backend_api_models.dart';
import '../viewmodels/backend_viewmodels.dart';
import '../viewmodels/login_viewmodel.dart';
import 'widgets/atoms/ironclad_empty_state.dart';
import 'widgets/atoms/ironclad_loading_indicator.dart';
import 'widgets/atoms/ironclad_form_field.dart';
import 'widgets/molecules/ironclad_section_header.dart';

class WodsView extends StatefulWidget {
  const WodsView({super.key});

  @override
  State<WodsView> createState() => _WodsViewState();
}

class _WodsViewState extends State<WodsView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMonthData(_focusedDay);
      context.read<TrainersViewModel>().loadAll();
    });
  }

  void _loadMonthData(DateTime date) {
    context.read<WodsViewModel>().loadByMonth(date.year, date.month);
  }

  List<WodDto> _getEventsForDay(DateTime day, List<WodDto> allWods) {
    return allWods.where((wod) {
      if (wod.fecha == null) return false;
      return isSameDay(wod.fecha, day);
    }).toList();
  }

  bool _isAdmin(String role) {
    final r = role.toLowerCase();
    return r == 'admin' || r == 'administrador';
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<LoginViewModel>().currentRole;
    final isAdmin = _isAdmin(role);

    return Scaffold(
      appBar: AppBar(title: const Text('WODs')),
      body: Consumer<WodsViewModel>(
        builder: (context, vm, _) {
          final events = vm.items;

          return ListView(
            children: [
              const IroncladSectionHeader(
                title: 'Calendario WOD',
                subtitle: 'Visualiza y gestiona los WODs del box',
                icon: Icons.calendar_month,
              ),
              TableCalendar<WodDto>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                availableCalendarFormats: const {CalendarFormat.month: 'Mes'},
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: (day) => _getEventsForDay(day, events),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  context.read<WodsViewModel>().loadByDate(selectedDay);
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                  _loadMonthData(focusedDay);
                },
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(color: Color(0x4DFF3B30), shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(color: Color(0xFFFF3B30), shape: BoxShape.circle),
                  markerDecoration: BoxDecoration(color: Color(0xFFFF3B30), shape: BoxShape.circle),
                ),
                headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
              ),
              const SizedBox(height: 16),
              if (isAdmin)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddWodDialog(_selectedDay ?? _focusedDay),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar WOD / Horario'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3B30),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              _buildWodDetail(_getEventsForDay(_selectedDay ?? _focusedDay, events), vm),
            ],
          );
        },
      ),
    );
  }

  void _showAddWodDialog(DateTime date) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String? selectedType;
    String? selectedLevel;
    
    final List<Map<String, dynamic>> schedulesPayload = [
      {'hora': '07:00', 'cupo_maximo': 12, 'id_entrenador': null}
    ];

    final trainers = context.read<TrainersViewModel>().items;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text('Programar WOD: ${DateFormat('dd/MM/yyyy').format(date)}', style: const TextStyle(color: Colors.white, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IroncladFormField(
                  controller: titleController,
                  label: 'Título (ej: prueba)',
                  icon: Icons.title,
                  validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                IroncladFormField(
                  controller: descController,
                  label: 'Descripción del WOD',
                  icon: Icons.description,
                  validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  dropdownColor: const Color(0xFF2A2A2A),
                  value: selectedType,
                  items: ['AMRAP', 'FOR TIME', 'EMOM', 'TABATA', 'STRENGTH', 'CHIPPER', 'HERO', 'BENCHMARK']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 13))))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedType = v),
                  decoration: const InputDecoration(labelText: 'Tipo de WOD', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  dropdownColor: const Color(0xFF2A2A2A),
                  value: selectedLevel,
                  items: ['Principiante', 'Intermedio', 'Avanzado', 'RX', 'Scaled']
                      .map((l) => DropdownMenuItem(value: l, child: Text(l, style: const TextStyle(color: Colors.white, fontSize: 13))))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedLevel = v),
                  decoration: const InputDecoration(labelText: 'Nivel', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                const Text('Horarios y Entrenadores', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...schedulesPayload.asMap().entries.map((entry) {
                  int idx = entry.key;
                  Map<String, dynamic> schedule = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(border: Border.all(color: Colors.white10), borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 7, minute: 0));
                                  if (time != null) {
                                    if (time.hour < 7 || time.hour > 21) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solo de 7am a 9pm')));
                                      return;
                                    }
                                    setDialogState(() => schedule['hora'] = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}");
                                  }
                                },
                                child: InputDecorator(
                                  decoration: const InputDecoration(labelText: 'Hora', isDense: true),
                                  child: Text(schedule['hora'], style: const TextStyle(color: Colors.white)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 60,
                              child: TextFormField(
                                initialValue: schedule['cupo_maximo'].toString(),
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: const InputDecoration(labelText: 'Cupo', isDense: true),
                                onChanged: (v) => schedule['cupo_maximo'] = int.tryParse(v) ?? 12,
                              ),
                            ),
                            IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => setDialogState(() => schedulesPayload.removeAt(idx))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          dropdownColor: const Color(0xFF2A2A2A),
                          value: schedule['id_entrenador'],
                          items: trainers.map((t) => DropdownMenuItem(value: t.id, child: Text('${t.nombre} ${t.apellido}', style: const TextStyle(color: Colors.white, fontSize: 12)))).toList(),
                          onChanged: (v) => setDialogState(() => schedule['id_entrenador'] = v),
                          decoration: const InputDecoration(labelText: 'Entrenador', isDense: true),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                TextButton.icon(
                  onPressed: () => setDialogState(() => schedulesPayload.add({'hora': '08:00', 'cupo_maximo': 12, 'id_entrenador': null})),
                  icon: const Icon(Icons.add_circle_outline, color: Colors.orange, size: 20),
                  label: const Text('Agregar Horario', style: TextStyle(color: Colors.orange, fontSize: 13)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final payload = {
                  'fecha': date.toIso8601String().split('T').first,
                  'titulo': titleController.text.trim(),
                  'descripcion': descController.text.trim(),
                  'tipo': selectedType,
                  'nivel': selectedLevel,
                  'horarios': schedulesPayload,
                };
                await context.read<WodsViewModel>().create(payload);
                if (mounted) Navigator.pop(context);
                _loadMonthData(date);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWodDetail(List<WodDto> dayEvents, WodsViewModel vm) {
    if (vm.isLoading && vm.items.isEmpty) return const Center(child: IroncladLoadingIndicator(message: 'Cargando...'));
    final fullDetail = vm.selectedItem;
    final bool hasFullDetail = fullDetail != null && _selectedDay != null && isSameDay(fullDetail.fecha, _selectedDay);
    if (dayEvents.isEmpty) return const IroncladEmptyState(icon: Icons.fitness_center, title: 'Sin WOD', message: 'No hay un WOD programado para este día.');
    final wod = hasFullDetail ? fullDetail : dayEvents.first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(wod.titulo?.toLowerCase() ?? 'wod', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (wod.tipo != null) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)), child: Text(wod.tipo!, style: const TextStyle(color: Colors.white70, fontSize: 11))),
                        if (wod.nivel != null) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFFF3B30).withOpacity(0.2), borderRadius: BorderRadius.circular(20)), child: Text(wod.nivel!, style: const TextStyle(color: Color(0xFFFF3B30), fontSize: 11, fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ],
                ),
              ),
              if (_isAdmin(context.read<LoginViewModel>().currentRole)) IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () async { await vm.delete(wod.id!); _loadMonthData(_focusedDay); }),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(8), border: const Border(left: BorderSide(color: Color(0xFFFF3B30), width: 3))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Descripción del WOD', style: TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 6),
              Text(wod.descripcion ?? 'Sin descripción', style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ]),
          ),
          const SizedBox(height: 24),
          const Row(children: [Icon(Icons.access_time, color: Colors.white, size: 20), SizedBox(width: 8), Text('Horarios Disponibles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))]),
          const SizedBox(height: 12),
          if (vm.isLoading && !hasFullDetail) const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator(color: Color(0xFFFF3B30))))
          else if (wod.horarios.isEmpty) const Text('No hay horarios definidos.', style: TextStyle(color: Colors.grey))
          else SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: wod.horarios.length,
              itemBuilder: (context, index) {
                final h = wod.horarios[index];
                final percent = (h.cupoMaximo != null && h.cupoMaximo! > 0) ? (h.inscritos ?? 0) / h.cupoMaximo! : 0.0;
                return Container(
                  width: 180,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFC8E6C9).withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(h.hora?.substring(0, 5) ?? '--:--', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF4CAF50), borderRadius: BorderRadius.circular(8)), child: const Text('OK', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))),
                    ]),
                    const SizedBox(height: 12),
                    Text('👥 ${h.inscritos ?? 0}/${h.cupoMaximo ?? 12}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 6),
                    ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: percent, backgroundColor: Colors.white10, color: const Color(0xFF4CAF50), minHeight: 4)),
                    const Spacer(),
                    Text(h.entrenadorNombre ?? 'Sin asignar', style: const TextStyle(color: Colors.white60, fontSize: 12), overflow: TextOverflow.ellipsis),
                  ]),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
