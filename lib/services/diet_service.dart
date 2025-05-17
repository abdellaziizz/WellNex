import 'package:wellnex/models/diet_plan_model.dart';
import 'package:wellnex/models/health_metrics_model.dart';
import 'package:wellnex/services/health_metrics_service.dart';

class DietService {
  static final DietService _instance = DietService._internal();
  factory DietService() => _instance;
  DietService._internal();

  final HealthMetricsService _healthMetricsService = HealthMetricsService();

  DietPlan generateDietPlan({
    required double weight,
    required double height,
    required int age,
    required String gender,
    required String healthGoal,
  }) {
    // Calculate BMI and BMR
    double bmi = _healthMetricsService.calculateBMI(weight, height);
    double bmr = _healthMetricsService.calculateBMR(weight, height, age, gender);
    
    // Get daily calorie needs and macronutrient distribution
    final calorieInfo = _healthMetricsService.calculateDailyCalories(bmr, healthGoal);
    
    // Generate meal suggestions based on health goal and calories
    final mealSuggestions = DietPlan.generateMealSuggestions(
      healthGoal,
      calorieInfo['dailyCalories'],
    );

    return DietPlan(
      healthGoal: healthGoal,
      dailyCalories: calorieInfo['dailyCalories'],
      macronutrients: Map<String, double>.from(calorieInfo['macronutrients']),
      mealSuggestions: mealSuggestions,
    );
  }

  String getDietaryAdvice(String bmiCategory, String healthGoal) {
    switch (healthGoal.toLowerCase()) {
      case 'lose weight':
        return '''
• Focus on creating a caloric deficit through portion control
• Increase protein intake to preserve muscle mass
• Include plenty of fiber-rich vegetables to stay full
• Stay hydrated with water throughout the day
• Consider meal prepping to control portions
''';
      
      case 'gain muscle':
        return '''
• Ensure you're in a slight caloric surplus
• Prioritize protein intake after workouts
• Include complex carbohydrates for energy
• Don't skip healthy fats for hormone production
• Time your meals around your workouts
''';
      
      default:
        return '''
• Focus on balanced, nutrient-dense meals
• Include a variety of fruits and vegetables
• Choose whole grains over refined grains
• Include lean proteins in each meal
• Stay consistent with portion sizes
''';
    }
  }
} 