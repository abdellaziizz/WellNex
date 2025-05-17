import '../services/service_factory.dart';
import '../models/workout_model.dart';
import 'dart:developer' as developer;

class WorkoutRepository {
  final ServiceFactory _services = ServiceFactory();

  // Create a new workout for the current user
  Future<Workout> createWorkout({
    required String name,
    required String description,
    required List<Exercise> exercises,
    required int durationMinutes,
    required String intensityLevel,
  }) async {
    final userId = _services.currentUserId;
    if (userId == null) {
      throw Exception('No user is logged in');
    }
    
    try {
      final workout = Workout(
        id: '',
        userId: userId,
        name: name,
        description: description,
        exercises: exercises,
        durationMinutes: durationMinutes,
        intensityLevel: intensityLevel,
        createdAt: DateTime.now(),
      );
      
      return await _services.workout.createWorkout(workout);
    } catch (e) {
      developer.log('Error creating workout: ${e.toString()}', error: e);
      throw Exception('Failed to create workout: ${e.toString()}');
    }
  }

  // Update an existing workout
  Future<void> updateWorkout(Workout workout) async {
    final userId = _services.currentUserId;
    if (userId == null) {
      throw Exception('No user is logged in');
    }
    
    // Validate that the workout belongs to the current user
    if (workout.userId != userId) {
      throw Exception('Cannot update a different user\'s workout');
    }
    
    try {
      await _services.workout.updateWorkout(workout);
    } catch (e) {
      developer.log('Error updating workout: ${e.toString()}', error: e);
      throw Exception('Failed to update workout: ${e.toString()}');
    }
  }

  // Delete a workout
  Future<void> deleteWorkout(String workoutId) async {
    try {
      final workout = await _services.workout.getWorkout(workoutId);
      
      final userId = _services.currentUserId;
      if (userId == null) {
        throw Exception('No user is logged in');
      }
      
      // Validate that the workout belongs to the current user
      if (workout.userId != userId) {
        throw Exception('Cannot delete a different user\'s workout');
      }
      
      await _services.workout.deleteWorkout(workoutId);
    } catch (e) {
      developer.log('Error deleting workout: ${e.toString()}', error: e);
      throw Exception('Failed to delete workout: ${e.toString()}');
    }
  }

  // Get all workouts for the current user
  Future<List<Workout>> getUserWorkouts() async {
    final userId = _services.currentUserId;
    if (userId == null) {
      throw Exception('No user is logged in');
    }
    
    try {
      return await _services.workout.getUserWorkouts(userId);
    } catch (e) {
      developer.log('Error getting user workouts: ${e.toString()}', error: e);
      throw Exception('Failed to get user workouts: ${e.toString()}');
    }
  }

  // Stream all workouts for the current user (real-time updates)
  Stream<List<Workout>> streamUserWorkouts() {
    final userId = _services.currentUserId;
    if (userId == null) {
      throw Exception('No user is logged in');
    }
    
    return _services.workout.streamUserWorkouts(userId);
  }

  // Mark a workout as completed
  Future<void> completeWorkout(String workoutId) async {
    try {
      final workout = await _services.workout.getWorkout(workoutId);
      
      final userId = _services.currentUserId;
      if (userId == null) {
        throw Exception('No user is logged in');
      }
      
      // Validate that the workout belongs to the current user
      if (workout.userId != userId) {
        throw Exception('Cannot complete a different user\'s workout');
      }
      
      await _services.workout.completeWorkout(workoutId);
    } catch (e) {
      developer.log('Error completing workout: ${e.toString()}', error: e);
      throw Exception('Failed to complete workout: ${e.toString()}');
    }
  }

  // Get workouts filtered by intensity level
  Future<List<Workout>> getWorkoutsByIntensity(String intensityLevel) async {
    final userId = _services.currentUserId;
    if (userId == null) {
      throw Exception('No user is logged in');
    }
    
    try {
      return await _services.workout.getWorkoutsByIntensity(userId, intensityLevel);
    } catch (e) {
      developer.log('Error getting workouts by intensity: ${e.toString()}', error: e);
      throw Exception('Failed to get workouts by intensity: ${e.toString()}');
    }
  }

  // Get only completed workouts
  Future<List<Workout>> getCompletedWorkouts() async {
    final userId = _services.currentUserId;
    if (userId == null) {
      throw Exception('No user is logged in');
    }
    
    try {
      final allWorkouts = await _services.workout.getUserWorkouts(userId);
      return allWorkouts.where((workout) => workout.isCompleted).toList();
    } catch (e) {
      developer.log('Error getting completed workouts: ${e.toString()}', error: e);
      throw Exception('Failed to get completed workouts: ${e.toString()}');
    }
  }
} 