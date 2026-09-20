import 'dart:io';
import 'package:flutter/widgets.dart';

import 'package:shared_preferences/shared_preferences.dart';

/// Simple script to reset daily missions
Future<void> main() async {
  print('🎯 Resetting Daily Missions...');
  
  try {
    // Initialize Flutter bindings for SharedPreferences
    WidgetsFlutterBinding.ensureInitialized();
    
    final prefs = await SharedPreferences.getInstance();
    
    // Mission-related keys (matching MissionService constants)
    const dailyMissionsKey = 'daily_missions';
    const lastMissionDateKey = 'last_mission_date';
    const gamesPlayedTodayKey = 'games_played_today';
    const lastPlayedGamesKey = 'last_played_games';
    
    // Clear all mission data
    await prefs.remove(dailyMissionsKey);
    await prefs.remove(lastMissionDateKey);
    await prefs.remove(gamesPlayedTodayKey);
    await prefs.remove(lastPlayedGamesKey);
    
    print('✅ Daily missions reset successfully!');
    print('📱 Restart the app to see fresh missions.');
    
  } catch (e) {
    print('❌ Error resetting missions: $e');
    exit(1);
  }
}
