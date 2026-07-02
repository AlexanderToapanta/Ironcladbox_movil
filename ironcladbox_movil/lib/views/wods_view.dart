import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/backend_api_models.dart';
import '../viewmodels/backend_viewmodels.dart';
import 'widgets/atoms/ironclad_empty_state.dart';
import 'widgets/atoms/ironclad_loading_indicator.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WODs')),
      body: Consumer<WodsViewModel>(
        builder: (context, vm, _) {
          final events = vm.items;

          return Column(
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
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: (day) => _getEventsForDay(day, events),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                  _loadMonthData(focusedDay);
                },
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Color(0x4DFF3B30),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Color(0xFFFF3B30),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Color(0xFFFF3B30),
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _buildEventList(_getEventsForDay(_selectedDay ?? _focusedDay, events), vm),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEventList(List<WodDto> dayEvents, WodsViewModel vm) {
    if (vm.isLoading && vm.items.isEmpty) {
      return const Center(child: IroncladLoadingIndicator(message: 'Cargando...'));
    }

    if (dayEvents.isEmpty) {
      return const IroncladEmptyState(
        icon: Icons.fitness_center,
        title: 'Sin WOD',
        message: 'No hay un WOD programado para este día.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: dayEvents.length,
      itemBuilder: (context, index) {
        final wod = dayEvents[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFFF3B30),
              child: Icon(Icons.fitness_center, color: Colors.white),
            ),
            title: Text(
              wod.titulo ?? 'WOD del día',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(wod.descripcion ?? 'Sin descripción'),
                if (wod.tipo != null || wod.nivel != null) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (wod.tipo != null)
                        _buildChip(wod.tipo!, Icons.category_outlined),
                      if (wod.nivel != null)
                        _buildChip(wod.nivel!, Icons.trending_up),
                    ],
                  ),
                ],
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
