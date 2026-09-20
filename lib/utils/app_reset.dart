import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AppReset {
  /// Complete app reset for production release
  /// This will clear ALL stored data and reset the app to fresh state
  static Future<void> resetAppForProduction() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear ALL SharedPreferences data
      await prefs.clear();
      
      debugPrint('✅ App reset completed successfully');
      debugPrint('🚀 App is now ready for App Store publishing');
      
    } catch (e) {
      debugPrint('❌ Error during app reset: $e');
      rethrow;
    }
  }

  /// Reset only mission-related data (for testing purposes)
  static Future<void> resetMissionsOnly() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Mission-related keys
      await prefs.remove('daily_missions');
      await prefs.remove('last_mission_date');
      await prefs.remove('games_played_today');
      await prefs.remove('last_played_games');
      
      debugPrint('✅ Mission data reset completed');
      
    } catch (e) {
      debugPrint('❌ Error during mission reset: $e');
      rethrow;
    }
  }

  /// Reset only game scores and statistics
  static Future<void> resetScoresOnly() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Game score keys
      final keys = prefs.getKeys();
      final scoreKeys = keys.where((key) => 
        key.contains('best') || 
        key.contains('score') || 
        key.contains('high') ||
        key.contains('stats') ||
        key.contains('level') ||
        key.contains('games_played') ||
        key.contains('wins') ||
        key.contains('losses')
      ).toList();
      
      for (String key in scoreKeys) {
        await prefs.remove(key);
      }
      
      debugPrint('✅ Game scores and statistics reset completed');
      debugPrint('📊 Reset ${scoreKeys.length} score-related keys');
      
    } catch (e) {
      debugPrint('❌ Error during scores reset: $e');
      rethrow;
    }
  }

  /// Reset user profile data only
  static Future<void> resetProfileOnly() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Profile-related keys
      await prefs.remove('user_name');
      await prefs.remove('user_avatar_emoji');
      await prefs.remove('profile_setup_completed');
      
      debugPrint('✅ User profile data reset completed');
      
    } catch (e) {
      debugPrint('❌ Error during profile reset: $e');
      rethrow;
    }
  }

  /// Get current storage usage info (for debugging)
  static Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      final Map<String, dynamic> info = {
        'total_keys': keys.length,
        'mission_keys': [],
        'score_keys': [],
        'profile_keys': [],
        'other_keys': [],
      };
      
      for (String key in keys) {
        final value = prefs.get(key);
        
        if (key.contains('mission') || key.contains('daily') || key.contains('challenge')) {
          info['mission_keys'].add({'key': key, 'type': value.runtimeType.toString()});
        } else if (key.contains('best') || key.contains('score') || key.contains('stats') || key.contains('level')) {
          info['score_keys'].add({'key': key, 'type': value.runtimeType.toString()});
        } else if (key.contains('user') || key.contains('profile') || key.contains('avatar')) {
          info['profile_keys'].add({'key': key, 'type': value.runtimeType.toString()});
        } else {
          info['other_keys'].add({'key': key, 'type': value.runtimeType.toString()});
        }
      }
      
      return info;
      
    } catch (e) {
      debugPrint('❌ Error getting storage info: $e');
      return {'error': e.toString()};
    }
  }

  /// Print detailed storage information
  static Future<void> printStorageInfo() async {
    final info = await getStorageInfo();
    
    debugPrint('📱 === APP STORAGE INFO ===');
    debugPrint('📊 Total Keys: ${info['total_keys']}');
    debugPrint('');
    
    debugPrint('🎯 Mission Keys (${(info['mission_keys'] as List).length}):');
    for (var item in info['mission_keys']) {
      debugPrint('  - ${item['key']} (${item['type']})');
    }
    debugPrint('');
    
    debugPrint('🏆 Score Keys (${(info['score_keys'] as List).length}):');
    for (var item in info['score_keys']) {
      debugPrint('  - ${item['key']} (${item['type']})');
    }
    debugPrint('');
    
    debugPrint('👤 Profile Keys (${(info['profile_keys'] as List).length}):');
    for (var item in info['profile_keys']) {
      debugPrint('  - ${item['key']} (${item['type']})');
    }
    debugPrint('');
    
    debugPrint('📦 Other Keys (${(info['other_keys'] as List).length}):');
    for (var item in info['other_keys']) {
      debugPrint('  - ${item['key']} (${item['type']})');
    }
    debugPrint('');
    debugPrint('========================');
  }
}
