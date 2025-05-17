// viewmodels/recommendations_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/recommendation_model.dart';

class RecommendationsViewModel with ChangeNotifier {
  List<Recommendation> _recommendations = [];
  List<Article> _articles = [];
  User? _user;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Recommendation> get recommendations => _recommendations;
  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DietPlan? get dietPlan => _recommendations.whereType<DietPlan>().firstOrNull;
  ExercisePlan? get exercisePlan => _recommendations.whereType<ExercisePlan>().firstOrNull;

  // Update user data when UserViewModel changes
  void updateUserData(User? user) {
    _user = user;
    if (user != null) {
      fetchRecommendations(user);
      fetchArticles();
    }
    notifyListeners();
  }

  Future<void> fetchRecommendations(User user) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      _recommendations = [
        ExercisePlan(
          planName: 'General Fitness Plan',
          durationPerSession: 30,
          frequencyPerWeek: 3,
          exerciseTypes: ['cardio', 'strength'],
          intensityLevel: 'moderate',
        ),
        DietPlan(
          planName: 'Balanced Nutrition',
          targetCalories: 2000,
          hydrationGoalLiters: 2.0,
          dietType: 'balanced',
        )
      ];

      // Add user-specific recommendations
      if (user is WeightMgmtUser) {
        _recommendations.add(DietPlan(
          planName: 'Weight Management',
          targetCalories: user.calculateDailyCalorieTarget().round(),
          hydrationGoalLiters: 2.5,
          dietType: 'calorie-controlled',
        ));
      } else if (user is Elder) {
        _recommendations.add(ExercisePlan(
          planName: 'Mobility Routine',
          durationPerSession: 20,
          frequencyPerWeek: 5,
          exerciseTypes: ['stretching', 'balance'],
          intensityLevel: 'light',
        ));
      }
    } catch (e) {
      _error = 'Failed to load recommendations: ${e.toString()}';
      _recommendations = [_createFallbackRecommendation()];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchArticles() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await Future.delayed(const Duration(seconds: 1));

      _articles = [
        Article(
            title: '10 Tips for Healthier Life',
            summary: 'Lorem ipsum dolor sit amet...',
            content: 'Full content here...',
            category: 'Wellness',
            publishedDate: DateTime.now()),
        Article(
            title: 'Understanding Nutritional Labels',
            summary: 'Lorem ipsum dolor sit amet...',
            content: 'Full content here...',
            category: 'Nutrition',
            publishedDate: DateTime.now()),
      ];
    } catch (e) {
      _error = 'Failed to load articles: ${e.toString()}';
      _articles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Recommendation _createFallbackRecommendation() {
    return ExercisePlan(
      planName: 'General Fitness Plan',
      durationPerSession: 30,
      frequencyPerWeek: 3,
      exerciseTypes: ['cardio', 'strength'],
      intensityLevel: 'moderate',
    );
  }
}

class Article {
  final String title;
  final String summary;
  final String content;
  final String category;
  final DateTime publishedDate;

  Article({
    required this.title,
    required this.summary,
    required this.content,
    required this.category,
    required this.publishedDate,
  });
}