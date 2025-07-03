import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/room_model.dart';
import '../providers/reservation_provider.dart';
import '../../rooms/providers/room_provider.dart';
import '../../../shared/widgets/loading_overlay.dart';

class CreateReservationScreen extends StatefulWidget {
  const CreateReservationScreen({super.key});

  @override
  State<CreateReservationScreen> createState() => _CreateReservationScreenState();
}

class _CreateReservationScreenState extends State<CreateReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _motifController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  Room? _selectedRoom;
  
  bool _showAvailableRooms = false;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  @override
  void dispose() {
    _motifController.dispose();
    super.dispose();
  }

  void _loadRooms() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoomProvider>().loadRooms();
    });
  }

  void _searchAvailableRooms() {
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner les heures de début et de fin'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    final startTimeStr = '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}';
    final endTimeStr = '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}';
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    context.read<RoomProvider>().loadAvailableRooms(dateStr, startTimeStr, endTimeStr);
    setState(() {
      _showAvailableRooms = true;
    });
  }

  Future<void> _createReservation() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une salle'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    final startTimeStr = '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}';
    final endTimeStr = '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}';

    final success = await context.read<ReservationProvider>().createReservation(
      salleId: _selectedRoom!.id,
      date: _selectedDate,
      heureDebut: startTimeStr,
      heureFin: endTimeStr,
      motif: _motifController.text.trim().isEmpty ? null : _motifController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Réservation créée avec succès'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle réservation'),
      ),
      body: Consumer2<RoomProvider, ReservationProvider>(
        builder: (context, roomProvider, reservationProvider, _) {
          return LoadingOverlay(
            isLoading: roomProvider.isLoading || reservationProvider.isLoading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sélection de la date
                    _buildDateSelection(),
                    
                    const SizedBox(height: 24),
                    
                    // Sélection des heures
                    _buildTimeSelection(),
                    
                    const SizedBox(height: 24),
                    
                    // Bouton pour rechercher les salles disponibles
                    _buildSearchButton(),
                    
                    const SizedBox(height: 24),
                    
                    // Liste des salles disponibles
                    if (_showAvailableRooms) _buildAvailableRooms(roomProvider),
                    
                    const SizedBox(height: 24),
                    
                    // Motif (optionnel)
                    _buildMotifField(),
                    
                    const SizedBox(height: 32),
                    
                    // Bouton de création
                    _buildCreateButton(reservationProvider),
                    
                    // Affichage des erreurs
                    if (reservationProvider.error != null) ...[
                      const SizedBox(height: 16),
                      _buildErrorMessage(reservationProvider.error!),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date de réservation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TableCalendar<dynamic>(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 90)),
              focusedDay: _selectedDate,
              selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                  _showAvailableRooms = false;
                  _selectedRoom = null;
                });
              },
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                selectedDecoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Horaires',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTimeField(
                    'Heure de début',
                    _startTime,
                    (time) => setState(() {
                      _startTime = time;
                      _showAvailableRooms = false;
                      _selectedRoom = null;
                    }),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimeField(
                    'Heure de fin',
                    _endTime,
                    (time) => setState(() {
                      _endTime = time;
                      _showAvailableRooms = false;
                      _selectedRoom = null;
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField(String label, TimeOfDay? time, Function(TimeOfDay) onChanged) {
    return InkWell(
      onTap: () async {
        final selectedTime = await showTimePicker(
          context: context,
          initialTime: time ?? TimeOfDay.now(),
        );
        if (selectedTime != null) {
          onChanged(selectedTime);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.access_time),
        ),
        child: Text(
          time?.format(context) ?? 'Sélectionner',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _searchAvailableRooms,
        icon: const Icon(Icons.search),
        label: const Text('Rechercher les salles disponibles'),
      ),
    );
  }

  Widget _buildAvailableRooms(RoomProvider roomProvider) {
    final availableRooms = roomProvider.availableRooms;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Salles disponibles',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (availableRooms.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.meeting_room_outlined,
                      size: 48,
                      color: AppTheme.textTertiary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucune salle disponible',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Essayez un autre créneau horaire',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...availableRooms.map((room) => _buildRoomTile(room)),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomTile(Room room) {
    final isSelected = _selectedRoom?.id == room.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : null,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isSelected 
                ? AppTheme.primaryColor 
                : AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            Icons.meeting_room,
            color: isSelected ? Colors.white : AppTheme.primaryColor,
          ),
        ),
        title: Text(
          room.nom,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${room.capacite} places'),
            if (room.description != null && room.description!.isNotEmpty)
              Text(
                room.description!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
              )
            : null,
        onTap: () {
          setState(() {
            _selectedRoom = room;
          });
        },
      ),
    );
  }

  Widget _buildMotifField() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Motif (optionnel)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _motifController,
              maxLines: 3,
              maxLength: AppConstants.maxDescriptionLength,
              decoration: const InputDecoration(
                hintText: 'Décrivez brièvement l\'objet de votre réunion...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton(ReservationProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: provider.isLoading ? null : _createReservation,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: provider.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('Créer la réservation'),
      ),
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.errorColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: AppTheme.errorColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}