import 'package:cloud_firestore/cloud_firestore.dart';

// Achievement types enum
enum AchievementType {
  meal, // General meal achieve, mealCompletionments
  workout, // Workout completion achievements
  water, // Water intake achievements
  streak, // Streak achievements (consecutive days)
  mealCompletion, // Specific meal completion achievements
  firstMealOfDay, // First meal of the day achievements
  balancedMeal, // Balanced nutrition achievements
}

class Achievement {
  final String id;
  final String userId;
  final AchievementType type;
  final String itemId;
  final String title;
  final String description;
  final DateTime date;
  final int points;
  final Map<String, dynamic>? metadata;

  Achievement({
    required this.id,
    required this.userId,
    required this.type,
    required this.itemId,
    required this.title,
    required this.description,
    required this.date,
    required this.points,
    this.metadata,
  });

  // Factory constructor to create Achievement from Firestore document
  factory Achievement.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Parse the type string to AchievementType enum
    AchievementType parseType(String typeStr) {
      switch (typeStr) {
        case 'meal':
          return AchievementType.meal;
        case 'workout':
          return AchievementType.workout;
        case 'water':
          return AchievementType.water;
        case 'streak':
          return AchievementType.streak;
        case 'mealCompletion':
          return AchievementType.mealCompletion;
        case 'firstMealOfDay':
          return AchievementType.firstMealOfDay;
        case 'balancedMeal':
          return AchievementType.balancedMeal;
        default:
          return AchievementType.meal; // Default to meal type
      }
    }

    Timestamp timestamp = data['date'] as Timestamp;

    return Achievement(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: parseType(data['type'] ?? 'meal'),
      itemId: data['itemId'] ?? '',
      title: data['title'] ?? 'Achievement',
      description: data['description'] ?? '',
      date: timestamp.toDate(),
      points: data['points'] ?? 0,
      metadata: data['metadata'],
    );
  }

  // Convert Achievement to Map for Firestore
  Map<String, dynamic> toFirestore() {
    String typeString = type.toString().split('.').last;

    return {
      'userId': userId,
      'type': typeString,
      'itemId': itemId,
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'points': points,
      'metadata': metadata ?? {},
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Factory constructor from JSON/Map
  factory Achievement.fromMap(Map<String, dynamic> map) {
    // Parse the type string to AchievementType enum
    AchievementType parseType(String typeStr) {
      switch (typeStr) {
        case 'meal':
          return AchievementType.meal;
        case 'workout':
          return AchievementType.workout;
        case 'water':
          return AchievementType.water;
        case 'streak':
          return AchievementType.streak;
        case 'mealCompletion':
          return AchievementType.mealCompletion;
        case 'firstMealOfDay':
          return AchievementType.firstMealOfDay;
        case 'balancedMeal':
          return AchievementType.balancedMeal;
        default:
          return AchievementType.meal; // Default to meal type
      }
    }

    // Handle different date formats
    DateTime parseDate(dynamic dateValue) {
      if (dateValue is Timestamp) {
        return dateValue.toDate();
      } else if (dateValue is DateTime) {
        return dateValue;
      } else if (dateValue is String) {
        return DateTime.parse(dateValue);
      } else {
        return DateTime.now(); // Default to current time if can't parse
      }
    }

    return Achievement(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      type: parseType(map['type'] ?? 'meal'),
      itemId: map['itemId'] ?? '',
      title: map['title'] ?? 'Achievement',
      description: map['description'] ?? '',
      date: parseDate(map['date'] ?? DateTime.now()),
      points: map['points'] ?? 0,
      metadata: map['metadata'] ?? {},
    );
  }

  // Convert to JSON/Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last,
      'itemId': itemId,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'points': points,
      'metadata': metadata ?? {},
    };
  }

  // Factory to create a copy with updated fields
  Achievement copyWith({
    String? id,
    String? userId,
    AchievementType? type,
    String? itemId,
    String? title,
    String? description,
    DateTime? date,
    int? points,
    Map<String, dynamic>? metadata,
  }) {
    return Achievement(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      itemId: itemId ?? this.itemId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      points: points ?? this.points,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'Achievement(id: $id, type: $type, title: $title, points: $points)';
  }
}
