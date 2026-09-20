import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mission.dart';
import '../models/mission_type.dart';
import 'stats_service.dart';


class MissionService {
  static const String _dailyMissionsKey = 'daily_missions';
  static const String _lastMissionDateKey = 'last_mission_date';
  static const String _gamesPlayedTodayKey = 'games_played_today';
  static const String _lastPlayedGamesKey = 'last_played_games';

  // Singleton pattern
  static final MissionService _instance = MissionService._internal();
  factory MissionService() => _instance;
  MissionService._internal();

  List<Mission> _dailyMissions = [];
  List<Mission> get dailyMissions => List.unmodifiable(_dailyMissions);

  // Mission Pool - All possible missions that can be assigned
  static final List<Mission> _missionPool = [
    // Play Games in a Row missions
    Mission(
      id: 'play_3_in_row',
      description: 'Complete 3 games in a row',
      type: MissionTypeData.playGamesInARow(3),
      goal: 3,
    ),
    Mission(
      id: 'play_5_in_row',
      description: 'Complete 5 games in a row',
      type: MissionTypeData.playGamesInARow(5),
      goal: 5,
    ),
    Mission(
      id: 'play_2_in_row',
      description: 'Play 2 games back to back',
      type: MissionTypeData.playGamesInARow(2),
      goal: 2,
    ),

    // Beat Personal Best missions
    Mission(
      id: 'beat_best_2048',
      description: 'Beat your best score in 2048',
      type: MissionTypeData.beatPersonalBest('2048'),
      goal: 1,
    ),
    Mission(
      id: 'beat_best_memory',
      description: 'Beat your best score in Memory Match',
      type: MissionTypeData.beatPersonalBest('Memory Match'),
      goal: 1,
    ),
    Mission(
      id: 'beat_best_quick_reaction',
      description: 'Beat your best score in Quick Reaction',
      type: MissionTypeData.beatPersonalBest('Quick Reaction'),
      goal: 1,
    ),
    Mission(
      id: 'beat_best_word_guess',
      description: 'Beat your best score in Word Guess',
      type: MissionTypeData.beatPersonalBest('Word Guess'),
      goal: 1,
    ),
    Mission(
      id: 'beat_best_simon_says',
      description: 'Beat your best score in Simon Says',
      type: MissionTypeData.beatPersonalBest('Simon Says'),
      goal: 1,
    ),
    Mission(
      id: 'beat_best_tower_builder',
      description: 'Beat your best score in Tower Builder',
      type: MissionTypeData.beatPersonalBest('Tower Builder'),
      goal: 1,
    ),

    // Try New Game missions
    Mission(
      id: 'try_new_game_1',
      description: 'Try a new game you haven\'t played today',
      type: MissionTypeData.tryNewGame(),
      goal: 1,
    ),
    Mission(
      id: 'try_new_game_2',
      description: 'Explore a different game today',
      type: MissionTypeData.tryNewGame(),
      goal: 1,
    ),
    Mission(
      id: 'try_new_game_3',
      description: 'Challenge yourself with a new game',
      type: MissionTypeData.tryNewGame(),
      goal: 1,
    ),
  ];

  /// Initialize the mission system - call this when the app starts
  Future<void> initialize() async {
    await checkForNewDayAndGenerateMissions();
  }

  /// Check if it's a new day and generate new missions if needed
  Future<void> checkForNewDayAndGenerateMissions() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD format
    final lastMissionDate = prefs.getString(_lastMissionDateKey);

