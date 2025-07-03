import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constants/app_constants.dart';
import '../exceptions/api_exception.dart';

/// Service API centralisé pour toutes les communications avec le backend
class ApiService {
  late final Dio _dio;
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
    ),
  );
  String? _authToken;

  ApiService() {
    _initializeDio();
    _setupInterceptors();
  }

  /// Initialise la configuration Dio avec les paramètres optimaux
  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectionTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      sendTimeout: AppConstants.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      // Validation du statut HTTP
      validateStatus: (status) {
        return status != null && status < 500;
      },
    ));
  }

  /// Configure les intercepteurs pour le logging et l'authentification
  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Ajouter le token d'authentification si disponible
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        
        _logger.d('🚀 REQUEST: ${options.method} ${options.path}');
        _logger.d('📤 Headers: ${options.headers}');
        if (options.data != null) {
          _logger.d('📤 Data: ${_sanitizeLogData(options.data)}');
        }
        
        handler.next(options);
      },
      
      onResponse: (response, handler) {
        _logger.i('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
        _logger.d('📥 Data: ${_sanitizeLogData(response.data)}');
        handler.next(response);
      },
      
      onError: (error, handler) {
        _logger.e('❌ ERROR: ${error.requestOptions.path}');
        _logger.e('❌ Status: ${error.response?.statusCode}');
        _logger.e('❌ Message: ${error.message}');
        _logger.e('❌ Response: ${error.response?.data}');
        handler.next(error);
      },
    ));
  }

  /// Sanitise les données sensibles pour les logs
  dynamic _sanitizeLogData(dynamic data) {
    if (data is Map) {
      final sanitized = Map.from(data);
      // Masquer les mots de passe dans les logs
      if (sanitized.containsKey('mot_de_passe')) {
        sanitized['mot_de_passe'] = '***';
      }
      if (sanitized.containsKey('password')) {
        sanitized['password'] = '***';
      }
      if (sanitized.containsKey('ancien_mot_de_passe')) {
        sanitized['ancien_mot_de_passe'] = '***';
      }
      if (sanitized.containsKey('nouveau_mot_de_passe')) {
        sanitized['nouveau_mot_de_passe'] = '***';
      }
      return sanitized;
    }
    return data;
  }

  /// Définit le token d'authentification
  void setAuthToken(String token) {
    _authToken = token;
    _logger.i('🔐 Token d\'authentification configuré');
  }

  /// Supprime le token d'authentification
  void clearAuthToken() {
    _authToken = null;
    _logger.i('🔓 Token d\'authentification supprimé');
  }

  /// Gestionnaire centralisé des requêtes avec gestion d'erreurs
  Future<Map<String, dynamic>> _handleRequest(Future<Response> request) async {
    try {
      final response = await request;
      
      // Vérifier si la réponse contient des données valides
      if (response.data == null) {
        throw ApiException('Réponse vide du serveur');
      }
      
      // Retourner les données de la réponse
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else {
        // Si ce n'est pas un Map, l'encapsuler
        return {'data': response.data};
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      _logger.e('💥 Erreur inattendue: $e');
      throw ApiException(AppConstants.unknownError);
    }
  }

  /// Convertit les erreurs Dio en ApiException avec messages utilisateur
  ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          'Délai d\'attente dépassé. Vérifiez votre connexion.',
          statusCode: 408,
        );
        
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        
        String message = 'Erreur du serveur';
        if (data is Map<String, dynamic> && data.containsKey('error')) {
          message = data['error'] as String;
        }
        
        switch (statusCode) {
          case 400:
            return ApiException(message, statusCode: 400);
          case 401:
            return ApiException(
              AppConstants.sessionExpired, 
              statusCode: 401,
            );
          case 403:
            return ApiException(
              'Accès non autorisé à cette ressource.', 
              statusCode: 403,
            );
          case 404:
            return ApiException(
              'Ressource non trouvée.', 
              statusCode: 404,
            );
          case 409:
            return ApiException(message, statusCode: 409);
          case 422:
            return ApiException(message, statusCode: 422);
          case 500:
            return ApiException(
              AppConstants.serverError, 
              statusCode: 500,
            );
          default:
            return ApiException(message, statusCode: statusCode);
        }
        
      case DioExceptionType.cancel:
        return ApiException('Requête annulée.');
        
      case DioExceptionType.connectionError:
        return ApiException(AppConstants.networkError);
        
      default:
        return ApiException('${AppConstants.unknownError}: ${error.message}');
    }
  }

  // ==================== ENDPOINTS D'AUTHENTIFICATION ====================

  /// Connexion utilisateur
  Future<Map<String, dynamic>> login(String email, String password) async {
    _logger.i('🔐 Tentative de connexion pour: $email');
    return _handleRequest(_dio.post('/auth/login', data: {
      'email': email,
      'mot_de_passe': password,
    }));
  }

  /// Récupération du profil utilisateur
  Future<Map<String, dynamic>> getProfile() async {
    _logger.i('👤 Récupération du profil utilisateur');
    return _handleRequest(_dio.get('/auth/me'));
  }

  /// Changement de mot de passe
  Future<Map<String, dynamic>> changePassword(String oldPassword, String newPassword) async {
    _logger.i('🔒 Changement de mot de passe');
    return _handleRequest(_dio.put('/auth/change-password', data: {
      'ancien_mot_de_passe': oldPassword,
      'nouveau_mot_de_passe': newPassword,
    }));
  }

  // ==================== ENDPOINTS DES SALLES ====================

  /// Récupération de toutes les salles
  Future<Map<String, dynamic>> getRooms() async {
    _logger.i('🏢 Récupération des salles');
    return _handleRequest(_dio.get('/salles'));
  }

  /// Récupération des salles disponibles pour une période
  Future<Map<String, dynamic>> getAvailableRooms(String date, String startTime, String endTime) async {
    _logger.i('🔍 Recherche des salles disponibles pour $date de $startTime à $endTime');
    return _handleRequest(_dio.get('/salles/libres', queryParameters: {
      'date': date,
      'heure_debut': startTime,
      'heure_fin': endTime,
    }));
  }

  /// Récupération des réservations d'une salle
  Future<Map<String, dynamic>> getRoomReservations(int roomId, String date) async {
    _logger.i('📅 Récupération des réservations de la salle $roomId pour $date');
    return _handleRequest(_dio.get('/salles/$roomId/reservations', queryParameters: {
      'date': date,
    }));
  }

  /// Création d'une salle (admin)
  Future<Map<String, dynamic>> createRoom(Map<String, dynamic> roomData) async {
    _logger.i('➕ Création d\'une nouvelle salle');
    return _handleRequest(_dio.post('/salles', data: roomData));
  }

  /// Modification d'une salle (admin)
  Future<Map<String, dynamic>> updateRoom(int roomId, Map<String, dynamic> roomData) async {
    _logger.i('✏️ Modification de la salle $roomId');
    return _handleRequest(_dio.put('/salles/$roomId', data: roomData));
  }

  /// Mise hors service d'une salle (admin)
  Future<Map<String, dynamic>> setRoomOutOfService(int roomId) async {
    _logger.w('⚠️ Mise hors service de la salle $roomId');
    return _handleRequest(_dio.post('/salles/$roomId/hors-service'));
  }

  /// Remise en service d'une salle (admin)
  Future<Map<String, dynamic>> setRoomInService(int roomId) async {
    _logger.i('✅ Remise en service de la salle $roomId');
    return _handleRequest(_dio.post('/salles/$roomId/en-service'));
  }

  /// Suppression d'une salle (admin)
  Future<Map<String, dynamic>> deleteRoom(int roomId) async {
    _logger.w('🗑️ Suppression de la salle $roomId');
    return _handleRequest(_dio.delete('/salles/$roomId'));
  }

  // ==================== ENDPOINTS DES RÉSERVATIONS ====================

  /// Création d'une réservation
  Future<Map<String, dynamic>> createReservation(Map<String, dynamic> reservationData) async {
    _logger.i('📝 Création d\'une nouvelle réservation');
    return _handleRequest(_dio.post('/reservations', data: reservationData));
  }

  /// Récupération des réservations de l'utilisateur
  Future<Map<String, dynamic>> getMyReservations() async {
    _logger.i('📋 Récupération de mes réservations');
    return _handleRequest(_dio.get('/reservations/mes-reservations'));
  }

  /// Récupération de toutes les réservations (admin)
  Future<Map<String, dynamic>> getAllReservations() async {
    _logger.i('📊 Récupération de toutes les réservations');
    return _handleRequest(_dio.get('/reservations/all'));
  }

  /// Annulation d'une réservation
  Future<Map<String, dynamic>> cancelReservation(int reservationId) async {
    _logger.w('❌ Annulation de la réservation $reservationId');
    return _handleRequest(_dio.delete('/reservations/$reservationId'));
  }

  /// Création d'une réservation prioritaire (admin)
  Future<Map<String, dynamic>> createPriorityReservation(Map<String, dynamic> reservationData) async {
    _logger.w('🚨 Création d\'une réservation prioritaire');
    return _handleRequest(_dio.post('/reservations/prioritaire', data: reservationData));
  }

  /// Récupération des statistiques des réservations (admin)
  Future<Map<String, dynamic>> getReservationStats() async {
    _logger.i('📈 Récupération des statistiques des réservations');
    return _handleRequest(_dio.get('/reservations/stats'));
  }

  // ==================== ENDPOINTS DES UTILISATEURS ====================

  /// Récupération de tous les utilisateurs (admin)
  Future<Map<String, dynamic>> getUsers() async {
    _logger.i('👥 Récupération des utilisateurs');
    return _handleRequest(_dio.get('/utilisateurs'));
  }

  /// Récupération d'un utilisateur (admin)
  Future<Map<String, dynamic>> getUser(int userId) async {
    _logger.i('👤 Récupération de l\'utilisateur $userId');
    return _handleRequest(_dio.get('/utilisateurs/$userId'));
  }

  /// Création d'un utilisateur (admin)
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    _logger.i('➕ Création d\'un nouvel utilisateur');
    return _handleRequest(_dio.post('/utilisateurs', data: userData));
  }

  /// Modification d'un utilisateur (admin)
  Future<Map<String, dynamic>> updateUser(int userId, Map<String, dynamic> userData) async {
    _logger.i('✏️ Modification de l\'utilisateur $userId');
    return _handleRequest(_dio.put('/utilisateurs/$userId', data: userData));
  }

  /// Suppression d'un utilisateur (admin)
  Future<Map<String, dynamic>> deleteUser(int userId) async {
    _logger.w('🗑️ Suppression de l\'utilisateur $userId');
    return _handleRequest(_dio.delete('/utilisateurs/$userId'));
  }

  /// Récupération des statistiques des utilisateurs (admin)
  Future<Map<String, dynamic>> getUserStats() async {
    _logger.i('📊 Récupération des statistiques des utilisateurs');
    return _handleRequest(_dio.get('/utilisateurs/stats/overview'));
  }

  // ==================== ENDPOINT DE SANTÉ ====================

  /// Vérification de l'état du serveur
  Future<Map<String, dynamic>> healthCheck() async {
    _logger.i('🏥 Vérification de l\'état du serveur');
    return _handleRequest(_dio.get('/health'));
  }
}