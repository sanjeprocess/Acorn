import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository to handle local storage operations
class StorageRepository {
  final SharedPreferences _preferences;

  StorageRepository(this._preferences);

  /// Save a string value
  Future<bool> saveString(String key, String value) async {
    return await _preferences.setString(key, value);
  }

  /// Get a string value
  Future<String?> getString(String key) async {
    return _preferences.getString(key);
  }

  /// Save an integer value
  Future<bool> saveInt(String key, int value) async {
    return await _preferences.setInt(key, value);
  }

  /// Get an integer value
  Future<int?> getInt(String key) async {
    return _preferences.getInt(key);
  }

  /// Save a boolean value
  Future<bool> saveBool(String key, bool value) async {
    return await _preferences.setBool(key, value);
  }

  /// Get a boolean value
  Future<bool?> getBool(String key) async {
    return _preferences.getBool(key);
  }

  /// Save a double value
  Future<bool> saveDouble(String key, double value) async {
    return await _preferences.setDouble(key, value);
  }

  /// Get a double value
  Future<double?> getDouble(String key) async {
    return _preferences.getDouble(key);
  }

  /// Save a list of strings
  Future<bool> saveStringList(String key, List<String> value) async {
    return await _preferences.setStringList(key, value);
  }

  /// Get a list of strings
  Future<List<String>?> getStringList(String key) async {
    return _preferences.getStringList(key);
  }

  /// Save a JSON object
  Future<bool> saveJson(String key, Map<String, dynamic> value) async {
    return await _preferences.setString(key, jsonEncode(value));
  }

  /// Get a JSON object
  Future<Map<String, dynamic>?> getJson(String key) async {
    final data = _preferences.getString(key);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  /// Remove a value
  Future<bool> remove(String key) async {
    return await _preferences.remove(key);
  }

  /// Clear all values
  Future<bool> clear() async {
    return await _preferences.clear();
  }

  /// Check if a key exists
  bool containsKey(String key) {
    return _preferences.containsKey(key);
  }
}
