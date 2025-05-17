import './user_repository.dart';
import './workout_repository.dart';
import './meal_plan_repository.dart';
import './health_repository.dart';

class Repository {
  // Private singleton instance
  static Repository? _instance;
  
  // Repositories
  late final UserRepository _userRepository;
  late final WorkoutRepository _workoutRepository;
  late final MealPlanRepository _mealPlanRepository;
  late final HealthRepository _healthRepository;
  
  // Private constructor
  Repository._internal() {
    _userRepository = UserRepository();
    _workoutRepository = WorkoutRepository();
    _mealPlanRepository = MealPlanRepository();
    _healthRepository = HealthRepository();
  }
  
  // Factory constructor
  factory Repository() {
    _instance ??= Repository._internal();
    return _instance!;
  }
  
  // Repository getters
  UserRepository get user => _userRepository;
  WorkoutRepository get workout => _workoutRepository;
  MealPlanRepository get mealPlan => _mealPlanRepository;
  HealthRepository get health => _healthRepository;
  
  // Reset for testing purposes
  static void reset() {
    _instance = null;
  }
} 