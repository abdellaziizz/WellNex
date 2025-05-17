import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import 'package:wellnex/models/diet_plan_model.dart';
import 'package:wellnex/models/health_metrics_model.dart';
import 'package:wellnex/services/health_metrics_service.dart';
import 'package:wellnex/services/diet_service.dart';
import 'package:wellnex/services/auth_service.dart';
import 'package:wellnex/services/firebase_service.dart';

class HealthRecommendationsViewModel extends ChangeNotifier {
  final HealthMetricsService _healthMetricsService = HealthMetricsService();
  final DietService _dietService = DietService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseService _firebaseService = FirebaseService();
  late final AuthService _authService;

  HealthMetrics? _healthMetrics;
  DietPlan? _dietPlan;
  String? _error;
  String? _userId;
  bool _isLoading = false;

  HealthRecommendationsViewModel() {
    _authService = AuthService(_firebaseService);
  }

  // Getters
  HealthMetrics? get healthMetrics => _healthMetrics;
  DietPlan? get dietPlan => _dietPlan;
  String? get error => _error;
  bool get isLoading => _isLoading;

  // Initialize with current user
  Future<void> initialize() async {
    final currentUser = _authService.currentUser;
    if (currentUser != null && currentUser.email != null) {
      await loadUserDataByEmail(currentUser.email!);
    }
  }

