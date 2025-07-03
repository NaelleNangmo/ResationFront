import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/reservations/providers/reservation_provider.dart';
import '../../../features/users/providers/user_provider.dart';
import '../../../shared/widgets/loading_overlay.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? _reservationStats;
  Map<String, dynamic>? _userStats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() async {
    final reservationProvider = context.read<ReservationProvider>();
    final userProvider = context.read<UserProvider>();
    
    final reservationStats = await reservationProvider.getStats();
    final userStats = await userProvider.getStats();
    
    if (mounted) {
      setState(() {
        _reservationStats = reservationStats;
        _userStats = userStats;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push(AppConstants.profileRoute),
          ),
        ],
      ),
      body: Consumer2<ReservationProvider, UserProvider>(
        builder: (context, reservationProvider, userProvider, _) {
          return LoadingOverlay(
            isLoading: reservationProvider.isLoading || userProvider.isLoading,
            child: RefreshIndicator(
              onRefresh: () async => _loadStats(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bienvenue
                    _buildWelcomeCard(user),
                    
                    const SizedBox(height: 24),
                    
                    // Actions rapides
                    _buildQuickActions(),
                    
                    const SizedBox(height: 24),
                    
                    // Statistiques des réservations
                    if (_reservationStats != null) _buildReservationStats(),
                    
                    const SizedBox(height: 24),
                    
                    // Statistiques des utilisateurs
                    if (_userStats != null) _buildUserStats(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildAdminBottomNav(),
    );
  }

  Widget _buildWelcomeCard(user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.admin_panel_settings,
                size: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenue, ${user.nom}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tableau de bord administrateur',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildActionCard(
              'Gérer les utilisateurs',
              Icons.people,
              AppTheme.primaryColor,
              () => context.push(AppConstants.usersRoute),
            ),
            _buildActionCard(
              'Gérer les salles',
              Icons.meeting_room,
              AppTheme.secondaryColor,
              () => context.push(AppConstants.adminRoomsRoute),
            ),
            _buildActionCard(
              'Toutes les réservations',
              Icons.event,
              AppTheme.warningColor,
              () => context.push(AppConstants.adminReservationsRoute),
            ),
            _buildActionCard(
              'Nouvelle réservation',
              Icons.add_circle,
              AppTheme.successColor,
              () => context.push('/reservations/create'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReservationStats() {
    final stats = _reservationStats!['statistiques'] as Map<String, dynamic>;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistiques des réservations',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total',
                stats['total_reservations'].toString(),
                Icons.event,
                AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Actives',
                stats['reservations_actives'].toString(),
                Icons.event_available,
                AppTheme.successColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Aujourd\'hui',
                stats['reservations_aujourd_hui'].toString(),
                Icons.today,
                AppTheme.warningColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Futures',
                stats['reservations_futures'].toString(),
                Icons.schedule,
                AppTheme.secondaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserStats() {
    final stats = _userStats!['statistiques'] as Map<String, dynamic>;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistiques des utilisateurs',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total',
                stats['total_utilisateurs'].toString(),
                Icons.people,
                AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Admins',
                stats['total_admins'].toString(),
                Icons.admin_panel_settings,
                AppTheme.errorColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 0:
            // Déjà sur le dashboard
            break;
          case 1:
            context.push(AppConstants.usersRoute);
            break;
          case 2:
            context.push(AppConstants.adminRoomsRoute);
            break;
          case 3:
            context.push(AppConstants.adminReservationsRoute);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Utilisateurs',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.meeting_room),
          label: 'Salles',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event),
          label: 'Réservations',
        ),
      ],
    );
  }
}