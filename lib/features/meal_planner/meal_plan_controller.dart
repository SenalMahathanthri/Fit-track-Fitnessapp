// lib/features/meal/meal_plan_controller.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/firebase/achivement_service.dart';
import '../../core/services/firebase/meal_plan_service.dart';
import '../../core/services/firebase/meal_service.dart';
import '../../core/services/firebase/notification_service.dart';
import '../../data/models/achievement.dart';
import '../../data/models/meal_model.dart';
import '../../data/models/meal_plan.dart';

class MealPlanController extends GetxController {
  final MealService _mealService = MealService();
  final MealPlanService _mealPlanService = MealPlanService();
  final AchievementService _achievementService = AchievementService();
  final NotificationService _notificationService = NotificationService();

  // Observable variables
  final RxList<Meal> meals = <Meal>[].obs;
  final RxList<MealPlan> userMealPlans = <MealPlan>[].obs;
  final RxList<MealPlan> todayMealPlans = <MealPlan>[].obs;
  final RxList<Achievement> userAchievements = <Achievement>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isSearching = false.obs;
  final RxList<Meal> searchResults = <Meal>[].obs;
  final RxString searchQuery = ''.obs;

  // Additional loading state variables
  final RxBool isLoadingUserMealPlans = false.obs;
  final RxBool isLoadingTodayMealPlans = false.obs;
  final RxBool isLoadingMeals = false.obs;
  final RxBool isLoadingAchievements = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isUpdating = false.obs;
  final RxBool isAddingMeal = false.obs;
  final RxBool isNotificationLoading = false.obs;

  // Debug mode for troubleshooting
  final RxBool debugMode = false.obs;

  // Achievement variables
  final RxInt userPoints = 0.obs;
  final RxBool showAchievementPopup = false.obs;
  final RxString achievementTitle = ''.obs;
  final RxString achievementDescription = ''.obs;
  final RxInt achievementPoints = 10.obs; // Default value
  final RxInt streakDays = 0.obs;

  // Notification status
  final RxBool notificationsEnabled = false.obs;
  final RxBool notificationsInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    initializeNotificationService();
    fetchMeals();
    fetchUserMealPlans();
    fetchTodayMealPlans();
    fetchUserPoints();
    fetchUserAchievements();

