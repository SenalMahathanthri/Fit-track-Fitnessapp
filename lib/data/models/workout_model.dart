import 'package:cloud_firestore/cloud_firestore.dart';

enum WorkoutType { FatBurn, WeightGain }

class Workout {
  final String id;
  final String name;
  final String description;
  final WorkoutType
  workoutType; // Changed from 'type' to 'workoutType' to match usage in screens
  final double calories;
  final int durationMinutes;
  final String imageUrl;
  final List<String> steps;
  final String difficulty; // e.g., "Easy", "Medium", "Hard"

  Workout({
    required this.id,
    required this.name,
    required this.description,
    required this.workoutType,
    required this.calories,
    required this.durationMinutes,
    required this.imageUrl,
    required this.steps,
    required this.difficulty,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type':
          workoutType
              .toString()
              .split('.')
              .last, // Store as string in Firestore
      'calories': calories,
      'durationMinutes': durationMinutes,
      'imageUrl': imageUrl,
      'steps': steps,
      'difficulty': difficulty,
    };
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      workoutType: _parseWorkoutType(json['type']),
      calories: (json['calories'] ?? 0).toDouble(),
      durationMinutes: json['durationMinutes'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      steps: List<String>.from(json['steps'] ?? []),
      difficulty: json['difficulty'] ?? 'Easy',
    );
  }

  factory Workout.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Workout(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      workoutType: _parseWorkoutType(data['type']),
      calories: (data['calories'] ?? 0).toDouble(),
      durationMinutes: data['durationMinutes'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      steps: List<String>.from(data['steps'] ?? []),
      difficulty: data['difficulty'] ?? 'Easy',
    );
  }

  Workout copyWith({
    String? id,
    String? name,
    String? description,
    WorkoutType? workoutType,
    double? calories,
    int? durationMinutes,
    String? imageUrl,
    List<String>? steps,
    String? difficulty,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      workoutType: workoutType ?? this.workoutType,
      calories: calories ?? this.calories,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      imageUrl: imageUrl ?? this.imageUrl,
      steps: steps ?? this.steps,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  // Helper method to parse WorkoutType from string
  static WorkoutType _parseWorkoutType(String? typeStr) {
    if (typeStr == null || typeStr.isEmpty) {
      return WorkoutType.FatBurn; // Default value
    }

    // Convert to lowercase for case-insensitive comparison
    String normalizedType = typeStr.toLowerCase();

    // Check for variations of FatBurn type
    if (normalizedType == 'fatburn' ||
        normalizedType == 'fat_burn' ||
        normalizedType == 'fat burn' ||
        normalizedType == 'weightloss' ||
        normalizedType == 'weight_loss' ||
        normalizedType == 'weight loss') {
      return WorkoutType.FatBurn;
    }

    // Check for variations of WeightGain type
    if (normalizedType == 'weightgain' ||
        normalizedType == 'weight_gain' ||
        normalizedType == 'weight gain' ||
        normalizedType == 'bodygain' ||
        normalizedType == 'body_gain' ||
        normalizedType == 'body gain') {
      return WorkoutType.WeightGain;
    }

    // Try to parse the enum directly
    try {
      return WorkoutType.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == normalizedType,
      );
    } catch (_) {
      // If no match is found, return default
      return WorkoutType.FatBurn;
    }
  }

  // Helper method to get a display string for the workout type
  String get typeDisplayName {
    switch (workoutType) {
      case WorkoutType.FatBurn:
        return "Fat Burn";
      case WorkoutType.WeightGain:
        return "Weight Gain";
      default:
        return workoutType.toString().split('.').last;
    }
  }
}
