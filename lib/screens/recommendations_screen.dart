import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/health_recommendations_viewmodel.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize the ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<HealthRecommendationsViewModel>(context, listen: false);
      viewModel.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Health Plan'),
        elevation: 0,
      ),
      body: Consumer<HealthRecommendationsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    viewModel.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.retryLoading(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.dietPlan == null) {
            return const Center(
              child: Text('No diet plan available. Please complete your health assessment.'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Health Metrics Card
                _buildMetricsCard(viewModel),
                const SizedBox(height: 16),

                // Daily Nutrition Card
                _buildNutritionCard(viewModel),
                const SizedBox(height: 16),

                // Meal Plan Card
                _buildMealPlanCard(viewModel),
                const SizedBox(height: 16),

                // Dietary Advice Card
                _buildDietaryAdviceCard(viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricsCard(HealthRecommendationsViewModel viewModel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Health Metrics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B4C37),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'BMI',
                    viewModel.getBMIStatus(),
                    Icons.monitor_weight,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Daily Calories',
                    viewModel.getFormattedDailyCalories(),
                    Icons.local_fire_department,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionCard(HealthRecommendationsViewModel viewModel) {
    final macros = viewModel.getFormattedMacronutrients();
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Nutrition Goals',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B4C37),
              ),
            ),
            const SizedBox(height: 16),
            _buildNutrientRow('Protein', macros['protein'] ?? 'Not calculated', const Color(0xFF43A047)),
            const SizedBox(height: 8),
            _buildNutrientRow('Carbs', macros['carbs'] ?? 'Not calculated', const Color(0xFF1E88E5)),
            const SizedBox(height: 8),
            _buildNutrientRow('Fats', macros['fats'] ?? 'Not calculated', const Color(0xFFFB8C00)),
          ],
        ),
      ),
    );
  }

  Widget _buildMealPlanCard(HealthRecommendationsViewModel viewModel) {
    final dietPlan = viewModel.dietPlan;
    if (dietPlan == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Meal Suggestions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B4C37),
                  ),
                ),
                Text(
                  'Goal: ${dietPlan.healthGoal}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMealSection('Breakfast', dietPlan.mealSuggestions['breakfast'] ?? []),
            const SizedBox(height: 12),
            _buildMealSection('Lunch', dietPlan.mealSuggestions['lunch'] ?? []),
            const SizedBox(height: 12),
            _buildMealSection('Dinner', dietPlan.mealSuggestions['dinner'] ?? []),
            const SizedBox(height: 12),
            _buildMealSection('Snacks', dietPlan.mealSuggestions['snacks'] ?? []),
          ],
        ),
      ),
    );
  }

  Widget _buildDietaryAdviceCard(HealthRecommendationsViewModel viewModel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dietary Advice',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B4C37),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              viewModel.getDietaryAdvice(),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealSection(String title, List<String> meals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0B4C37),
          ),
        ),
        const SizedBox(height: 8),
        ...meals.map((meal) => Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 4),
          child: Row(
            children: [
              const Icon(Icons.circle, size: 8, color: Color(0xFF0B4C37)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  meal,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF0B4C37), size: 32),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNutrientRow(String nutrient, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          nutrient,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}