import 'package:flutter/material.dart';
import 'models/user_model.dart';
import 'models/recommendation_model.dart';

// Abstract Factory
abstract class UserFactory {
  User createProfile(Map<String, dynamic> data);
  Recommendation createRecommendation(User user);

  static UserFactory getFactory(User user) {
    if (user is Elder || user is BusyUser || user.age > 40) {
      return ConcreteFactoryB();
    }
    return ConcreteFactoryA();
  }
}

// Factory for Beginner, Fitness, WeightMgmt
class ConcreteFactoryA implements UserFactory {
  @override
  User createProfile(Map<String, dynamic> data) {
    try {
      final age = data['age'] as int? ?? 30;
      final height = (data['height'] as num?)?.toDouble() ?? 170.0;
      final weight = (data['weight'] as num?)?.toDouble() ?? 70.0;
      final healthGoal = data['healthGoal'] as String? ?? 'General fitness';
      final joinDate = DateTime.tryParse(data['joinDate'] as String? ?? '') ?? DateTime.now();
      final userType = (data['userType'] as String? ?? '').toLowerCase();

      switch (userType) {
        case 'beginner':
          return Beginner(
            id: data['id'] as String? ?? UniqueKey().toString(),
            name: data['name'] as String? ?? 'New User',
            age: age,
            gender: data['gender'] as String? ?? 'Other',
            height: height,
            weight: weight,
            healthGoal: healthGoal,
            joinDate: joinDate,
            motivationLevel: (data['motivationLevel'] as int?)?.clamp(1, 10) ?? 5,
            learningPreferences: _parseStringList(data['learningPreferences']),
            hasPreviousInjury: data['hasPreviousInjury'] as bool? ?? false,
          );
        case 'weightmanagement':
          return WeightMgmtUser(
            id: data['id'] as String? ?? UniqueKey().toString(),
            name: data['name'] as String? ?? 'New User',
            age: age,
            gender: data['gender'] as String? ?? 'Other',
            height: height,
            weight: weight,
            healthGoal: healthGoal,
            joinDate: joinDate,
            targetWeight: (data['targetWeight'] as num?)?.toDouble() ?? (weight - 5),
            dietPreference: data['dietPreference'] as String? ?? 'Balanced',
            weeklyGoal: (data['weeklyGoal'] as num?)?.toDouble().clamp(0.1, 1.0) ?? 0.5,
            dietaryRestrictions: _parseStringList(data['dietaryRestrictions']),
          );
        case 'fitness':
          return FitnessUser(
            id: data['id'] as String? ?? UniqueKey().toString(),
            name: data['name'] as String? ?? 'New User',
            age: age,
            gender: data['gender'] as String? ?? 'Other',
            height: height,
            weight: weight,
            healthGoal: healthGoal,
            joinDate: joinDate,
            trainingTypes: _parseStringList(data['trainingTypes'], defaults: ['Cardio']),
            fitnessLevel: _validateFitnessLevel(data['fitnessLevel'] as String?),
            workoutDaysPerWeek: (data['workoutDaysPerWeek'] as int?)?.clamp(1, 7) ?? 3,
            currentRoutine: data['currentRoutine'] as String?,
          );
        default:
          return Beginner(
            id: data['id'] as String? ?? UniqueKey().toString(),
            name: data['name'] as String? ?? 'New User',
            age: age,
            gender: data['gender'] as String? ?? 'Other',
            height: height,
            weight: weight,
            healthGoal: healthGoal,
            joinDate: joinDate,
            motivationLevel: 5,
            learningPreferences: ['visual'],
            hasPreviousInjury: false,
          );
      }
    } catch (e) {
      debugPrint('Error creating profile in ConcreteFactoryA: $e');
      throw Exception('Failed to create user profile');
    }
  }

  @override
  Recommendation createRecommendation(User user) {
    try {
      if (user is WeightMgmtUser) {
        return DietPlan(
          planName: "${user.name}'s Weight Management Plan",
          targetCalories: user.calculateDailyCalorieTarget().round(),
          hydrationGoalLiters: 2.5,
          dietType: user.getMealPlanType(),
        );
      } else if (user is FitnessUser) {
        return ExercisePlan(
          planName: "${user.name}'s ${user.fitnessLevel} Training Plan",
          durationPerSession: user.workoutDaysPerWeek > 4 ? 45 : 60,
          frequencyPerWeek: user.workoutDaysPerWeek,
          exerciseTypes: user.trainingTypes,
          intensityLevel: user.fitnessLevel.toLowerCase(),
        );
      } else if (user is Beginner) {
        return ExercisePlan(
          planName: "${user.name}'s Beginner Program",
          durationPerSession: 30,
          frequencyPerWeek: 3,
          exerciseTypes: ['cardio', 'strength', 'flexibility'],
          intensityLevel: 'beginner',
        );
      }
      return _createDefaultRecommendation();
    } catch (e) {
      debugPrint('Error creating recommendation in ConcreteFactoryA: $e');
      return _createDefaultRecommendation();
    }
  }

