import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class WaterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _waterCollection = FirebaseFirestore.instance
      .collection('water_intake');
  final CollectionReference _achievementsCollection = FirebaseFirestore.instance
      .collection('achievements');
  final CollectionReference _usersCollection = FirebaseFirestore.instance
      .collection('users');

  // Get current user ID
  String? get currentUserId {
    final user = _auth.currentUser;
    if (user == null) {
      print('Warning: No authenticated user found in WaterService.');
    }
    return user?.uid;
  }

  // Add water intake
  Future<String?> addWaterIntake(int amount) async {
    try {
      String? userId = currentUserId;
      if (userId == null || userId.isEmpty) {
        print('Error: User not authenticated in addWaterIntake');
        return null;
      }

      // Create water intake document
      DocumentReference docRef = await _waterCollection.add({
        'userId': userId,
        'amount': amount,
        'date': _getTodayFormatted(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Added water intake: $amount ml, ID: ${docRef.id}');

      // Check if user reached daily goal (2500ml)
      int todayTotal = await getTodayWaterIntake();
      if (todayTotal >= 2500) {
        await _checkAndCreateWaterAchievement();
      }

      return docRef.id;
    } catch (e) {
      print('Error adding water intake: $e');
      return null;
    }
  }

  // Get today's total water intake
  Future<int> getTodayWaterIntake() async {
    try {
      String? userId = currentUserId;
      if (userId == null || userId.isEmpty) {
        print('Error: User not authenticated in getTodayWaterIntake');
        return 0;
      }

      QuerySnapshot snapshot =
          await _waterCollection
              .where('userId', isEqualTo: userId)
              .where('date', isEqualTo: _getTodayFormatted())
              .get();

      int total = 0;
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        total += (data['amount'] as num).toInt();
      }

      return total;
    } catch (e) {
      print('Error getting today water intake: $e');
      return 0;
    }
  }

  // Get water intake for a specific date
  Future<int> getWaterIntakeForDate(DateTime date) async {
    try {
      String? userId = currentUserId;
      if (userId == null || userId.isEmpty) {
        print('Error: User not authenticated in getWaterIntakeForDate');
        return 0;
      }

      String formattedDate = DateFormat('yyyy-MM-dd').format(date);

      QuerySnapshot snapshot =
          await _waterCollection
              .where('userId', isEqualTo: userId)
              .where('date', isEqualTo: formattedDate)
              .get();

      int total = 0;
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        total += (data['amount'] as num).toInt();
      }

      return total;
    } catch (e) {
      print('Error getting water intake for date: $e');
      return 0;
    }
  }

  // Get water intake for the last 7 days
  Future<Map<String, int>> getWeeklyWaterIntake() async {
    try {
      String? userId = currentUserId;
      if (userId == null || userId.isEmpty) {
        print('Error: User not authenticated in getWeeklyWaterIntake');
        return {};
      }

      // Get dates for the last 7 days
      final Map<String, int> weeklyData = {};
      final now = DateTime.now();

      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final formattedDate = DateFormat('yyyy-MM-dd').format(date);
        weeklyData[formattedDate] = 0;
      }

      // Get start date (7 days ago)
      final DateTime startDate = now.subtract(const Duration(days: 6));
      final String startDateStr = DateFormat('yyyy-MM-dd').format(startDate);

      // Query Firestore for water intake records
      QuerySnapshot snapshot =
          await _waterCollection
              .where('userId', isEqualTo: userId)
              .where('date', isGreaterThanOrEqualTo: startDateStr)
              .where('date', isLessThanOrEqualTo: _getTodayFormatted())
              .get();

      // Calculate daily totals
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String date = data['date'] as String;
        int amount = (data['amount'] as num).toInt();

        if (weeklyData.containsKey(date)) {
          weeklyData[date] = (weeklyData[date] ?? 0) + amount;
        }
      }

      return weeklyData;
    } catch (e) {
      print('Error getting weekly water intake: $e');
      return {};
    }
  }

  // Listen to today's water intake in real-time
  Stream<int> todayWaterIntakeStream() {
    String? userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      print('Error: User not authenticated in todayWaterIntakeStream');
      return Stream.value(0);
    }

    return _waterCollection
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: _getTodayFormatted())
        .snapshots()
        .map((snapshot) {
          int total = 0;
          for (var doc in snapshot.docs) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            total += (data['amount'] as num).toInt();
          }
          return total;
        })
        .handleError((error) {
          print('Error in water intake stream: $error');
          return 0;
        });
  }

  // Check if user has reached water goal and create achievement if needed
  Future<void> _checkAndCreateWaterAchievement() async {
    try {
      String? userId = currentUserId;
      if (userId == null || userId.isEmpty) return;

      // Check if user already has a water achievement for today
      QuerySnapshot existingAchievement =
          await _achievementsCollection
              .where('userId', isEqualTo: userId)
              .where('type', isEqualTo: 'water')
              .where('itemId', isEqualTo: _getTodayFormatted())
              .get();

      // If already has achievement, don't create another
      if (existingAchievement.docs.isNotEmpty) return;

      // Create achievement document
      DocumentReference docRef = await _achievementsCollection.add({
        'userId': userId,
        'type': 'water',
        'itemId': _getTodayFormatted(),
        'title': 'Daily Water Goal',
        'description': 'Completed your daily water intake goal of 2.5L',
        'date': Timestamp.fromDate(DateTime.now()),
        'points': 10,
      });

      // Update user points
      await _updateUserPoints(userId, 10);

      print('Created water achievement with ID: ${docRef.id}');
    } catch (e) {
      print('Error creating water achievement: $e');
    }
  }

  // Update user points
  Future<bool> _updateUserPoints(String userId, int points) async {
    try {
      // Get the user document
      DocumentSnapshot userDoc = await _usersCollection.doc(userId).get();

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
        await _usersCollection.doc(userId).update({'points': updatedPoints});
        print('Updated user points: $currentPoints -> $updatedPoints');

        return true;
      } else {
        // User document doesn't exist, create it
        await _usersCollection.doc(userId).set({
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

  // Get user's daily water goal
  Future<int> getDailyWaterGoal() async {
    try {
      String? userId = currentUserId;
      if (userId == null || userId.isEmpty) {
        return 2500; // Default water goal (ml)
      }

      DocumentSnapshot userDoc = await _usersCollection.doc(userId).get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        if (userData.containsKey('waterGoal')) {
          return (userData['waterGoal'] as num).toInt();
        }
      }

      return 2500; // Default water goal (ml)
    } catch (e) {
      print('Error getting daily water goal: $e');
      return 2500; // Default water goal (ml)
    }
  }

  // Update user's daily water goal
  Future<bool> updateDailyWaterGoal(int goal) async {
    try {
      String? userId = currentUserId;
      if (userId == null || userId.isEmpty) {
        print('Error: User not authenticated in updateDailyWaterGoal');
        return false;
      }

      await _usersCollection.doc(userId).update({'waterGoal': goal});
      print('Updated daily water goal to: $goal ml');
      return true;
    } catch (e) {
      print('Error updating daily water goal: $e');
      return false;
    }
  }

  // Calculate water goal progress percentage
  Future<double> getWaterGoalProgress() async {
    try {
      int goal = await getDailyWaterGoal();
      int current = await getTodayWaterIntake();

      if (goal == 0) return 0.0; // Prevent division by zero

      double progress = current / goal;
      return progress > 1.0 ? 1.0 : progress; // Cap at 100%
    } catch (e) {
      print('Error calculating water goal progress: $e');
      return 0.0;
    }
  }

  // Get total water intake for current month
  Future<int> getMonthlyWaterIntake() async {
    try {
      String? userId = currentUserId;
      if (userId == null || userId.isEmpty) {
        print('Error: User not authenticated in getMonthlyWaterIntake');
        return 0;
      }

      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final firstDayFormatted = DateFormat(
        'yyyy-MM-dd',
      ).format(firstDayOfMonth);
      final lastDayFormatted = DateFormat('yyyy-MM-dd').format(lastDayOfMonth);

      QuerySnapshot snapshot =
          await _waterCollection
              .where('userId', isEqualTo: userId)
              .where('date', isGreaterThanOrEqualTo: firstDayFormatted)
              .where('date', isLessThanOrEqualTo: lastDayFormatted)
              .get();

      int total = 0;
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        total += (data['amount'] as num).toInt();
      }

      return total;
    } catch (e) {
      print('Error getting monthly water intake: $e');
      return 0;
    }
  }

  // Helper method to get today's date in YYYY-MM-DD format
  String _getTodayFormatted() {
    final now = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(now);
  }
}
