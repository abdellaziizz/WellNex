class DietPlan {
  final String healthGoal;
  final double dailyCalories;
  final Map<String, double> macronutrients;
  final Map<String, List<String>> mealSuggestions;

  DietPlan({
    required this.healthGoal,
    required this.dailyCalories,
    required this.macronutrients,
    required this.mealSuggestions,
  });

  Map<String, dynamic> toMap() {
    return {
      'healthGoal': healthGoal,
      'dailyCalories': dailyCalories,
      'macronutrients': macronutrients,
      'mealSuggestions': mealSuggestions,
    };
  }

  factory DietPlan.fromMap(Map<String, dynamic> map) {
    return DietPlan(
      healthGoal: map['healthGoal'] ?? '',
      dailyCalories: map['dailyCalories']?.toDouble() ?? 0.0,
      macronutrients: Map<String, double>.from(map['macronutrients'] ?? {}),
      mealSuggestions: Map<String, List<String>>.from(
        map['mealSuggestions']?.map((key, value) => MapEntry(
          key,
          List<String>.from(value),
        )) ?? {},
      ),
    );
  }

  // Generate meal suggestions based on health goal and calories
  static Map<String, List<String>> generateMealSuggestions(String healthGoal, double dailyCalories) {
    Map<String, List<String>> suggestions = {
      'breakfast': [],
      'lunch': [],
      'dinner': [],
      'snacks': [],
    };

    // Example meal suggestions based on health goal
    switch (healthGoal.toLowerCase()) {
      case 'lose weight':
        suggestions = {
          'breakfast': [
            'Oatmeal with berries and protein powder',
            'Greek yogurt with honey and nuts',
            'Egg white omelet with vegetables',
          ],
          'lunch': [
            'Grilled chicken salad with olive oil dressing',
            'Quinoa bowl with roasted vegetables',
            'Turkey and avocado wrap with whole grain bread',
          ],
          'dinner': [
            'Baked salmon with steamed broccoli',
            'Lean beef stir-fry with brown rice',
            'Grilled tofu with mixed vegetables',
          ],
          'snacks': [
            'Apple slices with almond butter',
            'Carrot sticks with hummus',
            'Protein smoothie',
          ],
        };
        break;

      case 'gain muscle':
        suggestions = {
          'breakfast': [
            'Protein pancakes with banana and honey',
            'Scrambled eggs with whole grain toast',
            'Protein smoothie bowl with granola',
          ],
          'lunch': [
            'Chicken breast with sweet potato',
            'Tuna pasta with olive oil',
            'Rice bowl with beef and vegetables',
          ],
          'dinner': [
            'Salmon with quinoa and asparagus',
            'Lean beef burger with avocado',
            'Chicken stir-fry with brown rice',
          ],
          'snacks': [
            'Protein shake with banana',
            'Greek yogurt with nuts',
            'Peanut butter sandwich',
          ],
        };
        break;

      default: // Maintain weight / General fitness
        suggestions = {
          'breakfast': [
            'Whole grain toast with eggs and avocado',
            'Fruit smoothie with protein powder',
            'Overnight oats with nuts and seeds',
          ],
          'lunch': [
            'Mixed green salad with grilled chicken',
            'Vegetable soup with whole grain bread',
            'Mediterranean quinoa bowl',
          ],
          'dinner': [
            'Grilled fish with roasted vegetables',
            'Turkey meatballs with zucchini noodles',
            'Vegetarian stir-fry with tofu',
          ],
          'snacks': [
            'Mixed nuts and dried fruits',
            'Rice cakes with avocado',
            'Fresh fruit with yogurt',
          ],
        };
    }

    return suggestions;
  }
} 