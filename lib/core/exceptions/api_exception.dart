/// Exception personnalisée pour les erreurs API avec gestion détaillée
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? details;
  final String? errorCode;

  const ApiException(
    this.message, {
    this.statusCode,
    this.details,
    this.errorCode,
  });

  @override
  String toString() {
    return 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
  }

  // Getters pour identifier rapidement le type d'erreur
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;
  bool get isValidationError => statusCode == 422;
  bool get isServerError => statusCode != null && statusCode! >= 500;
  bool get isNetworkError => statusCode == null;
  bool get isTimeout => statusCode == 408;

  /// Retourne un message utilisateur approprié selon le type d'erreur
  String get userFriendlyMessage {
    if (isUnauthorized) {
      return 'Session expirée. Veuillez vous reconnecter.';
    } else if (isForbidden) {
      return 'Vous n\'avez pas les permissions nécessaires.';
    } else if (isNotFound) {
      return 'Ressource non trouvée.';
    } else if (isConflict) {
      return message; // Les conflits ont généralement des messages spécifiques
    } else if (isValidationError) {
      return message; // Les erreurs de validation ont des messages spécifiques
    } else if (isServerError) {
      return 'Erreur du serveur. Veuillez réessayer plus tard.';
    } else if (isNetworkError) {
      return 'Problème de connexion. Vérifiez votre connexion internet.';
    } else if (isTimeout) {
      return 'Délai d\'attente dépassé. Veuillez réessayer.';
    } else {
      return message;
    }
  }

  /// Crée une ApiException à partir d'une réponse HTTP
  factory ApiException.fromResponse(int statusCode, Map<String, dynamic>? data) {
    String message = 'Erreur inconnue';
    String? errorCode;
    
    if (data != null) {
      if (data.containsKey('error')) {
        message = data['error'] as String;
      } else if (data.containsKey('message')) {
        message = data['message'] as String;
      }
      
      if (data.containsKey('code')) {
        errorCode = data['code'] as String;
      }
    }

    return ApiException(
      message,
      statusCode: statusCode,
      details: data,
      errorCode: errorCode,
    );
  }

  /// Crée une ApiException pour les erreurs réseau
  factory ApiException.networkError([String? customMessage]) {
    return ApiException(
      customMessage ?? 'Erreur de connexion réseau',
      statusCode: null,
    );
  }

  /// Crée une ApiException pour les timeouts
  factory ApiException.timeout([String? customMessage]) {
    return ApiException(
      customMessage ?? 'Délai d\'attente dépassé',
      statusCode: 408,
    );
  }

  /// Crée une ApiException pour les erreurs de parsing
  factory ApiException.parseError([String? customMessage]) {
    return ApiException(
      customMessage ?? 'Erreur de traitement des données',
      statusCode: null,
      errorCode: 'PARSE_ERROR',
    );
  }
}