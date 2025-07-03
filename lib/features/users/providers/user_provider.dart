import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/exceptions/api_exception.dart';

class UserProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  List<User> _users = [];
  bool _isLoading = false;
  String? _error;

  UserProvider(this._apiService);

  // Getters
  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Charger tous les utilisateurs (admin)
  Future<void> loadUsers() async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.getUsers();
      final usersData = response['utilisateurs'] as List;
      _users = usersData.map((data) => User.fromJson(data)).toList();
      
      // Trier par nom
      _users.sort((a, b) => a.nom.compareTo(b.nom));
      
      notifyListeners();
    } on ApiException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Erreur lors du chargement des utilisateurs: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Créer un utilisateur (admin)
  Future<bool> createUser({
    required String nom,
    required String email,
    required String motDePasse,
    required String role,
    required String telephone,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _apiService.createUser({
        'nom': nom,
        'email': email,
        'mot_de_passe': motDePasse,
        'role': role,
        'telephone': telephone,
      });
      
      // Recharger les utilisateurs
      await loadUsers();
      
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Erreur lors de la création de l\'utilisateur: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Modifier un utilisateur (admin)
  Future<bool> updateUser({
    required int userId,
    required String nom,
    required String email,
    required String role,
    required String telephone,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _apiService.updateUser(userId, {
        'nom': nom,
        'email': email,
        'role': role,
        'telephone': telephone,
      });
      
      // Recharger les utilisateurs
      await loadUsers();
      
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Erreur lors de la modification de l\'utilisateur: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Supprimer un utilisateur (admin)
  Future<bool> deleteUser(int userId) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _apiService.deleteUser(userId);
      
      // Supprimer localement
      _users.removeWhere((u) => u.id == userId);
      
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Erreur lors de la suppression de l\'utilisateur: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Obtenir les statistiques des utilisateurs (admin)
  Future<Map<String, dynamic>?> getStats() async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.getUserStats();
      return response;
    } on ApiException catch (e) {
      _setError(e.message);
      return null;
    } catch (e) {
      _setError('Erreur lors du chargement des statistiques: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Obtenir un utilisateur par ID
  User? getUserById(int userId) {
    try {
      return _users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  // Filtrer les utilisateurs par rôle
  List<User> getUsersByRole(String role) {
    return _users.where((user) => user.role == role).toList();
  }

  // Obtenir les administrateurs
  List<User> getAdmins() {
    return _users.where((user) => user.isAdmin).toList();
  }

  // Obtenir les utilisateurs normaux
  List<User> getRegularUsers() {
    return _users.where((user) => user.isUser).toList();
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