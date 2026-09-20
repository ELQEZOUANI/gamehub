import '../services/mission_service.dart';

class MissionTracker {
  static final MissionService _missionService = MissionService();

  /// Call this method when a game ends to track mission progress
  /// 
  /// [gameTitle] - The name of the game (must match the keys in HomeScreen._gameScreens)
  /// [finalScore] - The final score achieved in the game
  /// [wasNewGame] - Whether this is the first time playing this game today
  static Future<void> trackGameCompletion({
    required String gameTitle,
    required int finalScore,
    bool? wasNewGame,
  }) async {
    // Check if this is a new game today if not provided
    wasNewGame ??= await _missionService.isGameNewToday(gameTitle);
    
    await _missionService.trackEvent(
      gameID: gameTitle,
      score: finalScore,
      wasNewGame: wasNewGame,
    );
  }

  /// Convenience method for games that don't have scores
  /// Just tracks that the game was played
  static Future<void> trackGamePlayed({
    required String gameTitle,
    bool? wasNewGame,
  }) async {
    await trackGameCompletion(
      gameTitle: gameTitle,
      finalScore: 1, // Default score for games without scoring
      wasNewGame: wasNewGame,
    );
  }

  /// Get current mission progress (useful for debugging or showing progress)
  static Future<List<String>> getCurrentMissionStatus() async {
    await _missionService.initialize();
    return _missionService.dailyMissions
        .map((mission) => '${mission.description}: ${mission.progressText}')
        .toList();
  }

  /// Force refresh missions (useful for testing)
  static Future<void> forceRefreshMissions() async {
    await _missionService.forceRefreshMissions();
  }
}
