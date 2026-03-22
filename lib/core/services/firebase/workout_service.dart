// lib/core/services/firebase/workout_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/workout_model.dart';

class WorkoutService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'workouts';

  // Get a stream of all workouts
  Stream<List<Workout>> workoutsStream() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Workout.fromFirestore(doc)).toList(),
        );
  }

  // Get all workouts
  Future<List<Workout>> getAllWorkouts() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection(_collection).get();
      return snapshot.docs.map((doc) => Workout.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching workouts: $e');
      return [];
    }
  }

  // Get workout by ID
  Future<Workout?> getWorkoutById(String id) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Workout.fromFirestore(doc);
      } else {
        print('Workout not found with ID: $id');
        return null;
      }
    } catch (e) {
      print('Error fetching workout: $e');
      return null;
    }
  }

  // Add a new workout
  Future<Workout?> addWorkout(Workout workout) async {
    try {
      // Convert to JSON
      final workoutData = workout.toJson();
      // Remove ID field as Firestore will generate it
      workoutData.remove('id');
      // Add document to Firestore
      final docRef = await _firestore.collection(_collection).add(workoutData);
      // Get the newly created document
      final doc = await docRef.get();
      // Return the workout with the generated ID
      return Workout.fromFirestore(doc);
    } catch (e) {
      print('Error adding workout: $e');
      return null;
    }
  }

  // Update a workout
  Future<bool> updateWorkout(Workout workout) async {
    try {
      if (workout.id.isEmpty) {
        print('Error: Workout ID cannot be empty');
        return false;
      }

      await _firestore
          .collection(_collection)
          .doc(workout.id)
          .update(workout.toJson());
      return true;
    } catch (e) {
      print('Error updating workout: $e');
      return false;
    }
  }

  // Delete a workout
  Future<bool> deleteWorkout(String id) async {
    try {
      if (id.isEmpty) {
        print('Error: Workout ID cannot be empty');
        return false;
      }

      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting workout: $e');
      return false;
    }
  }

  // Get workout count by type
  Future<Map<WorkoutType, int>> getWorkoutTypeCount() async {
    try {
      final workouts = await getAllWorkouts();
      final Map<WorkoutType, int> result = {};

      for (final type in WorkoutType.values) {
        result[type] = workouts.where((w) => w.workoutType == type).length;
      }

      return result;
    } catch (e) {
      print('Error counting workout types: $e');
      return {};
    }
  }

  // Get workout count by difficulty
  Future<Map<String, int>> getDifficultyCount() async {
    try {
      final workouts = await getAllWorkouts();
      final Map<String, int> result = {};
      final difficulties = ['Easy', 'Medium', 'Hard'];

      for (final difficulty in difficulties) {
        result[difficulty] =
            workouts.where((w) => w.difficulty == difficulty).length;
      }

      return result;
    } catch (e) {
      print('Error counting workout difficulties: $e');
      return {};
    }
  }

  // Search workouts by name or description
  Future<List<Workout>> searchWorkouts(String query) async {
    try {
      if (query.isEmpty) {
        return await getAllWorkouts();
      }

      // Get all workouts and filter client-side
      // (Firestore doesn't support full-text search directly)
      final workouts = await getAllWorkouts();

      return workouts.where((workout) {
        final name = workout.name.toLowerCase();
        final description = workout.description.toLowerCase();
        final searchQuery = query.toLowerCase();

        return name.contains(searchQuery) || description.contains(searchQuery);
      }).toList();
    } catch (e) {
      print('Error searching workouts: $e');
      return [];
    }
  }

  // Get workouts by type
  Future<List<Workout>> getWorkoutsByType(WorkoutType type) async {
    try {
      final QuerySnapshot snapshot =
          await _firestore
              .collection(_collection)
              .where('workoutType', isEqualTo: type.toString())
              .get();

      return snapshot.docs.map((doc) => Workout.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching workouts by type: $e');
      return [];
    }
  }
}