    // Setup streams for real-time updates
    setupMealPlanStreams();
    setupAchievementStream();
  }

  // Initialize notification service
  Future<void> initializeNotificationService() async {
    try {
      notificationsInitialized.value = false;
      await _notificationService.init();
      notificationsEnabled.value = true;
      notificationsInitialized.value = true;
      debugPrint('Notification service initialized successfully');

      // Test notification if in debug mode
      if (debugMode.value) {
        await sendTestNotification();
      }
    } catch (e) {
      debugPrint('Error initializing notification service: $e');
      notificationsEnabled.value = false;
      notificationsInitialized.value = true;
    }
  }

  // Send a test notification for debugging
  Future<bool> sendTestNotification() async {
    try {
      final success = await _notificationService.sendTestNotification(
        title: 'Test Notification',
        body: 'This is a test notification from your meal planner app',
      );
      if (success) {
        debugPrint('Test notification sent successfully');
      } else {
        debugPrint('Failed to send test notification');
      }
      return success;
    } catch (e) {
      debugPrint('Error sending test notification: $e');
      return false;
    }
  }

  void toggleDebugMode() {
    debugMode.value = !debugMode.value;
    debugPrint('Debug mode: ${debugMode.value}');

    // Send a test notification when debug mode is enabled
    if (debugMode.value) {
      sendTestNotification();
      _notificationService.printPendingNotifications();
    }
  }

  void setupMealPlanStreams() {
    // Listen to today's meal plans with proper error handling
    _mealPlanService.todayMealPlansStream().listen(
      (mealPlans) {
        debugPrint('Received ${mealPlans.length} meal plans for today');
        for (var plan in mealPlans) {
          debugPrint(
            'Today meal plan: ${plan.name}, type: ${plan.type}, date: ${plan.date}',
          );
        }
        todayMealPlans.value = mealPlans;
      },
      onError: (e) {
        debugPrint('Error in today meal plans stream: $e');
        todayMealPlans.value = [];
      },
    );

    // Listen to all user meal plans with proper error handling
    _mealPlanService.mealPlansStream().listen(
      (mealPlans) {
        debugPrint('Received ${mealPlans.length} user meal plans');
        userMealPlans.value = mealPlans;
      },
      onError: (e) {
        debugPrint('Error in user meal plans stream: $e');
        userMealPlans.value = [];
      },
    );
  }

  void setupAchievementStream() {
    // Listen to user achievements with proper error handling
    _achievementService.userAchievementsStream().listen(
      (achievements) {
        debugPrint('Received ${achievements.length} user achievements');
        userAchievements.value = achievements.cast<Achievement>();
        // Update user points when achievements change
        fetchUserPoints();
      },
      onError: (e) {
        debugPrint('Error in user achievements stream: $e');
        userAchievements.value = [];
      },
    );
  }

  Future<void> fetchUserAchievements() async {
    isLoadingAchievements.value = true;
    try {
      final achievements = await _achievementService.getUserAchievements();
      debugPrint('Fetched ${achievements.length} user achievements');
      userAchievements.value = achievements.cast<Achievement>();
    } catch (e) {
      debugPrint('Error fetching user achievements: $e');
      userAchievements.value = [];
    } finally {
      isLoadingAchievements.value = false;
    }
  }

  Future<void> fetchMeals() async {
    isLoadingMeals.value = true;
    isLoading.value = true;
    try {
      final fetchedMeals = await _mealService.getAllMeals();
      debugPrint('Fetched ${fetchedMeals.length} meals');
      meals.value = fetchedMeals;
    } catch (e) {
      debugPrint('Error fetching meals: $e');
      meals.value = [];
    } finally {
      isLoadingMeals.value = false;
      isLoading.value = false;
    }
  }

  Future<void> searchMeals(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      isSearching.value = false;
      return;
    }

    isSearching.value = true;
    searchQuery.value = query;

    try {
      // Search in local list first
      final filteredMeals =
          meals
              .where(
                (meal) => meal.name.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();

      debugPrint('Found ${filteredMeals.length} meals matching query: $query');
      searchResults.value = filteredMeals;
    } catch (e) {
      debugPrint('Error searching meals: $e');
      searchResults.value = [];
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> fetchUserMealPlans() async {
    isLoadingUserMealPlans.value = true;
    isLoading.value = true;
    try {
      final mealPlans = await _mealPlanService.getUserMealPlans();
      debugPrint('Fetched ${mealPlans.length} user meal plans');
      userMealPlans.value = mealPlans;
    } catch (e) {
      debugPrint('Error fetching user meal plans: $e');
      userMealPlans.value = [];
    } finally {
      isLoadingUserMealPlans.value = false;
      isLoading.value = false;
    }
  }

  Future<void> fetchTodayMealPlans() async {
    isLoadingTodayMealPlans.value = true;
    isLoading.value = true;
    try {
      // Get the current date and ensure we're using the right time boundaries
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      debugPrint('Fetching meal plans for date: ${today.toString()}');
      final mealPlans = await _mealPlanService.getMealPlansForDate(today);
      debugPrint('Fetched ${mealPlans.length} meal plans for today');

      for (var plan in mealPlans) {
        debugPrint(
          'Today meal plan: ${plan.name}, type: ${plan.type}, date: ${plan.date}',
        );
      }

      todayMealPlans.value = mealPlans;
    } catch (e) {
      debugPrint('Error fetching today\'s meal plans: $e');
      todayMealPlans.value = [];
    } finally {
      isLoadingTodayMealPlans.value = false;
      isLoading.value = false;
    }
  }

  Future<void> fetchUserPoints() async {
    try {
      final points = await _achievementService.getUserPoints();
      userPoints.value = points;
    } catch (e) {
      debugPrint('Error fetching user points: $e');
    }
  }

  Future<bool> addMealPlan({
    required String name,
    required String type,
    required String time,
    required List<Meal> selectedMeals,
    required List<double> quantities,
    bool reminder = false,
    String reminderTime = '',
    DateTime? date,
    String? assignedToUserId,
  }) async {
    isAddingMeal.value = true;
    isSaving.value = true;

    try {
      if (name.isEmpty) {
        debugPrint('Error: Meal plan name cannot be empty');
        return false;
      }

      if (selectedMeals.isEmpty || quantities.isEmpty) {
        debugPrint('Error: Selected meals or quantities cannot be empty');
        return false;
      }

      if (selectedMeals.length != quantities.length) {
        debugPrint(
          'Error: Number of selected meals does not match number of quantities',
        );
        return false;
      }

      // Create meal plan items
      List<Meal> items = [];
      double totalCalories = 0;
      double totalProteins = 0;
      double totalCarbs = 0;

      for (int i = 0; i < selectedMeals.length; i++) {
        final meal = selectedMeals[i];
        final quantity = quantities[i];

        double itemCalories = meal.calories * quantity / meal.grams;
        double itemProteins = meal.proteins * quantity / meal.grams;
        double itemCarbs = meal.carbs * quantity / meal.grams;

        totalCalories += itemCalories;
        totalProteins += itemProteins;
        totalCarbs += itemCarbs;

        items.add(
          Meal(
            id: meal.id,
            name: meal.name,
            calories: itemCalories,
            proteins: itemProteins,
            carbs: itemCarbs,
            grams: quantity,
            isConsumed: false,
          ),
        );
      }

      // Set the date to today if not provided
      final mealDate = date ?? DateTime.now();

      // Create meal plan
      final mealPlan = MealPlan(
        id: '',
        userId: assignedToUserId ?? '', // Will be correctly set by the service if empty
        name: name,
        type: type,
        time: time,
        items: items,
        totalCalories: totalCalories,
        totalProteins: totalProteins,
        totalCarbs: totalCarbs,
        reminder: reminder,
        reminderTime: reminderTime,
        date: mealDate,
        isCompleted: false,
        isFavorite: false,
        assignedBy: assignedToUserId != null ? FirebaseAuth.instance.currentUser?.uid : null,
        status: assignedToUserId != null ? 'approved' : 'pending',
      );

      debugPrint(
        'Adding meal plan: ${mealPlan.name}, type: ${mealPlan.type}, date: ${mealPlan.date}, reminder: $reminder, reminderTime: $reminderTime',
      );

      // Save to Firestore
      final mealPlanId = await _mealPlanService.addMealPlan(mealPlan, targetUserId: assignedToUserId);

      if (mealPlanId != null) {
        debugPrint('Successfully added meal plan with ID: $mealPlanId');

        // Set up notification if reminder is enabled
        if (reminder && reminderTime.isNotEmpty && notificationsEnabled.value) {
          isNotificationLoading.value = true;
          try {
            // Extract time from the time string (HH:MM)
            final timeParts = time.split(':');
            if (timeParts.length == 2) {
              int hour = int.tryParse(timeParts[0]) ?? 0;
              int minute = int.tryParse(timeParts[1]) ?? 0;

              // Create a DateTime object with the meal time
              final fullMealDateTime = DateTime(
                mealDate.year,
                mealDate.month,
                mealDate.day,
                hour,
                minute,
              );

              debugPrint(
                'Scheduling reminder for meal: $name at $fullMealDateTime with reminder time: $reminderTime',
              );

              final reminderSuccess = await _notificationService
                  .scheduleMealReminder(
                    mealPlanId,
                    name,
                    reminderTime,
                    fullMealDateTime,
                  );

              if (reminderSuccess) {
                debugPrint(
                  'Successfully scheduled reminder for meal plan: $mealPlanId',
                );
              } else {
                debugPrint(
                  'Failed to schedule reminder for meal plan: $mealPlanId',
                );
                // Continue anyway, as the meal plan was saved successfully
              }
            } else {
              debugPrint('Invalid time format for scheduling reminder: $time');
            }
          } catch (e) {
            debugPrint('Error scheduling meal reminder: $e');
          } finally {
            isNotificationLoading.value = false;
          }
        }

        // Check if this is the first meal plan of the day and award achievement
        if (todayMealPlans.length == 1) {
          final achievementId =
              await _achievementService.createFirstMealOfDayAchievement();
          if (achievementId != null) {
            // Show achievement popup
            achievementTitle.value = "First Meal of the Day!";
            achievementDescription.value =
                "You've planned your first meal of the day";
            achievementPoints.value =
                AchievementService.FIRST_MEAL_OF_DAY_POINTS;
            showAchievementPopup.value = true;
          }
        }

        // Check if meal is balanced and award achievement if it is
        await _achievementService.checkAndAwardBalancedMealAchievement(
          mealPlanId,
          name,
          totalProteins,
          totalCarbs,
          totalCalories,
        );

        // Refresh meal plans
        fetchUserMealPlans();
        fetchTodayMealPlans();
        fetchUserPoints();

        return true;
      } else {
        debugPrint('Failed to add meal plan');
        return false;
      }
    } catch (e) {
      debugPrint('Error adding meal plan: $e');
      return false;
    } finally {
      isAddingMeal.value = false;
      isSaving.value = false;
    }
  }

  Future<bool> updateMealPlan(MealPlan mealPlan) async {
    isUpdating.value = true;
    isSaving.value = true;

    try {
      if (mealPlan.id.isEmpty) {
        debugPrint('Error: Meal plan ID cannot be empty');
        return false;
      }

      debugPrint('Updating meal plan: ${mealPlan.id}, ${mealPlan.name}');

      // Update in Firestore
      final success = await _mealPlanService.updateMealPlan(mealPlan);

      if (success) {
        debugPrint('Successfully updated meal plan: ${mealPlan.id}');

        // Update notification if enabled
        if (notificationsEnabled.value) {
          isNotificationLoading.value = true;
          try {
            if (mealPlan.reminder && mealPlan.reminderTime.isNotEmpty) {
              // Create a DateTime with the meal time components
              final timeParts = mealPlan.time.split(':');
              if (timeParts.length == 2) {
                int hour = int.tryParse(timeParts[0]) ?? 0;
                int minute = int.tryParse(timeParts[1]) ?? 0;

                final fullMealDateTime = DateTime(
                  mealPlan.date.year,
                  mealPlan.date.month,
                  mealPlan.date.day,
                  hour,
                  minute,
                );

                // First cancel any existing reminder
                await _notificationService.cancelMealReminder(mealPlan.id);

                // Then schedule the new reminder
                final reminderSuccess = await _notificationService
                    .scheduleMealReminder(
                      mealPlan.id,
                      mealPlan.name,
                      mealPlan.reminderTime,
                      fullMealDateTime,
                    );

                if (reminderSuccess) {
                  debugPrint(
                    'Successfully updated reminder for meal plan: ${mealPlan.id}',
                  );
                } else {
                  debugPrint(
                    'Failed to update reminder for meal plan: ${mealPlan.id}',
                  );
                }
              } else {
                debugPrint(
                  'Invalid time format for scheduling reminder: ${mealPlan.time}',
                );
              }
            } else {
              // Cancel notification if reminder is disabled
              await _notificationService.cancelMealReminder(mealPlan.id);
              debugPrint('Cancelled reminder for meal plan: ${mealPlan.id}');
            }
          } catch (e) {
            debugPrint('Error updating meal reminder: $e');
          } finally {
            isNotificationLoading.value = false;
          }
        }

        // Refresh meal plans
        fetchUserMealPlans();
        fetchTodayMealPlans();
      } else {
        debugPrint('Failed to update meal plan: ${mealPlan.id}');
      }

      return success;
    } catch (e) {
      debugPrint('Error updating meal plan: $e');
      return false;
    } finally {
      isUpdating.value = false;
      isSaving.value = false;
    }
  }

  Future<bool> deleteMealPlan(String id) async {
    isDeleting.value = true;
    try {
      if (id.isEmpty) {
        debugPrint('Error: Meal plan ID cannot be empty');
        return false;
      }

      debugPrint('Deleting meal plan: $id');

      // Cancel notification if exists
      if (notificationsEnabled.value) {
        isNotificationLoading.value = true;
        try {
          await _notificationService.cancelMealReminder(id);
          debugPrint('Cancelled reminder for deleted meal plan: $id');
        } catch (e) {
          debugPrint('Error cancelling meal reminder: $e');
          // Continue with deletion anyway
        } finally {
          isNotificationLoading.value = false;
        }
      }

      // Delete from Firestore
      final success = await _mealPlanService.deleteMealPlan(id);

      if (success) {
        debugPrint('Successfully deleted meal plan: $id');

        // Refresh meal plans after deletion
        fetchUserMealPlans();
        fetchTodayMealPlans();
      } else {
        debugPrint('Failed to delete meal plan: $id');
      }

      return success;
    } catch (e) {
      debugPrint('Error deleting meal plan: $e');
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  Future<bool> toggleMealPlanFavorite(String id, bool isFavorite) async {
    try {
      if (id.isEmpty) {
        debugPrint('Error: Meal plan ID cannot be empty');
        return false;
      }

      debugPrint('Toggling meal plan favorite: $id to $isFavorite');

      final success = await _mealPlanService.toggleMealPlanFavorite(
        id,
        isFavorite,
      );

      if (success) {
        debugPrint(
          'Successfully toggled meal plan favorite: $id to $isFavorite',
        );
      } else {
        debugPrint('Failed to toggle meal plan favorite: $id');
      }

      return success;
    } catch (e) {
      debugPrint('Error toggling meal plan favorite: $e');
      return false;
    }
  }

  Future<bool> toggleMealPlanCompletion(String id, bool isCompleted) async {
    try {
      if (id.isEmpty) {
        debugPrint('Error: Meal plan ID cannot be empty');
        return false;
      }

      debugPrint('Toggling meal plan completion: $id to $isCompleted');

      final success = await _mealPlanService.toggleMealPlanCompletion(
        id,
        isCompleted,
      );

      if (success) {
        debugPrint(
          'Successfully toggled meal plan completion: $id to $isCompleted',
        );

        // If completed, create achievement
        if (isCompleted) {
          final mealPlan = userMealPlans.firstWhere((plan) => plan.id == id);
          final achievementId = await _achievementService
              .createMealPlanAchievement(id, mealPlan.name);

          if (achievementId != null) {
            debugPrint('Created achievement for completing meal plan: $id');

            // Show achievement popup
            achievementTitle.value = 'Meal Plan Completed!';
            achievementDescription.value =
                'You completed the ${mealPlan.name} meal plan';
            achievementPoints.value =
                AchievementService.MEAL_PLAN_COMPLETION_POINTS;
            showAchievementPopup.value = true;

            // Update user points
            await fetchUserPoints();
          }

          // Cancel notification if completed
          if (notificationsEnabled.value) {
            try {
              await _notificationService.cancelMealReminder(id);
              debugPrint('Cancelled reminder for completed meal plan: $id');
            } catch (e) {
              debugPrint(
                'Error cancelling reminder for completed meal plan: $e',
              );
            }
          }
        }
      } else {
        debugPrint('Failed to toggle meal plan completion: $id');
      }

      return success;
    } catch (e) {
      debugPrint('Error toggling meal plan completion: $e');
      return false;
    }
  }

  Future<bool> markMealItemConsumed(
    String mealPlanId,
    int itemIndex,
    bool isConsumed,
  ) async {
    try {
      if (mealPlanId.isEmpty) {
        debugPrint('Error: Meal plan ID cannot be empty');
        return false;
      }

      if (itemIndex < 0) {
        debugPrint('Error: Item index must be non-negative');
        return false;
      }

      debugPrint(
        'Marking meal item consumed: $mealPlanId, index: $itemIndex, consumed: $isConsumed',
      );

      final success = await _mealPlanService.markMealItemConsumed(
        mealPlanId,
        itemIndex,
        isConsumed,
      );

      if (success) {
        debugPrint(
          'Successfully marked meal item as consumed: $mealPlanId, index: $itemIndex',
        );

        // Check if all items in the meal plan are now consumed
        final mealPlan = userMealPlans.firstWhere(
          (plan) => plan.id == mealPlanId,
        );
        final allConsumed = mealPlan.items.every(
          (item) => item.isConsumed ?? false,
        );

        // If all items are consumed and meal plan is not already completed,
        // suggest completing the meal plan
        if (allConsumed && !mealPlan.isCompleted) {
          Get.snackbar(
            'All items consumed!',
            'All items in this meal plan have been consumed. Would you like to mark it as completed?',
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM,
            mainButton: TextButton(
              onPressed: () => toggleMealPlanCompletion(mealPlanId, true),
              child: const Text(
                'Complete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }
      } else {
        debugPrint(
          'Failed to mark meal item as consumed: $mealPlanId, index: $itemIndex',
        );
      }

      return success;
    } catch (e) {
      debugPrint('Error marking meal item as consumed: $e');
      return false;
    }
  }

  void hideAchievementPopup() {
    showAchievementPopup.value = false;
  }

  // Helper method to calculate daily totals
  Map<String, double> calculateDailyTotals() {
    double calories = 0;
    double proteins = 0;
    double carbs = 0;

    for (var mealPlan in todayMealPlans) {
      calories += mealPlan.totalCalories;
      proteins += mealPlan.totalProteins;
      carbs += mealPlan.totalCarbs;
    }

    return {'calories': calories, 'proteins': proteins, 'carbs': carbs};
  }

  // Debug method to get all meal plan information
  String getMealPlanDebugInfo() {
    StringBuffer buffer = StringBuffer();

    buffer.writeln('User Meal Plans (${userMealPlans.length}):');
    for (var plan in userMealPlans) {
      buffer.writeln(
        '- ${plan.name} (${plan.type}), ID: ${plan.id}, Date: ${plan.date}',
      );
      buffer.writeln(
        '  Reminder: ${plan.reminder ? "Yes" : "No"}, Time: ${plan.reminderTime}',
      );
    }

    buffer.writeln('\nToday Meal Plans (${todayMealPlans.length}):');
    for (var plan in todayMealPlans) {
      buffer.writeln(
        '- ${plan.name} (${plan.type}), ID: ${plan.id}, Date: ${plan.date}',
      );
      buffer.writeln(
        '  Reminder: ${plan.reminder ? "Yes" : "No"}, Time: ${plan.reminderTime}',
      );
    }

    // Add achievement info
    buffer.writeln('\nUser Achievements (${userAchievements.length}):');
    for (var achievement in userAchievements) {
      buffer.writeln(
        '- ${achievement.title}: ${achievement.points} points, Date: ${achievement.date}',
      );
    }

    buffer.writeln('\nTotal Points: ${userPoints.value}');

    // Add notification info
    buffer.writeln('\nNotifications:');
    buffer.writeln('- Initialized: ${notificationsInitialized.value}');
    buffer.writeln('- Enabled: ${notificationsEnabled.value}');

    return buffer.toString();
  }

  // Refresh all data
  Future<void> refreshAllData() async {
    debugPrint('Refreshing all data...');
    await fetchMeals();
    await fetchUserMealPlans();
    await fetchTodayMealPlans();
    await fetchUserPoints();
    await fetchUserAchievements();
    debugPrint('All data refreshed');
  }

  // Check all scheduled notifications
  Future<void> checkScheduledNotifications() async {
    if (!notificationsEnabled.value) {
      debugPrint('Notifications are not enabled');
      return;
    }

    try {
      if (debugMode.value) {
        await _notificationService.printPendingNotifications();
      }

      final notifications =
          await _notificationService.getScheduledNotifications();
      debugPrint('Found ${notifications.length} scheduled notifications');

      for (final notification in notifications) {
        final int? scheduledTime = notification['scheduledTime'];
        if (scheduledTime != null) {
          final DateTime notificationTime = DateTime.fromMillisecondsSinceEpoch(
            scheduledTime,
          );
          final String type = notification['type'] ?? 'unknown';
          final String title = notification['title'] ?? 'No title';

          debugPrint(
            'Notification: $title, Type: $type, Time: $notificationTime',
          );
        }
      }
    } catch (e) {
      debugPrint('Error checking scheduled notifications: $e');
    }
  }
}
