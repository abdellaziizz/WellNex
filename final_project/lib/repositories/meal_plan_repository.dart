import '../services/service_factory.dart';
import '../models/meal_plan_model.dart';
import 'dart:developer' as developer;

class MealPlanRepository {
  final ServiceFactory _services = ServiceFactory();

  // Create a new meal plan for the current user
  Future<MealPlan> createMealPlan({
    required String name,
    required String dietType,
    required int totalCalories,
    required List<Meal> meals,
    required double proteinGrams,
    required double carbsGrams,
    required double fatsGrams,
    required double hydrationGoalLiters,
    required List<String> restrictions,
  }) async {
    final userId = _services.currentUserId;
    if (userId == null) {
      throw Exception('No user is logged in');
    }
    
    try {
      final mealPlan = MealPlan(
        id: '',
        userId: userId,
        name: name,
        dietType: dietType,
        totalCalories: totalCalories,
        createdAt: DateTime.now(),
        meals: meals,
        proteinGrams: proteinGrams,
        carbsGrams: carbsGrams,
        fatsGrams: fatsGrams,
        hydrationGoalLiters: hydrationGoalLiters,
        restrictions: restrictions,
      );
      
      return await _services.mealPlan.createMealPlan(mealPlan);
    } catch (e) {
      developer.log('Error creating meal plan: ${e.toString()}', error: e);
      throw Exception('Failed to create meal plan: ${e.toString()}');
    }
  }

  // Update an existing meal plan
  Future<void> updateMealPlan(MealPlan mealPlan) async {
    final userId = _services.currentUserId;
    if (userId == null) {
      throw Exception('No user is logged in');
    }
    
    // Validate that the meal plan belongs to the current user
    if (mealPlan.userId != userId) {
      throw Exception('Cannot update a different user\'s meal plan');
    }
    
    try {
      await _services.mealPlan.updateMealPlan(mealPlan);
    } catch (e) {
      developer.log('Error updating meal plan: ${e.toString()}', error: e);
      throw Exception('Failed to update meal plan: ${e.toString()}');
    }
  }

  // Delete a meal plan
  Future<void> deleteMealPlan(String mealPlanId) async {
    try {
      final mealPlan = await _services.mealPlan.getMealPlan(mealPlanId);
      
      final userId = _services.currentUserId;
      if (userId == null) {
        throw Exception('No user is logged in');
      }
      
      // Validate that the meal plan belongs to the current user
      if (mealPlan.userId != userId) {
        throw Exception('Cannot delete a different user\'s meal plan');
      }
      
      await _services.mealPlan.deleteMealPlan(mealPlanId);
    } catch (e) {
      developer.log('Error deleting meal plan: ${e.toString()}', error: e);
      throw Exception('Failed to delete meal plan: ${e.toString()}');
    }
  }

  // Get all meal plans for the current user
  Future<List<MealPlan>> getUserMealPlans() async {
    final userId = _services.currentUserId;
    if (userId == null) {
      throw Exception('No user is logged in');
    }
    
    try {
      return await _services.mealPlan.getUserMealPlans(userId);
    } catch (e) {
      developer.log('Error getting user meal plans: ${e.toString()}', error: e);
      throw Exception('Failed to get user meal plans: ${e.toString()}');
    }
  }

  // Stream all meal plans for the current user (real-time updates)
  Stream<List<MealPlan>> streamUserMealPlans() {
    final userId = _services.currentUserId;
    if (userId == null) {
      throw Exception('No user is logged in');
    }
    
    return _services.mealPlan.streamUserMealPlans(userId);
  }

  // Get meal plans by diet type
  Future<List<MealPlan>> getMealPlansByDietType(String dietType) async {
    final userId = _services.currentUserId;
    if (userId == null) {
      throw Exception('No user is logged in');
    }
    
    try {
      return await _services.mealPlan.getMealPlansByDietType(userId, dietType);
    } catch (e) {
      developer.log('Error getting meal plans by diet type: ${e.toString()}', error: e);
      throw Exception('Failed to get meal plans by diet type: ${e.toString()}');
    }
  }

  // Get meal plans within a calorie range
  Future<List<MealPlan>> getMealPlansByCalorieRange(
    int minCalories, 
    int maxCalories
  ) async {
    final userId = _services.currentUserId;
    if (userId == null) {
      throw Exception('No user is logged in');
    }
    
    try {
      return await _services.mealPlan.getMealPlansByCalorieRange(
        userId, 
        minCalories, 
        maxCalories
      );
    } catch (e) {
      developer.log('Error getting meal plans by calorie range: ${e.toString()}', error: e);
      throw Exception('Failed to get meal plans by calorie range: ${e.toString()}');
    }
  }

