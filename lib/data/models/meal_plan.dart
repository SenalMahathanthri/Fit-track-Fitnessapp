// lib/models/meal_plan_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import 'meal_model.dart';

class MealPlan {
  final String id;
  final String userId;
  final String name;
  final String type; // Breakfast, Lunch, Dinner, Snack
  final String time;
  final List<Meal> items;
  final double totalCalories;
  final double totalProteins;
  final double totalCarbs;
  final bool reminder;
  final String reminderTime;
  final bool isFavorite;
  final bool isCompleted;
  final DateTime date;
  final String? assignedBy;
  final String status; // 'pending', 'approved', 'rejected'
  final String? coachComments;

  MealPlan({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.time,
    required this.items,
    required this.totalCalories,
    required this.totalProteins,
    required this.totalCarbs,
    this.reminder = false,
    this.reminderTime = '',
    this.isFavorite = false,
    this.isCompleted = false,
    required this.date,
    this.assignedBy,
    this.status = 'pending', // Default requires coach approval
    this.coachComments,
  });

  factory MealPlan.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    List<Meal> items = [];
    if (data['items'] != null) {
      items =
          (data['items'] as List).map((item) => Meal.fromJson(item)).toList();
    }

    return MealPlan(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      time: data['time'] ?? '',
      items: items,
      totalCalories: (data['totalCalories'] ?? 0).toDouble(),
      totalProteins: (data['totalProteins'] ?? 0).toDouble(),
      totalCarbs: (data['totalCarbs'] ?? 0).toDouble(),
      reminder: data['reminder'] ?? false,
      reminderTime: data['reminderTime'] ?? '',
      isFavorite: data['isFavorite'] ?? false,
      isCompleted: data['isCompleted'] ?? false,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      assignedBy: data['assignedBy'],
      status: data['status'] ?? 'pending',
      coachComments: data['coachComments'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'type': type,
      'time': time,
      'items': items.map((item) => item.toJson()).toList(),
      'totalCalories': totalCalories,
      'totalProteins': totalProteins,
      'totalCarbs': totalCarbs,
      'reminder': reminder,
      'reminderTime': reminderTime,
      'isFavorite': isFavorite,
      'isCompleted': isCompleted,
      'date': Timestamp.fromDate(date),
      'assignedBy': assignedBy,
      'status': status,
      'coachComments': coachComments,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  MealPlan copyWith({
    String? id,
    String? userId,
    String? name,
    String? type,
    String? time,
    List<Meal>? items,
    double? totalCalories,
    double? totalProteins,
    double? totalCarbs,
    bool? reminder,
    String? reminderTime,
    bool? isFavorite,
    bool? isCompleted,
    DateTime? date,
    String? assignedBy,
    String? status,
    String? coachComments,
  }) {
    return MealPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      time: time ?? this.time,
      items: items ?? this.items,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProteins: totalProteins ?? this.totalProteins,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      reminder: reminder ?? this.reminder,
      reminderTime: reminderTime ?? this.reminderTime,
      isFavorite: isFavorite ?? this.isFavorite,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date ?? this.date,
      assignedBy: assignedBy ?? this.assignedBy,
      status: status ?? this.status,
      coachComments: coachComments ?? this.coachComments,
    );
  }
}