    if (lastMissionDate != today) {
      // It's a new day, generate new missions
      await _generateNewDailyMissions();
      await prefs.setString(_lastMissionDateKey, today);
      
      // Reset daily tracking
      await prefs.remove(_gamesPlayedTodayKey);
      await prefs.remove(_lastPlayedGamesKey);
    } else {
      // Same day, load existing missions
      await _loadDailyMissions();
    }
  }

  /// Generate 3 random missions from the mission pool
  Future<void> _generateNewDailyMissions() async {
    final random = Random();
    final availableMissions = List<Mission>.from(_missionPool);
    _dailyMissions.clear();

    // Ensure we get 3 different types of missions
    final selectedTypes = <MissionType>{};
    final selectedMissions = <Mission>[];

    // Try to get one mission of each type if possible
    for (final type in MissionType.values) {
      final missionsOfType = availableMissions.where(
        (mission) => mission.type.type == type && !selectedTypes.contains(type)
      ).toList();
      
      if (missionsOfType.isNotEmpty && selectedMissions.length < 3) {
        final selectedMission = missionsOfType[random.nextInt(missionsOfType.length)];
        selectedMissions.add(_createMissionCopy(selectedMission));
        selectedTypes.add(type);
        availableMissions.remove(selectedMission);
      }
    }

    // If we still need more missions, pick randomly from remaining
    while (selectedMissions.length < 3 && availableMissions.isNotEmpty) {
      final randomMission = availableMissions[random.nextInt(availableMissions.length)];
      selectedMissions.add(_createMissionCopy(randomMission));
      availableMissions.remove(randomMission);
    }

    _dailyMissions = selectedMissions;
    await _saveDailyMissions();
  }

  /// Create a copy of a mission with reset progress
  Mission _createMissionCopy(Mission original) {
    return Mission(
      id: original.id,
      description: original.description,
      type: original.type,
      goal: original.goal,
      progress: 0,
      isCompleted: false,
    );
  }

  /// Save daily missions to local storage
  Future<void> _saveDailyMissions() async {
    final prefs = await SharedPreferences.getInstance();
    final missionsJson = Mission.listToJsonString(_dailyMissions);
    await prefs.setString(_dailyMissionsKey, missionsJson);
  }

  /// Load daily missions from local storage
  Future<void> _loadDailyMissions() async {
    final prefs = await SharedPreferences.getInstance();
    final missionsJson = prefs.getString(_dailyMissionsKey) ?? '';
    _dailyMissions = Mission.listFromJsonString(missionsJson);
  }

  /// Central function to track game events and update mission progress
  Future<void> trackEvent({
    required String gameID,
    required int score,
    required bool wasNewGame,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Update games played in a row counter
    await _updateGamesInARowCounter();
    
    // Track if this is a new game today
    await _trackNewGameToday(gameID);

    // Update mission progress
    bool anyMissionUpdated = false;
    
    for (final mission in _dailyMissions) {
      if (mission.isCompleted) continue;

      switch (mission.type.type) {
        case MissionType.playGamesInARow:
          final gamesInRow = prefs.getInt(_gamesPlayedTodayKey) ?? 0;
          if (gamesInRow >= (mission.type.count ?? 0)) {
            mission.complete();
            anyMissionUpdated = true;
          }
          break;

        case MissionType.beatPersonalBest:
          if (mission.type.gameID == gameID) {
            final previousBest = await _getPreviousBestScore(gameID);
            if (score > previousBest) {
              mission.complete();
              anyMissionUpdated = true;
            }
          }
          break;

        case MissionType.tryNewGame:
          if (wasNewGame) {
            mission.complete();
            anyMissionUpdated = true;
          }
          break;
      }
    }

    if (anyMissionUpdated) {
      await _saveDailyMissions();
    }
  }

  /// Update the games played in a row counter
  Future<void> _updateGamesInARowCounter() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_gamesPlayedTodayKey) ?? 0;
    await prefs.setInt(_gamesPlayedTodayKey, currentCount + 1);
  }

  /// Track if this game is new today
  Future<void> _trackNewGameToday(String gameID) async {
    final prefs = await SharedPreferences.getInstance();
    final playedGamesJson = prefs.getString(_lastPlayedGamesKey) ?? '[]';
    final playedGames = List<String>.from(
      (playedGamesJson.isNotEmpty) 
        ? (jsonDecode(playedGamesJson) as List<dynamic>)
        : []
    );

    if (!playedGames.contains(gameID)) {
      playedGames.add(gameID);
      await prefs.setString(_lastPlayedGamesKey, jsonEncode(playedGames));
    }
  }

  /// Get the previous best score for a game
  Future<int> _getPreviousBestScore(String gameID) async {
    final statsService = StatsService();
    await statsService.initialize();
    
    switch (gameID) {
      case '2048':
        return statsService.getBestScore(gameID: '${StatsService.game2048}_4x4');
      case 'Quick Reaction':
        return statsService.getBestScore(gameID: StatsService.gameQuickReaction);
      case 'Memory Match':
        return statsService.getBestScore(gameID: StatsService.gameMemoryMatch);
      case 'Word Guess':
        return statsService.getBestScore(gameID: StatsService.gameWordGuess);
      case 'Simon Says':
        return statsService.getBestScore(gameID: StatsService.gameSimonSays);

      default:
        return 0;
    }
  }

  /// Check if a game is new today
  Future<bool> isGameNewToday(String gameID) async {
    final prefs = await SharedPreferences.getInstance();
    final playedGamesJson = prefs.getString(_lastPlayedGamesKey) ?? '[]';
    final playedGames = List<String>.from(
      (playedGamesJson.isNotEmpty) 
        ? (jsonDecode(playedGamesJson) as List<dynamic>)
        : []
    );
    return !playedGames.contains(gameID);
  }

  /// Get completed missions count
  int get completedMissionsCount {
    return _dailyMissions.where((mission) => mission.isCompleted).length;
  }

  /// Get total missions count
  int get totalMissionsCount => _dailyMissions.length;

  /// Get completion percentage (0.0 to 1.0)
  double get completionPercentage {
    if (totalMissionsCount == 0) return 0.0;
    return completedMissionsCount / totalMissionsCount;
  }

  /// Force refresh missions (for testing or manual refresh)
  Future<void> forceRefreshMissions() async {
    await _generateNewDailyMissions();
  }

  /// Reset all mission data (for app reset)
  Future<void> resetAllMissionData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Clear all mission-related data
    await prefs.remove(_dailyMissionsKey);
    await prefs.remove(_lastMissionDateKey);
    await prefs.remove(_gamesPlayedTodayKey);
    await prefs.remove(_lastPlayedGamesKey);
    
    // Clear local state
    _dailyMissions.clear();
  }
}
