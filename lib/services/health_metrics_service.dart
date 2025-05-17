import 'dart:math';

class HealthMetricsService {
  static final HealthMetricsService _instance = HealthMetricsService._internal();
  factory HealthMetricsService() => _instance;
  HealthMetricsService._internal();

  double calculateBMI(double weightKg, double heightCm) {
    // Convert height to meters
    double heightM = heightCm / 100;
    // Calculate BMI
    return weightKg / (heightM * heightM);
  }

  String getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi >= 18.5 && bmi < 25) {
      return 'Normal weight';
    } else if (bmi >= 25 && bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  double calculateBMR(double weightKg, double heightCm, int age, String gender) {
    // Mifflin-St Jeor Equation
    double bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
    
    if (gender.toLowerCase() == 'male') {
      bmr += 5;
    } else if (gender.toLowerCase() == 'female') {
      bmr -= 161;
    }
    
    return bmr;
  }

  Map<String, dynamic> calculateDailyCalories(double bmr, String healthGoal) {
    double dailyCalories;
    Map<String, double> macronutrients;

    switch (healthGoal.toLowerCase()) {
      case 'lose weight':
        dailyCalories = bmr - 500; // Caloric deficit
        macronutrients = {
          'protein': dailyCalories * 0.35, // 35% protein
          'carbs': dailyCalories * 0.40,   // 40% carbs
          'fats': dailyCalories * 0.25,    // 25% fats
        };
        break;
      case 'gain muscle':
        dailyCalories = bmr + 400; // Caloric surplus
        macronutrients = {
          'protein': dailyCalories * 0.35, // 35% protein
          'carbs': dailyCalories * 0.45,   // 45% carbs
          'fats': dailyCalories * 0.20,    // 20% fats
        };
        break;
      default:
        dailyCalories = bmr; // Maintenance
        macronutrients = {
          'protein': dailyCalories * 0.30, // 30% protein
          'carbs': dailyCalories * 0.40,   // 40% carbs
          'fats': dailyCalories * 0.30,    // 30% fats
        };
    }

    return {
      'dailyCalories': dailyCalories,
      'macronutrients': macronutrients,
    };
  }
} 