// lib/core/services/firebase/workout_plan_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/workout_plan.dart';

class WorkoutPlanService {
  final CollectionReference workoutPlansCollection = FirebaseFirestore.instance
      .collection('workout_plans');
  final CollectionReference achievementsCollection = FirebaseFirestore.instance
      .collection('achievements');
  final CollectionReference usersCollection = FirebaseFirestore.instance
      .collection('users');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId {
    final user = _auth.currentUser;
    if (user == null) {
      print('Warning: No authenticated user found in WorkoutPlanService.');
    }
    return user?.uid;
  }

  // Update user points
  Future<bool> _updateUserPoints(String userId, int points) async {
    try {
      // Get the user document
      DocumentSnapshot userDoc = await usersCollection.doc(userId).get();

      if (userDoc.exists) {
        // User document exists, update the points
        int currentPoints = 0;
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        if (userData.containsKey('points')) {
          currentPoints = userData['points'] as int;
        }

        // Add the new points
        int updatedPoints = currentPoints + points;

        // Update the user document
        await usersCollection.doc(userId).update({'points': updatedPoints});
        print('Updated user points: $currentPoints -> $updatedPoints');

        return true;
      } else {
        // User document doesn't exist, create it
        await usersCollection.doc(userId).set({
          'userId': userId,
          'points': points,
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('Created user document with initial points: $points');

        return true;
      }
    } catch (e) {
      print('Error updating user points: $e');
      return false;
    }
  }

  // Add new workout plan with repetition data
  Future<String?> addWorkoutPlanWithReps(
    WorkoutPlan workoutPlan,
    List<Map<String, dynamic>> workoutReps, {
    String? targetUserId,
  }) async {
    try {
      String? userId = targetUserId ?? currentUserId;
      if (userId == null || userId.isEmpty) {
        print('Error: User not authenticated in addWorkoutPlanWithReps');
        return null;
      }

      WorkoutPlan planWithUserId = workoutPlan.copyWith(userId: userId);

      if (planWithUserId.name.isEmpty) {
        print('Error: Workout plan name cannot be empty');
        return null;
      }

      Map<String, dynamic> planData = planWithUserId.toFirestore();

      // Add the workout reps data
      planData['workoutReps'] = workoutReps;

      DocumentReference docRef = await workoutPlansCollection.add(planData);
      print('Added workout plan with reps, ID: ${docRef.id}');

      return docRef.id;
    } catch (e) {
      print('Error adding workout plan with reps: $e');
      return null;
    }
  }

  // Add new workout plan (legacy method)
  Future<String?> addWorkoutPlan(WorkoutPlan workoutPlan) async {
    try {
      String? userId = currentUserId;
      if (userId == null || userId.isEmpty) {
        print('Error: User not authenticated in addWorkoutPlan');
        return null;
      }

      WorkoutPlan planWithUserId = workoutPlan.copyWith(userId: userId);

      if (planWithUserId.name.isEmpty) {
        print('Error: Workout plan name cannot be empty');
        return null;
      }

      Map<String, dynamic> planData = planWithUserId.toFirestore();

      DocumentReference docRef = await workoutPlansCollection.add(planData);
      print('Added workout plan with ID: ${docRef.id}');

      return docRef.id;
    } catch (e) {
      print('Error adding workout plan: $e');
      return null;
    }
  }

  // Get all workout plans for current user
  Future<List<WorkoutPlan>> getUserWorkoutPlans() async {
    try {
      String? userId = currentUserId;
      if (userId == null || userId.isEmpty) {
        print('Error: User not authenticated in getUserWorkoutPlans');
        return [];
      }

      // Create a composite index in Firebase for this query
      QuerySnapshot querySnapshot =
          await workoutPlansCollection
              .where('userId', isEqualTo: userId)
              .orderBy('date', descending: true)
              .get();

      List<WorkoutPlan> plans = [];
      for (var doc in querySnapshot.docs) {
        try {
          plans.add(WorkoutPlan.fromFirestore(doc));
        } catch (e) {
          print(
            'Error parsing workout plan from Firestore: $e for document: ${doc.id}',
          );
        }
      }

      return plans;
    } catch (e) {
      print('Error fetching workout plans: $e');
      return [];
    }
  }

  // Get workout plans for a specific date
  Future<List<WorkoutPlan>> getWorkoutPlansForDate(DateTime date) async {
    try {
      String? userId = currentUserId;
      if (userId == null || userId.isEmpty) {
        print('Error: User not authenticated in getWorkoutPlansForDate');
        return [];
      }

      // Create date range for the specified day
      DateTime startOfDay = DateTime(date.year, date.month, date.day);
      DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      // Create a composite index in Firebase for this query
      QuerySnapshot querySnapshot =
          await workoutPlansCollection
              .where('userId', isEqualTo: userId)
              .where(
                'date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
              )
              .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
              .get();

      List<WorkoutPlan> plans = [];
      for (var doc in querySnapshot.docs) {
        try {
          plans.add(WorkoutPlan.fromFirestore(doc));
        } catch (e) {
          print(
            'Error parsing workout plan from Firestore: $e for document: ${doc.id}',
          );
        }
      }

      return plans;
    } catch (e) {
      print('Error fetching workout plans for date: $e');
      return [];
    }
  }

  // Get a single workout plan by ID
  Future<WorkoutPlan?> getWorkoutPlanById(String id) async {
    try {
      if (id.isEmpty) {
        print('Error: Workout plan ID cannot be empty');
        return null;
      }

      DocumentSnapshot doc = await workoutPlansCollection.doc(id).get();
      if (!doc.exists) {
        print('Error: Workout plan not found: $id');
        return null;
      }

      return WorkoutPlan.fromFirestore(doc);
    } catch (e) {
      print('Error getting workout plan by ID: $e');
      return null;
    }
  }

  // Update workout plan with rep data
  Future<bool> updateWorkoutPlanWithReps(
    WorkoutPlan workoutPlan,
    List<Map<String, dynamic>> workoutReps,
  ) async {
    try {
      String? userId = currentUserId;
      if (userId == null || userId.isEmpty) {
        print('Error: User not authenticated in updateWorkoutPlanWithReps');
        return false;
      }

      if (workoutPlan.id.isEmpty) {
        print('Error: Workout plan ID cannot be empty');
        return false;
      }

      // Verify this workout plan belongs to the current user before updating
      DocumentSnapshot doc =
          await workoutPlansCollection.doc(workoutPlan.id).get();
      if (!doc.exists) {
        print('Error: Workout plan not found: ${workoutPlan.id}');
        return false;
      }

      WorkoutPlan existingPlan = WorkoutPlan.fromFirestore(doc);
      if (existingPlan.userId != userId) {
        print(
          'Error: User does not have permission to update this workout plan',
        );
        return false;
      }

      WorkoutPlan updatedPlan = workoutPlan.copyWith(
        userId: userId,
        workoutReps: workoutReps,
      );
      Map<String, dynamic> planData = updatedPlan.toFirestore();

      await workoutPlansCollection.doc(workoutPlan.id).update(planData);
      print('Updated workout plan with reps: ${workoutPlan.id}');

      return true;
    } catch (e) {
      print('Error updating workout plan with reps: $e');
      return false;
    }
  }

  // Update workout plan
  Future<bool> updateWorkoutPlan(WorkoutPlan workoutPlan) async {
    try {
      String? userId = currentUserId;
      if (userId == null || userId.isEmpty) {
        print('Error: User not authenticated in updateWorkoutPlan');
        return false;
      }

      if (workoutPlan.id.isEmpty) {
        print('Error: Workout plan ID cannot be empty');
        return false;
      }

      // Verify this workout plan belongs to the current user before updating
      DocumentSnapshot doc =
          await workoutPlansCollection.doc(workoutPlan.id).get();
      if (!doc.exists) {
        print('Error: Workout plan not found: ${workoutPlan.id}');
        return false;
      }

      WorkoutPlan existingPlan = WorkoutPlan.fromFirestore(doc);
      if (existingPlan.userId != userId) {
        print(
          'Error: User does not have permission to update this workout plan',
        );
        return false;
      }

      WorkoutPlan updatedPlan = workoutPlan.copyWith(userId: userId);
      Map<String, dynamic> planData = updatedPlan.toFirestore();

      await workoutPlansCollection.doc(workoutPlan.id).update(planData);
      print('Updated workout plan: ${workoutPlan.id}');

      return true;
    } catch (e) {
      print('Error updating workout plan: $e');
      return false;
    }
  }

  // Delete workout plan
  Future<bool> deleteWorkoutPlan(String id) async {
    try {
      String? userId = currentUserId;
      if (userId == null || userId.isEmpty) {
        print('Error: User not authenticated in deleteWorkoutPlan');
        return false;
      }

      // Verify this workout plan belongs to the current user before deleting
      DocumentSnapshot doc = await workoutPlansCollection.doc(id).get();
      if (!doc.exists) {
        print('Error: Workout plan not found: $id');
        return false;
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != userId) {
        print(
          'Error: User does not have permission to delete this workout plan',
        );
        return false;
      }

      await workoutPlansCollection.doc(id).delete();
      print('Deleted workout plan: $id');

      return true;
    } catch (e) {
      print('Error deleting workout plan: $e');
      return false;
    }
  }

  // Toggle workout plan finished status
  Future<bool> toggleWorkoutPlanFinished(String id, bool isFinished) async {
    try {
      String? userId = currentUserId;
      if (userId == null || userId.isEmpty) {
        print('Error: User not authenticated in toggleWorkoutPlanFinished');
        return false;
      }

      // Verify this workout plan belongs to the current user
      DocumentSnapshot doc = await workoutPlansCollection.doc(id).get();
      if (!doc.exists) {
        print('Error: Workout plan not found: $id');
        return false;
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != userId) {
        print(
          'Error: User does not have permission to modify this workout plan',
        );
        return false;
      }

      await workoutPlansCollection.doc(id).update({'isFinished': isFinished});
      print('Toggled workout plan finished: $id to $isFinished');

      return true;
    } catch (e) {
      print('Error toggling workout plan finished: $e');
      return false;
    }
  }

  // Toggle workout plan favorite status
  Future<bool> toggleWorkoutPlanFavorite(String id, bool isFavorite) async {
    try {
      String? userId = currentUserId;
      if (userId == null || userId.isEmpty) {
        print('Error: User not authenticated in toggleWorkoutPlanFavorite');
        return false;
      }

      // Verify this workout plan belongs to the current user
      DocumentSnapshot doc = await workoutPlansCollection.doc(id).get();
      if (!doc.exists) {
        print('Error: Workout plan not found: $id');
        return false;
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != userId) {
        print(
          'Error: User does not have permission to modify this workout plan',
        );
        return false;
      }

      await workoutPlansCollection.doc(id).update({'isFavorite': isFavorite});
      print('Toggled workout plan favorite: $id to $isFavorite');

      return true;
    } catch (e) {
      print('Error toggling workout plan favorite: $e');
      return false;
    }
  }

  // Get real-time updates for workout plans
  Stream<List<WorkoutPlan>> workoutPlansStream() {
    String? userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      print('Error: User not authenticated in workoutPlansStream');
      return Stream.value([]);
    }

    // Create a composite index in Firebase for this query
    return workoutPlansCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          List<WorkoutPlan> plans = [];
          for (var doc in snapshot.docs) {
            try {
              plans.add(WorkoutPlan.fromFirestore(doc));
            } catch (e) {
              print(
                'Error parsing workout plan in stream: $e for document: ${doc.id}',
              );
            }
          }
          return plans;
        })
        .handleError((error) {
          print('Error in workout plans stream: $error');
          return [];
        });
  }

  // Get real-time updates for today's workout plans
  Stream<List<WorkoutPlan>> todayWorkoutPlansStream() {
    String? userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      print('Error: User not authenticated in todayWorkoutPlansStream');
      return Stream.value([]);
    }

    // Create date range for today
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    // Create a composite index in Firebase for this query
    return workoutPlansCollection
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) {
          List<WorkoutPlan> plans = [];
          for (var doc in snapshot.docs) {
            try {
              plans.add(WorkoutPlan.fromFirestore(doc));
            } catch (e) {
              print(
                'Error parsing workout plan in today\'s stream: $e for document: ${doc.id}',
              );
            }
          }
          return plans;
        })
        .handleError((error) {
          print('Error in today\'s workout plans stream: $error');
          return [];
        });
  }

  // Get user points from Firestore
  Future<int> getUserPoints() async {
    try {
      String? userId = currentUserId;
      if (userId == null || userId.isEmpty) {
        print('Error: User not authenticated in getUserPoints');
        return 0;
      }

      DocumentSnapshot userDoc = await usersCollection.doc(userId).get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        if (userData.containsKey('points')) {
          return userData['points'] as int;
        }
      }

      return 0;
    } catch (e) {
      print('Error getting user points: $e');
      return 0;
    }
  }

  // Create workout achievement
  Future<String?> createWorkoutAchievement(
    String workoutPlanId,
    String workoutName,
    int calories,
  ) async {
    try {
      String? userId = currentUserId;
      if (userId == null || userId.isEmpty) {
        print('Error: User not authenticated in createWorkoutAchievement');
        return null;
      }

      // Define point values based on calories burned
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

      // Create achievement document
      DocumentReference docRef = await achievementsCollection.add({
        'userId': userId,
        'title': 'Completed Workout',
        'description': 'Completed the $workoutName workout',
        'points': pointsAwarded,
        'type': 'workout',
        'relatedId': workoutPlanId,
        'calories': calories,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Add points to user
      await _updateUserPoints(userId, pointsAwarded);

      print('Created workout achievement with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error creating workout achievement: $e');
      return null;
    }
  }

  // Update workout reps for a workout plan
  Future<bool> updateWorkoutReps(
    String planId,
    List<Map<String, dynamic>> workoutReps,
  ) async {
    try {
      String? userId = currentUserId;
      if (userId == null || userId.isEmpty) {
        print('Error: User not authenticated in updateWorkoutReps');
        return false;
      }

      // Get the workout plan
      WorkoutPlan? workoutPlan = await getWorkoutPlanById(planId);
      if (workoutPlan == null) {
        print('Error: Workout plan not found: $planId');
        return false;
      }

      // Verify ownership
      if (workoutPlan.userId != userId) {
        print(
          'Error: User does not have permission to modify this workout plan',
        );
        return false;
      }

      // Update only the reps field
      await workoutPlansCollection.doc(planId).update({
        'workoutReps': workoutReps,
      });

      print('Updated workout reps for plan: $planId');
      return true;
    } catch (e) {
      print('Error updating workout reps: $e');
      return false;
    }
  }
}
