class HealthMetrics {
  final double bmi;
  final String bmiCategory;
  final double bmr;
  final double dailyCalories;
  final Map<String, double> macronutrients;

  HealthMetrics({
    required this.bmi,
    required this.bmiCategory,
    required this.bmr,
    required this.dailyCalories,
    required this.macronutrients,
  });

  Map<String, dynamic> toMap() {
    return {
      'bmi': bmi,
      'bmiCategory': bmiCategory,
      'bmr': bmr,
      'dailyCalories': dailyCalories,
      'macronutrients': macronutrients,
    };
  }

  factory HealthMetrics.fromMap(Map<String, dynamic> map) {
    return HealthMetrics(
      bmi: map['bmi']?.toDouble() ?? 0.0,
      bmiCategory: map['bmiCategory'] ?? 'Not calculated',
      bmr: map['bmr']?.toDouble() ?? 0.0,
      dailyCalories: map['dailyCalories']?.toDouble() ?? 0.0,
      macronutrients: Map<String, double>.from(map['macronutrients'] ?? {}),
    );
  }
} 