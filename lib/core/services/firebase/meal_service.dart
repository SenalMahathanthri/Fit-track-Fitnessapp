// lib/services/meal_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/meal_model.dart';

class MealService {
  final CollectionReference mealsCollection = FirebaseFirestore.instance
      .collection('meals');

  // Get all meals
  Future<List<Meal>> getAllMeals() async {
    try {
      QuerySnapshot querySnapshot = await mealsCollection.get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Meal.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching meals: $e');
      return [];
    }
  }

  // Get meal by ID
  Future<Meal?> getMealById(String id) async {
    try {
      DocumentSnapshot doc = await mealsCollection.doc(id).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Meal.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching meal by ID: $e');
      return null;
    }
  }

  // Add a new meal
  Future<Meal?> addMeal(
    String name,
    double grams,
    double calories,
    double proteins,
    double carbs,
  ) async {
    try {
      Map<String, dynamic> mealData = {
        'name': name,
        'grams': grams,
        'calories': calories,
        'proteins': proteins,
        'carbs': carbs,
        'createdAt': FieldValue.serverTimestamp(),
      };

      DocumentReference docRef = await mealsCollection.add(mealData);

      // Return the newly created meal with the Firestore-generated ID
      return Meal(
        id: docRef.id,
        name: name,
        grams: grams,
        calories: calories,
        proteins: proteins,
        carbs: carbs,
      );
    } catch (e) {
      print('Error adding meal: $e');
      return null;
    }
  }

  // Update a meal
  Future<bool> updateMeal(Meal meal) async {
    try {
      await mealsCollection.doc(meal.id).update({
        'name': meal.name,
        'grams': meal.grams,
        'calories': meal.calories,
        'proteins': meal.proteins,
        'carbs': meal.carbs,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating meal: $e');
      return false;
    }
  }

  // Delete a meal
  Future<bool> deleteMeal(String id) async {
    try {
      await mealsCollection.doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting meal: $e');
      return false;
    }
  }

  // Get total nutritional values
  Future<Map<String, double>> getTotalNutrients() async {
    double totalCalories = 0;
    double totalProteins = 0;
    double totalCarbs = 0;

    try {
      List<Meal> meals = await getAllMeals();
      for (var meal in meals) {
        totalCalories += meal.calories;
        totalProteins += meal.proteins;
        totalCarbs += meal.carbs;
      }

      return {
        'calories': totalCalories,
        'proteins': totalProteins,
        'carbs': totalCarbs,
      };
    } catch (e) {
      print('Error calculating nutrient totals: $e');
      return {'calories': 0, 'proteins': 0, 'carbs': 0};
    }
  }

  // Get high protein meals (more than 20g per 100g)
  Future<List<Meal>> getHighProteinMeals() async {
    try {
      List<Meal> meals = await getAllMeals();
      return meals
          .where((meal) => (meal.proteins / meal.grams) * 100 > 20)
          .toList();
    } catch (e) {
      print('Error fetching high protein meals: $e');
      return [];
    }
  }

  // Get low carb meals (less than 10g per 100g)
  Future<List<Meal>> getLowCarbMeals() async {
    try {
      List<Meal> meals = await getAllMeals();
      return meals
          .where((meal) => (meal.carbs / meal.grams) * 100 < 10)
          .toList();
    } catch (e) {
      print('Error fetching low carb meals: $e');
      return [];
    }
  }

  // Stream of meals for real-time updates
  Stream<List<Meal>> mealsStream() {
    return mealsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Meal.fromJson(data);
      }).toList();
    });
  }
}
