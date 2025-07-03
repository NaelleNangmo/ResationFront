import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// Service d'authentification gérant la connexion, déconnexion et persistance
class AuthService {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthService(this._apiService, this._storageService);

  /// Connexion utilisateur avec persistance des données
  Future<User> login(String email, String password) async {
    final response = await _apiService.login(email, password);
    
    final token = response['token'] as String;
    final userData = response['user'] as Map<String, dynamic>;
    final user = User.fromJson(userData);
    
    // Sauvegarder le token et les données utilisateur de manière sécurisée
    await _storageService.saveToken(token);
    await _storageService.saveUser(user);
    
    // Configurer le token pour les futures requêtes API
    _apiService.setAuthToken(token);
    
    return user;
  }

  /// Déconnexion avec nettoyage des données locales
  Future<void> logout() async {
    // Supprimer toutes les données locales
    await _storageService.clearAll();
    
    // Supprimer le token de l'API service
    _apiService.clearAuthToken();
  }

  /// Récupération de l'utilisateur actuellement connecté
  Future<User?> getCurrentUser() async {
    return await _storageService.getUser();
  }

  /// Vérification de l'état de connexion
  Future<bool> isLoggedIn() async {
    return await _storageService.isLoggedIn();
  }

  /// Initialisation de l'authentification au démarrage de l'app
  Future<void> initializeAuth() async {
    final token = await _storageService.getToken();
    if (token != null) {
      _apiService.setAuthToken(token);
    }
  }

  /// Actualisation des données utilisateur depuis le serveur
  Future<User> refreshUserData() async {
    final response = await _apiService.getProfile();
    final userData = response['user'] as Map<String, dynamic>;
    final user = User.fromJson(userData);
    
    // Mettre à jour les données utilisateur stockées
    await _storageService.saveUser(user);
    
    return user;
  }

  /// Changement de mot de passe
  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _apiService.changePassword(oldPassword, newPassword);
  }
}