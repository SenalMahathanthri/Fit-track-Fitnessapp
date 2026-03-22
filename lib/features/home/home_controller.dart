import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../../data/models/user_model.dart' as user_model;
import '../../../data/models/workout_plan.dart';
import '../../../data/models/meal_plan.dart';
import '../../../data/models/Achievement.dart';
import '../../../core/services/firebase/meal_plan_service.dart';
import '../../../core/services/firebase/water_service.dart';
import '../../core/services/firebase/achivement_service.dart';
import '../../core/services/firebase/firebase_auth_service.dart';
import '../../core/services/firebase/workout_Plans_service.dart';

class HomeController extends GetxController {
  // Services
  final WorkoutPlanService _workoutService = WorkoutPlanService();
  final MealPlanService _mealService = MealPlanService();
  final AuthService _authService = AuthService();
  final WaterService _waterService = WaterService();
  final AchievementService _achievementService = AchievementService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observable variables
  final RxBool isLoading = true.obs;
  final RxBool isLoadingWorkouts = false.obs;
  final RxBool isLoadingMeals = false.obs;
  final RxBool isLoadingAchievements = false.obs;

  final Rx<user_model.UserModel?> user = Rx<user_model.UserModel?>(null);
  final RxList<WorkoutPlan> todayWorkouts = <WorkoutPlan>[].obs;
  final RxList<MealPlan> todayMeals = <MealPlan>[].obs;
  final RxList<Achievement> recentAchievements = <Achievement>[].obs;
  final RxList<Achievement> todayAchievements = <Achievement>[].obs;

  final RxInt userPoints = 0.obs;
  final RxDouble totalCalories = 0.0.obs;
  final RxInt waterIntake = 0.obs;
  final RxDouble waterGoalProgress = 0.0.obs;
  final RxInt dailyWaterGoal = 2500.obs; // Default 2500ml

  // Statistics for summary
  final RxInt completedWorkoutsCount = 0.obs;
  final RxInt totalWorkoutsCount = 0.obs;
  final RxInt streakDays = 0.obs;
  final RxMap<String, int> weeklyWaterData = <String, int>{}.obs;

  // Reminders data
  final RxList<Map<String, dynamic>> reminders = <Map<String, dynamic>>[].obs;

  // Stream subscriptions for real-time updates
  StreamSubscription? _workoutSubscription;
  StreamSubscription? _mealSubscription;
  StreamSubscription? _waterSubscription;
  StreamSubscription? _achievementSubscription;
  StreamSubscription? _userSubscription;

  @override
  void onInit() {
    super.onInit();
    setupReminders();
    loadAllData();
    startListeners();
  }

  @override
  void onClose() {
    stopListeners();
    super.onClose();
  }

