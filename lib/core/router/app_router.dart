import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/reservations/screens/reservations_screen.dart';
import '../../features/reservations/screens/create_reservation_screen.dart';
import '../../features/rooms/screens/rooms_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/admin/screens/admin_users_screen.dart';
import '../../features/admin/screens/admin_rooms_screen.dart';
import '../../features/admin/screens/admin_reservations_screen.dart';
import '../../shared/screens/splash_screen.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final isLoggedIn = authProvider.isAuthenticated;
        final isLoggingIn = state.matchedLocation == AppConstants.loginRoute;
        final isSplash = state.matchedLocation == '/';

        // Si on est sur le splash, laisser passer
        if (isSplash) return null;

        // Si pas connecté et pas sur la page de login, rediriger vers login
        if (!isLoggedIn && !isLoggingIn) {
          return AppConstants.loginRoute;
        }

        // Si connecté et sur la page de login, rediriger vers home
        if (isLoggedIn && isLoggingIn) {
          return AppConstants.homeRoute;
        }

        return null;
      },
      routes: [
        // Splash Screen
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),

        // Auth Routes
        GoRoute(
          path: AppConstants.loginRoute,
          builder: (context, state) => const LoginScreen(),
        ),

        // User Routes
        GoRoute(
          path: AppConstants.homeRoute,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: AppConstants.reservationsRoute,
          builder: (context, state) => const ReservationsScreen(),
        ),
        GoRoute(
          path: '/reservations/create',
          builder: (context, state) => const CreateReservationScreen(),
        ),
        GoRoute(
          path: AppConstants.roomsRoute,
          builder: (context, state) => const RoomsScreen(),
        ),
        GoRoute(
          path: AppConstants.profileRoute,
          builder: (context, state) => const ProfileScreen(),
        ),

        // Admin Routes
        GoRoute(
          path: AppConstants.adminDashboardRoute,
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: AppConstants.usersRoute,
          builder: (context, state) => const AdminUsersScreen(),
        ),
        GoRoute(
          path: AppConstants.adminRoomsRoute,
          builder: (context, state) => const AdminRoomsScreen(),
        ),
        GoRoute(
          path: AppConstants.adminReservationsRoute,
          builder: (context, state) => const AdminReservationsScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Page non trouvée',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'La page "${state.matchedLocation}" n\'existe pas.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppConstants.homeRoute),
                child: const Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}