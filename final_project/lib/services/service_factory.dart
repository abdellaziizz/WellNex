import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './database_service.dart';
import './workout_service.dart';
import './meal_plan_service.dart';
import './health_data_service.dart';

class ServiceFactory {
  // Private singleton instance
  static ServiceFactory? _instance;
  
  // Services
  late final DatabaseService _databaseService;
  late final WorkoutService _workoutService;
  late final MealPlanService _mealPlanService;
  late final HealthDataService _healthDataService;
  
  // Firebase instances
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  
  // Private constructor
  ServiceFactory._internal(this._firestore, this._auth) {
    _databaseService = DatabaseService(_firestore);
    _workoutService = WorkoutService(_firestore);
    _mealPlanService = MealPlanService(_firestore);
    _healthDataService = HealthDataService(_firestore);
  }
  
  // Factory constructor
  factory ServiceFactory({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) {
    _instance ??= ServiceFactory._internal(
      firestore ?? FirebaseFirestore.instance,
      auth ?? FirebaseAuth.instance,
    );
    
    return _instance!;
  }
  
  // Service getters
  DatabaseService get database => _databaseService;
  WorkoutService get workout => _workoutService;
  MealPlanService get mealPlan => _mealPlanService;
  HealthDataService get healthData => _healthDataService;
  
  // Firebase getters
  FirebaseFirestore get firestore => _firestore;
  FirebaseAuth get auth => _auth;
  
  // Current user shortcut
  String? get currentUserId => _auth.currentUser?.uid;
  
  // Reset for testing purposes
  static void reset() {
    _instance = null;
  }
} 