  // Refresh all data in the dashboard
  Future<void> refreshAll() async {
    isLoading.value = true;

    try {
      // Execute all data refresh operations in parallel for better performance
      await Future.wait([
        loadUserData(),
        loadTodayWorkouts(),
        loadTodayMeals(),
        loadWaterIntake(),
        loadWorkoutStatistics(),
      ]);

      // Show refresh confirmation
      Get.snackbar(
        'Updated',
        'Dashboard data refreshed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(10),
        borderRadius: 10,
      );
    } catch (e) {
      print('Error refreshing data: $e');
      Get.snackbar(
        'Error',
        'Failed to refresh data',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(10),
        borderRadius: 10,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Setup default reminders
  void setupReminders() {
    reminders.value = [
      {
        "title": "Morning Workout",
        "time": "07:00 AM",
        "icon": "fitness_center",
        "color": "blue",
        "tip": "30 min cardio improves heart health",
      },
      {
        "title": "Drink Water",
        "time": "Every hour",
        "icon": "water_drop",
        "color": "lightBlue",
        "tip": "Aim for 2.5L daily",
      },
      {
        "title": "Protein Intake",
        "time": "With meals",
        "icon": "restaurant",
        "color": "purple",
        "tip": "0.8g per kg of body weight daily",
      },
      {
        "title": "Sleep Time",
        "time": "10:30 PM",
        "icon": "bedtime",
        "color": "pink",
        "tip": "7-9 hours helps recovery",
      },
    ];
  }

  // Load all initial data
  Future<void> loadAllData() async {
    isLoading.value = true;
    try {
      await loadUserData();
      await loadTodayWorkouts();
      await loadTodayMeals();
      await loadWaterIntake();
      await loadWeeklyWaterData();
      await loadWorkoutStatistics();
      await getStreak();
    } catch (e) {
      print('Error loading initial data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Start listening to real-time updates
  void startListeners() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Listen for workout plans updates
    _workoutSubscription = _workoutService.todayWorkoutPlansStream().listen((
      data,
    ) {
      todayWorkouts.value = data;
      _calculateTotalCalories();
      updateWorkoutStatistics();
    }, onError: (e) => print('Error in workout stream: $e'));

    // Listen for meal plans updates
    _mealSubscription = _mealService.todayMealPlansStream().listen((data) {
      todayMeals.value = data;
    }, onError: (e) => print('Error in meal stream: $e'));

    // Listen for water intake updates
    _waterSubscription = _waterService.todayWaterIntakeStream().listen((
      amount,
    ) {
      waterIntake.value = amount;
      _updateWaterGoalProgress();
    }, onError: (e) => print('Error in water intake stream: $e'));

    // Listen for user data updates
    _userSubscription = _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            try {
              final userData = snapshot.data();
              if (userData != null) {
                // Update points
                if (userData.containsKey('points')) {
                  userPoints.value = userData['points'] as int? ?? 0;
                } else if (userData.containsKey('achievementPoints')) {
                  userPoints.value = userData['achievementPoints'] as int? ?? 0;
                }

                // Update water goal if available
                if (userData.containsKey('waterGoal')) {
                  dailyWaterGoal.value = userData['waterGoal'] as int? ?? 2500;
                  _updateWaterGoalProgress();
                }

                // Update user model if needed
                if (user.value == null) {
                  loadUserData();
                }
              }
            } catch (e) {
              print('Error parsing user snapshot: $e');
            }
          }
        }, onError: (e) => print('Error in user stream: $e'));
  }

  // Stop all listeners
  void stopListeners() {
    _workoutSubscription?.cancel();
    _mealSubscription?.cancel();
    _waterSubscription?.cancel();
    _achievementSubscription?.cancel();
    _userSubscription?.cancel();
  }

  // Update water goal progress
  Future<void> _updateWaterGoalProgress() async {
    try {
      final goal = dailyWaterGoal.value;
      final current = waterIntake.value;

      if (goal == 0) {
        waterGoalProgress.value = 0.0;
      } else {
        double progress = current / goal;
        waterGoalProgress.value = progress > 1.0 ? 1.0 : progress;
      }
    } catch (e) {
      print('Error updating water goal progress: $e');
    }
  }

  // Load user data
  Future<void> loadUserData() async {
    try {
      // Get current user data
      final userData = await _authService.getUserData();
      if (userData != null) {
        user.value = userData;
      }

      // Get user points
      await fetchUserPoints();

      // Get user water goal
      await loadWaterGoal();
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  // Load user's daily water goal
  Future<void> loadWaterGoal() async {
    try {
      final goal = await _waterService.getDailyWaterGoal();
      dailyWaterGoal.value = goal;
    } catch (e) {
      print('Error loading water goal: $e');
    }
  }

  // Load today's workouts
  Future<void> loadTodayWorkouts() async {
    isLoadingWorkouts.value = true;
    try {
      final workouts = await _workoutService.getWorkoutPlansForDate(
        DateTime.now(),
      );
      todayWorkouts.value = workouts;
      _calculateTotalCalories();
      updateWorkoutStatistics();
    } catch (e) {
      print('Error loading today\'s workouts: $e');
    } finally {
      isLoadingWorkouts.value = false;
    }
  }

  // Calculate total calories from workouts
  void _calculateTotalCalories() {
    double total = 0;
    for (var workout in todayWorkouts) {
      if (workout.isFinished) {
        total += workout.estimatedCalories;
      }
    }
    totalCalories.value = total;
  }

  // Update workout statistics
  void updateWorkoutStatistics() {
    // Update completed workouts count
    int completed = 0;
    for (var workout in todayWorkouts) {
      if (workout.isFinished) {
        completed++;
      }
    }

    completedWorkoutsCount.value = completed;
    totalWorkoutsCount.value = todayWorkouts.length;
  }

  // Load today's meals
  Future<void> loadTodayMeals() async {
    isLoadingMeals.value = true;
    try {
      final meals = await _mealService.getMealPlansForDate(DateTime.now());
      todayMeals.value = meals;
    } catch (e) {
      print('Error loading today\'s meals: $e');
    } finally {
      isLoadingMeals.value = false;
    }
  }

  // Toggle meal completion status
  Future<bool> toggleMealCompletion(String mealId, bool isCompleted) async {
    try {
      await _mealService.toggleMealPlanCompletion(mealId, isCompleted);

      // Show feedback to user
      if (isCompleted) {
        Get.snackbar(
          'Meal Completed',
          'Great job! You completed your meal.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(10),
          borderRadius: 10,
        );
      }
      return true;
    } catch (e) {
      print('Error toggling meal completion: $e');
      Get.snackbar(
        'Error',
        'Failed to update meal status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(10),
        borderRadius: 10,
      );
      return false;
    }
  }

  // Toggle workout completion status
  Future<bool> toggleWorkoutCompletion(
    String workoutId,
    bool isCompleted,
  ) async {
    try {
      await _workoutService.toggleWorkoutPlanFinished(workoutId, isCompleted);

      // Show feedback to user
      if (isCompleted) {
        Get.snackbar(
          'Workout Completed',
          'Amazing! You finished your workout.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(10),
          borderRadius: 10,
        );
      }
      return true;
    } catch (e) {
      print('Error toggling workout completion: $e');
      Get.snackbar(
        'Error',
        'Failed to update workout status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(10),
        borderRadius: 10,
      );
      return false;
    }
  }

  // Get user points
  Future<void> fetchUserPoints() async {
    try {
      final points = await _achievementService.getUserPoints();
      userPoints.value = points;
    } catch (e) {
      print('Error fetching user points: $e');
    }
  }

  // Load water intake for today
  Future<void> loadWaterIntake() async {
    try {
      final amount = await _waterService.getTodayWaterIntake();
      waterIntake.value = amount;
      _updateWaterGoalProgress();
    } catch (e) {
      print('Error loading water intake: $e');
    }
  }

  // Add water intake
  Future<bool> addWaterIntake(int amount) async {
    try {
      await _waterService.addWaterIntake(amount);

      // Check if water goal is reached after adding this amount
      final currentTotal = waterIntake.value + amount;
      if (currentTotal >= dailyWaterGoal.value &&
          waterIntake.value < dailyWaterGoal.value) {
        // Water goal was just reached, create achievement
        await _achievementService.createWaterAchievement();

        // Show congratulatory message
        Get.snackbar(
          'Water Goal Reached!',
          'Congratulations! You reached your daily water goal.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.blue.withOpacity(0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(10),
          borderRadius: 10,
        );
      }

      return true;
    } catch (e) {
      print('Error adding water intake: $e');
      return false;
    }
  }

  // Get weekly water intake data for chart
  Future<void> loadWeeklyWaterData() async {
    try {
      final data = await _waterService.getWeeklyWaterIntake();
      weeklyWaterData.value = data;
    } catch (e) {
      print('Error getting weekly water data: $e');
    }
  }

  // Update user's daily water goal
  Future<bool> updateDailyWaterGoal(int goalMl) async {
    try {
      await _waterService.updateDailyWaterGoal(goalMl);
      dailyWaterGoal.value = goalMl;
      _updateWaterGoalProgress();

      // Show confirmation
      Get.snackbar(
        'Water Goal Updated',
        'Your daily water goal is now $goalMl ml',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(10),
        borderRadius: 10,
      );

      return true;
    } catch (e) {
      print('Error updating daily water goal: $e');

      Get.snackbar(
        'Error',
        'Failed to update water goal',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(10),
        borderRadius: 10,
      );

      return false;
    }
  }

  // Load workout statistics
  Future<void> loadWorkoutStatistics() async {
    try {
      updateWorkoutStatistics();
    } catch (e) {
      print('Error loading workout statistics: $e');
    }
  }

  // Get user's streak (consecutive days with completed workouts/meals)
  Future<void> getStreak() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        streakDays.value = 0;
        return;
      }

      // Use an efficient query to get the last 30 days of data
      final DateTime thirtyDaysAgo = DateTime.now().subtract(
        const Duration(days: 30),
      );

      // Get workout achievements
      final workoutAchievements =
          await _firestore
              .collection('achievements')
              .where('userId', isEqualTo: userId)
              .where('type', isEqualTo: 'workout')
              .where(
                'date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(thirtyDaysAgo),
              )
              .orderBy('date', descending: true)
              .get();

      // Get meal achievements
      final mealAchievements =
          await _firestore
              .collection('achievements')
              .where('userId', isEqualTo: userId)
              .where('type', isEqualTo: 'meal')
              .where(
                'date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(thirtyDaysAgo),
              )
              .orderBy('date', descending: true)
              .get();

      // Combine all achievements and organize by date
      final Map<String, bool> dateMap = {};

      // Process all achievements
      for (var doc in [...workoutAchievements.docs, ...mealAchievements.docs]) {
        final date = (doc.data()['date'] as Timestamp).toDate();
        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        dateMap[dateStr] = true;
      }

      // Count streak (consecutive days from today backwards)
      int streak = 0;
      final now = DateTime.now();

      for (int i = 0; i < 30; i++) {
        final checkDate = now.subtract(Duration(days: i));
        final checkDateStr = DateFormat('yyyy-MM-dd').format(checkDate);

        if (dateMap[checkDateStr] == true) {
          streak++;
        } else {
          // Break at first day without activity
          break;
        }
      }

      streakDays.value = streak;

      // If streak is significant (>= 7), show a celebration
      if (streak >= 7 && streak % 7 == 0) {
        Get.snackbar(
          'Streak Milestone! 🔥',
          'Amazing! You\'ve been active for $streak days in a row!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.withOpacity(0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(10),
          borderRadius: 10,
        );
      }
    } catch (e) {
      print('Error calculating streak: $e');
      streakDays.value = 0;
    }
  }

  // Calculate daily workout stats
  Map<String, double> calculateDailyWorkoutStats() {
    double totalCalories = 0;
    int totalDuration = 0;
    int completedWorkouts = 0;

    for (var workoutPlan in todayWorkouts) {
      if (workoutPlan.isFinished) {
        totalCalories += workoutPlan.estimatedCalories;
        totalDuration += workoutPlan.workouts.fold(
          0,
          (sum, workout) => sum + workout.durationMinutes,
        );
        completedWorkouts++;
      }
    }

    return {
      'calories': totalCalories,
      'duration': totalDuration.toDouble(),
      'completed': completedWorkouts.toDouble(),
      'total': todayWorkouts.length.toDouble(),
    };
  }
}
