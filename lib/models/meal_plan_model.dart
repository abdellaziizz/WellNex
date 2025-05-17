import 'package:cloud_firestore/cloud_firestore.dart';

class MealPlan {
  final String id;
  final String userId;
  final String name;
  final String dietType;
  final int totalCalories;
  final DateTime createdAt;
  final List<Meal> meals;
  final double proteinGrams;
  final double carbsGrams;
  final double fatsGrams;
  final double hydrationGoalLiters;
  final List<String> restrictions;

  MealPlan({
    required this.id,
    required this.userId,
    required this.name,
    required this.dietType,
    required this.totalCalories,
    required this.createdAt,
    required this.meals,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatsGrams,
    required this.hydrationGoalLiters,
    required this.restrictions,
  });

  // Create a factory constructor for creating a MealPlan from Firestore data
  factory MealPlan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MealPlan(
      id: doc.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      dietType: data['dietType'] as String,
      totalCalories: data['totalCalories'] as int,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      meals: (data['meals'] as List<dynamic>)
          .map((m) => Meal.fromMap(m as Map<String, dynamic>))
          .toList(),
      proteinGrams: (data['proteinGrams'] as num).toDouble(),
      carbsGrams: (data['carbsGrams'] as num).toDouble(),
      fatsGrams: (data['fatsGrams'] as num).toDouble(),
      hydrationGoalLiters: (data['hydrationGoalLiters'] as num).toDouble(),
      restrictions: List<String>.from(data['restrictions'] as List<dynamic>),
    );
  }

  // Convert meal plan to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'dietType': dietType,
      'totalCalories': totalCalories,
      'createdAt': Timestamp.fromDate(createdAt),
      'meals': meals.map((m) => m.toMap()).toList(),
      'proteinGrams': proteinGrams,
      'carbsGrams': carbsGrams,
      'fatsGrams': fatsGrams,
      'hydrationGoalLiters': hydrationGoalLiters,
      'restrictions': restrictions,
    };
  }

  // Create a copy of the meal plan with updated fields
  MealPlan copyWith({
    String? id,
    String? userId,
    String? name,
    String? dietType,
    int? totalCalories,
    DateTime? createdAt,
    List<Meal>? meals,
    double? proteinGrams,
    double? carbsGrams,
    double? fatsGrams,
    double? hydrationGoalLiters,
    List<String>? restrictions,
  }) {
    return MealPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      dietType: dietType ?? this.dietType,
      totalCalories: totalCalories ?? this.totalCalories,
      createdAt: createdAt ?? this.createdAt,
      meals: meals ?? this.meals,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      carbsGrams: carbsGrams ?? this.carbsGrams,
      fatsGrams: fatsGrams ?? this.fatsGrams,
      hydrationGoalLiters: hydrationGoalLiters ?? this.hydrationGoalLiters,
      restrictions: restrictions ?? this.restrictions,
    );
  }
}

class Meal {
  final String name;
  final String mealType; // e.g., "breakfast", "lunch", "dinner", "snack"
  final int calories;
  final List<FoodItem> foodItems;
  final String recipe;
  final String? imageUrl;

  Meal({
    required this.name,
    required this.mealType,
    required this.calories,
    required this.foodItems,
    required this.recipe,
    this.imageUrl,
  });

  // Create from Map
  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      name: map['name'] as String,
      mealType: map['mealType'] as String,
      calories: map['calories'] as int,
      foodItems: (map['foodItems'] as List<dynamic>)
          .map((f) => FoodItem.fromMap(f as Map<String, dynamic>))
          .toList(),
      recipe: map['recipe'] as String,
      imageUrl: map['imageUrl'] as String?,
    );
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'mealType': mealType,
      'calories': calories,
      'foodItems': foodItems.map((f) => f.toMap()).toList(),
      'recipe': recipe,
      'imageUrl': imageUrl,
    };
  }
}

class FoodItem {
  final String name;
  final double quantity;
  final String unit;
  final int calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatsGrams;

  FoodItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatsGrams,
  });

  // Create from Map
  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      name: map['name'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      unit: map['unit'] as String,
      calories: map['calories'] as int,
      proteinGrams: (map['proteinGrams'] as num).toDouble(),
      carbsGrams: (map['carbsGrams'] as num).toDouble(),
      fatsGrams: (map['fatsGrams'] as num).toDouble(),
    );
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'calories': calories,
      'proteinGrams': proteinGrams,
      'carbsGrams': carbsGrams,
      'fatsGrams': fatsGrams,
    };
  }
} 