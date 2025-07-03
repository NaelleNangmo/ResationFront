import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/reservations/providers/reservation_provider.dart';
import '../../../shared/widgets/loading_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Chargement initial des réservations après build complet
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  /// Charge les réservations, compatible RefreshIndicator
  Future<void> _loadData() async {
    try {
      await context.read<ReservationProvider>().loadMyReservations();
    } catch (e) {
      // Logique gestion erreur, par ex. afficher SnackBar
      debugPrint('Erreur chargement réservations : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Bonjour, ${user.nom}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push(AppConstants.profileRoute),
          ),
        ],
      ),
      body: Consumer<ReservationProvider>(
        builder: (context, reservationProvider, _) {
          return LoadingOverlay(
            isLoading: reservationProvider.isLoading,
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    _buildUpcomingReservations(reservationProvider),
                    const SizedBox(height: 24),
                    _buildPersonalStats(reservationProvider),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return; // Optimisation : pas de reload inutile
          setState(() => _currentIndex = index);

          switch (index) {
            case 0:
              // Accueil, rien à faire
              break;
            case 1:
              context.push(AppConstants.reservationsRoute);
              break;
            case 2:
              context.push(AppConstants.roomsRoute);
              break;
            case 3:
              context.push(AppConstants.profileRoute);
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Réservations'),
          BottomNavigationBarItem(icon: Icon(Icons.meeting_room), label: 'Salles'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/reservations/create'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Nouvelle réservation',
                Icons.add_circle,
                AppTheme.primaryColor,
                () => context.push('/reservations/create'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Voir les salles',
                Icons.meeting_room,
                AppTheme.secondaryColor,
                () => context.push(AppConstants.roomsRoute),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingReservations(ReservationProvider provider) {
    final upcomingReservations = provider.myReservations
        .where((r) => r.isActive && (r.isFuture || r.isToday))
        .take(3)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Prochaines réservations',
          actionText: 'Voir tout',
          onActionPressed: () => context.push(AppConstants.reservationsRoute),
        ),
        const SizedBox(height: 16),
        if (upcomingReservations.isEmpty)
          _buildEmptyStateCard()
        else
          ...upcomingReservations.map(_buildReservationCard),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String actionText,
    required VoidCallback onActionPressed,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        TextButton(onPressed: onActionPressed, child: Text(actionText)),
      ],
    );
  }

  Widget _buildEmptyStateCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.event_available, size: 48, color: AppTheme.textTertiary),
            const SizedBox(height: 16),
            Text(
              'Aucune réservation à venir',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Créez votre première réservation',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationCard(reservation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(Icons.meeting_room, color: AppTheme.primaryColor),
        ),
        title: Text(reservation.salleNom ?? 'Salle inconnue', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('EEEE dd MMMM yyyy', 'fr_FR').format(reservation.date)),
            Text(reservation.timeRange),
          ],
        ),
        trailing: reservation.isToday
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Aujourd\'hui',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildPersonalStats(ReservationProvider provider) {
    final total = provider.myReservations.length;
    final active = provider.myReservations.where((r) => r.isActive).length;
    final completed = provider.myReservations.where((r) => r.isCompleted).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mes statistiques', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard('Total', total.toString(), Icons.event, AppTheme.primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard('Actives', active.toString(), Icons.event_available, AppTheme.successColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard('Terminées', completed.toString(), Icons.event_note, AppTheme.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}
