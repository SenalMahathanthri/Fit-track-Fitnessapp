import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/meal_model.dart';
import '../../../data/models/meal_plan.dart';

class MealPlanService {
  final CollectionReference mealPlansCollection = FirebaseFirestore.instance
      .collection('meal_plans');
  final CollectionReference achievementsCollection = FirebaseFirestore.instance
      .collection('achievements');
  final CollectionReference usersCollection = FirebaseFirestore.instance
      .collection('users');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID with a more robust implementation
  String? get currentUserId {
    final user = _auth.currentUser;
    if (user == null) {
      print('Warning: No authenticated user found.');
    }
    return user?.uid;
  }

  // Get all meal plans for current user
  Future<List<MealPlan>> getUserMealPlans() async {
    try {
      String? userId = currentUserId;
      if (userId == null || userId.isEmpty) {
        print('Error: User not authenticated in getUserMealPlans');
        return [];
      }

      print('Fetching meal plans for user: $userId');
      QuerySnapshot querySnapshot =
          await mealPlansCollection
              .where('userId', isEqualTo: userId)
              .get();

      print('Found ${querySnapshot.docs.length} meal plans');

      List<MealPlan> plans = [];
      for (var doc in querySnapshot.docs) {
        try {
          plans.add(MealPlan.fromFirestore(doc));
        } catch (e) {
          print(
            'Error parsing meal plan from Firestore: $e for document: ${doc.id}',
          );
        }
      }
      
      // Sort in memory to avoid requiring a composite index
      plans.sort((a, b) => b.date.compareTo(a.date));

      return plans;
    } catch (e) {
      print('Error fetching meal plans: $e');
      return [];
    }
  }

  // Get meal plans for a specific date
  Future<List<MealPlan>> getMealPlansForDate(DateTime date) async {
    try {
      String? userId = currentUserId;
      if (userId == null || userId.isEmpty) {
        print('Error: User not authenticated in getMealPlansForDate');
        return [];
      }

      DateTime startOfDay = DateTime(date.year, date.month, date.day);
      DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      print('Fetching meal plans for date: ${startOfDay.toString()} to ${endOfDay.toString()}');

      QuerySnapshot querySnapshot =
          await mealPlansCollection
              .where('userId', isEqualTo: userId)
              .get();

      List<MealPlan> plans = [];
      for (var doc in querySnapshot.docs) {
        try {
          MealPlan plan = MealPlan.fromFirestore(doc);
          // Filter by date in memory
          if (plan.date.isAfter(startOfDay.subtract(const Duration(milliseconds: 1))) && 
              plan.date.isBefore(endOfDay.add(const Duration(milliseconds: 1)))) {
            plans.add(plan);
          }
        } catch (e) {
          print(
            'Error parsing meal plan from Firestore: $e for document: ${doc.id}',
          );
        }
      }
      
      plans.sort((a, b) => a.date.compareTo(b.date));
      return plans;
    } catch (e) {
      print('Error fetching meal plans for date: $e');
      return [];
    }
  }

  // Add new meal plan with data validation
  Future<String?> addMealPlan(MealPlan mealPlan, {String? targetUserId}) async {
    try {
      // Ensure current user ID is set
      String? currentUserIdStr = currentUserId;
      if (currentUserIdStr == null || currentUserIdStr.isEmpty) {
        print('Error: User not authenticated in addMealPlan');
        return null;
      }

      // If a targetUserId is provided (e.g. assigned by Coach), use that user's ID
      // Otherwise, default to the current user's ID
      String userIdToUse = targetUserId ?? currentUserIdStr;

      // Create a new meal plan with the current user ID
      MealPlan planWithUserId = mealPlan.copyWith(userId: userIdToUse);

      // Validate the meal plan data
      if (planWithUserId.name.isEmpty) {
        print('Error: Meal plan name cannot be empty');
        return null;
      }

      // Convert to Firestore data
      Map<String, dynamic> planData = planWithUserId.toFirestore();

      print(
        'Adding meal plan: ${planWithUserId.name} with ${planWithUserId.items.length} items',
      );
      DocumentReference docRef = await mealPlansCollection.add(planData);
      print('Added meal plan with ID: ${docRef.id}');

      return docRef.id;
    } catch (e) {
      print('Error adding meal plan: $e');
      return null;
    }
  }

