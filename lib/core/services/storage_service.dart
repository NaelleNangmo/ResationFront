import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';


/// Service de stockage sécurisé pour les données sensibles et préférences
class StorageService {
  // Configuration du stockage sécurisé avec chiffrement
 static const _secureStorage = FlutterSecureStorage(
  aOptions: const AndroidOptions(
    encryptedSharedPreferences: true,
  ),
);

  
  late SharedPreferences _prefs;

  /// Initialisation du service de stockage
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ==================== GESTION DES TOKENS ====================

  /// Sauvegarde sécurisée du token JWT
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: AppConstants.tokenKey, value: token);
  }

  /// Récupération du token JWT
  Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConstants.tokenKey);
  }

  /// Suppression du token JWT
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
  }

  // ==================== GESTION DES DONNÉES UTILISATEUR ====================

  /// Sauvegarde sécurisée des données utilisateur
  Future<void> saveUser(User user) async {
    final userJson = jsonEncode(user.toJson());
    await _secureStorage.write(key: AppConstants.userKey, value: userJson);
  }

  /// Récupération des données utilisateur avec gestion d'erreurs
  Future<User?> getUser() async {
    final userJson = await _secureStorage.read(key: AppConstants.userKey);
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return User.fromJson(userMap);
      } catch (e) {
        // Si erreur de parsing, supprimer les données corrompues
        await deleteUser();
        return null;
      }
    }
    return null;
  }

  /// Suppression des données utilisateur
  Future<void> deleteUser() async {
    await _secureStorage.delete(key: AppConstants.userKey);
  }

  // ==================== GESTION DES PRÉFÉRENCES ====================

  /// Sauvegarde du mode de thème
  Future<void> saveThemeMode(String themeMode) async {
    await _prefs.setString(AppConstants.themeKey, themeMode);
  }

  /// Récupération du mode de thème
  String getThemeMode() {
    return _prefs.getString(AppConstants.themeKey) ?? 'light';
  }

  /// Sauvegarde de la langue
  Future<void> saveLanguage(String language) async {
    await _prefs.setString(AppConstants.languageKey, language);
  }

  /// Récupération de la langue
  String getLanguage() {
    return _prefs.getString(AppConstants.languageKey) ?? 'fr';
  }

  // ==================== NETTOYAGE ET VÉRIFICATIONS ====================

  /// Suppression de toutes les données stockées
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs.clear();
  }

  /// Vérification de l'état de connexion
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    final user = await getUser();
    return token != null && user != null;
  }

  // ==================== PARAMÈTRES GÉNÉRIQUES ====================

  /// Sauvegarde d'un paramètre booléen
  Future<void> saveBoolSetting(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  /// Récupération d'un paramètre booléen
  bool getBoolSetting(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  /// Sauvegarde d'un paramètre string
  Future<void> saveStringSetting(String key, String value) async {
    await _prefs.setString(key, value);
  }

  /// Récupération d'un paramètre string
  String getStringSetting(String key, {String defaultValue = ''}) {
    return _prefs.getString(key) ?? defaultValue;
  }

  /// Sauvegarde d'un paramètre entier
  Future<void> saveIntSetting(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  /// Récupération d'un paramètre entier
  int getIntSetting(String key, {int defaultValue = 0}) {
    return _prefs.getInt(key) ?? defaultValue;
  }

  /// Sauvegarde d'un paramètre double
  Future<void> saveDoubleSetting(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  /// Récupération d'un paramètre double
  double getDoubleSetting(String key, {double defaultValue = 0.0}) {
    return _prefs.getDouble(key) ?? defaultValue;
  }

  /// Sauvegarde d'une liste de strings
  Future<void> saveStringListSetting(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  /// Récupération d'une liste de strings
  List<String> getStringListSetting(String key, {List<String>? defaultValue}) {
    return _prefs.getStringList(key) ?? defaultValue ?? [];
  }

  /// Suppression d'un paramètre spécifique
  Future<void> removeSetting(String key) async {
    await _prefs.remove(key);
  }

  /// Vérification de l'existence d'un paramètre
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  /// Récupération de toutes les clés stockées
  Set<String> getAllKeys() {
    return _prefs.getKeys();
  }
}