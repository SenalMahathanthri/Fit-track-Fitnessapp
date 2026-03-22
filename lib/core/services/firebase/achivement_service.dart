import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

import '../../../data/models/achievement.dart';

class AchievementService {
  final CollectionReference achievementsCollection = FirebaseFirestore.instance
      .collection('achievements');
  final CollectionReference usersCollection = FirebaseFirestore.instance
      .collection('users');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Points awarded for different achievements
  static const int MEAL_PLAN_COMPLETION_POINTS = 10;
  static const int FIRST_MEAL_OF_DAY_POINTS = 5;
  static const int STREAK_POINTS = 15;
  static const int BALANCED_MEAL_POINTS = 20;

  // Create achievement when meal plan is completed
  Future<String?> createMealPlanAchievement(
    String mealPlanId,
    String mealPlanName, [
    AchievementType type = AchievementType.meal,
  ]) async {
    try {
      String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        developer.log('Error: User not authenticated');
        return null;
      }

      // Check if achievement already exists for this meal plan
      QuerySnapshot existingAchievement =
          await achievementsCollection
              .where('userId', isEqualTo: userId)
              .where('type', isEqualTo: type.toString().split('.').last)
              .where('itemId', isEqualTo: mealPlanId)
              .get();

      // If achievement already exists, don't create a duplicate
      if (existingAchievement.docs.isNotEmpty) {
        developer.log('Achievement already exists for meal plan: $mealPlanId');
        return existingAchievement.docs.first.id;
      }

      // Determine achievement details based on type
      String title;
      String description;
      int points;

      switch (type) {
        case AchievementType.mealCompletion:
          title = 'Meal Completed';
          description = 'You completed your meal plan: $mealPlanName';
          points = MEAL_PLAN_COMPLETION_POINTS;
          break;
        case AchievementType.firstMealOfDay:
          title = 'Early Bird';
          description = 'You added your first meal of the day';
          points = FIRST_MEAL_OF_DAY_POINTS;
          break;
        case AchievementType.balancedMeal:
          title = 'Nutrition Master';
          description = 'Perfect balance of nutrients in your meal';
          points = BALANCED_MEAL_POINTS;
          break;
        default:
          title = 'Completed Meal Plan';
          description = 'You completed the $mealPlanName meal plan';
          points = MEAL_PLAN_COMPLETION_POINTS;
      }

      // Create achievement data
      Achievement achievement = Achievement(
        id: '',
        userId: userId,
        type: type,
        itemId: mealPlanId,
        title: title,
        description: description,
        date: DateTime.now(),
        points: points,
      );

      // Add achievement to Firestore
      DocumentReference docRef = await achievementsCollection.add(
        achievement.toFirestore(),
      );

      // Update user's total achievement points
      await _updateUserPoints(userId, achievement.points);

      developer.log(
        'Created meal plan achievement with ID: ${docRef.id}, points: ${achievement.points}',
      );
      return docRef.id;
    } catch (e) {
      developer.log('Error creating meal plan achievement: $e');
      return null;
    }
  }

  // Create achievement for first meal of the day
  Future<String?> createFirstMealOfDayAchievement() async {
    try {
      String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) return null;

      // Get today's date in YYYY-MM-DD format
      String todayFormatted = _getTodayFormatted();

      // Check if there's already a first meal achievement for today
      QuerySnapshot existingAchievement =
          await achievementsCollection
              .where('userId', isEqualTo: userId)
              .where('type', isEqualTo: 'first_meal')
              .where('itemId', isEqualTo: todayFormatted)
              .get();

      // If achievement already exists, don't create a duplicate
      if (existingAchievement.docs.isNotEmpty) {
        developer.log('First meal achievement already exists for today');
        return existingAchievement.docs.first.id;
      }

      // Create achievement data
      Achievement achievement = Achievement(
        id: '',
        userId: userId,
        type: AchievementType.firstMealOfDay,
        itemId: todayFormatted,
        title: 'First Meal of the Day',
        description: 'You\'ve planned your first meal of the day',
        date: DateTime.now(),
        points: FIRST_MEAL_OF_DAY_POINTS,
      );

      // Add achievement to Firestore
      DocumentReference docRef = await achievementsCollection.add(
        achievement.toFirestore(),
      );

      // Update user's total achievement points
      await _updateUserPoints(userId, achievement.points);

      developer.log(
        'Created first meal of day achievement with ID: ${docRef.id}, points: ${achievement.points}',
      );
      return docRef.id;
    } catch (e) {
      developer.log('Error creating first meal of day achievement: $e');
      return null;
    }
  }

  // Create achievement for maintaining a streak
  Future<String?> createStreakAchievement(int streakDays) async {
    try {
      String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) return null;

      // Get today's date in YYYY-MM-DD format
      String todayFormatted = _getTodayFormatted();

      // Check if there's already a streak achievement for this count
      QuerySnapshot existingAchievement =
          await achievementsCollection
              .where('userId', isEqualTo: userId)
              .where('type', isEqualTo: 'streak')
              .where('itemId', isEqualTo: 'streak_$streakDays')
              .get();

      // If achievement already exists, don't create a duplicate
      if (existingAchievement.docs.isNotEmpty) {
        developer.log('Streak achievement already exists for $streakDays days');
        return existingAchievement.docs.first.id;
      }

      // Create achievement data
      Achievement achievement = Achievement(
        id: '',
        userId: userId,
        type: AchievementType.streak,
        itemId: 'streak_$streakDays',
        title: '$streakDays Day Streak!',
        description:
            'You\'ve maintained your meal planning streak for $streakDays days',
        date: DateTime.now(),
        points: STREAK_POINTS,
      );

      // Add achievement to Firestore
      DocumentReference docRef = await achievementsCollection.add(
        achievement.toFirestore(),
      );

      // Update user's total achievement points
      await _updateUserPoints(userId, achievement.points);

      developer.log(
        'Created streak achievement with ID: ${docRef.id}, points: ${achievement.points}',
      );
      return docRef.id;
    } catch (e) {
      developer.log('Error creating streak achievement: $e');
      return null;
    }
  }

  // Create achievement for balanced meal
  Future<String?> checkAndAwardBalancedMealAchievement(
    String mealPlanId,
    String mealPlanName,
    double proteins,
    double carbs,
    double calories,
  ) async {
    try {
      String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) return null;

      // Check if achievement already exists for this meal plan
      QuerySnapshot existingAchievement =
          await achievementsCollection
              .where('userId', isEqualTo: userId)
              .where('type', isEqualTo: 'balanced_meal')
              .where('itemId', isEqualTo: mealPlanId)
              .get();

      // If achievement already exists, don't create a duplicate
      if (existingAchievement.docs.isNotEmpty) {
        developer.log(
          'Balanced meal achievement already exists for: $mealPlanId',
        );
        return existingAchievement.docs.first.id;
      }

      // Check if the meal has a good balance of macronutrients
      // A balanced meal typically has:
      // - 20-30% of calories from protein
      // - 45-65% of calories from carbs

      // Calculate percentages (1g protein = 4 calories, 1g carbs = 4 calories)
      double proteinCalories = proteins * 4;
      double carbCalories = carbs * 4;

      double proteinPercentage = (proteinCalories / calories) * 100;
      double carbPercentage = (carbCalories / calories) * 100;

      // Check if within ideal ranges
      bool isBalanced =
          (proteinPercentage >= 20 && proteinPercentage <= 30) &&
          (carbPercentage >= 45 && carbPercentage <= 65);

      if (!isBalanced) {
        // Not a balanced meal
        return null;
      }

      // Create achievement data
      Achievement achievement = Achievement(
        id: '',
        userId: userId,
        type: AchievementType.balancedMeal,
        itemId: mealPlanId,
        title: 'Perfectly Balanced Meal',
        description: 'Your $mealPlanName has the perfect balance of nutrients',
        date: DateTime.now(),
        points: BALANCED_MEAL_POINTS,
      );

      // Add achievement to Firestore
      DocumentReference docRef = await achievementsCollection.add(
        achievement.toFirestore(),
      );

      // Update user's total achievement points
      await _updateUserPoints(userId, achievement.points);

      developer.log(
        'Created balanced meal achievement with ID: ${docRef.id}, points: ${achievement.points}',
      );
      return docRef.id;
    } catch (e) {
      developer.log('Error creating balanced meal achievement: $e');
      return null;
    }
  }

  // Create workout achievement
  Future<String?> createWorkoutAchievement(
    String workoutPlanId,
    String workoutName,
    int calories,
  ) async {
    try {
      String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) return null;

      // Check if achievement already exists for this workout
      QuerySnapshot existingAchievement =
          await achievementsCollection
              .where('userId', isEqualTo: userId)
              .where('type', isEqualTo: 'workout')
              .where('itemId', isEqualTo: workoutPlanId)
              .get();

      // If achievement already exists, don't create a duplicate
      if (existingAchievement.docs.isNotEmpty) {
        developer.log('Achievement already exists for workout: $workoutPlanId');
        return existingAchievement.docs.first.id;
      }

      // Calculate points based on calories burned
      int pointsAwarded = 0;
      if (calories < 100) {
        pointsAwarded = 5;
      } else if (calories < 300) {
        pointsAwarded = 10;
      } else if (calories < 500) {
        pointsAwarded = 15;
      } else {
        pointsAwarded = 20;
      }

      // Create achievement data
      Achievement achievement = Achievement(
        id: '',
        userId: userId,
        type: AchievementType.workout,
        itemId: workoutPlanId,
        title: 'Completed Workout',
        description:
            'You completed the $workoutName workout and burned $calories calories',
        date: DateTime.now(),
        points: pointsAwarded,
      );

      // Add achievement to Firestore
      DocumentReference docRef = await achievementsCollection.add(
        achievement.toFirestore(),
      );

      // Update user's total achievement points
      await _updateUserPoints(userId, achievement.points);

      developer.log(
        'Created workout achievement with ID: ${docRef.id} for $workoutName, points: $pointsAwarded',
      );
      return docRef.id;
    } catch (e) {
      developer.log('Error creating workout achievement: $e');
      return null;
    }
  }

  // Create water achievement
  Future<String?> createWaterAchievement() async {
    try {
      String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) return null;

      // Check if there's already a water achievement for today
      String todayFormatted = _getTodayFormatted();

      QuerySnapshot existingAchievement =
          await achievementsCollection
              .where('userId', isEqualTo: userId)
              .where('type', isEqualTo: 'water')
              .where('itemId', isEqualTo: todayFormatted)
              .get();

      // If achievement already exists, don't create a duplicate
      if (existingAchievement.docs.isNotEmpty) {
        developer.log('Water achievement already exists for today');
        return existingAchievement.docs.first.id;
      }

      // Create achievement data
      Achievement achievement = Achievement(
        id: '',
        userId: userId,
        type: AchievementType.water,
        itemId: todayFormatted,
        title: 'Daily Water Goal',
        description: 'Completed your daily water intake goal of 2.5L',
        date: DateTime.now(),
        points: 10,
      );

      // Add achievement to Firestore
      DocumentReference docRef = await achievementsCollection.add(
        achievement.toFirestore(),
      );

      // Update user's total achievement points
      await _updateUserPoints(userId, achievement.points);

      developer.log(
        'Created water achievement with ID: ${docRef.id}, points: ${achievement.points}',
      );
      return docRef.id;
    } catch (e) {
      developer.log('Error creating water achievement: $e');
      return null;
    }
  }

  // Get all achievements for current user
  Future<List<Achievement>> getUserAchievements() async {
    try {
      String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) return [];

      QuerySnapshot querySnapshot =
          await achievementsCollection
              .where('userId', isEqualTo: userId)
              .orderBy('date', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => Achievement.fromFirestore(doc))
          .toList();
    } catch (e) {
      developer.log('Error fetching user achievements: $e');
      return [];
    }
  }

  // Get achievements by type
  Future<List<Achievement>> getAchievementsByType(AchievementType type) async {
    try {
      String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) return [];

      QuerySnapshot querySnapshot =
          await achievementsCollection
              .where('userId', isEqualTo: userId)
              .where('type', isEqualTo: type.toString().split('.').last)
              .orderBy('date', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => Achievement.fromFirestore(doc))
          .toList();
    } catch (e) {
      developer.log('Error fetching achievements by type: $e');
      return [];
    }
  }

  // Update user's total achievement points
  Future<void> _updateUserPoints(String userId, int points) async {
    try {
      // Get current user points
      DocumentSnapshot userDoc = await usersCollection.doc(userId).get();
      int currentPoints = 0;
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        // Check both fields for backward compatibility
        if (userData.containsKey('achievementPoints')) {
          currentPoints = userData['achievementPoints'] ?? 0;
        } else if (userData.containsKey('points')) {
          currentPoints = userData['points'] ?? 0;
        }
      }

      // Update points in both fields for compatibility
      await usersCollection.doc(userId).set({
        'achievementPoints': currentPoints + points,
        'points': currentPoints + points,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      developer.log(
        'Updated user points: $currentPoints → ${currentPoints + points}',
      );
    } catch (e) {
      developer.log('Error updating user points: $e');
      throw Exception('Failed to update user points: $e');
    }
  }

  // Update user points with a given amount
  Future<bool> updateUserPoints(int points) async {
    try {
      String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) return false;

      await _updateUserPoints(userId, points);
      return true;
    } catch (e) {
      developer.log('Error updating user points directly: $e');
      return false;
    }
  }

  // Get user's total achievement points
  Future<int> getUserPoints() async {
    try {
      String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) return 0;

      DocumentSnapshot userDoc = await usersCollection.doc(userId).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        // Check both fields for backward compatibility
        if (userData.containsKey('achievementPoints')) {
          return userData['achievementPoints'] ?? 0;
        } else if (userData.containsKey('points')) {
          return userData['points'] ?? 0;
        }
      }
      return 0;
    } catch (e) {
      developer.log('Error getting user points: $e');
      return 0;
    }
  }

  // Check and award streak achievements
  Future<void> checkAndAwardStreakAchievement() async {
    try {
      String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) return;

      // Get user streak from Firestore
      DocumentSnapshot userDoc = await usersCollection.doc(userId).get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        if (userData.containsKey('streak')) {
          int currentStreak = userData['streak'] ?? 0;

          // Check if we need to award a streak achievement
          // Award at 3, 7, 14, 30, 60, 90 days
          if ([3, 7, 14, 30, 60, 90].contains(currentStreak)) {
            await createStreakAchievement(currentStreak);
          }
        }
      }
    } catch (e) {
      developer.log('Error checking and awarding streak achievement: $e');
    }
  }

  // Get recent achievements for the last 7 days
  Future<List<Achievement>> getRecentAchievements() async {
    try {
      String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) return [];

      // Calculate date one week ago
      DateTime oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));

      QuerySnapshot querySnapshot =
          await achievementsCollection
              .where('userId', isEqualTo: userId)
              .where(
                'date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(oneWeekAgo),
              )
              .orderBy('date', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => Achievement.fromFirestore(doc))
          .toList();
    } catch (e) {
      developer.log('Error fetching recent achievements: $e');
      return [];
    }
  }

  // Get recent achievements by type
  Future<List<Achievement>> getRecentAchievementsByType(
    AchievementType type,
  ) async {
    try {
      String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) return [];

      // Calculate date one week ago
      DateTime oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));

      QuerySnapshot querySnapshot =
          await achievementsCollection
              .where('userId', isEqualTo: userId)
              .where('type', isEqualTo: type.toString().split('.').last)
              .where(
                'date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(oneWeekAgo),
              )
              .orderBy('date', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => Achievement.fromFirestore(doc))
          .toList();
    } catch (e) {
      developer.log('Error fetching recent achievements by type: $e');
      return [];
    }
  }

  // Get workout achievements from the past week
  Future<List<Achievement>> getRecentWorkoutAchievements() async {
    return getRecentAchievementsByType(AchievementType.workout);
  }

  // Calculate total calories burned from completed workouts
  Future<int> getTotalCaloriesBurned() async {
    try {
      String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) return 0;

      QuerySnapshot querySnapshot =
          await achievementsCollection
              .where('userId', isEqualTo: userId)
              .where(
                'type',
                isEqualTo: AchievementType.workout.toString().split('.').last,
              )
              .get();

      int totalCalories = 0;
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('metadata') &&
            data['metadata'] is Map &&
            (data['metadata'] as Map).containsKey('calories')) {
          totalCalories += (data['metadata']['calories'] as int);
        }
      }

      return totalCalories;
    } catch (e) {
      developer.log('Error calculating total calories burned: $e');
      return 0;
    }
  }

  // Helper method to get today's date in YYYY-MM-DD format
  String _getTodayFormatted() {
    final now = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(now);
  }

  // Stream of achievements for real-time updates
  Stream<List<Achievement>> achievementsStream() {
    String userId = _auth.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      return Stream.value([]);
    }

    return achievementsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Achievement.fromFirestore(doc))
              .toList();
        })
        .handleError((error) {
          developer.log('Error in achievements stream: $error');
          return [];
        });
  }

  // Stream of user achievements for real-time updates
  Stream<List<Achievement>> userAchievementsStream() {
    String userId = _auth.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      return Stream.value([]);
    }

    return achievementsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Achievement.fromFirestore(doc))
              .toList();
        })
        .handleError((error) {
          developer.log('Error in user achievements stream: $error');
          return [];
        });
  }

  // Get today's achievements
  Future<List<Achievement>> getTodayAchievements() async {
    try {
      String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) return [];

      // Create date range for today
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      QuerySnapshot querySnapshot =
          await achievementsCollection
              .where('userId', isEqualTo: userId)
              .where(
                'date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
              )
              .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
              .orderBy('date', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => Achievement.fromFirestore(doc))
          .toList();
    } catch (e) {
      developer.log('Error fetching today\'s achievements: $e');
      return [];
    }
  }
}
