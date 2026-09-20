import 'package:shared_preferences/shared_preferences.dart';

class GamePrefsService {
  static const String _bestScoreTowerBuilderKey = 'towerBuilder_bestScore';
  static const String _bestScoreSimonSaysKey = 'simonSays_bestScore';
  static const String _lastPlayedGameKey = 'lastPlayedGame';
  static const String _lastChallengeDateKey = 'lastChallengeDate';
  static const String _dailyChallengeGameKey = 'dailyChallengeGame';

  // Best Score for Tower Builder
  static Future<int> getBestScoreTowerBuilder() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bestScoreTowerBuilderKey) ?? 0;
  }

  static Future<void> setBestScoreTowerBuilder(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final currentBest = await getBestScoreTowerBuilder();
    if (score > currentBest) {
      await prefs.setInt(_bestScoreTowerBuilderKey, score);
    }
  }

  // Best Score for Simon Says
  static Future<int> getBestScoreSimonSays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bestScoreSimonSaysKey) ?? 0;
  }

  static Future<void> setBestScoreSimonSays(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final currentBest = await getBestScoreSimonSays();
    if (score > currentBest) {
      await prefs.setInt(_bestScoreSimonSaysKey, score);
    }
  }

  // Last Played Game
  static Future<String?> getLastPlayedGame() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastPlayedGameKey);
  }

  static Future<void> setLastPlayedGame(String gameTitle) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastPlayedGameKey, gameTitle);
  }

  // Daily Challenge
  static Future<String> getDailyChallengeGame(List<String> allGameTitles) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10); // YYYY-MM-DD
    final lastDate = prefs.getString(_lastChallengeDateKey);

    if (lastDate != today) {
      // New day, new challenge
      final newChallengeGame = (allGameTitles..shuffle()).first;
      await prefs.setString(_lastChallengeDateKey, today);
      await prefs.setString(_dailyChallengeGameKey, newChallengeGame);
      return newChallengeGame;
    } else {
      return prefs.getString(_dailyChallengeGameKey) ?? (allGameTitles..shuffle()).first;
    }
  }
}
