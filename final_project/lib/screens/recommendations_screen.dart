import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wellnex/viewmodels/recommendations_viewmodel.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommendations'),
      ),
      body: Consumer<RecommendationsViewModel>(
        builder: (context, recVM, _) {
          if (recVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (recVM.error != null) {
            return Center(child: Text(recVM.error!));
          }

          if (recVM.recommendations.isEmpty) {
            return const Center(child: Text('No recommendations available'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (recVM.dietPlan != null)
                _buildRecommendationCard(
                  icon: Icons.restaurant,
                  title: recVM.dietPlan!.planName,
                  subtitle: '${recVM.dietPlan!.dietType} • ${recVM.dietPlan!.targetCalories} kcal/day',
                  details: {
                    'Target Calories': '${recVM.dietPlan!.targetCalories} kcal',
                    'Hydration Goal': '${recVM.dietPlan!.hydrationGoalLiters}L/day',
                    'Diet Type': recVM.dietPlan!.dietType,
                  },
                  color: Colors.orange,
                  context: context,
                ),

              if (recVM.exercisePlan != null)
                _buildRecommendationCard(
                  icon: Icons.fitness_center,
                  title: recVM.exercisePlan!.planName,
                  subtitle: '${recVM.exercisePlan!.frequencyPerWeek}x/week • ${recVM.exercisePlan!.durationPerSession} mins',
                  details: {
                    'Intensity': recVM.exercisePlan!.intensityLevel,
                    'Duration': '${recVM.exercisePlan!.durationPerSession} mins',
                    'Frequency': '${recVM.exercisePlan!.frequencyPerWeek}x/week',
                    'Exercises': recVM.exercisePlan!.exerciseTypes.join(', '),
                  },
                  color: Colors.blue,
                  context: context,
                ),

              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Health Articles',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              ...recVM.articles.map((article) => _buildArticleCard(article, context)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecommendationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Map<String, dynamic> details,
    required Color color,
    required BuildContext context,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showRecommendationDetails(
          context: context,
          title: title,
          description: subtitle,
          details: details,
        ),
      ),
    );
  }

  Widget _buildArticleCard(Article article, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(article.title),
        subtitle: Text(article.summary),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showArticleDetails(article, context),
      ),
    );
  }

  void _showRecommendationDetails({
    required BuildContext context,
    required String title,
    required String description,
    required Map<String, dynamic> details,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(description),
                const SizedBox(height: 16),
                ...details.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(entry.value.toString()),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showArticleDetails(Article article, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(article.title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  article.summary,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(article.content),
                const SizedBox(height: 8),
                Text(
                  'Category: ${article.category}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}