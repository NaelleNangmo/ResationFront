import 'package:flutter/material.dart';
import '../../../core/models/room_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/exceptions/api_exception.dart';

class RoomProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  List<Room> _rooms = [];
  List<Room> _availableRooms = [];
  bool _isLoading = false;
  String? _error;

  RoomProvider(this._apiService);

  // Getters
  List<Room> get rooms => _rooms;
  List<Room> get availableRooms => _availableRooms;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Charger toutes les salles
  Future<void> loadRooms() async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.getRooms();
      final roomsData = response['salles'] as List;
      _rooms = roomsData.map((data) => Room.fromJson(data)).toList();
      
      // Trier par nom
      _rooms.sort((a, b) => a.nom.compareTo(b.nom));
      
      notifyListeners();
    } on ApiException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Erreur lors du chargement des salles: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Charger les salles disponibles pour une période
  Future<void> loadAvailableRooms(String date, String startTime, String endTime) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.getAvailableRooms(date, startTime, endTime);
      final roomsData = response['salles_libres'] as List;
      _availableRooms = roomsData.map((data) => Room.fromJson(data)).toList();
      
      // Trier par nom
      _availableRooms.sort((a, b) => a.nom.compareTo(b.nom));
      
      notifyListeners();
    } on ApiException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Erreur lors du chargement des salles disponibles: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Créer une salle (admin)
  Future<bool> createRoom({
    required String nom,
    required int capacite,
    String? description,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _apiService.createRoom({
        'nom': nom,
        'capacite': capacite,
        'description': description,
      });
      
      // Recharger les salles
      await loadRooms();
      
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Erreur lors de la création de la salle: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Modifier une salle (admin)
  Future<bool> updateRoom({
    required int roomId,
    required String nom,
    required int capacite,
    String? description,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _apiService.updateRoom(roomId, {
        'nom': nom,
        'capacite': capacite,
        'description': description,
      });
      
      // Recharger les salles
      await loadRooms();
      
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Erreur lors de la modification de la salle: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Mettre une salle hors service (admin)
  Future<bool> setRoomOutOfService(int roomId) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _apiService.setRoomOutOfService(roomId);
      
      // Mettre à jour localement
      _rooms = _rooms.map((r) {
        if (r.id == roomId) {
          return r.copyWith(statut: 'hors_service');
        }
        return r;
      }).toList();
      
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Erreur lors de la mise hors service: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Remettre une salle en service (admin)
  Future<bool> setRoomInService(int roomId) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _apiService.setRoomInService(roomId);
      
      // Mettre à jour localement
      _rooms = _rooms.map((r) {
        if (r.id == roomId) {
          return r.copyWith(statut: 'disponible');
        }
        return r;
      }).toList();
      
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Erreur lors de la remise en service: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Supprimer une salle (admin)
  Future<bool> deleteRoom(int roomId) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _apiService.deleteRoom(roomId);
      
      // Supprimer localement
      _rooms.removeWhere((r) => r.id == roomId);
      
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Erreur lors de la suppression de la salle: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Obtenir une salle par ID
  Room? getRoomById(int roomId) {
    try {
      return _rooms.firstWhere((room) => room.id == roomId);
    } catch (e) {
      return null;
    }
  }

  // Filtrer les salles par statut
  List<Room> getRoomsByStatus(String status) {
    return _rooms.where((room) => room.statut == status).toList();
  }

  // Obtenir les salles disponibles
  List<Room> getAvailableRoomsOnly() {
    return _rooms.where((room) => room.isAvailable).toList();
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