  // Update meal plan with error handling
  Future<bool> updateMealPlan(MealPlan mealPlan) async {
    try {
      String? userId = currentUserId;
      if (userId == null || userId.isEmpty) {
        print('Error: User not authenticated in updateMealPlan');
        return false;
      }

      // Validate the meal plan data
      if (mealPlan.id.isEmpty) {
        print('Error: Meal plan ID cannot be empty');
        return false;
      }

      // Verify this meal plan belongs to the current user before updating
      DocumentSnapshot doc = await mealPlansCollection.doc(mealPlan.id).get();
      if (!doc.exists) {
        print('Error: Meal plan not found: ${mealPlan.id}');
        return false;
      }

      MealPlan existingPlan = MealPlan.fromFirestore(doc);
      if (existingPlan.userId != userId) {
        print('Error: User does not have permission to update this meal plan');
        return false;
      }

      // Ensure userId is set correctly when updating
      MealPlan updatedPlan = mealPlan.copyWith(userId: userId);
      Map<String, dynamic> planData = updatedPlan.toFirestore();

      print('Updating meal plan: ${mealPlan.id}');
      await mealPlansCollection.doc(mealPlan.id).update(planData);
      print('Updated meal plan successfully');

      return true;
    } catch (e) {
      print('Error updating meal plan: $e');
      return false;
    }
  }

