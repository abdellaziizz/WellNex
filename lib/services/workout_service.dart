import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import '../models/workout_model.dart';

class WorkoutService {
  final FirebaseFirestore _firestore;
  final String _collection = 'workouts';

  WorkoutService(this._firestore);

  // Create a new workout
  Future<Workout> createWorkout(Workout workout) async {
    try {
      // Use the provided ID if it's not empty, otherwise Firestore will generate one
      final workoutData = workout.toFirestore();
      
      if (workout.id.isEmpty) {
        // Let Firestore generate the ID
        final docRef = await _firestore.collection(_collection).add(workoutData);
        return workout.copyWith(id: docRef.id);
      } else {
        // Use the provided ID
        await _firestore.collection(_collection).doc(workout.id).set(workoutData);
        return workout;
      }
    } catch (e) {
      developer.log('Error creating workout: ${e.toString()}', error: e);
      throw Exception('Failed to create workout: ${e.toString()}');
    }
  }

  // Get a workout by ID
  Future<Workout> getWorkout(String workoutId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(workoutId).get();
      if (!doc.exists) {
        throw Exception('Workout not found');
      }
      return Workout.fromFirestore(doc);
    } catch (e) {
      developer.log('Error getting workout: ${e.toString()}', error: e);
      throw Exception('Failed to get workout: ${e.toString()}');
    }
  }

  // Update a workout
  Future<void> updateWorkout(Workout workout) async {
    try {
      await _firestore.collection(_collection).doc(workout.id).update(workout.toFirestore());
    } catch (e) {
      developer.log('Error updating workout: ${e.toString()}', error: e);
      throw Exception('Failed to update workout: ${e.toString()}');
    }
  }

  // Delete a workout
  Future<void> deleteWorkout(String workoutId) async {
    try {
      await _firestore.collection(_collection).doc(workoutId).delete();
    } catch (e) {
      developer.log('Error deleting workout: ${e.toString()}', error: e);
      throw Exception('Failed to delete workout: ${e.toString()}');
    }
  }

  // Get all workouts for a user
  Future<List<Workout>> getUserWorkouts(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Workout.fromFirestore(doc))
          .toList();
    } catch (e) {
      developer.log('Error getting user workouts: ${e.toString()}', error: e);
      throw Exception('Failed to get user workouts: ${e.toString()}');
    }
  }

  // Stream all workouts for a user (real-time updates)
  Stream<List<Workout>> streamUserWorkouts(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => Workout.fromFirestore(doc)).toList());
  }

  // Mark a workout as completed
  Future<void> completeWorkout(String workoutId) async {
    try {
      await _firestore.collection(_collection).doc(workoutId).update({
        'isCompleted': true,
        'completedAt': Timestamp.now(),
      });
    } catch (e) {
      developer.log('Error completing workout: ${e.toString()}', error: e);
      throw Exception('Failed to complete workout: ${e.toString()}');
    }
  }
  
  // Get workouts by intensity level
  Future<List<Workout>> getWorkoutsByIntensity(String userId, String intensityLevel) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('intensityLevel', isEqualTo: intensityLevel)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Workout.fromFirestore(doc))
          .toList();
    } catch (e) {
      developer.log('Error getting workouts by intensity: ${e.toString()}', error: e);
      throw Exception('Failed to get workouts by intensity: ${e.toString()}');
    }
  }
} 