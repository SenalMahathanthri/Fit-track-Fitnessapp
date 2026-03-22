// lib/controllers/meal_controller.dart
import 'package:get/get.dart';
import '../../../core/services/error_handling.dart';
import '../../../core/services/firebase/meal_service.dart';
import '../../../data/models/meal_model.dart';

class MealController extends GetxController {
  final MealService _mealService = MealService();
  final ErrorHandlingService _errorHandler = Get.put(ErrorHandlingService());

  // Observable variables
  final RxList<Meal> _meals = <Meal>[].obs;
  final RxBool _isLoading = false.obs;
  final Rxn<String> _error = Rxn<String>();

  // Stats observables
  final Rx<Map<String, dynamic>> _mealStats = Rx<Map<String, dynamic>>({});

  // Getters
  List<Meal> get meals => _meals;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;
  int get mealCount => _meals.length;
  Rx<Map<String, dynamic>> getMealStats() => _mealStats;

  // Constructor to initialize data
  @override
  void onInit() {
    super.onInit();
    fetchMeals();

    // Subscribe to realtime updates
    ever(_meals, (_) {
      update();
      _updateStats();
    });

    ever(_error, (errorMsg) {
      if (errorMsg != null) {
        _errorHandler.handleError(errorMsg);
        resetError(); // Clear error after handling
      }
    });

    _listenToMealChanges();
  }

  void _updateStats() async {
    try {
      final nutrients = await _mealService.getTotalNutrients();
      final highProteinMeals = await _mealService.getHighProteinMeals();
      final lowCarbMeals = await _mealService.getLowCarbMeals();

      _mealStats.value = {
        'nutrients': nutrients,
        'highProteinCount': highProteinMeals.length,
        'lowCarbCount': lowCarbMeals.length,
        'totalCount': _meals.length,
      };
    } catch (e) {
      _errorHandler.handleError(
        e,
        customMessage: 'Error updating meal statistics',
      );
    }
  }

  void _listenToMealChanges() {
    _mealService.mealsStream().listen(
      (mealsList) {
        _meals.value = mealsList;
      },
      onError: (error) {
        _errorHandler.handleError(error, customMessage: 'Error in meal stream');
      },
    );
  }

  // Fetch all meals
  Future<void> fetchMeals() async {
    _setLoading(true);
    try {
      final mealsList = await _mealService.getAllMeals();
      _meals.value = mealsList;
      _setLoading(false);
      _updateStats();
    } catch (e) {
      _setError('Failed to fetch meals: $e');
    }
  }

  // Add a new meal
  Future<bool> addMeal(
    String name,
    double grams,
    double calories,
    double proteins,
    double carbs,
  ) async {
    _setLoading(true);
    try {
      final meal = await _mealService.addMeal(
        name,
        grams,
        calories,
        proteins,
        carbs,
      );
      _setLoading(false);

      if (meal != null) {
        _errorHandler.handleSuccess('Meal added successfully');
        return true;
      } else {
        _errorHandler.handleError('Failed to add meal');
        return false;
      }
    } catch (e) {
      _setError('Failed to add meal: $e');
      return false;
    }
  }

  // Update a meal
  Future<bool> updateMeal(Meal meal) async {
    _setLoading(true);
    try {
      final success = await _mealService.updateMeal(meal);
      _setLoading(false);

      if (success) {
        _errorHandler.handleSuccess('Meal updated successfully');
      } else {
        _errorHandler.handleError('Failed to update meal');
      }

      return success;
    } catch (e) {
      _setError('Failed to update meal: $e');
      return false;
    }
  }

  // Delete a meal
  Future<bool> deleteMeal(String id) async {
    _setLoading(true);
    try {
      final success = await _mealService.deleteMeal(id);
      _setLoading(false);

      if (success) {
        _errorHandler.handleSuccess('Meal deleted successfully');
      } else {
        _errorHandler.handleError('Failed to delete meal');
      }

      return success;
    } catch (e) {
      _setError('Failed to delete meal: $e');
      return false;
    }
  }

  // Get meal by ID
  Future<Meal?> getMealById(String id) async {
    try {
      return await _mealService.getMealById(id);
    } catch (e) {
      _setError('Failed to get meal: $e');
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
