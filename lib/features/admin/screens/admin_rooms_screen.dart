import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/room_model.dart';
import '../../../features/rooms/providers/room_provider.dart';
import '../../../shared/widgets/loading_overlay.dart';

class AdminRoomsScreen extends StatefulWidget {
  const AdminRoomsScreen({super.key});

  @override
  State<AdminRoomsScreen> createState() => _AdminRoomsScreenState();
}

class _AdminRoomsScreenState extends State<AdminRoomsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    try {
      await context.read<RoomProvider>().loadRooms();
    } catch (e) {
      debugPrint('Erreur lors du chargement des salles : $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du chargement des salles'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des salles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: Consumer<RoomProvider>(
        builder: (context, provider, _) {
          return LoadingOverlay(
            isLoading: provider.isLoading,
            child: _buildRoomsList(provider),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateRoomDialog,
        tooltip: 'Ajouter une salle',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRoomsList(RoomProvider provider) {
    if (provider.rooms.isEmpty) {
      return const Center(
        child: Text('Aucune salle trouvée'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: provider.rooms.length,
        itemBuilder: (context, index) {
          final room = provider.rooms[index];
          return _buildRoomCard(room);
        },
      ),
    );
  }

  Widget _buildRoomCard(Room room) {
    final statusColor = _getRoomStatusColor(room.statut);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Icon(
            Icons.meeting_room,
            color: Colors.white,
          ),
        ),
        title: Text(
          room.nom,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${room.capacite} places'),
            if (room.description != null && room.description!.isNotEmpty)
              Text(
                room.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                room.statusDisplayName,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleRoomAction(value, room),
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Modifier'),
                ],
              ),
            ),
            if (room.isAvailable)
              const PopupMenuItem(
                value: 'out_of_service',
                child: Row(
                  children: [
                    Icon(Icons.block, color: AppTheme.warningColor),
                    SizedBox(width: 8),
                    Text('Mettre hors service'),
                  ],
                ),
              ),
            if (room.isOutOfService)
              const PopupMenuItem(
                value: 'in_service',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: AppTheme.successColor),
                    SizedBox(width: 8),
                    Text('Remettre en service'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: AppTheme.errorColor),
                  SizedBox(width: 8),
                  Text('Supprimer', style: TextStyle(color: AppTheme.errorColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoomStatusColor(String status) {
    switch (status) {
      case 'disponible':
        return AppTheme.successColor;
      case 'hors_service':
        return AppTheme.errorColor;
      case 'maintenance':
        return AppTheme.warningColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  void _handleRoomAction(String action, Room room) {
    switch (action) {
      case 'edit':
        _showEditRoomDialog(room);
        break;
      case 'out_of_service':
        _setRoomOutOfService(room);
        break;
      case 'in_service':
        _setRoomInService(room);
        break;
      case 'delete':
        _showDeleteRoomDialog(room);
        break;
    }
  }

  void _showCreateRoomDialog() {
    showDialog(
      context: context,
      builder: (_) => _RoomFormDialog(),
    );
  }

  void _showEditRoomDialog(Room room) {
    showDialog(
      context: context,
      builder: (_) => _RoomFormDialog(room: room),
    );
  }

  void _setRoomOutOfService(Room room) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mettre hors service'),
        content: Text(
          'Êtes-vous sûr de vouloir mettre "${room.nom}" hors service ?\n\n'
          'Cela annulera automatiquement toutes les réservations des 7 prochains jours.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await context.read<RoomProvider>().setRoomOutOfService(room.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Salle mise hors service avec succès'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
                _loadData();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warningColor,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _setRoomInService(Room room) async {
    final success = await context.read<RoomProvider>().setRoomInService(room.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Salle remise en service avec succès'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      _loadData();
    }
  }

  void _showDeleteRoomDialog(Room room) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer la salle'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${room.nom}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await context.read<RoomProvider>().deleteRoom(room.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Salle supprimée avec succès'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
                _loadData();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

class _RoomFormDialog extends StatefulWidget {
  final Room? room;

  const _RoomFormDialog({this.room});

  @override
  State<_RoomFormDialog> createState() => _RoomFormDialogState();
}

class _RoomFormDialogState extends State<_RoomFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _capaciteController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.room != null) {
      _nomController.text = widget.room!.nom;
      _capaciteController.text = widget.room!.capacite.toString();
      _descriptionController.text = widget.room!.description ?? '';
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _capaciteController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveRoom() async {
    if (!_formKey.currentState!.validate()) return;

    final roomProvider = context.read<RoomProvider>();
    bool success;

    final nom = _nomController.text.trim();
    final capacite = int.parse(_capaciteController.text.trim());
    final description = _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim();

    if (widget.room == null) {
      // Créer une nouvelle salle
      success = await roomProvider.createRoom(
        nom: nom,
        capacite: capacite,
        description: description,
      );
    } else {
      // Modifier une salle existante
      success = await roomProvider.updateRoom(
        roomId: widget.room!.id,
        nom: nom,
        capacite: capacite,
        description: description,
      );
    }

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.room == null ? 'Salle créée avec succès' : 'Salle modifiée avec succès',
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );
      // Actualiser la liste après modification/ajout
      context.read<RoomProvider>().loadRooms();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.room == null ? 'Nouvelle salle' : 'Modifier la salle'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la salle',
                  prefixIcon: Icon(Icons.meeting_room),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez saisir le nom de la salle';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capaciteController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Capacité (nombre de places)',
                  prefixIcon: Icon(Icons.people),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez saisir la capacité';
                  }
                  final capacity = int.tryParse(value);
                  if (capacity == null || capacity <= 0) {
                    return 'Veuillez saisir un nombre valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                maxLength: AppConstants.maxDescriptionLength,
                decoration: const InputDecoration(
                  labelText: 'Description (optionnelle)',
                  prefixIcon: Icon(Icons.description),
                  hintText: 'Équipements, localisation, etc.',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _saveRoom,
          child: Text(widget.room == null ? 'Créer' : 'Modifier'),
        ),
      ],
    );
  }
}
