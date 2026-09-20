import 'package:shared_preferences/shared_preferences.dart';

class SudokuProgressService {
  static const String _progressKey = 'sudoku_progress';
  
  /// Get the highest completed level (0 means no levels completed)
  static Future<int> getHighestCompletedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_progressKey) ?? 0;
  }
  
  /// Mark a level as completed
  static Future<void> completeLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    final currentProgress = prefs.getInt(_progressKey) ?? 0;
    
    // Only update if this level is higher than current progress
    if (level > currentProgress) {
      await prefs.setInt(_progressKey, level);
    }
  }
  
  /// Check if a level is unlocked
  static Future<bool> isLevelUnlocked(int level) async {
    if (level == 1) return true; // Level 1 is always unlocked
    
    final highestCompleted = await getHighestCompletedLevel();
    return level <= highestCompleted + 1;
  }
  
  /// Get total completed levels count
  static Future<int> getTotalCompletedLevels() async {
    return await getHighestCompletedLevel();
  }
  
  /// Reset all progress (for testing or reset feature)
  static Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressKey);
  }
}
