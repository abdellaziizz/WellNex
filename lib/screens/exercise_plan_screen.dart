import 'package:flutter/material.dart';
import '../models/workout_model.dart';
import 'dart:async';

class ExercisePlanScreen extends StatefulWidget {
  const ExercisePlanScreen({super.key});

  @override
  State<ExercisePlanScreen> createState() => _ExercisePlanScreenState();
}

class _ExercisePlanScreenState extends State<ExercisePlanScreen> {
  final List<Exercise> _beginnerExercises = [
    Exercise(
      name: 'Push-ups',
      muscleGroup: 'Chest, Shoulders, Triceps',
      sets: 3,
      reps: 10,
      notes: 'Keep your body straight. Go to your knees if needed.',
    ),
    Exercise(
      name: 'Bodyweight Squats',
      muscleGroup: 'Legs, Glutes',
      sets: 3,
      reps: 15,
      notes: 'Keep your back straight and knees behind toes.',
    ),
    Exercise(
      name: 'Plank',
      muscleGroup: 'Core, Shoulders',
      sets: 3,
      reps: 1,
      notes: 'Hold for 30 seconds. Keep your body in a straight line.',
    ),
    Exercise(
      name: 'Walking Lunges',
      muscleGroup: 'Legs, Glutes',
      sets: 2,
      reps: 10,
      notes: '10 steps per leg. Keep your front knee at 90 degrees.',
    ),
    Exercise(
      name: 'Shoulder Taps',
      muscleGroup: 'Shoulders, Core',
      sets: 2,
      reps: 20,
      notes: 'Start in plank position. Tap opposite shoulder while maintaining stability.',
    ),
  ];
  
  // Track completed sets for each exercise
  final Map<int, List<bool>> _completedSets = {};
  // Track overall workout completion percentage
  double _completionPercentage = 0.0;
  // Timer for rest periods
  Timer? _restTimer;
  int _restTimeRemaining = 0;
  int _currentExerciseIndex = -1;
  
