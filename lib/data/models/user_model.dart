// lib/data/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String age;
  final String ageUnit;
  final String gender;
  final String goalType;
  final String height;
  final String heightUnit;
  final String weight;
  final String weightUnit;
  final DateTime createdAt;
  final DateTime lastActive;
  final String? profileImageUrl;
  final bool isActive;
  final String role; // User role: 'customer', 'coach', or 'admin'
  final Map<String, dynamic>? preferences;
  final List<String>? savedWorkouts;
  final List<String>? savedMeals;
  final Map<String, dynamic>? fitnessLevel;
  final Map<String, dynamic>? activityLog;
  final String? coachId;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.age,
    required this.ageUnit,
    required this.gender,
    required this.goalType,
    required this.height,
    required this.heightUnit,
    required this.weight,
    required this.weightUnit,
    required this.createdAt,
    required this.lastActive,
    this.profileImageUrl,
    this.isActive = true,
    this.role = 'customer', // Default role is customer
    this.preferences,
    this.savedWorkouts,
    this.savedMeals,
    this.fitnessLevel,
    this.activityLog,
    this.coachId,
  });

  factory UserModel.fromMap(String documentId, Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      age: map['age'] ?? '',
      ageUnit: map['age_unit'] ?? 'years',
      gender: map['gender'] ?? '',
      goalType: map['goalType'] ?? '',
      height: map['height'] ?? '',
      heightUnit: map['height_unit'] ?? 'cm',
      weight: map['weight'] ?? '',
      weightUnit: map['weight_unit'] ?? 'kg',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActive: (map['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
      profileImageUrl: map['profileImageUrl'],
      isActive: map['isActive'] ?? true,
      role: map['role'] ?? 'customer', // Defaults to customer
      preferences: map['preferences'],
      savedWorkouts: List<String>.from(map['savedWorkouts'] ?? []),
      savedMeals: List<String>.from(map['savedMeals'] ?? []),
      fitnessLevel: map['fitnessLevel'],
      activityLog: map['activityLog'],
      coachId: map['coachId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'age': age,
      'age_unit': ageUnit,
      'gender': gender,
      'goal_type': goalType,
      'height': height,
      'height_unit': heightUnit,
      'weight': weight,
      'weight_unit': weightUnit,
      'createdAt': createdAt,
      'lastActive': lastActive,
      'profileImageUrl': profileImageUrl,
      'isActive': isActive,
      'role': role,
      'preferences': preferences,
      'savedWorkouts': savedWorkouts,
      'savedMeals': savedMeals,
      'fitnessLevel': fitnessLevel,
      'activityLog': activityLog,
      'coachId': coachId,
    };
  }

  // Calculate BMI
  double? calculateBMI() {
    try {
      double heightValue = double.parse(height);
      double weightValue = double.parse(weight);

      // Convert height to meters if in cm
      if (heightUnit == 'cm') {
        heightValue = heightValue / 100;
      }

      // Convert weight to kg if in pounds
      if (weightUnit == 'lbs') {
        weightValue = weightValue * 0.453592;
      }

      // BMI formula: weight(kg) / (height(m) * height(m))
      return weightValue / (heightValue * heightValue);
    } catch (e) {
      print('Error calculating BMI: $e');
      return null;
    }
  }

  // Get BMI category
  String getBMICategory() {
    final double? bmi = calculateBMI();
    if (bmi == null) return 'Unknown';

    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi < 25) {
      return 'Normal';
    } else if (bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  // Get user age in years
  int? getAgeInYears() {
    try {
      return int.parse(age);
    } catch (e) {
      return null;
    }
  }

  // Check if user is new (registered within the last 7 days)
  bool isNewUser() {
    final DateTime sevenDaysAgo = DateTime.now().subtract(
      const Duration(days: 7),
    );
    return createdAt.isAfter(sevenDaysAgo);
  }

  // Copy with method for updating user properties
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phoneNumber,
    String? age,
    String? ageUnit,
    String? gender,
    String? goalType,
    String? height,
    String? heightUnit,
    String? weight,
    String? weightUnit,
    DateTime? createdAt,
    DateTime? lastActive,
    String? profileImageUrl,
    bool? isActive,
    String? role,
    Map<String, dynamic>? preferences,
    List<String>? savedWorkouts,
    List<String>? savedMeals,
    Map<String, dynamic>? fitnessLevel,
    Map<String, dynamic>? activityLog,
    String? coachId,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      age: age ?? this.age,
      ageUnit: ageUnit ?? this.ageUnit,
      gender: gender ?? this.gender,
      goalType: goalType ?? this.goalType,
      height: height ?? this.height,
      heightUnit: heightUnit ?? this.heightUnit,
      weight: weight ?? this.weight,
      weightUnit: weightUnit ?? this.weightUnit,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isActive: isActive ?? this.isActive,
      role: role ?? this.role,
      preferences: preferences ?? this.preferences,
      savedWorkouts: savedWorkouts ?? this.savedWorkouts,
      savedMeals: savedMeals ?? this.savedMeals,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      activityLog: activityLog ?? this.activityLog,
      coachId: coachId ?? this.coachId,
    );
  }
}
