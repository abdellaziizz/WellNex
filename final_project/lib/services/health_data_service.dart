import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import '../models/health_data_model.dart';

class HealthDataService {
  final FirebaseFirestore _firestore;
  final String _collection = 'health_data';

  HealthDataService(this._firestore);

  // Create a new health data point
  Future<HealthDataPoint> createHealthDataPoint(HealthDataPoint dataPoint) async {
    try {
      final data = dataPoint.toFirestore();
      
      if (dataPoint.id.isEmpty) {
        // Let Firestore generate the ID
        final docRef = await _firestore.collection(_collection).add(data);
        return dataPoint.copyWith(id: docRef.id);
      } else {
        // Use the provided ID
        await _firestore.collection(_collection).doc(dataPoint.id).set(data);
        return dataPoint;
      }
    } catch (e) {
      developer.log('Error creating health data point: ${e.toString()}', error: e);
      throw Exception('Failed to create health data point: ${e.toString()}');
    }
  }

  // Get a health data point by ID
  Future<HealthDataPoint> getHealthDataPoint(String dataPointId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(dataPointId).get();
      if (!doc.exists) {
        throw Exception('Health data point not found');
      }
      return HealthDataPoint.fromFirestore(doc);
    } catch (e) {
      developer.log('Error getting health data point: ${e.toString()}', error: e);
      throw Exception('Failed to get health data point: ${e.toString()}');
    }
  }

  // Update a health data point
  Future<void> updateHealthDataPoint(HealthDataPoint dataPoint) async {
    try {
      await _firestore.collection(_collection).doc(dataPoint.id).update(dataPoint.toFirestore());
    } catch (e) {
      developer.log('Error updating health data point: ${e.toString()}', error: e);
      throw Exception('Failed to update health data point: ${e.toString()}');
    }
  }

  // Delete a health data point
  Future<void> deleteHealthDataPoint(String dataPointId) async {
    try {
      await _firestore.collection(_collection).doc(dataPointId).delete();
    } catch (e) {
      developer.log('Error deleting health data point: ${e.toString()}', error: e);
      throw Exception('Failed to delete health data point: ${e.toString()}');
    }
  }

  // Get all health data points for a user
  Future<List<HealthDataPoint>> getUserHealthData(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => HealthDataPoint.fromFirestore(doc))
          .toList();
    } catch (e) {
      developer.log('Error getting user health data: ${e.toString()}', error: e);
      throw Exception('Failed to get user health data: ${e.toString()}');
    }
  }

  // Stream all health data for a user (real-time updates)
  Stream<List<HealthDataPoint>> streamUserHealthData(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => HealthDataPoint.fromFirestore(doc)).toList());
  }

  // Get health data by category
  Future<List<HealthDataPoint>> getHealthDataByCategory(String userId, String category) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('category', isEqualTo: category)
          .orderBy('date', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => HealthDataPoint.fromFirestore(doc))
          .toList();
    } catch (e) {
      developer.log('Error getting health data by category: ${e.toString()}', error: e);
      
      // Check for permission denied errors
      if (e.toString().contains('permission-denied') || 
          e.toString().contains('PERMISSION_DENIED')) {
        developer.log('Permission denied when accessing health data. Using empty data set.');
        // Return empty list instead of throwing when it's a permissions issue
        // This allows the app to continue functioning with sample data
        return [];
      }
      
      throw Exception('Failed to get health data by category: ${e.toString()}');
    }
  }

  // Get health data for specific date range
  Future<List<HealthDataPoint>> getHealthDataByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
    [String? category]
  ) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      
      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }
      
      final querySnapshot = await query.orderBy('date', descending: false).get();
      
      return querySnapshot.docs
          .map((doc) => HealthDataPoint.fromFirestore(doc))
          .toList();
    } catch (e) {
      developer.log('Error getting health data by date range: ${e.toString()}', error: e);
      throw Exception('Failed to get health data by date range: ${e.toString()}');
    }
  }

  // Get latest health data point for a specific category
  Future<HealthDataPoint?> getLatestHealthDataByCategory(String userId, String category) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('category', isEqualTo: category)
          .orderBy('date', descending: true)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        return null;
      }
      
      return HealthDataPoint.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      developer.log('Error getting latest health data: ${e.toString()}', error: e);
      throw Exception('Failed to get latest health data: ${e.toString()}');
    }
  }
} 