  // Delete meal plan with better error handling
  Future<bool> deleteMealPlan(String id) async {
    try {
      String? userId = currentUserId;
      if (userId == null || userId.isEmpty) {
        print('Error: User not authenticated in deleteMealPlan');
        return false;
      }

      // Verify this meal plan belongs to the current user before deleting
      DocumentSnapshot doc = await mealPlansCollection.doc(id).get();
      if (!doc.exists) {
        print('Error: Meal plan not found: $id');
        return false;
      }

      try {
        MealPlan existingPlan = MealPlan.fromFirestore(doc);
        if (existingPlan.userId != userId) {
          print(
            'Error: User does not have permission to delete this meal plan',
          );
          return false;
        }
      } catch (e) {
        print('Error parsing meal plan during deletion check: $e');
        // If we can't parse it, we'll still allow deletion if we can verify userId directly
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['userId'] != userId) {
          print(
            'Error: User does not have permission to delete this meal plan',
          );
          return false;
        }
      }

      print('Deleting meal plan: $id');
      await mealPlansCollection.doc(id).delete();
      print('Deleted meal plan successfully');

      return true;
    } catch (e) {
      print('Error deleting meal plan: $e');
      return false;
    }
  }

  // Toggle meal plan completed status with improved error handling
  Future<bool> toggleMealPlanCompletion(String id, bool isCompleted) async {
    try {
      String? userId = currentUserId;
      if (userId == null || userId.isEmpty) {
        print('Error: User not authenticated in toggleMealPlanCompletion');
        return false;
      }

      // Verify this meal plan belongs to the current user
      DocumentSnapshot doc = await mealPlansCollection.doc(id).get();
      if (!doc.exists) {
        print('Error: Meal plan not found: $id');
        return false;
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != userId) {
        print('Error: User does not have permission to modify this meal plan');
        return false;
      }

      print('Toggling meal plan completion: $id to $isCompleted');
      await mealPlansCollection.doc(id).update({'isCompleted': isCompleted});
      print('Updated meal plan completion status successfully');

      // If the meal plan is being marked as completed, create an achievement
      if (isCompleted) {
        try {
          // Get meal plan details for the achievement
          MealPlan mealPlan = MealPlan.fromFirestore(doc);
          await createMealAchievement(id, mealPlan.name);
        } catch (e) {
          print('Error creating meal achievement: $e');
          // Still return true since the meal plan was marked as completed
        }
      }

      return true;
    } catch (e) {
      print('Error toggling meal plan completion: $e');
      return false;
    }
  }

  // Create achievement when meal plan is completed
  Future<String?> createMealAchievement(
    String mealPlanId,
    String mealPlanName,
  ) async {
    try {
      String? userId = currentUserId;
      if (userId == null || userId.isEmpty) {
        print('Error: User not authenticated in createMealAchievement');
        return null;
      }

      // Check if achievement already exists for this meal plan
      QuerySnapshot existingAchievement =
          await achievementsCollection
              .where('userId', isEqualTo: userId)
              .where('type', isEqualTo: 'meal')
              .where('itemId', isEqualTo: mealPlanId)
              .get();

      // If achievement already exists, don't create a duplicate
      if (existingAchievement.docs.isNotEmpty) {
        print('Achievement already exists for meal plan: $mealPlanId');
        return existingAchievement.docs.first.id;
      }

      // Create achievement document
      DocumentReference docRef = await achievementsCollection.add({
        'userId': userId,
        'type': 'meal',
        'itemId': mealPlanId,
        'title': 'Completed Meal Plan',
        'description': 'You completed the $mealPlanName meal plan',
        'date': Timestamp.fromDate(DateTime.now()),
        'points': 10,
      });

      // Update user's total achievement points
      await _updateUserPoints(userId, 10);

      print('Created meal achievement with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error creating meal achievement: $e');
      return null;
    }
  }

  // Update user's achievement points
  Future<bool> _updateUserPoints(String userId, int points) async {
    try {
      // Get current user points
      DocumentSnapshot userDoc = await usersCollection.doc(userId).get();
      int currentPoints = 0;

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        if (userData.containsKey('points')) {
          currentPoints = userData['points'] as int;
        }
      }

      // Add the new points
      int updatedPoints = currentPoints + points;

      // Update or create user document
      await usersCollection.doc(userId).set({
        'points': updatedPoints,
      }, SetOptions(merge: true));

      print('Updated user points: $currentPoints -> $updatedPoints');
      return true;
    } catch (e) {
      print('Error updating user points: $e');
      return false;
    }
  }

  // Toggle meal plan favorite status with improved error handling
  Future<bool> toggleMealPlanFavorite(String id, bool isFavorite) async {
    try {
      String? userId = currentUserId;
      if (userId == null || userId.isEmpty) {
        print('Error: User not authenticated in toggleMealPlanFavorite');
        return false;
      }

      // Verify this meal plan belongs to the current user
      DocumentSnapshot doc = await mealPlansCollection.doc(id).get();
      if (!doc.exists) {
        print('Error: Meal plan not found: $id');
        return false;
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != userId) {
        print('Error: User does not have permission to modify this meal plan');
        return false;
      }

      print('Toggling meal plan favorite: $id to $isFavorite');
      await mealPlansCollection.doc(id).update({'isFavorite': isFavorite});
      print('Updated meal plan favorite status successfully');

      return true;
    } catch (e) {
      print('Error toggling meal plan favorite: $e');
      return false;
    }
  }

  // Mark meal item as consumed with improved validation and error handling
  Future<bool> markMealItemConsumed(
    String mealPlanId,
    int itemIndex,
    bool isConsumed,
  ) async {
    try {
      String? userId = currentUserId;
      if (userId == null || userId.isEmpty) {
        print('Error: User not authenticated in markMealItemConsumed');
        return false;
      }

      // Validate parameters
      if (mealPlanId.isEmpty) {
        print('Error: Meal plan ID cannot be empty');
        return false;
      }

      if (itemIndex < 0) {
        print('Error: Item index must be non-negative');
        return false;
      }

      // First get the current meal plan
      DocumentSnapshot doc = await mealPlansCollection.doc(mealPlanId).get();
      if (!doc.exists) {
        print('Error: Meal plan not found: $mealPlanId');
        return false;
      }

      MealPlan mealPlan;
      try {
        mealPlan = MealPlan.fromFirestore(doc);
      } catch (e) {
        print('Error parsing meal plan: $e');
        return false;
      }

      // Verify this meal plan belongs to the current user
      if (mealPlan.userId != userId) {
        print('Error: User does not have permission to modify this meal plan');
        return false;
      }

      // Validate item index
      if (itemIndex >= mealPlan.items.length) {
        print(
          'Error: Item index out of bounds: $itemIndex, max: ${mealPlan.items.length - 1}',
        );
        return false;
      }

      List<Meal> updatedItems = List.from(mealPlan.items);

      // Update the specific item
      updatedItems[itemIndex] = updatedItems[itemIndex].copyWith(
        isConsumed: isConsumed,
      );

      // Check if all items are consumed and update meal plan completion status
      bool allConsumed = updatedItems.every((item) => item.isConsumed ?? false);

      print(
        'Marking meal item as consumed: Plan ID: $mealPlanId, Item Index: $itemIndex, Consumed: $isConsumed',
      );

      // Update the document
      await mealPlansCollection.doc(mealPlanId).update({
        'items': updatedItems.map((item) => item.toJson()).toList(),
        'isCompleted': allConsumed,
      });

      // If all items are consumed now, create an achievement
      if (allConsumed && !mealPlan.isCompleted) {
        await createMealAchievement(mealPlanId, mealPlan.name);
      }

      print('Updated meal item consumed status successfully');
      return true;
    } catch (e) {
      print('Error marking meal item as consumed: $e');
      return false;
    }
  }

  // Get real-time updates for meal plans with improved error handling
  Stream<List<MealPlan>> mealPlansStream() {
    String? userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      print('Error: User not authenticated in mealPlansStream');
      return Stream.value([]);
    }

    print('Setting up meal plans stream for user: $userId');
    return mealPlansCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          print('Stream data received: ${snapshot.docs.length} meal plans');
          List<MealPlan> plans = [];
          for (var doc in snapshot.docs) {
            try {
              plans.add(MealPlan.fromFirestore(doc));
            } catch (e) {
              print(
                'Error parsing meal plan in stream: $e for document: ${doc.id}',
              );
            }
          }
          plans.sort((a, b) => b.date.compareTo(a.date));
          return plans;
        })
        .handleError((error) {
          print('Error in meal plans stream: $error');
          return [];
        });
  }

  // Get real-time updates for today's meal plans with improved validation
  Stream<List<MealPlan>> todayMealPlansStream() {
    String? userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      print('Error: User not authenticated in todayMealPlansStream');
      return Stream.value([]);
    }

    // Create date range for today
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    print(
      'Setting up today\'s meal plans stream for user: $userId, date: ${startOfDay.toString()}',
    );

    return mealPlansCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          print(
            'Today\'s stream data received: ${snapshot.docs.length} meal plans',
          );
          List<MealPlan> plans = [];
          for (var doc in snapshot.docs) {
            try {
              MealPlan plan = MealPlan.fromFirestore(doc);
              if (plan.date.isAfter(startOfDay.subtract(const Duration(milliseconds: 1))) && 
                  plan.date.isBefore(endOfDay.add(const Duration(milliseconds: 1)))) {
                plans.add(plan);
              }
            } catch (e) {
              print(
                'Error parsing meal plan in today\'s stream: $e for document: ${doc.id}',
              );
            }
          }
          plans.sort((a, b) => a.date.compareTo(b.date));
          return plans;
        })
        .handleError((error) {
          print('Error in today\'s meal plans stream: $error');
          return [];
        });
  }

  // Get favorite meal plans with improved validation
  Future<List<MealPlan>> getFavoriteMealPlans() async {
    try {
      String? userId = currentUserId;
      if (userId == null || userId.isEmpty) {
        print('Error: User not authenticated in getFavoriteMealPlans');
        return [];
      }

      print('Fetching favorite meal plans for user: $userId');
      QuerySnapshot querySnapshot =
          await mealPlansCollection
              .where('userId', isEqualTo: userId)
              .where('isFavorite', isEqualTo: true)
              .orderBy('date', descending: true)
              .get();

      print('Found ${querySnapshot.docs.length} favorite meal plans');

      List<MealPlan> plans = [];
      for (var doc in querySnapshot.docs) {
        try {
          plans.add(MealPlan.fromFirestore(doc));
        } catch (e) {
          print('Error parsing favorite meal plan: $e for document: ${doc.id}');
        }
      }

      return plans;
    } catch (e) {
      print('Error fetching favorite meal plans: $e');
      return [];
    }
  }
}
