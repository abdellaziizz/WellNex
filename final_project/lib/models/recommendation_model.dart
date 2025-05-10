import 'package:wellnex/models/user_model.dart';

// Abstract Recommendation Class
abstract class Recommendation {
  final String planName;

  Recommendation({required this.planName});

  void generatePlan();
}

// Diet Plan
class DietPlan extends Recommendation {
  final int targetCalories;
  final double hydrationGoalLiters;
  final String dietType;

  DietPlan({
    required super.planName,
    required this.targetCalories,
    required this.hydrationGoalLiters,
    required this.dietType,
  });

  @override
  void generatePlan() {
    // Implementation for generating a diet plan
  }

  Map<String, int> calculateDailyNeeds(User user) {
    final bmr = calculateBasalMetabolicRate(user);
    int protein = 0;
    int carbs = 0;
    int fats = 0;

    switch (dietType.toLowerCase()) {
      case 'balanced':
        protein = ((bmr * 0.3) / 4).round();
        carbs = ((bmr * 0.45) / 4).round();
        fats = ((bmr * 0.25) / 9).round();
        break;
      case 'low carb':
        protein = ((bmr * 0.4) / 4).round();
        carbs = ((bmr * 0.2) / 4).round();
        fats = ((bmr * 0.4) / 9).round();
        break;
      case 'high protein':
        protein = ((bmr * 0.45) / 4).round();
        carbs = ((bmr * 0.35) / 4).round();
        fats = ((bmr * 0.2) / 9).round();
        break;
      default:
        protein = ((bmr * 0.3) / 4).round();
        carbs = ((bmr * 0.4) / 4).round();
        fats = ((bmr * 0.3) / 9).round();
    }

    return {
      'calories': bmr.round(),
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
    };
  }

  int calculateBasalMetabolicRate(User user) {
    if (user.gender.toLowerCase() == 'male') {
      return (88.362 + (13.397 * user.weight) + (4.799 * user.height) - (5.677 * user.age)).round();
    } else {
      return (447.593 + (9.247 * user.weight) + (3.098 * user.height) - (4.330 * user.age)).round();
    }
  }
}

// Meal Suggestions
class Meal {
  final int mealsPerDay;
  final int caloriesPerMeal;
  final List<String> restrictedFoods;

  Meal({
    required this.mealsPerDay,
    required this.caloriesPerMeal,
    required this.restrictedFoods,
  });

  int calculateTotalCalories() {
    return mealsPerDay * caloriesPerMeal;
  }

  List<String> suggestMealsByDietType(String dietType) {
    List<String> suggestions = [];

    switch (dietType.toLowerCase()) {
      case 'keto':
        suggestions = [
          'Avocado and bacon breakfast bowl',
          'Grilled chicken with asparagus',
          'Salmon with broccoli and cheese sauce',
          'Steak with buttered green beans',
        ];
        break;
      case 'vegan':
        suggestions = [
          'Overnight oats with berries',
          'Lentil and vegetable soup',
          'Chickpea curry with rice',
          'Tofu stir-fry with mixed vegetables',
        ];
        break;
      case 'paleo':
        suggestions = [
          'Egg and vegetable breakfast scramble',
          'Grilled chicken salad with olive oil dressing',
          'Baked salmon with sweet potato',
          'Grass-fed beef with steamed vegetables',
        ];
        break;
      default:
        suggestions = [
          'Greek yogurt with granola and fruit',
          'Turkey sandwich with side salad',
          'Baked chicken with vegetables and quinoa',
          'Fish with roasted vegetables',
        ];
    }

    return suggestions;
  }
}

// Exercise Plan
class ExercisePlan extends Recommendation {
  final int durationPerSession;
  final int frequencyPerWeek;
  final List<String> exerciseTypes;
  final String intensityLevel;

  ExercisePlan({
    required super.planName,
    required this.durationPerSession,
    required this.frequencyPerWeek,
    required this.exerciseTypes,
    required this.intensityLevel,
  });

  @override
  void generatePlan() {
    // Implementation for generating an exercise plan
  }

  List<String> suggestExercises() {
    List<String> suggestions = [];

    if (exerciseTypes.contains('cardio')) {
      if (intensityLevel == 'beginner') {
        suggestions.addAll(['Walking', 'Light cycling', 'Swimming (leisure)']);
      } else if (intensityLevel == 'intermediate') {
        suggestions.addAll(['Jogging', 'Cycling', 'Swimming laps']);
      } else {
        suggestions.addAll(['Running', 'HIIT', 'Spinning']);
      }
    }

    if (exerciseTypes.contains('strength')) {
      if (intensityLevel == 'beginner') {
        suggestions.addAll(['Bodyweight squats', 'Modified push-ups', 'Resistance band exercises']);
      } else if (intensityLevel == 'intermediate') {
        suggestions.addAll(['Dumbbell training', 'Kettlebell workouts', 'Circuit training']);
      } else {
        suggestions.addAll(['Heavy weightlifting', 'Advanced calisthenics', 'Power training']);
      }
    }

    if (exerciseTypes.contains('flexibility')) {
      suggestions.addAll(['Yoga', 'Stretching routine', 'Pilates']);
    }

    return suggestions;
  }
}
