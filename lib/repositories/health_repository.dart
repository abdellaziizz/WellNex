import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/health_data_model.dart';
import '../services/service_factory.dart';
import 'dart:developer' as developer;

class HealthRepository {
  final ServiceFactory _services = ServiceFactory();

  HealthRepository();

  // Collection reference
  CollectionReference<Map<String, dynamic>> _healthCollection() =>
      _services.firestore.collection('health_data');

  // Add health data point
  Future<HealthDataPoint> addHealthData(HealthDataPoint data) async {
    try {
      return await _services.healthData.createHealthDataPoint(data);
    } catch (e) {
      developer.log('Error adding health data: ${e.toString()}', error: e);
      throw Exception('Failed to add health data: ${e.toString()}');
    }
  }

  // Get health data stream for current user by category
  Stream<List<HealthDataPoint>> getHealthDataStream(String category) {
    final userId = _services.currentUserId;
    if (userId == null) {
      throw Exception('No user is logged in');
    }
    
    try {
      return _services.healthData.streamUserHealthData(userId)
          .map((dataPoints) => dataPoints
              .where((point) => point.category == category)
              .toList());
    } catch (e) {
      developer.log('Error streaming health data: ${e.toString()}', error: e);
      throw Exception('Failed to stream health data: ${e.toString()}');
    }
  }

  // Get latest health data point for current user
  Future<HealthDataPoint?> getLatestHealthData(String category) async {
    final userId = _services.currentUserId;
    if (userId == null) {
      throw Exception('No user is logged in');
    }
    
    try {
      return await _services.healthData.getLatestHealthDataByCategory(userId, category);
    } catch (e) {
      developer.log('Error getting latest health data: ${e.toString()}', error: e);
      throw Exception('Failed to get latest health data: ${e.toString()}');
    }
  }

  // Get health data by date range for current user
  Future<List<HealthDataPoint>> getHealthDataByDateRange(
    String category,
    DateTime start,
    DateTime end,
  ) async {
    final userId = _services.currentUserId;
    if (userId == null) {
      throw Exception('No user is logged in');
    }
    
    try {
      return await _services.healthData.getHealthDataByDateRange(
        userId,
        start,
        end,
        category,
      );
    } catch (e) {
      developer.log('Error getting health data range: ${e.toString()}', error: e);
      throw Exception('Failed to get health data range: ${e.toString()}');
    }
  }

  // Update health data point
  Future<void> updateHealthData(HealthDataPoint dataPoint) async {
    final userId = _services.currentUserId;
    if (userId == null) {
      throw Exception('No user is logged in');
    }
    
    // Verify the data point belongs to current user
    if (dataPoint.userId != userId) {
      throw Exception('Cannot update health data belonging to another user');
    }
    
    try {
      await _services.healthData.updateHealthDataPoint(dataPoint);
    } catch (e) {
      developer.log('Error updating health data: ${e.toString()}', error: e);
      throw Exception('Failed to update health data: ${e.toString()}');
    }
  }

  // Delete health data point
  Future<void> deleteHealthData(String dataPointId) async {
    try {
      await _services.healthData.deleteHealthDataPoint(dataPointId);
    } catch (e) {
      developer.log('Error deleting health data: ${e.toString()}', error: e);
      throw Exception('Failed to delete health data: ${e.toString()}');
    }
  }

  // Create a new health data point for current user
  Future<HealthDataPoint> createHealthDataPoint({
    required double value,
    required String metric,
    required String category,
    String? notes,
  }) async {
    final userId = _services.currentUserId;
    if (userId == null) {
      throw Exception('No user is logged in');
    }
    
    try {
      final dataPoint = HealthDataPoint(
        id: '',
        userId: userId,
        date: DateTime.now(),
        value: value,
        metric: metric,
        category: category,
        notes: notes,
      );
      
      return await _services.healthData.createHealthDataPoint(dataPoint);
    } catch (e) {
      developer.log('Error creating health data point: ${e.toString()}', error: e);
      throw Exception('Failed to create health data point: ${e.toString()}');
    }
  }

  // Get all health data for current user
  Future<List<HealthDataPoint>> getAllHealthData() async {
    final userId = _services.currentUserId;
    if (userId == null) {
      throw Exception('No user is logged in');
    }
    
    try {
      return await _services.healthData.getUserHealthData(userId);
    } catch (e) {
      developer.log('Error getting all health data: ${e.toString()}', error: e);
      throw Exception('Failed to get all health data: ${e.toString()}');
    }
  }
}