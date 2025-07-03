/// Constantes globales de l'application
class AppConstants {
  // Informations de l'application
  static const String appName = 'Meeting Room Booking';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Réservation de salles de réunion professionnelle';
  
  // Configuration de l'API - URL du backend
  static const String baseUrl = 'https://reservationapp-0o9k.onrender.com';
  
  // Clés de stockage local
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  
  // Routes de navigation
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';
  static const String adminDashboardRoute = '/admin';
  static const String reservationsRoute = '/reservations';
  static const String roomsRoute = '/rooms';
  static const String profileRoute = '/profile';
  static const String usersRoute = '/admin/users';
  static const String adminRoomsRoute = '/admin/rooms';
  static const String adminReservationsRoute = '/admin/reservations';
  static const String createReservationRoute = '/reservations/create';
  
  // Rôles utilisateur
  static const String adminRole = 'admin';
  static const String userRole = 'utilisateur';
  
  // Formats de date et heure
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String apiDateFormat = 'yyyy-MM-dd';
  
  // Validation des formulaires
  static const int minPasswordLength = 6;
  static const int maxNameLength = 100;
  static const int maxDescriptionLength = 500;
  static const int maxMotifLength = 500;
  
  // Constantes UI pour un design cohérent
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  static const double cardElevation = 2.0;
  static const double buttonHeight = 48.0;
  static const double inputHeight = 56.0;
  
  // Durées d'animation pour une UX fluide
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  static const Duration pageTransition = Duration(milliseconds: 250);
  
  // Timeouts réseau
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // Pagination et limites
  static const int defaultPageSize = 20;
  static const int maxReservationsPerDay = 5;
  static const int maxReservationDaysAhead = 90;
  
  // Messages d'erreur communs
  static const String networkError = 'Erreur de connexion. Vérifiez votre connexion internet.';
  static const String serverError = 'Erreur du serveur. Veuillez réessayer plus tard.';
  static const String unknownError = 'Une erreur inattendue s\'est produite.';
  static const String sessionExpired = 'Session expirée. Veuillez vous reconnecter.';
  
  // Messages de succès
  static const String loginSuccess = 'Connexion réussie';
  static const String logoutSuccess = 'Déconnexion réussie';
  static const String reservationCreated = 'Réservation créée avec succès';
  static const String reservationCancelled = 'Réservation annulée avec succès';
  static const String passwordChanged = 'Mot de passe modifié avec succès';
}