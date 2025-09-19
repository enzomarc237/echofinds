import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:echofinds/models/alternative.dart';
import 'package:echofinds/models/search_history.dart';
import 'package:echofinds/models/user_settings.dart';
import 'package:echofinds/utils/constants.dart';

class StorageService {
  static SharedPreferences? _prefs;
  
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
  
  // Favorites Management
  static Future<List<Alternative>> getFavorites() async {
    await init();
    final favoritesJson = _prefs?.getStringList(AppConstants.favoritesKey) ?? [];
    return favoritesJson
        .map((json) => Alternative.fromJson(jsonDecode(json)))
        .toList();
  }
  
  static Future<void> addFavorite(Alternative alternative) async {
    await init();
    final favorites = await getFavorites();
    if (!favorites.contains(alternative)) {
      favorites.add(alternative);
      await _saveFavorites(favorites);
    }
  }
  
  static Future<void> removeFavorite(Alternative alternative) async {
    await init();
    final favorites = await getFavorites();
    favorites.removeWhere((fav) => fav == alternative);
    await _saveFavorites(favorites);
  }
  
  static Future<bool> isFavorite(Alternative alternative) async {
    final favorites = await getFavorites();
    return favorites.contains(alternative);
  }
  
  static Future<void> _saveFavorites(List<Alternative> favorites) async {
    final favoritesJson = favorites.map((fav) => jsonEncode(fav.toJson())).toList();
    await _prefs?.setStringList(AppConstants.favoritesKey, favoritesJson);
  }
  
  // Search History Management
  static Future<List<SearchHistory>> getSearchHistory() async {
    await init();
    final historyJson = _prefs?.getStringList(AppConstants.searchHistoryKey) ?? [];
    return historyJson
        .map((json) => SearchHistory.fromJson(jsonDecode(json)))
        .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
  
  static Future<void> addSearchHistory(SearchHistory history) async {
    await init();
    final settings = await getUserSettings();
    if (!settings.saveSearchHistory) return;
    
    final historyList = await getSearchHistory();
    
    // Remove duplicate queries
    historyList.removeWhere((h) => 
        h.query.toLowerCase() == history.query.toLowerCase() &&
        h.category == history.category);
    
    historyList.insert(0, history);
    
    // Limit history size
    if (historyList.length > settings.maxHistoryItems) {
      historyList.removeRange(settings.maxHistoryItems, historyList.length);
    }
    
    await _saveSearchHistory(historyList);
  }
  
  static Future<void> clearSearchHistory() async {
    await init();
    await _prefs?.remove(AppConstants.searchHistoryKey);
  }
  
  static Future<void> _saveSearchHistory(List<SearchHistory> history) async {
    final historyJson = history.map((h) => jsonEncode(h.toJson())).toList();
    await _prefs?.setStringList(AppConstants.searchHistoryKey, historyJson);
  }
  
  // User Settings Management
  static Future<UserSettings> getUserSettings() async {
    await init();
    final settingsJson = _prefs?.getString(AppConstants.userSettingsKey);
    if (settingsJson != null) {
      return UserSettings.fromJson(jsonDecode(settingsJson));
    }
    return UserSettings(); // Default settings
  }
  
  static Future<void> saveUserSettings(UserSettings settings) async {
    await init();
    await _prefs?.setString(
      AppConstants.userSettingsKey,
      jsonEncode(settings.toJson()),
    );
  }
  
  // Data Export/Import
  static Future<Map<String, dynamic>> exportAllData() async {
    final favorites = await getFavorites();
    final history = await getSearchHistory();
    final settings = await getUserSettings();
    
    return {
      'version': '1.0',
      'exportDate': DateTime.now().toIso8601String(),
      'favorites': favorites.map((f) => f.toJson()).toList(),
      'searchHistory': history.map((h) => h.toJson()).toList(),
      'userSettings': settings.toJson(),
    };
  }
  
  static Future<void> importData(Map<String, dynamic> data) async {
    try {
      // Import favorites
      if (data['favorites'] != null) {
        final favorites = (data['favorites'] as List)
            .map((item) => Alternative.fromJson(item))
            .toList();
        await _saveFavorites(favorites);
      }
      
      // Import search history
      if (data['searchHistory'] != null) {
        final history = (data['searchHistory'] as List)
            .map((item) => SearchHistory.fromJson(item))
            .toList();
        await _saveSearchHistory(history);
      }
      
      // Import user settings
      if (data['userSettings'] != null) {
        final settings = UserSettings.fromJson(data['userSettings']);
        await saveUserSettings(settings);
      }
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }
  
  static Future<void> clearAllData() async {
    await init();
    await _prefs?.remove(AppConstants.favoritesKey);
    await _prefs?.remove(AppConstants.searchHistoryKey);
    await _prefs?.remove(AppConstants.userSettingsKey);
  }
}