/// Modèle de données pour les utilisateurs avec validation et sérialisation
class User {
  final int id;
  final String nom;
  final String email;
  final String role;
  final String telephone;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.nom,
    required this.email,
    required this.role,
    required this.telephone,
    required this.createdAt,
    this.updatedAt,
  });

  /// Création d'un utilisateur à partir de données JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      nom: json['nom'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      telephone: json['telephone'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Conversion en JSON pour la sérialisation
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'email': email,
      'role': role,
      'telephone': telephone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Getters pour identifier le rôle
  bool get isAdmin => role == 'admin';
  bool get isUser => role == 'utilisateur';

  /// Nom d'affichage du rôle
  String get roleDisplayName {
    switch (role) {
      case 'admin':
        return 'Administrateur';
      case 'utilisateur':
        return 'Utilisateur';
      default:
        return role;
    }
  }

  /// Initiales de l'utilisateur pour l'avatar
  String get initials {
    final names = nom.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return 'U';
  }

  /// Validation de l'email
  bool get hasValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validation du téléphone (format international)
  bool get hasValidPhone {
    return RegExp(r'^\+[1-9]\d{1,14}$').hasMatch(telephone);
  }

  /// Copie avec modification de certains champs
  User copyWith({
    int? id,
    String? nom,
    String? email,
    String? role,
    String? telephone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      email: email ?? this.email,
      role: role ?? this.role,
      telephone: telephone ?? this.telephone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, nom: $nom, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}