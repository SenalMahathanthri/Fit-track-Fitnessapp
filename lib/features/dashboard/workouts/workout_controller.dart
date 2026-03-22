// lib/features/dashboard/workouts/workout_controller.dart
import 'package:get/get.dart';
import '../../../core/services/error_handling.dart';
import '../../../core/services/firebase/workout_service.dart';
import '../../../data/models/workout_model.dart';

class WorkoutController extends GetxController {
  final WorkoutService _workoutService = WorkoutService();
  final ErrorHandlingService _errorHandler = Get.put(ErrorHandlingService());

  // Observable variables
  final RxList<Workout> _workouts = <Workout>[].obs;
  final RxBool _isLoading = false.obs;
  final Rxn<String> _error = Rxn<String>();

  // Additional observables for statistics
  final RxMap<WorkoutType, int> _typeCount = <WorkoutType, int>{}.obs;
  final RxMap<String, int> _difficultyCount = <String, int>{}.obs;

  // Getters
  List<Workout> get workouts => _workouts;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;
  int get workoutCount => _workouts.length;
  Map<WorkoutType, int> get typeCount => _typeCount;
  Map<String, int> get difficultyCount => _difficultyCount;

  // Constructor to initialize data
  @override
  void onInit() {
    super.onInit();
    fetchWorkouts();

    // Subscribe to realtime updates and errors
    ever(_workouts, (_) {
      update();
      _updateStatistics();
    });

    ever(_error, (errorMsg) {
      if (errorMsg != null) {
        _errorHandler.handleError(errorMsg);
        resetError(); // Clear error after handling
      }
    });

    _listenToWorkoutChanges();
  }

  // Update statistics when workouts change
  void _updateStatistics() async {
    try {
      final stats = await getWorkoutStats();
      _typeCount.value = stats['typeCount'] as Map<WorkoutType, int>;
      _difficultyCount.value = stats['difficultyCount'] as Map<String, int>;
    } catch (e) {
      _errorHandler.handleError(
        e,
        customMessage: 'Error updating workout statistics',
      );
    }
  }

  void _listenToWorkoutChanges() {
    _workoutService.workoutsStream().listen(
      (workoutsList) {
        _workouts.value = workoutsList;
      },
      onError: (error) {
        _errorHandler.handleError(
          error,
          customMessage: 'Error in workout stream',
        );
      },
    );
  }

  // Fetch all workouts
  Future<void> fetchWorkouts() async {
    _setLoading(true);
    try {
      final workoutsList = await _workoutService.getAllWorkouts();
      _workouts.value = workoutsList;
      _setLoading(false);
      _updateStatistics();
    } catch (e) {
      _setError('Failed to fetch workouts: $e');
    }
  }

  // Add a new workout
  Future<bool> addWorkout(Workout workout) async {
    _setLoading(true);
    try {
      final createdWorkout = await _workoutService.addWorkout(workout);
      _setLoading(false);

      if (createdWorkout != null) {
        _errorHandler.handleSuccess('Workout added successfully');
        return true;
      } else {
        _errorHandler.handleError('Failed to add workout');
        return false;
      }
    } catch (e) {
      _setError('Failed to add workout: $e');
      return false;
    }
  }

  // Update a workout
  Future<bool> updateWorkout(Workout workout) async {
    _setLoading(true);
    try {
      final success = await _workoutService.updateWorkout(workout);
      _setLoading(false);

      if (success) {
        _errorHandler.handleSuccess('Workout updated successfully');
      } else {
        _errorHandler.handleError('Failed to update workout');
      }

      return success;
    } catch (e) {
      _setError('Failed to update workout: $e');
      return false;
    }
  }

  // Delete a workout
  Future<bool> deleteWorkout(String id) async {
    _setLoading(true);
    try {
      final success = await _workoutService.deleteWorkout(id);
      _setLoading(false);

      if (success) {
        _errorHandler.handleSuccess('Workout deleted successfully');
      } else {
        _errorHandler.handleError('Failed to delete workout');
      }

      return success;
    } catch (e) {
      _setError('Failed to delete workout: $e');
      return false;
    }
  }

  // Get workout statistics
  Future<Map<String, dynamic>> getWorkoutStats() async {
    try {
      // Count workouts by type
      Map<WorkoutType, int> typeCount = {};
      for (var type in WorkoutType.values) {
        typeCount[type] = _workouts.where((w) => w.workoutType == type).length;
      }

      // Count workouts by difficulty
      Map<String, int> difficultyCount = {};
      var difficultyLevels = ['Easy', 'Medium', 'Hard'];
      for (var difficulty in difficultyLevels) {
        difficultyCount[difficulty] =
            _workouts.where((w) => w.difficulty == difficulty).length;
      }

      // Store statistics in observable variables
      _typeCount.value = typeCount;
      _difficultyCount.value = difficultyCount;

      return {
        'typeCount': typeCount,
        'difficultyCount': difficultyCount,
        'totalCount': _workouts.length,
      };
    } catch (e) {
      _setError('Failed to get workout statistics: $e');
      return {};
    }
  }

  // Get workout by ID
  Future<Workout?> getWorkoutById(String id) async {
    try {
      return await _workoutService.getWorkoutById(id);
    } catch (e) {
      _setError('Failed to get workout: $e');
      return null;
    }
  }

  // Reset error state
  void resetError() {
    _error.value = null;
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading.value = loading;
  }

  void _setError(String errorMsg) {
    _error.value = errorMsg;
    _isLoading.value = false;
  }
}
