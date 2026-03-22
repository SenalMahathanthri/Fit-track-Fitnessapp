// lib/data/models/workout_plan.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'workout_model.dart';

class WorkoutPlan {
  final String id;
  final String userId;
  final String name;
  final DateTime date;
  final String startTime;
  final bool isFinished;
  final List<Workout> workouts;
  final List<Map<String, dynamic>> workoutReps; // Repetition data for workouts
  final double estimatedCalories;
  final bool reminder;
  final String reminderTime;
  final bool isFavorite;
  final String? assignedBy;
  final String status; // 'pending', 'approved', 'rejected'
  final String? coachComments;

  WorkoutPlan({
    required this.id,
    required this.userId,
    required this.name,
    required this.date,
    required this.startTime,
    required this.isFinished,
    required this.workouts,
    required this.estimatedCalories,
    this.workoutReps = const [], // Default to empty list
    this.reminder = false,
    this.reminderTime = '',
    this.isFavorite = false,
    this.assignedBy,
    this.status = 'pending', // Default requires coach approval
    this.coachComments,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'isFinished': isFinished,
      'workouts': workouts.map((workout) => workout.toJson()).toList(),
      'workoutReps': workoutReps, // Store repetition data
      'estimatedCalories': estimatedCalories,
      'reminder': reminder,
      'reminderTime': reminderTime,
      'isFavorite': isFavorite,
      'assignedBy': assignedBy,
      'status': status,
      'coachComments': coachComments,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory WorkoutPlan.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Parse workouts
    List<Workout> workoutList = [];
    if (data['workouts'] != null) {
      workoutList = List<Workout>.from(
        (data['workouts'] as List).map(
          (workout) => Workout.fromJson(workout as Map<String, dynamic>),
        ),
      );
    }

    // Parse workout reps (with fallback for old data)
    List<Map<String, dynamic>> workoutRepsList = [];
    if (data['workoutReps'] != null) {
      workoutRepsList = List<Map<String, dynamic>>.from(
        (data['workoutReps'] as List).map((item) {
          // Convert to Map<String, dynamic>
          return Map<String, dynamic>.from(item as Map);
        }),
      );
    } else {
      // For backward compatibility, generate default reps for old workout plans
      workoutRepsList =
          workoutList
              .map(
                (workout) => {
                  'workoutId': workout.id,
                  'sets': 3,
                  'repsPerSet': 10,
                },
              )
              .toList();
    }

    return WorkoutPlan(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      startTime: data['startTime'] ?? '',
      isFinished: data['isFinished'] ?? false,
      workouts: workoutList,
      workoutReps: workoutRepsList,
      estimatedCalories: (data['estimatedCalories'] ?? 0).toDouble(),
      reminder: data['reminder'] ?? false,
      reminderTime: data['reminderTime'] ?? '',
      isFavorite: data['isFavorite'] ?? false,
      assignedBy: data['assignedBy'],
      status: data['status'] ?? 'pending',
      coachComments: data['coachComments'],
    );
  }

  WorkoutPlan copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? date,
    String? startTime,
    bool? isFinished,
    List<Workout>? workouts,
    List<Map<String, dynamic>>? workoutReps,
    double? estimatedCalories,
    bool? reminder,
    String? reminderTime,
    bool? isFavorite,
    String? assignedBy,
    String? status,
    String? coachComments,
  }) {
    return WorkoutPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      isFinished: isFinished ?? this.isFinished,
      workouts: workouts ?? this.workouts,
      workoutReps: workoutReps ?? this.workoutReps,
      estimatedCalories: estimatedCalories ?? this.estimatedCalories,
      reminder: reminder ?? this.reminder,
      reminderTime: reminderTime ?? this.reminderTime,
      isFavorite: isFavorite ?? this.isFavorite,
      assignedBy: assignedBy ?? this.assignedBy,
      status: status ?? this.status,
      coachComments: coachComments ?? this.coachComments,
    );
  }

  // Helper method to get repetition info for a specific workout
  Map<String, dynamic> getWorkoutReps(String workoutId) {
    try {
      return workoutReps.firstWhere(
        (rep) => rep['workoutId'] == workoutId,
        orElse: () => {'workoutId': workoutId, 'sets': 3, 'repsPerSet': 10},
      );
    } catch (e) {
      // Return default values if not found
      return {'workoutId': workoutId, 'sets': 3, 'repsPerSet': 10};
    }
  }

  // Calculate total sets and reps for this plan
  Map<String, int> calculateTotalSetsAndReps() {
    int totalSets = 0;
    int totalReps = 0;

    for (var repInfo in workoutReps) {
      final sets = repInfo['sets'] as int? ?? 3;
      final repsPerSet = repInfo['repsPerSet'] as int? ?? 10;

      totalSets += sets;
      totalReps += sets * repsPerSet;
    }

    return {'totalSets': totalSets, 'totalReps': totalReps};
  }

  // Get the formatted date string
  String get formattedDate {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Get the formatted time string
  String get formattedStartTime {
    return startTime;
  }

  // Check if plan is approved and active
  bool get isApproved => status == 'approved';

  // Format the workouts string (for display)
  String get workoutsString {
    if (workouts.isEmpty) return "No workouts";
    if (workouts.length == 1) return workouts[0].name;
    return "${workouts.length} workouts";
  }

  // Get total duration of all workouts
  int get totalDuration {
    return workouts.fold(0, (sum, workout) => sum + workout.durationMinutes);
  }

  // Get total calories in all workouts
  double get totalCalories {
    return workouts.fold(0.0, (sum, workout) => sum + workout.calories);
  }
}
