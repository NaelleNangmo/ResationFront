import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

/// Modèle de données pour les réservations avec logique métier
class Reservation {
  final int id;
  final int utilisateurId;
  final int salleId;
  final DateTime date;
  final String heureDebut;
  final String heureFin;
  final String statut;
  final String? motif;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // Données relationnelles (jointures)
  final String? utilisateurNom;
  final String? utilisateurEmail;
  final String? utilisateurTelephone;
  final String? salleNom;
  final int? salleCapacite;

  const Reservation({
    required this.id,
    required this.utilisateurId,
    required this.salleId,
    required this.date,
    required this.heureDebut,
    required this.heureFin,
    required this.statut,
    this.motif,
    required this.createdAt,
    this.updatedAt,
    this.utilisateurNom,
    this.utilisateurEmail,
    this.utilisateurTelephone,
    this.salleNom,
    this.salleCapacite,
  });

  /// Création d'une réservation à partir de données JSON
  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] as int,
      utilisateurId: json['utilisateur_id'] as int,
      salleId: json['salle_id'] as int,
      date: DateTime.parse(json['date'] as String),
      heureDebut: json['heure_debut'] as String,
      heureFin: json['heure_fin'] as String,
      statut: json['statut'] as String,
      motif: json['motif'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      utilisateurNom: json['utilisateur_nom'] as String?,
      utilisateurEmail: json['utilisateur_email'] as String?,
      utilisateurTelephone: json['utilisateur_telephone'] as String?,
      salleNom: json['salle_nom'] as String?,
      salleCapacite: json['salle_capacite'] as int?,
    );
  }

  /// Conversion en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'utilisateur_id': utilisateurId,
      'salle_id': salleId,
      'date': date.toIso8601String().split('T')[0],
      'heure_debut': heureDebut,
      'heure_fin': heureFin,
      'statut': statut,
      'motif': motif,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'utilisateur_nom': utilisateurNom,
      'utilisateur_email': utilisateurEmail,
      'utilisateur_telephone': utilisateurTelephone,
      'salle_nom': salleNom,
      'salle_capacite': salleCapacite,
    };
  }

  // Getters pour identifier le statut
  bool get isActive => statut == 'active';
  bool get isCancelled => statut == 'annulee';
  bool get isCompleted => statut == 'terminee';

  /// Nom d'affichage du statut
  String get statusDisplayName {
    switch (statut) {
      case 'active':
        return 'Active';
      case 'annulee':
        return 'Annulée';
      case 'terminee':
        return 'Terminée';
      default:
        return statut;
    }
  }

  /// Vérification si la réservation est dans le passé
  bool get isPast {
    final now = DateTime.now();
    final reservationDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(heureFin.split(':')[0]),
      int.parse(heureFin.split(':')[1]),
    );
    return reservationDateTime.isBefore(now);
  }

  /// Vérification si la réservation est aujourd'hui
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  /// Vérification si la réservation est dans le futur
  bool get isFuture {
    final now = DateTime.now();
    return date.isAfter(DateTime(now.year, now.month, now.day));
  }

  /// Vérification si la réservation est en cours
  bool get isOngoing {
    if (!isToday || !isActive) return false;
    
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    return currentTime.compareTo(heureDebut) >= 0 && 
           currentTime.compareTo(heureFin) < 0;
  }

  /// Plage horaire formatée
  String get timeRange => '$heureDebut - $heureFin';

  /// Date formatée pour l'affichage
  String get formattedDate => DateFormat('EEEE dd MMMM yyyy', 'fr_FR').format(date);

  /// Date courte formatée
  String get shortFormattedDate => DateFormat('dd/MM/yyyy').format(date);

  /// Durée de la réservation en minutes
  int get durationInMinutes {
    final start = TimeOfDay(
      hour: int.parse(heureDebut.split(':')[0]),
      minute: int.parse(heureDebut.split(':')[1]),
    );
    final end = TimeOfDay(
      hour: int.parse(heureFin.split(':')[0]),
      minute: int.parse(heureFin.split(':')[1]),
    );
    
    return (end.hour * 60 + end.minute) - (start.hour * 60 + start.minute);
  }

  /// Durée formatée en heures et minutes
  String get formattedDuration {
    final minutes = durationInMinutes;
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    
    if (hours > 0 && remainingMinutes > 0) {
      return '${hours}h ${remainingMinutes}min';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${remainingMinutes}min';
    }
  }

  /// Temps restant avant le début (si future)
  String? get timeUntilStart {
    if (!isFuture && !isToday) return null;
    
    final now = DateTime.now();
    final startDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(heureDebut.split(':')[0]),
      int.parse(heureDebut.split(':')[1]),
    );
    
    if (startDateTime.isBefore(now)) return null;
    
    final difference = startDateTime.difference(now);
    
    if (difference.inDays > 0) {
      return 'Dans ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Dans ${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return 'Dans ${difference.inMinutes}min';
    } else {
      return 'Maintenant';
    }
  }

  /// Peut être annulée (active et pas encore commencée)
  bool get canBeCancelled {
    if (!isActive) return false;
    
    final now = DateTime.now();
    final startDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(heureDebut.split(':')[0]),
      int.parse(heureDebut.split(':')[1]),
    );
    
    return startDateTime.isAfter(now);
  }

  /// Priorité d'affichage (pour le tri)
  int get displayPriority {
    if (isOngoing) return 1;
    if (isToday && isActive) return 2;
    if (isFuture && isActive) return 3;
    if (isPast && isActive) return 4;
    if (isCancelled) return 5;
    return 6;
  }

  /// Copie avec modification
  Reservation copyWith({
    int? id,
    int? utilisateurId,
    int? salleId,
    DateTime? date,
    String? heureDebut,
    String? heureFin,
    String? statut,
    String? motif,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? utilisateurNom,
    String? utilisateurEmail,
    String? utilisateurTelephone,
    String? salleNom,
    int? salleCapacite,
  }) {
    return Reservation(
      id: id ?? this.id,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      salleId: salleId ?? this.salleId,
      date: date ?? this.date,
      heureDebut: heureDebut ?? this.heureDebut,
      heureFin: heureFin ?? this.heureFin,
      statut: statut ?? this.statut,
      motif: motif ?? this.motif,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      utilisateurNom: utilisateurNom ?? this.utilisateurNom,
      utilisateurEmail: utilisateurEmail ?? this.utilisateurEmail,
      utilisateurTelephone: utilisateurTelephone ?? this.utilisateurTelephone,
      salleNom: salleNom ?? this.salleNom,
      salleCapacite: salleCapacite ?? this.salleCapacite,
    );
  }

  @override
  String toString() {
    return 'Reservation(id: $id, salle: $salleNom, date: $shortFormattedDate, time: $timeRange)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reservation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}