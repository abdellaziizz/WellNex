import 'package:wellnex/models/health_metrics_model.dart';
import 'package:wellnex/models/diet_plan_model.dart';

abstract class User {
  final String id;
  final String name;
  final int age;
  final String gender;
  final double height;
  final double weight;
  final String healthGoal;
  final DateTime joinDate;
  final HealthMetrics? healthMetrics;
  final DietPlan? dietPlan;

  User({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.healthGoal,
    required this.joinDate,
    this.healthMetrics,
    this.dietPlan,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'healthGoal': healthGoal,
      'joinDate': joinDate.toIso8601String(),
      'healthMetrics': healthMetrics?.toMap(),
      'dietPlan': dietPlan?.toMap(),
    };
  }
}

// Beginner User
class Beginner extends User {
  final int motivationLevel;
  final List<String> learningPreferences;
  final bool hasPreviousInjury;

  Beginner({
    required super.id,
    required super.name,
    required super.age,
    required super.gender,
    required super.height,
    required super.weight,
    required super.healthGoal,
    required super.joinDate,
    required this.motivationLevel,
    required this.learningPreferences,
    required this.hasPreviousInjury,
  });
}

// Weight Management User
class WeightMgmtUser extends User {
  final double targetWeight;
  final String dietPreference;
  final double weeklyGoal;
  final List<String> dietaryRestrictions;

  WeightMgmtUser({
    required super.id,
    required super.name,
    required super.age,
    required super.gender,
    required super.height,
    required super.weight,
    required super.healthGoal,
    required super.joinDate,
    required this.targetWeight,
    required this.dietPreference,
    required this.weeklyGoal,
    required this.dietaryRestrictions,
  });

  double calculateDailyCalorieTarget() {
    final maintenanceCalories = (10 * weight) + (6.25 * height) - (5 * age) + (gender.toLowerCase() == 'male' ? 5 : -161);
    return maintenanceCalories - (weeklyGoal * 7700) / 7; // 7700 kcal per kg fat
  }

  String getMealPlanType() {
    return dietPreference;
  }
}

// Fitness User
class FitnessUser extends User {
  final List<String> trainingTypes;
  final String fitnessLevel;
  final int workoutDaysPerWeek;
  final String? currentRoutine;

  FitnessUser({
    required super.id,
    required super.name,
    required super.age,
    required super.gender,
    required super.height,
    required super.weight,
    required super.healthGoal,
    required super.joinDate,
    required this.trainingTypes,
    required this.fitnessLevel,
    required this.workoutDaysPerWeek,
    this.currentRoutine,
  });
}

// Elder User
class Elder extends User {
  final String mobilityLevel;
  final List<String> healthConditions;
  final bool usesAssistiveDevice;

  Elder({
    required super.id,
    required super.name,
    required super.age,
    required super.gender,
    required super.height,
    required super.weight,
    required super.healthGoal,
    required super.joinDate,
    required this.mobilityLevel,
    required this.healthConditions,
    required this.usesAssistiveDevice,
  });

  bool needsSupervisedExercise() {
    return mobilityLevel == 'low' || usesAssistiveDevice;
  }

  String getRecommendedActivities() {
    if (mobilityLevel == 'low') return 'Chair exercises, Light walking';
    if (mobilityLevel == 'moderate') return 'Swimming, Light yoga';
    return 'Brisk walking, Tai chi';
  }
}

// Busy User
class BusyUser extends User {
  final int workHoursPerDay;
  final int availableExerciseTime;
  final String stressManagementPreference;

  BusyUser({
    required super.id,
    required super.name,
    required super.age,
    required super.gender,
    required super.height,
    required super.weight,
    required super.healthGoal,
    required super.joinDate,
    required this.workHoursPerDay,
    required this.availableExerciseTime,
    required this.stressManagementPreference,
  });

  String getTimeEfficientWorkouts() {
    if (availableExerciseTime < 20) {
      return 'High-intensity interval training (HIIT) 3x/week';
    } else if (availableExerciseTime < 40) {
      return 'Circuit training or compound exercises';
    }
    return 'Split routines with focused muscle groups';
  }

  String getStressReductionTips() {
    switch (stressManagementPreference) {
      case 'meditation':
        return '5-minute breathing exercises between meetings';
      case 'physical':
        return 'Quick desk stretches every hour';
      case 'social':
        return 'Walking meetings when possible';
      default:
        return 'Micro-breaks throughout the day';
    }
  }
}
