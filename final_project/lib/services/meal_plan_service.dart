import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import '../models/meal_plan_model.dart';

class MealPlanService {
  final FirebaseFirestore _firestore;
  final String _collection = 'meal_plans';

  MealPlanService(this._firestore);

  // Create a new meal plan
  Future<MealPlan> createMealPlan(MealPlan mealPlan) async {
    try {
      final mealPlanData = mealPlan.toFirestore();
      
      if (mealPlan.id.isEmpty) {
        // Let Firestore generate the ID
        final docRef = await _firestore.collection(_collection).add(mealPlanData);
        return mealPlan.copyWith(id: docRef.id);
      } else {
        // Use the provided ID
        await _firestore.collection(_collection).doc(mealPlan.id).set(mealPlanData);
        return mealPlan;
      }
    } catch (e) {
      developer.log('Error creating meal plan: ${e.toString()}', error: e);
      throw Exception('Failed to create meal plan: ${e.toString()}');
    }
  }

  // Get a meal plan by ID
  Future<MealPlan> getMealPlan(String mealPlanId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(mealPlanId).get();
      if (!doc.exists) {
        throw Exception('Meal plan not found');
      }
      return MealPlan.fromFirestore(doc);
    } catch (e) {
      developer.log('Error getting meal plan: ${e.toString()}', error: e);
      throw Exception('Failed to get meal plan: ${e.toString()}');
    }
  }

  // Update a meal plan
  Future<void> updateMealPlan(MealPlan mealPlan) async {
    try {
      await _firestore.collection(_collection).doc(mealPlan.id).update(mealPlan.toFirestore());
    } catch (e) {
      developer.log('Error updating meal plan: ${e.toString()}', error: e);
      throw Exception('Failed to update meal plan: ${e.toString()}');
    }
  }

  // Delete a meal plan
  Future<void> deleteMealPlan(String mealPlanId) async {
    try {
      await _firestore.collection(_collection).doc(mealPlanId).delete();
    } catch (e) {
      developer.log('Error deleting meal plan: ${e.toString()}', error: e);
      throw Exception('Failed to delete meal plan: ${e.toString()}');
    }
  }

  // Get all meal plans for a user
  Future<List<MealPlan>> getUserMealPlans(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => MealPlan.fromFirestore(doc))
          .toList();
    } catch (e) {
      developer.log('Error getting user meal plans: ${e.toString()}', error: e);
      throw Exception('Failed to get user meal plans: ${e.toString()}');
    }
  }

  // Stream all meal plans for a user (real-time updates)
  Stream<List<MealPlan>> streamUserMealPlans(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => MealPlan.fromFirestore(doc)).toList());
  }

  // Get meal plans by diet type
  Future<List<MealPlan>> getMealPlansByDietType(String userId, String dietType) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('dietType', isEqualTo: dietType)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => MealPlan.fromFirestore(doc))
          .toList();
    } catch (e) {
      developer.log('Error getting meal plans by diet type: ${e.toString()}', error: e);
      throw Exception('Failed to get meal plans by diet type: ${e.toString()}');
    }
  }

  // Get meal plans within calorie range
  Future<List<MealPlan>> getMealPlansByCalorieRange(
    String userId, 
    int minCalories, 
    int maxCalories
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('totalCalories', isGreaterThanOrEqualTo: minCalories)
          .where('totalCalories', isLessThanOrEqualTo: maxCalories)
          .orderBy('totalCalories')
          .get();
      
      return querySnapshot.docs
          .map((doc) => MealPlan.fromFirestore(doc))
          .toList();
    } catch (e) {
      developer.log('Error getting meal plans by calorie range: ${e.toString()}', error: e);
      throw Exception('Failed to get meal plans by calorie range: ${e.toString()}');
    }
  }
} 