  // Create a sample meal plan based on user preferences
  Future<MealPlan> createSampleMealPlan({
    required String dietType,
    required int targetCalories,
    required List<String> restrictions,
  }) async {
    final userId = _services.currentUserId;
    if (userId == null) {
      throw Exception('No user is logged in');
    }
    
    try {
      // For a real app, this would be more complex with actual meal generation
      // This is a simplified example
      
      // Calculate macros based on diet type
      double proteinPercentage, carbsPercentage, fatsPercentage;
      
      switch (dietType.toLowerCase()) {
        case 'keto':
          proteinPercentage = 0.25;
          carbsPercentage = 0.05;
          fatsPercentage = 0.70;
          break;
        case 'low carb':
          proteinPercentage = 0.35;
          carbsPercentage = 0.20;
          fatsPercentage = 0.45;
          break;
        case 'high protein':
          proteinPercentage = 0.40;
          carbsPercentage = 0.35;
          fatsPercentage = 0.25;
          break;
        case 'balanced':
        default:
          proteinPercentage = 0.30;
          carbsPercentage = 0.40;
          fatsPercentage = 0.30;
          break;
      }
      
      // Calculate grams based on calories
      // Protein: 4 calories per gram
      // Carbs: 4 calories per gram
      // Fats: 9 calories per gram
      final proteinGrams = (targetCalories * proteinPercentage) / 4;
      final carbsGrams = (targetCalories * carbsPercentage) / 4;
      final fatsGrams = (targetCalories * fatsPercentage) / 9;
      
      // Create sample meals
      List<Meal> meals = [
        Meal(
          name: 'Breakfast',
          mealType: 'breakfast',
          calories: (targetCalories * 0.3).round(),
          foodItems: [
            FoodItem(
              name: 'Eggs',
              quantity: 2,
              unit: 'large',
              calories: 140,
              proteinGrams: 12,
              carbsGrams: 0,
              fatsGrams: 10,
            ),
            FoodItem(
              name: 'Whole Grain Toast',
              quantity: 2,
              unit: 'slice',
              calories: 140,
              proteinGrams: 6,
              carbsGrams: 24,
              fatsGrams: 2,
            ),
          ],
          recipe: 'Scramble eggs and serve with toast.',
        ),
        Meal(
          name: 'Lunch',
          mealType: 'lunch',
          calories: (targetCalories * 0.35).round(),
          foodItems: [
            FoodItem(
              name: 'Chicken Breast',
              quantity: 4,
              unit: 'oz',
              calories: 140,
              proteinGrams: 26,
              carbsGrams: 0,
              fatsGrams: 3,
            ),
            FoodItem(
              name: 'Brown Rice',
              quantity: 0.5,
              unit: 'cup',
              calories: 110,
              proteinGrams: 2,
              carbsGrams: 23,
              fatsGrams: 1,
            ),
          ],
          recipe: 'Grill chicken and serve with rice.',
        ),
        Meal(
          name: 'Dinner',
          mealType: 'dinner',
          calories: (targetCalories * 0.35).round(),
          foodItems: [
            FoodItem(
              name: 'Salmon',
              quantity: 4,
              unit: 'oz',
              calories: 200,
              proteinGrams: 22,
              carbsGrams: 0,
              fatsGrams: 12,
            ),
            FoodItem(
              name: 'Mixed Vegetables',
              quantity: 1,
              unit: 'cup',
              calories: 80,
              proteinGrams: 2,
              carbsGrams: 16,
              fatsGrams: 0,
            ),
          ],
          recipe: 'Bake salmon and serve with steamed vegetables.',
        ),
      ];
      
      return createMealPlan(
        name: 'Sample $dietType Meal Plan',
        dietType: dietType,
        totalCalories: targetCalories,
        meals: meals,
        proteinGrams: proteinGrams,
        carbsGrams: carbsGrams,
        fatsGrams: fatsGrams,
        hydrationGoalLiters: 2.5, // Standard recommendation
        restrictions: restrictions,
      );
    } catch (e) {
      developer.log('Error creating sample meal plan: ${e.toString()}', error: e);
      throw Exception('Failed to create sample meal plan: ${e.toString()}');
    }
  }
} 