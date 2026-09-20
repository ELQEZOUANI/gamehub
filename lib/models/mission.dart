import 'dart:convert';
import 'mission_type.dart';

class Mission {
  final String id;
  final String description;
  final MissionTypeData type;
  final int goal;
  int progress;
  bool isCompleted;

  Mission({
    required this.id,
    required this.description,
    required this.type,
    required this.goal,
    this.progress = 0,
    this.isCompleted = false,
  });

  // Convert Mission to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'type': type.toJson(),
      'goal': goal,
      'progress': progress,
      'isCompleted': isCompleted,
    };
  }

  // Create Mission from JSON
  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'],
      description: json['description'],
      type: MissionTypeData.fromJson(json['type']),
      goal: json['goal'],
      progress: json['progress'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  // Convert list of missions to JSON string
  static String listToJsonString(List<Mission> missions) {
    final List<Map<String, dynamic>> jsonList = 
        missions.map((mission) => mission.toJson()).toList();
    return jsonEncode(jsonList);
  }

  // Create list of missions from JSON string
  static List<Mission> listFromJsonString(String jsonString) {
    if (jsonString.isEmpty) return [];
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Mission.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Update progress and check completion
  void updateProgress(int newProgress) {
    progress = newProgress;
    isCompleted = progress >= goal;
  }

  // Increment progress by 1
  void incrementProgress() {
    progress++;
    isCompleted = progress >= goal;
  }

  // Mark as completed
  void complete() {
    progress = goal;
    isCompleted = true;
  }

  // Get progress percentage (0.0 to 1.0)
  double get progressPercentage {
    if (goal == 0) return 1.0;
    return (progress / goal).clamp(0.0, 1.0);
  }

  // Get progress display text
  String get progressText {
    return '$progress / $goal';
  }

  @override
  String toString() {
    return 'Mission(id: $id, description: $description, progress: $progress/$goal, completed: $isCompleted)';
  }
}
