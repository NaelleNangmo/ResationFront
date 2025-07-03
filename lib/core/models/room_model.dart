/// Modèle de données pour les salles de réunion
class Room {
  final int id;
  final String nom;
  final int capacite;
  final String statut;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Room({
    required this.id,
    required this.nom,
    required this.capacite,
    required this.statut,
    this.description,
    required this.createdAt,
    this.updatedAt,
  });

  /// Création d'une salle à partir de données JSON
  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as int,
      nom: json['nom'] as String,
      capacite: json['capacite'] as int,
      statut: json['statut'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Conversion en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'capacite': capacite,
      'statut': statut,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Getters pour identifier le statut
  bool get isAvailable => statut == 'disponible';
  bool get isOutOfService => statut == 'hors_service';
  bool get isInMaintenance => statut == 'maintenance';

  /// Nom d'affichage du statut
  String get statusDisplayName {
    switch (statut) {
      case 'disponible':
        return 'Disponible';
      case 'hors_service':
        return 'Hors service';
      case 'maintenance':
        return 'Maintenance';
      default:
        return statut;
    }
  }

  /// Catégorie de taille de la salle
  String get sizeCategory {
    if (capacite <= 5) {
      return 'Petite salle';
    } else if (capacite <= 15) {
      return 'Salle moyenne';
    } else {
      return 'Grande salle';
    }
  }

  /// Icône appropriée selon la capacité
  String get capacityIcon {
    if (capacite <= 5) {
      return '👥';
    } else if (capacite <= 15) {
      return '🏢';
    } else {
      return '🏛️';
    }
  }

  /// Description formatée avec fallback
  String get displayDescription {
    if (description != null && description!.isNotEmpty) {
      return description!;
    }
    return 'Salle de réunion de $capacite places';
  }

  /// Copie avec modification
  Room copyWith({
    int? id,
    String? nom,
    int? capacite,
    String? statut,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Room(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      capacite: capacite ?? this.capacite,
      statut: statut ?? this.statut,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Room(id: $id, nom: $nom, capacite: $capacite, statut: $statut)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Room && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}