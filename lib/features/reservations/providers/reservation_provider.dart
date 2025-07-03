import 'package:flutter/material.dart';
import '../../../core/models/reservation_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/exceptions/api_exception.dart';

class ReservationProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  List<Reservation> _myReservations = [];
  List<Reservation> _allReservations = [];
  bool _isLoading = false;
  String? _error;

  ReservationProvider(this._apiService);

  // Getters
  List<Reservation> get myReservations => _myReservations;
  List<Reservation> get allReservations => _allReservations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Charger mes réservations
  Future<void> loadMyReservations() async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.getMyReservations();
      final reservationsData = response['reservations'] as List;
      _myReservations = reservationsData
          .map((data) => Reservation.fromJson(data))
          .toList();
      
      // Trier par date décroissante
      _myReservations.sort((a, b) => b.date.compareTo(a.date));
      
      notifyListeners();
    } on ApiException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Erreur lors du chargement des réservations: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Charger toutes les réservations (admin)
  Future<void> loadAllReservations() async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.getAllReservations();
      final reservationsData = response['reservations'] as List;
      _allReservations = reservationsData
          .map((data) => Reservation.fromJson(data))
          .toList();
      
      // Trier par date décroissante
      _allReservations.sort((a, b) => b.date.compareTo(a.date));
      
      notifyListeners();
    } on ApiException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Erreur lors du chargement des réservations: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Créer une réservation
  Future<bool> createReservation({
    required int salleId,
    required DateTime date,
    required String heureDebut,
    required String heureFin,
    String? motif,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.createReservation({
        'salle_id': salleId,
        'date': date.toIso8601String().split('T')[0],
        'heure_debut': heureDebut,
        'heure_fin': heureFin,
        'motif': motif,
      });
      
      // Recharger les réservations
      await loadMyReservations();
      
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Erreur lors de la création de la réservation: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Créer une réservation prioritaire (admin)
  Future<bool> createPriorityReservation({
    required int salleId,
    required DateTime date,
    required String heureDebut,
    required String heureFin,
    String? motif,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.createPriorityReservation({
        'salle_id': salleId,
        'date': date.toIso8601String().split('T')[0],
        'heure_debut': heureDebut,
        'heure_fin': heureFin,
        'motif': motif,
      });
      
      // Recharger les réservations
      await loadAllReservations();
      
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Erreur lors de la création de la réservation prioritaire: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Annuler une réservation
  Future<bool> cancelReservation(int reservationId) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _apiService.cancelReservation(reservationId);
      
      // Mettre à jour localement
      _myReservations = _myReservations.map((r) {
        if (r.id == reservationId) {
          return r.copyWith(statut: 'annulee');
        }
        return r;
      }).toList();
      
      _allReservations = _allReservations.map((r) {
        if (r.id == reservationId) {
          return r.copyWith(statut: 'annulee');
        }
        return r;
      }).toList();
      
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Erreur lors de l\'annulation de la réservation: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Obtenir les statistiques (admin)
  Future<Map<String, dynamic>?> getStats() async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.getReservationStats();
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

  // Filtrer les réservations par statut
  List<Reservation> getReservationsByStatus(String status, {bool isAdmin = false}) {
    final reservations = isAdmin ? _allReservations : _myReservations;
    return reservations.where((r) => r.statut == status).toList();
  }

  // Obtenir les réservations futures
  List<Reservation> getFutureReservations({bool isAdmin = false}) {
    final reservations = isAdmin ? _allReservations : _myReservations;
    return reservations.where((r) => r.isActive && r.isFuture).toList();
  }

  // Obtenir les réservations d'aujourd'hui
  List<Reservation> getTodayReservations({bool isAdmin = false}) {
    final reservations = isAdmin ? _allReservations : _myReservations;
    return reservations.where((r) => r.isActive && r.isToday).toList();
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