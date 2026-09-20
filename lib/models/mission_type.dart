enum MissionType {
  playGamesInARow,
  beatPersonalBest,
  tryNewGame,
}

class MissionTypeData {
  final MissionType type;
  final int? count;
  final String? gameID;

  const MissionTypeData({
    required this.type,
    this.count,
    this.gameID,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'count': count,
      'gameID': gameID,
    };
  }

  factory MissionTypeData.fromJson(Map<String, dynamic> json) {
    return MissionTypeData(
      type: MissionType.values[json['type']],
      count: json['count'],
      gameID: json['gameID'],
    );
  }

  // Factory constructors for each mission type
  factory MissionTypeData.playGamesInARow(int count) {
    return MissionTypeData(
      type: MissionType.playGamesInARow,
      count: count,
    );
  }

  factory MissionTypeData.beatPersonalBest(String gameID) {
    return MissionTypeData(
      type: MissionType.beatPersonalBest,
      gameID: gameID,
    );
  }

  factory MissionTypeData.tryNewGame() {
    return const MissionTypeData(
      type: MissionType.tryNewGame,
    );
  }
}