  Recommendation _createDefaultRecommendation() {
    return ExercisePlan(
      planName: 'General Fitness Plan',
      durationPerSession: 30,
      frequencyPerWeek: 3,
      exerciseTypes: ['cardio', 'strength'],
      intensityLevel: 'moderate',
    );
  }

  List<String> _parseStringList(dynamic input, {List<String> defaults = const []}) {
    if (input is List) {
      return input.whereType<String>().toList();
    }
    return defaults;
  }

  String _validateFitnessLevel(String? level) {
    const validLevels = ['Beginner', 'Intermediate', 'Advanced'];
    return validLevels.contains(level) ? level! : 'Intermediate';
  }
}

// Factory for Elder, Busy
class ConcreteFactoryB implements UserFactory {
  @override
  User createProfile(Map<String, dynamic> data) {
    try {
      final age = data['age'] as int? ?? 30;
      final height = (data['height'] as num?)?.toDouble() ?? 170.0;
      final weight = (data['weight'] as num?)?.toDouble() ?? 70.0;
      final healthGoal = data['healthGoal'] as String? ?? 'General wellness';
      final joinDate = DateTime.tryParse(data['joinDate'] as String? ?? '') ?? DateTime.now();
      final userType = (data['userType'] as String? ?? '').toLowerCase();

      switch (userType) {
        case 'elder':
          return Elder(
            id: data['id'] as String? ?? UniqueKey().toString(),
            name: data['name'] as String? ?? 'New User',
            age: age,
            gender: data['gender'] as String? ?? 'Other',
            height: height,
            weight: weight,
            healthGoal: healthGoal,
            joinDate: joinDate,
            mobilityLevel: _validateMobilityLevel(data['mobilityLevel'] as String?),
            healthConditions: _parseStringList(data['healthConditions']),
            usesAssistiveDevice: data['usesAssistiveDevice'] as bool? ?? false,
          );
        case 'busy':
          return BusyUser(
            id: data['id'] as String? ?? UniqueKey().toString(),
            name: data['name'] as String? ?? 'New User',
            age: age,
            gender: data['gender'] as String? ?? 'Other',
            height: height,
            weight: weight,
            healthGoal: healthGoal,
            joinDate: joinDate,
            workHoursPerDay: (data['workHoursPerDay'] as int?)?.clamp(1, 24) ?? 10,
            availableExerciseTime: (data['availableExerciseTime'] as int?)?.clamp(10, 120) ?? 30,
            stressManagementPreference: _validateStressPreference(data['stressManagementPreference'] as String?),
          );
        default:
          return Elder(
            id: data['id'] as String? ?? UniqueKey().toString(),
            name: data['name'] as String? ?? 'New User',
            age: age,
            gender: data['gender'] as String? ?? 'Other',
            height: height,
            weight: weight,
            healthGoal: healthGoal,
            joinDate: joinDate,
            mobilityLevel: 'moderate',
            healthConditions: [],
            usesAssistiveDevice: false,
          );
      }
    } catch (e) {
      debugPrint('Error creating profile in ConcreteFactoryB: $e');
      throw Exception('Failed to create user profile');
    }
  }

  @override
  Recommendation createRecommendation(User user) {
    try {
      if (user is Elder) {
        return ExercisePlan(
          planName: 'Senior Wellness Program',
          durationPerSession: user.mobilityLevel == 'low' ? 15 : 25,
          frequencyPerWeek: user.needsSupervisedExercise() ? 2 : 3,
          exerciseTypes: _parseActivityList(user.getRecommendedActivities()),
          intensityLevel: 'low',
        );
      } else if (user is BusyUser) {
        return ExercisePlan(
          planName: 'Time-Efficient ${user.stressManagementPreference} Routine',
          durationPerSession: user.availableExerciseTime.clamp(10, 45),
          frequencyPerWeek: user.workHoursPerDay > 8 ? 5 : 3,
          exerciseTypes: [user.getTimeEfficientWorkouts()],
          intensityLevel: 'moderate',
        );
      }
      return _createDefaultRecommendation();
    } catch (e) {
      debugPrint('Error creating recommendation in ConcreteFactoryB: $e');
      return _createDefaultRecommendation();
    }
  }

  Recommendation _createDefaultRecommendation() {
    return DietPlan(
      planName: 'Healthy Lifestyle Plan',
      targetCalories: 2000,
      hydrationGoalLiters: 2.0,
      dietType: 'Balanced',
    );
  }

  List<String> _parseStringList(dynamic input, {List<String> defaults = const []}) {
    if (input is List) {
      return input.whereType<String>().toList();
    }
    return defaults;
  }

  List<String> _parseActivityList(String activities) {
    return activities.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  String _validateMobilityLevel(String? level) {
    const validLevels = ['low', 'moderate', 'high'];
    return validLevels.contains(level?.toLowerCase()) ? level!.toLowerCase() : 'moderate';
  }

  String _validateStressPreference(String? preference) {
    const validPreferences = ['meditation', 'physical', 'social', 'other'];
    return validPreferences.contains(preference?.toLowerCase()) ? preference!.toLowerCase() : 'physical';
  }
}
