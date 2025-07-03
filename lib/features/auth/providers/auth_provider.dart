import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/exceptions/api_exception.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  AuthProvider(this._authService) {
    _initialize();
  }

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isUser => _user?.isUser ?? false;

  Future<void> _initialize() async {
    _setLoading(true);
    try {
      await _authService.initializeAuth();
      _user = await _authService.getCurrentUser();
      
      // Si on a un utilisateur, vérifier que la session est toujours valide
      if (_user != null) {
        try {
          _user = await _authService.refreshUserData();
        } catch (e) {
          // Si erreur, la session a expiré
          await logout();
        }
      }
    } catch (e) {
      _setError('Erreur d\'initialisation: ${e.toString()}');
    } finally {
      _isInitialized = true;
      _setLoading(false);
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      _user = await _authService.login(email, password);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Erreur de connexion: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _user = null;
      notifyListeners();
    } catch (e) {
      _setError('Erreur de déconnexion: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authService.changePassword(oldPassword, newPassword);
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Erreur lors du changement de mot de passe: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshUser() async {
    if (_user == null) return;
    
    try {
      _user = await _authService.refreshUserData();
      notifyListeners();
    } catch (e) {
      // Si erreur, probablement session expirée
      await logout();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}