import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/services/api_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/storage_service.dart';
import 'core/router/app_router.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/reservations/providers/reservation_provider.dart';
import 'features/rooms/providers/room_provider.dart';
import 'features/users/providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configuration de l'orientation (portrait uniquement)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Configuration de la barre de statut pour un look professionnel
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Initialisation de la localisation française
  await initializeDateFormatting('fr_FR', null);
  
  // Initialisation des services
  final storageService = StorageService();
  await storageService.init();
  
  final apiService = ApiService();
  final authService = AuthService(apiService, storageService);
  
  runApp(MeetingRoomApp(
    authService: authService,
    apiService: apiService,
    storageService: storageService,
  ));
}

/// Application principale avec configuration des providers et du thème
/// Utilise Google Fonts téléchargées automatiquement (pas d'assets locaux)
class MeetingRoomApp extends StatelessWidget {
  final AuthService authService;
  final ApiService apiService;
  final StorageService storageService;

  const MeetingRoomApp({
    super.key,
    required this.authService,
    required this.apiService,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider d'authentification (principal)
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService),
        ),
        // Provider de gestion des réservations
        ChangeNotifierProvider(
          create: (_) => ReservationProvider(apiService),
        ),
        // Provider de gestion des salles
        ChangeNotifierProvider(
          create: (_) => RoomProvider(apiService),
        ),
        // Provider de gestion des utilisateurs (admin)
        ChangeNotifierProvider(
          create: (_) => UserProvider(apiService),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final router = AppRouter.createRouter(authProvider);
          
return MaterialApp.router(
  title: AppConstants.appName,
  debugShowCheckedModeBanner: false,

  theme: AppTheme.lightTheme.copyWith(
    textTheme: GoogleFonts.interTextTheme(AppTheme.lightTheme.textTheme),
  ),
  darkTheme: AppTheme.darkTheme.copyWith(
    textTheme: GoogleFonts.interTextTheme(AppTheme.darkTheme.textTheme),
  ),
  themeMode: ThemeMode.light,

  locale: const Locale('fr', 'FR'),
  supportedLocales: const [
    Locale('fr', 'FR'),
    Locale('en', 'US'),
  ],
  localizationsDelegates: [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],

  routerConfig: router,

  builder: (context, child) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.0),
      ),
      child: child!,
    );
  },
);
        },
      ),
    );
  }
}