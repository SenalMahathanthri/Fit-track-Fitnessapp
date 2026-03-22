// lib/features/workout/workout_controller.dart
import 'package:get/get.dart';
import '../../core/services/firebase/workout_Plans_service.dart';
import '../../core/services/firebase/workout_service.dart';
import '../../core/services/firebase/notification_service.dart';
import '../../core/services/firebase/achivement_service.dart';
import '../../data/models/workout_model.dart';
import '../../data/models/workout_plan.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkoutPlanController extends GetxController {
  final WorkoutService _workoutService = WorkoutService();
  final WorkoutPlanService _workoutPlanService = WorkoutPlanService();
  final AchievementService _achievementService = AchievementService();
  final NotificationService _notificationService = NotificationService();

  // Observable variables
  final RxList<Workout> workouts = <Workout>[].obs;
  final RxList<WorkoutPlan> userWorkoutPlans = <WorkoutPlan>[].obs;
  final RxList<WorkoutPlan> todayWorkoutPlans = <WorkoutPlan>[].obs;

  // Filtered workout lists by type (but now also keeping all workouts visible)
  final RxList<Workout> bodyGainWorkouts = <Workout>[].obs;
  final RxList<Workout> weightLossWorkouts = <Workout>[].obs;

  // Loading state variables
  final RxBool isLoading = false.obs;
  final RxBool isLoadingWorkouts = false.obs;
  final RxBool isLoadingUserWorkoutPlans = false.obs;
  final RxBool isLoadingTodayWorkoutPlans = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isUpdating = false.obs;
  final RxBool isAddingWorkout = false.obs;

  // Search related variables
  final RxBool isSearching = false.obs;
  final RxList<Workout> searchResults = <Workout>[].obs;
  final RxString searchQuery = ''.obs;

  // User preferences - modified to default to "all" to show everything
  final RxString userGoalType =
      "all".obs; // Changed default to show all workouts

  // Debug mode for troubleshooting
  final RxBool debugMode = false.obs;

  // Achievement variables
  final RxInt userPoints = 0.obs;
  final RxBool showAchievementPopup = false.obs;
  final RxString achievementTitle = ''.obs;
  final RxString achievementDescription = ''.obs;

  // Statistics for summary
  final RxDouble totalCalories = 0.0.obs;
  final RxInt totalDuration = 0.obs;
  final RxInt totalWorkouts = 0.obs;

  // Currently selected workout plan
  final Rx<WorkoutPlan?> selectedWorkoutPlan = Rx<WorkoutPlan?>(null);

  @override
  void onInit() {
    super.onInit();
    _notificationService.init();
    fetchWorkouts();
    fetchUserWorkoutPlans();
    fetchTodayWorkoutPlans();
    fetchUserPoints();
    updateTotalStats();

    // Setup streams for real-time updates
    setupWorkoutPlanStreams();
  }

  void toggleDebugMode() {
    debugMode.value = !debugMode.value;
    print('Debug mode: ${debugMode.value}');
  }

  void setupWorkoutPlanStreams() {
    // Listen to today's workout plans with proper error handling
    _workoutPlanService.todayWorkoutPlansStream().listen(
      (workoutPlans) {
        print('Received ${workoutPlans.length} workout plans for today');
        todayWorkoutPlans.value = workoutPlans;
        updateTotalStats();
      },
      onError: (e) {
        print('Error in today workout plans stream: $e');
        todayWorkoutPlans.value = [];
      },
    );

    // Listen to all user workout plans with proper error handling
    _workoutPlanService.workoutPlansStream().listen(
      (workoutPlans) {
        print('Received ${workoutPlans.length} user workout plans');
        userWorkoutPlans.value = workoutPlans;
        updateTotalStats();
      },
      onError: (e) {
        print('Error in user workout plans stream: $e');
        userWorkoutPlans.value = [];
      },
    );
  }

  // Update total statistics
  void updateTotalStats() {
    totalCalories.value = userWorkoutPlans.fold(
      0,
      (sum, plan) => sum + plan.estimatedCalories,
    );

    totalDuration.value = userWorkoutPlans.fold(
      0,
      (sum, plan) =>
          sum +
          plan.workouts.fold(
            0,
            (workoutSum, workout) => workoutSum + workout.durationMinutes,
          ),
    );

    totalWorkouts.value = userWorkoutPlans.length;
  }

  // Set user goal type
  void setUserGoalType(String type) {
    userGoalType.value = type.toLowerCase();
    print('User goal type set to: ${userGoalType.value}');
  }

  Future<void> fetchWorkouts() async {
    isLoadingWorkouts.value = true;
    isLoading.value = true;
    try {
      final fetchedWorkouts = await _workoutService.getAllWorkouts();
      print('Fetched ${fetchedWorkouts.length} workouts');
      workouts.value = fetchedWorkouts;

      // Filter workouts by type using the enum WorkoutType
      bodyGainWorkouts.value =
          fetchedWorkouts
              .where((workout) => workout.workoutType == WorkoutType.WeightGain)
              .toList();
      weightLossWorkouts.value =
          fetchedWorkouts
              .where((workout) => workout.workoutType == WorkoutType.FatBurn)
              .toList();

      print('Body gain workouts: ${bodyGainWorkouts.length}');
      print('Weight loss workouts: ${weightLossWorkouts.length}');
    } catch (e) {
      print('Error fetching workouts: $e');
      workouts.value = [];
      bodyGainWorkouts.value = [];
      weightLossWorkouts.value = [];
    } finally {
      isLoadingWorkouts.value = false;
      isLoading.value = false;
    }
  }

  Future<void> searchWorkouts(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      isSearching.value = false;
      return;
    }

    isSearching.value = true;
    searchQuery.value = query;

    try {
      // Search in local list first
      final filteredWorkouts =
          workouts
              .where(
                (workout) =>
                    workout.name.toLowerCase().contains(query.toLowerCase()) ||
                    workout.description.toLowerCase().contains(
                      query.toLowerCase(),
                    ),
              )
              .toList();

      print('Found ${filteredWorkouts.length} workouts matching query: $query');
      searchResults.value = filteredWorkouts;
    } catch (e) {
      print('Error searching workouts: $e');
      searchResults.value = [];
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> fetchUserWorkoutPlans() async {
    isLoadingUserWorkoutPlans.value = true;
    isLoading.value = true;
    try {
      final workoutPlans = await _workoutPlanService.getUserWorkoutPlans();
      print('Fetched ${workoutPlans.length} user workout plans');
      userWorkoutPlans.value = workoutPlans;
      updateTotalStats();
    } catch (e) {
      print('Error fetching user workout plans: $e');
      userWorkoutPlans.value = [];
    } finally {
      isLoadingUserWorkoutPlans.value = false;
      isLoading.value = false;
    }
  }

  Future<void> fetchTodayWorkoutPlans() async {
    isLoadingTodayWorkoutPlans.value = true;
    isLoading.value = true;
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final workoutPlans = await _workoutPlanService.getWorkoutPlansForDate(
        today,
      );
      print('Fetched ${workoutPlans.length} workout plans for today');
      todayWorkoutPlans.value = workoutPlans;
    } catch (e) {
      print('Error fetching today\'s workout plans: $e');
      todayWorkoutPlans.value = [];
    } finally {
      isLoadingTodayWorkoutPlans.value = false;
      isLoading.value = false;
    }
  }

  Future<void> fetchUserPoints() async {
    try {
      final points = await _achievementService.getUserPoints();
      userPoints.value = points;
    } catch (e) {
      print('Error fetching user points: $e');
    }
  }

  // Get a single workout plan by ID
  Future<WorkoutPlan?> getWorkoutPlanById(String id) async {
    try {
      return await _workoutPlanService.getWorkoutPlanById(id);
    } catch (e) {
      print('Error getting workout plan by ID: $e');
      return null;
    }
  }

  // Set the currently selected workout plan
  void setSelectedWorkoutPlan(WorkoutPlan plan) {
    selectedWorkoutPlan.value = plan;
  }

  // Get the currently selected workout plan
  WorkoutPlan? getSelectedWorkoutPlan() {
    return selectedWorkoutPlan.value;
  }

  // Method to add workout plan with repetition data
  Future<bool> addWorkoutPlanWithReps({
    required String name,
    required DateTime date,
    required String startTime,
    required List<Workout> selectedWorkouts,
    required List<Map<String, dynamic>> workoutReps,
    bool reminder = false,
    String reminderTime = '',
    String? assignedToUserId, // New parameter for Coach Assignment
  }) async {
    isAddingWorkout.value = true;
    isSaving.value = true;

    try {
      if (name.isEmpty) {
        print('Error: Workout plan name cannot be empty');
        return false;
      }

      if (selectedWorkouts.isEmpty) {
        print('Error: Selected workouts cannot be empty');
        return false;
      }

      // Calculate total estimated calories
      double totalCalories = selectedWorkouts.fold(
        0,
        (sum, workout) => sum + workout.calories,
      );
      
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      // Create workout plan
      final workoutPlan = WorkoutPlan(
        id: '',
        userId: assignedToUserId ?? '', // Service overrides if empty
        name: name,
        date: date,
        startTime: startTime,
        isFinished: false,
        workouts: selectedWorkouts,
        workoutReps: workoutReps,
        estimatedCalories: totalCalories,
        reminder: reminder,
        reminderTime: reminderTime,
        isFavorite: false,
        assignedBy: assignedToUserId != null ? currentUserId : null,
        status: assignedToUserId != null ? 'approved' : 'pending',
      );

      // Save to Firestore
      final workoutPlanId = await _workoutPlanService.addWorkoutPlanWithReps(
        workoutPlan,
        workoutReps,
        targetUserId: assignedToUserId,
      );

      if (workoutPlanId != null) {
        print('Successfully added workout plan with ID: $workoutPlanId');

        // Set up notification if reminder is enabled
        if (reminder && reminderTime.isNotEmpty) {
          await _notificationService.scheduleWorkoutReminder(
            workoutPlanId,
            name,
            reminderTime,
            workoutPlan.date,
          );
        }

        // Refresh workout plans
        fetchUserWorkoutPlans();
        fetchTodayWorkoutPlans();
        updateTotalStats();

        return true;
      } else {
        print('Failed to add workout plan');
        return false;
      }
    } catch (e) {
      print('Error adding workout plan: $e');
      return false;
    } finally {
      isAddingWorkout.value = false;
      isSaving.value = false;
    }
  }

  // Original method for backward compatibility
  Future<bool> addWorkoutPlan({
    required String name,
    required DateTime date,
    required String startTime,
    required List<Workout> selectedWorkouts,
    bool reminder = false,
    String reminderTime = '',
  }) async {
    // Create default workout reps (3 sets of 10 reps for each workout)
    final workoutReps =
        selectedWorkouts
            .map(
              (workout) => {
                'workoutId': workout.id,
                'sets': 3,
                'repsPerSet': 10,
              },
            )
            .toList();

    return addWorkoutPlanWithReps(
      name: name,
      date: date,
      startTime: startTime,
      selectedWorkouts: selectedWorkouts,
      workoutReps: workoutReps,
      reminder: reminder,
      reminderTime: reminderTime,
    );
  }

  // Update workout plan with rep data
  Future<bool> updateWorkoutPlanWithReps(
    WorkoutPlan workoutPlan,
    List<Map<String, dynamic>> workoutReps,
  ) async {
    isUpdating.value = true;
    isSaving.value = true;

    try {
      if (workoutPlan.id.isEmpty) {
        print('Error: Workout plan ID cannot be empty');
        return false;
      }

      // Update in Firestore
      final success = await _workoutPlanService.updateWorkoutPlanWithReps(
        workoutPlan,
        workoutReps,
      );

      if (success) {
        print('Successfully updated workout plan with reps: ${workoutPlan.id}');

        // Update notification if reminder changed
        if (workoutPlan.reminder && workoutPlan.reminderTime.isNotEmpty) {
          await _notificationService.scheduleWorkoutReminder(
            workoutPlan.id,
            workoutPlan.name,
            workoutPlan.reminderTime,
            workoutPlan.date,
          );
        } else {
          await _notificationService.cancelWorkoutReminder(workoutPlan.id);
        }

        // Refresh workout plans
        fetchUserWorkoutPlans();
        fetchTodayWorkoutPlans();
        updateTotalStats();
      } else {
        print('Failed to update workout plan with reps: ${workoutPlan.id}');
      }

      return success;
    } catch (e) {
      print('Error updating workout plan with reps: $e');
      return false;
    } finally {
      isUpdating.value = false;
      isSaving.value = false;
    }
  }

  // Update only repetition data for a workout plan
  Future<bool> updateWorkoutReps(
    String planId,
    List<Map<String, dynamic>> workoutReps,
  ) async {
    isUpdating.value = true;

    try {
      if (planId.isEmpty) {
        print('Error: Workout plan ID cannot be empty');
        return false;
      }

      final success = await _workoutPlanService.updateWorkoutReps(
        planId,
        workoutReps,
      );

      if (success) {
        print('Successfully updated workout reps for plan: $planId');

        // Refresh workout plans
        fetchUserWorkoutPlans();
        fetchTodayWorkoutPlans();
      } else {
        print('Failed to update workout reps for plan: $planId');
      }

      return success;
    } catch (e) {
      print('Error updating workout reps: $e');
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  Future<bool> updateWorkoutPlan(WorkoutPlan workoutPlan) async {
    isUpdating.value = true;
    isSaving.value = true;

    try {
      if (workoutPlan.id.isEmpty) {
        print('Error: Workout plan ID cannot be empty');
        return false;
      }

      // Update in Firestore
      final success = await _workoutPlanService.updateWorkoutPlan(workoutPlan);

      if (success) {
        print('Successfully updated workout plan: ${workoutPlan.id}');

        // Update notification if reminder changed
        if (workoutPlan.reminder && workoutPlan.reminderTime.isNotEmpty) {
          await _notificationService.scheduleWorkoutReminder(
            workoutPlan.id,
            workoutPlan.name,
            workoutPlan.reminderTime,
            workoutPlan.date,
          );
        } else {
          await _notificationService.cancelWorkoutReminder(workoutPlan.id);
        }

        // Refresh workout plans
        fetchUserWorkoutPlans();
        fetchTodayWorkoutPlans();
        updateTotalStats();
      } else {
        print('Failed to update workout plan: ${workoutPlan.id}');
      }

      return success;
    } catch (e) {
      print('Error updating workout plan: $e');
      return false;
    } finally {
      isUpdating.value = false;
      isSaving.value = false;
    }
  }

  Future<bool> deleteWorkoutPlan(String id) async {
    isDeleting.value = true;
    try {
      if (id.isEmpty) {
        print('Error: Workout plan ID cannot be empty');
        return false;
      }

      // Cancel notification
      await _notificationService.cancelWorkoutReminder(id);

      // Delete from Firestore
      final success = await _workoutPlanService.deleteWorkoutPlan(id);

      if (success) {
        print('Successfully deleted workout plan: $id');

        // Refresh workout plans after deletion
        fetchUserWorkoutPlans();
        fetchTodayWorkoutPlans();
        updateTotalStats();
      } else {
        print('Failed to delete workout plan: $id');
      }

      return success;
    } catch (e) {
      print('Error deleting workout plan: $e');
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  Future<bool> toggleWorkoutPlanFinished(String id, bool isFinished) async {
    try {
      if (id.isEmpty) {
        print('Error: Workout plan ID cannot be empty');
        return false;
      }

      final success = await _workoutPlanService.toggleWorkoutPlanFinished(
        id,
        isFinished,
      );

      if (success) {
        print('Successfully toggled workout plan finished: $id to $isFinished');

        // If completed, create achievement
        if (isFinished) {
          final workoutPlan = userWorkoutPlans.firstWhere(
            (plan) => plan.id == id,
          );
          final achievementId = await _achievementService
              .createWorkoutAchievement(
                id,
                workoutPlan.name,
                workoutPlan.estimatedCalories.toInt(),
              );

          if (achievementId != null) {
            print('Created achievement for completing workout plan: $id');

            // Show achievement popup
            achievementTitle.value = 'Workout Completed!';
            achievementDescription.value =
                'You completed the ${workoutPlan.name} workout';
            showAchievementPopup.value = true;

            // Update user points
            await fetchUserPoints();
          }
        }
      } else {
        print('Failed to toggle workout plan finished: $id');
      }

      return success;
    } catch (e) {
      print('Error toggling workout plan finished: $e');
      return false;
    }
  }

  Future<bool> toggleWorkoutPlanFavorite(String id, bool isFavorite) async {
    try {
      if (id.isEmpty) {
        print('Error: Workout plan ID cannot be empty');
        return false;
      }

      final success = await _workoutPlanService.toggleWorkoutPlanFavorite(
        id,
        isFavorite,
      );

      if (success) {
        print('Successfully toggled workout plan favorite: $id to $isFavorite');
        // Update the selected workout plan if it's the one that was toggled
        if (selectedWorkoutPlan.value != null &&
            selectedWorkoutPlan.value!.id == id) {
          selectedWorkoutPlan.value = selectedWorkoutPlan.value!.copyWith(
            isFavorite: isFavorite,
          );
        }
      } else {
        print('Failed to toggle workout plan favorite: $id');
      }

      return success;
    } catch (e) {
      print('Error toggling workout plan favorite: $e');
      return false;
    }
  }

  void hideAchievementPopup() {
    showAchievementPopup.value = false;
  }

  // Helper method to calculate daily workout stats
  Map<String, double> calculateDailyWorkoutStats() {
    double totalCalories = 0;
    int totalDuration = 0;
    int completedWorkouts = 0;

    for (var workoutPlan in todayWorkoutPlans) {
      totalCalories += workoutPlan.estimatedCalories;
      totalDuration += workoutPlan.workouts.fold(
        0,
        (sum, workout) => sum + workout.durationMinutes,
      );

      if (workoutPlan.isFinished) {
        completedWorkouts++;
      }
    }

    return {
      'calories': totalCalories,
      'duration': totalDuration.toDouble(),
      'completed': completedWorkouts.toDouble(),
      'total': todayWorkoutPlans.length.toDouble(),
    };
  }

  // Get filtered workouts based on user goal type - modified to always return workouts
  List<Workout> getFilteredWorkouts() {
    if (userGoalType.value.isEmpty || userGoalType.value == 'all') {
      return workouts;
    } else if (userGoalType.value == 'bodygain') {
      return bodyGainWorkouts;
    } else if (userGoalType.value == 'weightloss') {
      return weightLossWorkouts;
    } else {
      return workouts; // Default to all workouts
    }
  }

  // Debug method to get all workout plan information
  String getWorkoutPlanDebugInfo() {
    StringBuffer buffer = StringBuffer();

    buffer.writeln('User Goal Type: ${userGoalType.value}');
    buffer.writeln('User Workout Plans (${userWorkoutPlans.length}):');
    for (var plan in userWorkoutPlans) {
      buffer.writeln(
        '- ${plan.name}, ID: ${plan.id}, Date: ${plan.date}, Finished: ${plan.isFinished}',
      );
    }

    buffer.writeln('\nToday Workout Plans (${todayWorkoutPlans.length}):');
    for (var plan in todayWorkoutPlans) {
      buffer.writeln(
        '- ${plan.name}, ID: ${plan.id}, Date: ${plan.date}, Finished: ${plan.isFinished}',
      );
    }

    buffer.writeln('\nWorkouts by Type:');
    buffer.writeln('Body Gain Workouts: ${bodyGainWorkouts.length}');
    buffer.writeln('Weight Loss Workouts: ${weightLossWorkouts.length}');
    buffer.writeln('Total Workouts: ${workouts.length}');

    buffer.writeln('\nTotal Stats:');
    buffer.writeln('Total Calories: ${totalCalories.value}');
    buffer.writeln('Total Duration: ${totalDuration.value} minutes');
    buffer.writeln('Total Points: ${userPoints.value}');

    return buffer.toString();
  }

  // Refresh all data
  Future<void> refreshAllData() async {
    print('Refreshing all workout data...');
    await fetchWorkouts();
    await fetchUserWorkoutPlans();
    await fetchTodayWorkoutPlans();
    await fetchUserPoints();
    updateTotalStats();
    print('All workout data refreshed');
  }

  // Get a workout by ID
  Workout? getWorkoutById(String workoutId) {
    try {
      return workouts.firstWhere((workout) => workout.id == workoutId);
    } catch (e) {
      print('Error finding workout with ID $workoutId: $e');
      return null;
    }
  }

  // Calculate total sets and reps for a workout plan
  Map<String, int> calculateTotalSetsAndReps(WorkoutPlan plan) {
    int totalSets = 0;
    int totalReps = 0;

    for (var repInfo in plan.workoutReps) {
      final sets = repInfo['sets'] as int? ?? 3;
      final repsPerSet = repInfo['repsPerSet'] as int? ?? 10;

      totalSets += sets;
      totalReps += sets * repsPerSet;
    }

    return {'totalSets': totalSets, 'totalReps': totalReps};
  }

  // Get workout repetition info for a specific workout in a plan
  Map<String, dynamic> getWorkoutReps(WorkoutPlan plan, String workoutId) {
    try {
      return plan.workoutReps.firstWhere(
        (rep) => rep['workoutId'] == workoutId,
        orElse: () => {'workoutId': workoutId, 'sets': 3, 'repsPerSet': 10},
      );
    } catch (e) {
      // Return default values if not found
      return {'workoutId': workoutId, 'sets': 3, 'repsPerSet': 10};
    }
  }
}
