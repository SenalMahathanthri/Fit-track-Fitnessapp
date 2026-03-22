// lib/models/meal_model.dart

class Meal {
  final String id;
  final String name;
  final double grams;
  final double calories;
  final double proteins;
  final double carbs;
  final bool isConsumed;

  Meal({
    required this.id,
    required this.name,
    required this.grams,
    required this.calories,
    required this.proteins,
    required this.carbs,
    this.isConsumed = false,
  });

  // Copy constructor with optional parameters
  Meal copyWith({
    String? id,
    String? name,
    double? grams,
    double? calories,
    double? proteins,
    double? carbs,
    bool? isConsumed,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      grams: grams ?? this.grams,
      calories: calories ?? this.calories,
      proteins: proteins ?? this.proteins,
      carbs: carbs ?? this.carbs,
      isConsumed: isConsumed ?? this.isConsumed,
    );
  }

  // Convert from JSON
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      name: json['name'],
      grams:
          (json['grams'] is int)
              ? (json['grams'] as int).toDouble()
              : json['grams'],
      calories:
          (json['calories'] is int)
              ? (json['calories'] as int).toDouble()
              : json['calories'],
      proteins:
          (json['proteins'] is int)
              ? (json['proteins'] as int).toDouble()
              : json['proteins'],
      carbs:
          (json['carbs'] is int)
              ? (json['carbs'] as int).toDouble()
              : json['carbs'],
      isConsumed: json['isConsumed'] ?? false,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'grams': grams,
      'calories': calories,
      'proteins': proteins,
      'carbs': carbs,
      'isConsumed': isConsumed,
    };
  }

  // For list formatting
  @override
  String toString() {
    return 'Meal(id: $id, name: $name, grams: $grams, calories: $calories, proteins: $proteins, carbs: $carbs, isConsumed: $isConsumed)';
  }
}
