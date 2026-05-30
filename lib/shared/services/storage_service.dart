import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Sauvegarde une valeur
  Future<bool> saveString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  Future<bool> saveInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  Future<bool> saveBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  Future<bool> saveList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }

  // Récupère une valeur
  String? getString(String key) {
    return _prefs.getString(key);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  List<String>? getList(String key) {
    return _prefs.getStringList(key);
  }

  // Supprime une clé
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  // Vérifie si une clé existe
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  // Sauvegarde un objet JSON
  Future<bool> saveJson(String key, Map<String, dynamic> value) async {
    return await _prefs.setString(key, jsonEncode(value));
  }

  // Récupère un objet JSON
  Map<String, dynamic>? getJson(String key) {
    final data = _prefs.getString(key);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  // Efface tout
  Future<bool> clear() async {
    return await _prefs.clear();
  }
}
