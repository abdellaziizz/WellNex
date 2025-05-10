import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/recommendation_model.dart';
import '../services/firebase_service.dart';

class RecommendationRepository {
  final FirebaseService _firebaseService;

  RecommendationRepository(this._firebaseService);

  // Main collection reference
  CollectionReference<Map<String, dynamic>> _userRecommendations(String userId) =>
      _firebaseService.firestore.collection('users/$userId/recommendations');

  // Save a recommendation to Firestore
  Future<String> saveRecommendation(String userId, Recommendation recommendation) async {
    try {
      final docRef = await _userRecommendations(userId).add(_recommendationToMap(recommendation));
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save recommendation: ${e.toString()}');
    }
  }

  // Get all recommendations for a user
  Stream<List<Recommendation>> getRecommendations(String userId) {
    return _userRecommendations(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => _recommendationFromFirestore(doc))
        .whereType<Recommendation>()
        .toList());
  }

  // Generate personalized recommendations based on user type
  Future<List<Recommendation>> generatePersonalizedRecommendations(User user) async {
    try {
      // Clear old recommendations
      await _clearOldRecommendations(user.id);

      // Generate new recommendations
      final List<Recommendation> recommendations = [];

      // Diet recommendation for weight management users
      if (user is WeightMgmtUser) {
        recommendations.add(DietPlan(
          planName: '${user.dietPreference} Diet Plan',
          targetCalories: user.calculateDailyCalorieTarget().round(),
          hydrationGoalLiters: 2.5,
          dietType: user.dietPreference,
        ));
      }

      // Exercise recommendation for all users
      recommendations.add(_generateExercisePlan(user));

      // Save all recommendations
      final batch = _firebaseService.firestore.batch();
      for (final recommendation in recommendations) {
        final docRef = _userRecommendations(user.id).doc();
        batch.set(docRef, _recommendationToMap(recommendation));
      }
      await batch.commit();

      return recommendations;
    } catch (e) {
      throw Exception('Failed to generate recommendations: ${e.toString()}');
    }
  }

  // Helper methods
  Future<void> _clearOldRecommendations(String userId) async {
    final query = await _userRecommendations(userId).get();
    final batch = _firebaseService.firestore.batch();
    for (final doc in query.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  ExercisePlan _generateExercisePlan(User user) {
    if (user is Beginner) {
      return ExercisePlan(
        planName: 'Beginner Fitness Plan',
        durationPerSession: 30,
        frequencyPerWeek: 3,
        exerciseTypes: ['cardio', 'strength'],
        intensityLevel: 'beginner',
      );
    } else if (user is Elder) {
      return ExercisePlan(
        planName: 'Senior Mobility Plan',
        durationPerSession: 20,
        frequencyPerWeek: 5,
        exerciseTypes: user.getRecommendedActivities().split(',').map((e) => e.trim()).toList(),
        intensityLevel: 'low',
      );
    } else if (user is BusyUser) {
      return ExercisePlan(
        planName: 'Time-Efficient Workouts',
        durationPerSession: user.availableExerciseTime,
        frequencyPerWeek: user.workHoursPerDay > 8 ? 3 : 4,
        exerciseTypes: [user.getTimeEfficientWorkouts()],
        intensityLevel: 'high',
      );
    } else if (user is FitnessUser) {
      return ExercisePlan(
        planName: 'Advanced Training Plan',
        durationPerSession: 60,
        frequencyPerWeek: user.workoutDaysPerWeek,
        exerciseTypes: user.trainingTypes,
        intensityLevel: user.fitnessLevel,
      );
    } else {
      return ExercisePlan(
        planName: 'General Fitness Plan',
        durationPerSession: 45,
        frequencyPerWeek: 3,
        exerciseTypes: ['cardio', 'strength', 'flexibility'],
        intensityLevel: 'moderate',
      );
    }
  }

  Map<String, dynamic> _recommendationToMap(Recommendation recommendation) {
    final base = {
      'planName': recommendation.planName,
      'createdAt': FieldValue.serverTimestamp(),
      'type': recommendation.runtimeType.toString(),
    };

    if (recommendation is DietPlan) {
      base.addAll({
        'subtype': 'diet',
        'targetCalories': recommendation.targetCalories,
        'hydrationGoal': recommendation.hydrationGoalLiters,
        'dietType': recommendation.dietType,
      });
    } else if (recommendation is ExercisePlan) {
      base.addAll({
        'subtype': 'exercise',
        'duration': recommendation.durationPerSession,
        'frequency': recommendation.frequencyPerWeek,
        'intensity': recommendation.intensityLevel,
        'exerciseTypes': recommendation.exerciseTypes,
      });
    }

    return base;
  }

  Recommendation? _recommendationFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return null;

    final type = data['type'] as String?;
    final planName = data['planName'] as String? ?? 'Unnamed Plan';

    if (type == 'DietPlan') {
      return DietPlan(
        planName: planName,
        targetCalories: data['targetCalories'] as int? ?? 2000,
        hydrationGoalLiters: data['hydrationGoal'] as double? ?? 2.0,
        dietType: data['dietType'] as String? ?? 'balanced',
      );
    } else if (type == 'ExercisePlan') {
      return ExercisePlan(
        planName: planName,
        durationPerSession: data['duration'] as int? ?? 30,
        frequencyPerWeek: data['frequency'] as int? ?? 3,
        exerciseTypes: List<String>.from(data['exerciseTypes'] ?? ['general']),
        intensityLevel: data['intensity'] as String? ?? 'moderate',
      );
    }

    return null;
  }

  // Mark recommendation as completed
  Future<void> markAsCompleted(String userId, String recommendationId) async {
    try {
      await _userRecommendations(userId).doc(recommendationId).update({
        'isCompleted': true,
        'completedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark recommendation complete: ${e.toString()}');
    }
  }

  // Get meal suggestions for a diet plan
  Future<List<String>> getMealSuggestions(String dietType) async {
    // This could be expanded to pull from Firestore or use local logic
    return Meal(
      mealsPerDay: 3,
      caloriesPerMeal: 600,
      restrictedFoods: [],
    ).suggestMealsByDietType(dietType);
  }
}