  // Load user data by email
  Future<void> loadUserDataByEmail(String email) async {
    try {
      _isLoading = true;
      notifyListeners();

      // First, get the user document by email
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        _error = 'User data not found';
        notifyListeners();
        return;
      }

      // Set the user ID and load their plans
      _userId = userQuery.docs.first.id;
      await _loadLatestPlans();

    } catch (e) {
      _error = 'Error loading user data: ${e.toString()}';
      developer.log('Error loading user data: ${e.toString()}', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set user ID when user logs in or signs up
  Future<void> setUserId(String userId) async {
    developer.log('Setting user ID: $userId');
    _userId = userId;
    _error = null; // Reset any previous errors
    await _loadLatestPlans(); // Load the most recent plans
    notifyListeners(); // Notify listeners after loading
  }

  // Load the most recent health and diet plans
  Future<void> _loadLatestPlans() async {
    if (_userId == null) {
      developer.log('No user ID available for loading plans');
      return;
    }

    try {
      developer.log('Loading plans for user: $_userId');
      _isLoading = true;
      notifyListeners();

      // First try to get active plan
      var dietDoc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('dietPlans')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      // If no active plan found, try to get and activate the most recent plan
      if (dietDoc.docs.isEmpty) {
        developer.log('No active plan found, trying to activate most recent plan');
        
        // Get most recent plan regardless of active status
        dietDoc = await _firestore
            .collection('users')
            .doc(_userId)
            .collection('dietPlans')
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get();

        if (dietDoc.docs.isNotEmpty) {
          // Activate this plan
          final batch = _firestore.batch();
          final planRef = dietDoc.docs.first.reference;
          
          batch.update(planRef, {'isActive': true});
          await batch.commit();
          
          developer.log('Activated most recent plan');
        }
      }

      developer.log('Diet plans query result - number of docs: ${dietDoc.docs.length}');

      if (dietDoc.docs.isNotEmpty) {
        final data = dietDoc.docs.first.data();
        developer.log('Found diet plan data: ${data.toString()}');
        _dietPlan = DietPlan.fromMap(data);
        
        // Load health metrics from the same diet plan
        _healthMetrics = HealthMetrics(
          bmi: data['bmi'] ?? 0.0,
          bmiCategory: data['bmiCategory'] ?? '',
          bmr: data['bmr'] ?? 0.0,
          dailyCalories: data['dailyCalories'] ?? 0.0,
          macronutrients: Map<String, double>.from(data['macronutrients'] ?? {}),
        );
        developer.log('Successfully loaded diet plan and health metrics');
      } else {
        developer.log('No diet plan found for user');
        _error = 'No diet plan found. Please complete your health assessment.';
      }

    } catch (e) {
      _error = 'Error loading saved plans: ${e.toString()}';
      developer.log('Error loading plans: ${e.toString()}', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save both health metrics and diet plan as new records
  Future<void> _savePlans(HealthMetrics metrics, DietPlan plan) async {
    if (_userId == null) return;

    try {
      final batch = _firestore.batch();
      
      // First, deactivate any existing active plans
      final existingPlans = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('dietPlans')
          .where('isActive', isEqualTo: true)
          .get();
          
      for (var doc in existingPlans.docs) {
        batch.update(doc.reference, {'isActive': false});
      }

      // Save diet plan as a new record
      final dietRef = _firestore
          .collection('users')
          .doc(_userId)
          .collection('dietPlans')
          .doc();
          
      batch.set(dietRef, {
        ...plan.toMap(),
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'bmi': metrics.bmi,
        'bmiCategory': metrics.bmiCategory,
        'bmr': metrics.bmr,
        'dailyCalories': metrics.dailyCalories,
        'macronutrients': metrics.macronutrients,
      });

      await batch.commit();
      
      // Update local state
      _dietPlan = plan;
      _healthMetrics = metrics;
      notifyListeners();
    } catch (e) {
      _error = 'Error saving plans: ${e.toString()}';
      developer.log('Error saving plans: ${e.toString()}', error: e);
      notifyListeners();
    }
  }

  // Get all health plans for the current user
  Future<List<HealthMetrics>> getHealthPlansHistory() async {
    if (_userId == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('healthPlans')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return HealthMetrics(
          bmi: data['bmi'] ?? 0.0,
          bmiCategory: data['bmiCategory'] ?? '',
          bmr: data['bmr'] ?? 0.0,
          dailyCalories: data['dailyCalories'] ?? 0.0,
          macronutrients: Map<String, double>.from(data['macronutrients'] ?? {}),
        );
      }).toList();
    } catch (e) {
      _error = 'Error loading health plans history: ${e.toString()}';
      notifyListeners();
      return [];
    }
  }

  // Get all diet plans for the current user
  Future<List<DietPlan>> getDietPlansHistory() async {
    if (_userId == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('dietPlans')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => DietPlan.fromMap(doc.data())).toList();
    } catch (e) {
      _error = 'Error loading diet plans history: ${e.toString()}';
      notifyListeners();
      return [];
    }
  }

  // Calculate and update health metrics
  Future<void> calculateHealthMetrics({
    required double weight,
    required double height,
    required int age,
    required String gender,
    required String healthGoal,
  }) async {
    if (_userId == null) {
      _error = 'User not logged in';
      developer.log('Cannot calculate metrics - user not logged in');
      notifyListeners();
      return;
    }

    try {
      developer.log('Calculating health metrics for user: $_userId');
      _isLoading = true;
      notifyListeners();

      // Calculate BMI
      final bmi = _healthMetricsService.calculateBMI(weight, height);
      final bmiCategory = _healthMetricsService.getBMICategory(bmi);
      
      // Calculate BMR
      final bmr = _healthMetricsService.calculateBMR(weight, height, age, gender);
      
      // Calculate daily calories and macronutrients
      final calorieInfo = _healthMetricsService.calculateDailyCalories(bmr, healthGoal);

      developer.log('Calculated metrics - BMI: $bmi, BMR: $bmr, Daily Calories: ${calorieInfo['dailyCalories']}');

      // Create health metrics object
      _healthMetrics = HealthMetrics(
        bmi: bmi,
        bmiCategory: bmiCategory,
        bmr: bmr,
        dailyCalories: calorieInfo['dailyCalories'],
        macronutrients: Map<String, double>.from(calorieInfo['macronutrients']),
      );

      // Generate diet plan with meal suggestions
      final mealSuggestions = DietPlan.generateMealSuggestions(
        healthGoal,
        calorieInfo['dailyCalories'],
      );

      // Create complete diet plan
      _dietPlan = DietPlan(
        healthGoal: healthGoal,
        dailyCalories: calorieInfo['dailyCalories'],
        macronutrients: Map<String, double>.from(calorieInfo['macronutrients']),
        mealSuggestions: mealSuggestions,
      );

      developer.log('Created new diet plan, saving to Firestore...');

      // Save both plans as new records
      if (_dietPlan != null && _healthMetrics != null) {
        await _savePlans(_healthMetrics!, _dietPlan!);
        developer.log('Successfully saved new plans to Firestore');
      }

      _error = null;
    } catch (e) {
      _error = 'Error calculating health metrics: ${e.toString()}';
      developer.log('Error calculating health metrics: ${e.toString()}', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Retry loading plans
  Future<void> retryLoading() async {
    if (_userId == null) return;
    _error = null;
    await _loadLatestPlans();
  }

  // Get dietary advice based on BMI category and health goal
  String getDietaryAdvice() {
    if (_healthMetrics == null || _dietPlan == null) {
      return 'Please calculate your health metrics first.';
    }
    return _dietService.getDietaryAdvice(_healthMetrics!.bmiCategory, _dietPlan!.healthGoal);
  }

  // Format macronutrients for display
  Map<String, String> getFormattedMacronutrients() {
    if (_dietPlan == null) {
      return {};
    }

    return _dietPlan!.macronutrients.map((key, value) {
      // Convert calories to grams
      double grams;
      switch (key) {
        case 'protein':
        case 'carbs':
          grams = value / 4; // 4 calories per gram
          break;
        case 'fats':
          grams = value / 9; // 9 calories per gram
          break;
        default:
          grams = 0;
      }
      return MapEntry(key, '${grams.toStringAsFixed(1)}g (${value.toStringAsFixed(0)} kcal)');
    });
  }

  // Get daily calorie target
  String getFormattedDailyCalories() {
    if (_dietPlan == null) {
      return 'Not calculated';
    }
    return '${_dietPlan!.dailyCalories.toStringAsFixed(0)} kcal';
  }

  // Get BMI status with interpretation
  String getBMIStatus() {
    if (_healthMetrics == null) {
      return 'Not calculated';
    }
    return '${_healthMetrics!.bmi.toStringAsFixed(1)} (${_healthMetrics!.bmiCategory})';
  }
} 