  @override
  void initState() {
    super.initState();
    // Initialize tracking maps
    for (int i = 0; i < _beginnerExercises.length; i++) {
      _completedSets[i] = List.generate(_beginnerExercises[i].sets, (_) => false);
    }
    _updateCompletionPercentage();
  }
  
  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }
  
  void _updateCompletionPercentage() {
    int totalSets = 0;
    int completedSets = 0;
    
    _completedSets.forEach((exerciseIndex, setsList) {
      totalSets += setsList.length;
      completedSets += setsList.where((isCompleted) => isCompleted).length;
    });
    
    setState(() {
      _completionPercentage = totalSets > 0 ? completedSets / totalSets * 100 : 0;
    });
  }
  
  void _toggleSetCompletion(int exerciseIndex, int setIndex) {
    setState(() {
      _completedSets[exerciseIndex]![setIndex] = !_completedSets[exerciseIndex]![setIndex];
      _updateCompletionPercentage();
    });
  }
  
  void _startRestTimer(int exerciseIndex) {
    _restTimer?.cancel();
    setState(() {
      _restTimeRemaining = 60; // 60 seconds rest
      _currentExerciseIndex = exerciseIndex;
    });
    
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_restTimeRemaining > 0) {
          _restTimeRemaining--;
        } else {
          _restTimer?.cancel();
          _currentExerciseIndex = -1;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Exercise Plan',
          style: TextStyle(
            color: Color(0xFF0B4C37),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressCard(),
            const SizedBox(height: 20),
            _buildInfoCard(),
            const SizedBox(height: 20),
            _buildExerciseList(),
            const SizedBox(height: 20),
            _buildTipsCard(),
          ],
        ),
      ),
      floatingActionButton: _completionPercentage >= 100 
        ? FloatingActionButton.extended(
            onPressed: _showCompletionDialog,
            backgroundColor: const Color(0xFF0B4C37),
            icon: const Icon(Icons.celebration),
            label: const Text('Complete'),
          )
        : null,
    );
  }
  
  Widget _buildProgressCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Color(0xFF0B4C37),
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Your Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B4C37),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _completionPercentage / 100,
                    minHeight: 12,
                    backgroundColor: Colors.grey[200],
                    color: _getProgressColor(_completionPercentage),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_completionPercentage.toStringAsFixed(0)}% Complete',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    _getMotivationalText(_completionPercentage),
                  ],
                ),
              ],
            ),
            if (_currentExerciseIndex != -1) ...[
              const SizedBox(height: 16),
              _buildRestTimerWidget(),
            ],
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage < 30) {
      return Colors.red;
    } else if (percentage < 70) {
      return Colors.orange;
    } else if (percentage < 100) {
      return Colors.green;
    } else {
      return const Color(0xFF0B4C37);
    }
  }
  
  Widget _getMotivationalText(double percentage) {
    String text = '';
    if (percentage < 25) {
      text = 'Getting started!';
    } else if (percentage < 50) {
      text = 'Keep going!';
    } else if (percentage < 75) {
      text = 'Halfway there!';
    } else if (percentage < 100) {
      text = 'Almost done!';
    } else {
      text = 'Workout complete!';
    }
    
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: _getProgressColor(percentage),
      ),
    );
  }
  
  Widget _buildRestTimerWidget() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer, color: Colors.blue),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rest Timer',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('$_restTimeRemaining seconds remaining'),
            ],
          ),
          const Spacer(),
          TextButton(
            child: const Text('Skip'),
            onPressed: () {
              _restTimer?.cancel();
              setState(() {
                _currentExerciseIndex = -1;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Basic Exercise Plan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B4C37),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'For beginners of all fitness levels',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'This exercise plan is designed for beginners and can be done without any equipment. Perform this routine 3 times per week with at least one rest day between sessions.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseList() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Workout',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B4C37),
              ),
            ),
            const SizedBox(height: 16),
            ..._beginnerExercises.asMap().entries.map(
              (entry) => _buildInteractiveExerciseItem(entry.key, entry.value)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveExerciseItem(int index, Exercise exercise) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 16),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                Icons.fitness_center,
                color: _isExerciseComplete(index) 
                    ? Colors.green
                    : Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: _isExerciseComplete(index) 
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${exercise.sets} sets x ${exercise.reps} ${exercise.reps > 1 ? 'reps' : 'rep'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      children: [
        Row(
          children: [
            const SizedBox(width: 52),  // Indentation to align with title content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Targets: ${exercise.muscleGroup}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (exercise.notes != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      exercise.notes!,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 8),
                  // Sets progress
                  Row(
                    children: List.generate(
                      exercise.sets,
                      (setIndex) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text('Set ${setIndex + 1}'),
                          selected: _completedSets[index]![setIndex],
                          onSelected: (_) => _toggleSetCompletion(index, setIndex),
                          backgroundColor: Colors.grey[200],
                          selectedColor: Colors.green[100],
                          checkmarkColor: Colors.green,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Action buttons
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _startRestTimer(index),
                        icon: const Icon(Icons.timer_outlined),
                        label: const Text('Rest Timer'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColor,
                          side: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  bool _isExerciseComplete(int exerciseIndex) {
    return _completedSets[exerciseIndex]!.every((isCompleted) => isCompleted);
  }

  Widget _buildTipsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Exercise Tips',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B4C37),
              ),
            ),
            const SizedBox(height: 16),
            _buildTipItem(
              'Always warm up for 5 minutes before starting your workout.',
              Icons.wb_sunny_outlined,
            ),
            _buildTipItem(
              'Start with lighter weights or modifications if needed.',
              Icons.fitness_center,
            ),
            _buildTipItem(
              'Stay hydrated throughout your workout.',
              Icons.water_drop_outlined,
            ),
            _buildTipItem(
              'Rest between sets for 30-60 seconds.',
              Icons.timer_outlined,
            ),
            _buildTipItem(
              'Focus on proper form rather than speed.',
              Icons.accessibility_new_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String tip, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon, 
            size: 16, 
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Workout Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events,
              size: 60,
              color: Colors.amber,
            ),
            const SizedBox(height: 16),
            const Text(
              'Great job completing today\'s workout!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'You completed ${_beginnerExercises.length} exercises with a total of ${_getTotalSets()} sets.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0B4C37),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
  
  int _getTotalSets() {
    int total = 0;
    for (var exercise in _beginnerExercises) {
      total += exercise.sets;
    }
    return total;
  }
} 