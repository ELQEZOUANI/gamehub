import 'dart:convert';

/// Centralized game statistics data model
/// Stores all statistical data for a specific game
class GameStats {
  final String gameID;
  int gamesPlayed;
  int bestScore;
  double totalScore;
  double averageScore;

  GameStats({
    required this.gameID,
    this.gamesPlayed = 0,
    this.bestScore = 0,
    this.totalScore = 0.0,
    this.averageScore = 0.0,
  });

  /// Create GameStats from JSON data
  factory GameStats.fromJson(Map<String, dynamic> json) {
    return GameStats(
      gameID: json['gameID'] as String,
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      bestScore: json['bestScore'] as int? ?? 0,
      totalScore: (json['totalScore'] as num?)?.toDouble() ?? 0.0,
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert GameStats to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'gameID': gameID,
      'gamesPlayed': gamesPlayed,
      'bestScore': bestScore,
      'totalScore': totalScore,
      'averageScore': averageScore,
    };
  }

  /// Update statistics with a new game result
  void recordGameResult(int score) {
    // Increment games played
    gamesPlayed++;
    
    // Update best score if this score is better
    if (score > bestScore) {
      bestScore = score;
    }
    
    // Update total score
    totalScore += score;
    
    // Recalculate average score (handle division by zero)
    averageScore = gamesPlayed > 0 ? totalScore / gamesPlayed : 0.0;
  }

  /// Reset all statistics to default values
  void reset() {
    gamesPlayed = 0;
    bestScore = 0;
    totalScore = 0.0;
    averageScore = 0.0;
  }

  /// Get formatted average score (2 decimal places)
  String get formattedAverageScore {
    return averageScore.toStringAsFixed(2);
  }

  /// Check if this game has been played
  bool get hasBeenPlayed => gamesPlayed > 0;

  /// Get win rate (if applicable - can be overridden by specific games)
  double get winRate {
    // Default implementation - can be customized per game
    return gamesPlayed > 0 ? (bestScore / (averageScore * gamesPlayed)) : 0.0;
  }

  /// Create a copy of this GameStats object
  GameStats copyWith({
    String? gameID,
    int? gamesPlayed,
    int? bestScore,
    double? totalScore,
    double? averageScore,
  }) {
    return GameStats(
      gameID: gameID ?? this.gameID,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      bestScore: bestScore ?? this.bestScore,
      totalScore: totalScore ?? this.totalScore,
      averageScore: averageScore ?? this.averageScore,
    );
  }

  @override
  String toString() {
    return 'GameStats(gameID: $gameID, gamesPlayed: $gamesPlayed, bestScore: $bestScore, averageScore: ${formattedAverageScore})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameStats &&
        other.gameID == gameID &&
        other.gamesPlayed == gamesPlayed &&
        other.bestScore == bestScore &&
        other.totalScore == totalScore &&
        other.averageScore == averageScore;
  }

  @override
  int get hashCode {
    return gameID.hashCode ^
        gamesPlayed.hashCode ^
        bestScore.hashCode ^
        totalScore.hashCode ^
        averageScore.hashCode;
  }
}

/// Helper class for encoding/decoding multiple GameStats
class GameStatsCollection {
  /// Convert a map of GameStats to JSON string
  static String encodeStatsMap(Map<String, GameStats> stats) {
    final Map<String, dynamic> jsonMap = {};
    stats.forEach((key, value) {
      jsonMap[key] = value.toJson();
    });
    return jsonEncode(jsonMap);
  }

  /// Convert JSON string to map of GameStats
  static Map<String, GameStats> decodeStatsMap(String jsonString) {
    if (jsonString.isEmpty) return {};
    
    try {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      final Map<String, GameStats> stats = {};
      
      jsonMap.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          stats[key] = GameStats.fromJson(value);
        }
      });
      
      return stats;
    } catch (e) {
      // Return empty map if decoding fails
      return {};
    }
  }
}
