import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/service_factory.dart';
import '../models/health_data_model.dart';
import 'dart:developer' as developer;
import '../helpers/firestore_helper.dart';

class UserRepository {
  final ServiceFactory _services = ServiceFactory();

  UserRepository();

  // Get user by ID
  Future<User?> getUser(String id) async {
    try {
      return await _services.database.getUser(id);
    } catch (e) {
      developer.log('Error getting user: ${e.toString()}', error: e);
      
      // Check if this is a permission error
      if (e.toString().contains('permission-denied') || 
          e.toString().contains('Missing or insufficient permissions')) {
        developer.log('Permission error detected, creating default user profile');
        
        // Create a minimal default user for development purposes
        try {
          final defaultUser = Beginner(
            id: id,
            name: 'Default User',
            age: 30,
            gender: 'Not specified',
            height: 170.0,
            weight: 70.0,
            healthGoal: 'General wellness',
            joinDate: DateTime.now(),
            motivationLevel: 3,
            learningPreferences: ['Video tutorials'],
            hasPreviousInjury: false,
          );
          
          // Try to save the default user
          try {
            await saveUser(defaultUser);
            developer.log('Default user created successfully');
          } catch (saveError) {
            developer.log('Could not save default user, using in-memory only', error: saveError);
          }
          
          return defaultUser;
        } catch (createError) {
          developer.log('Error creating default user', error: createError);
          throw Exception('Failed to get or create user: ${e.toString()}');
        }
      }
      
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  // Save or update user
  Future<void> saveUser(User user) async {
    try {
      await _services.database.saveUser(user);
    } catch (e) {
      throw Exception('Failed to save user: ${e.toString()}');
    }
  }

  // Stream user changes
  Stream<User> streamUser(String id) {
    return _services.database.streamUser(id).handleError((error) {
      throw Exception('Failed to stream user: ${error.toString()}');
    });
  }

  // Create user with specific type
  Future<User> createUserWithType({
    required String id,
    required String name,
    required int age,
    required String gender,
    required double height,
    required double weight,
    required String healthGoal,
    required String userType,
    Map<String, dynamic>? additionalData,
    String? username,
    String? email,
  }) async {
    try {
      final joinDate = DateTime.now();
      User user;

      switch (userType.toLowerCase()) {
        case 'beginner':
          user = Beginner(
            id: id,
            name: name,
            age: age,
            gender: gender,
            height: height,
            weight: weight,
            healthGoal: healthGoal,
            joinDate: joinDate,
            motivationLevel: additionalData?['motivationLevel'] ?? 3,
            learningPreferences:
            List<String>.from(additionalData?['learningPreferences'] ?? []),
            hasPreviousInjury: additionalData?['hasPreviousInjury'] ?? false,
          );
          break;

        case 'weightmanagement':
          user = WeightMgmtUser(
            id: id,
            name: name,
            age: age,
            gender: gender,
            height: height,
            weight: weight,
            healthGoal: healthGoal,
            joinDate: joinDate,
            targetWeight: additionalData?['targetWeight'] ?? weight,
            dietPreference: additionalData?['dietPreference'] ?? 'balanced',
            weeklyGoal: additionalData?['weeklyGoal'] ?? 0.5,
            dietaryRestrictions:
            List<String>.from(additionalData?['dietaryRestrictions'] ?? []),
          );
          break;

        case 'fitness':
          user = FitnessUser(
            id: id,
            name: name,
            age: age,
            gender: gender,
            height: height,
            weight: weight,
            healthGoal: healthGoal,
            joinDate: joinDate,
            trainingTypes:
            List<String>.from(additionalData?['trainingTypes'] ?? []),
            fitnessLevel: additionalData?['fitnessLevel'] ?? 'intermediate',
            workoutDaysPerWeek: additionalData?['workoutDaysPerWeek'] ?? 3,
            currentRoutine: additionalData?['currentRoutine'],
          );
          break;

        case 'elder':
          user = Elder(
            id: id,
            name: name,
            age: age,
            gender: gender,
            height: height,
            weight: weight,
            healthGoal: healthGoal,
            joinDate: joinDate,
            mobilityLevel: additionalData?['mobilityLevel'] ?? 'moderate',
            healthConditions:
            List<String>.from(additionalData?['healthConditions'] ?? []),
            usesAssistiveDevice: additionalData?['usesAssistiveDevice'] ?? false,
          );
          break;

        case 'busy':
          user = BusyUser(
            id: id,
            name: name,
            age: age,
            gender: gender,
            height: height,
            weight: weight,
            healthGoal: healthGoal,
            joinDate: joinDate,
            workHoursPerDay: additionalData?['workHoursPerDay'] ?? 8,
            availableExerciseTime:
            additionalData?['availableExerciseTime'] ?? 30,
            stressManagementPreference:
            additionalData?['stressManagementPreference'] ?? 'physical',
          );
          break;

        default:
          throw Exception('Invalid user type: $userType');
      }

      // Save user with username and email
      await _services.database.firestore
          .collection('users')
          .doc(id)
          .set({
            ...FirestoreHelper.userToMap(user),
            if (username != null) 'username': username,
            if (email != null) 'email': email,
          });
      return user;
    } catch (e) {
      throw Exception('Failed to create user: ${e.toString()}');
    }
  }

  // Update specific user fields
  Future<void> updateUserFields(
      String id,
      Map<String, dynamic> updates,
      ) async {
    try {
      // Convert DateTime to Timestamp if present
      if (updates.containsKey('joinDate')) {
        updates['joinDate'] = Timestamp.fromDate(updates['joinDate'] as DateTime);
      }

      await _services.database.firestore
          .collection('users')
          .doc(id)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update user fields: ${e.toString()}');
    }
  }

  // Get user BMI
  Future<double?> getUserBMI(String id) async {
    final user = await getUser(id);
    return user != null ? user.weight / ((user.height / 100) * (user.height / 100)) : null;
  }

  // Check if user exists
  Future<bool> userExists(String id) async {
    final doc = await _services.database.firestore.collection('users').doc(id).get();
    return doc.exists;
  }

  // Delete user account
  Future<void> deleteUser(String id) async {
    try {
      await _services.database.firestore.collection('users').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete user: ${e.toString()}');
    }
  }

  // Get the current logged-in user
  Future<User> getCurrentUser() async {
    final userId = _services.currentUserId;
    if (userId == null) {
      throw Exception('No user is logged in');
    }
    return _services.database.getUser(userId);
  }

  // Stream the current user's data for real-time updates
  Stream<User> streamCurrentUser() {
    final userId = _services.currentUserId;
    if (userId == null) {
      throw Exception('No user is logged in');
    }
    return _services.database.streamUser(userId);
  }

  // Update the current user's profile
  Future<void> updateUserProfile(User updatedUser) async {
    final userId = _services.currentUserId;
    if (userId == null) {
      throw Exception('No user is logged in');
    }
    
    // Validate that the user being updated is the current user
    if (updatedUser.id != userId) {
      throw Exception('Cannot update a different user\'s profile');
    }
    
    await _services.database.saveUser(updatedUser);
  }

  // Track a health metric for the current user
  Future<HealthDataPoint> trackHealthMetric({
    required String metric,
    required double value,
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
      developer.log('Error tracking health metric: ${e.toString()}', error: e);
      throw Exception('Failed to track health metric: ${e.toString()}');
    }
  }

  // Get latest weight for the current user
  Future<double?> getLatestWeight() async {
    final userId = _services.currentUserId;
    if (userId == null) {
      throw Exception('No user is logged in');
    }
    
    try {
      final latestWeightData = await _services.healthData
          .getLatestHealthDataByCategory(userId, 'weight');
      
      return latestWeightData?.value;
    } catch (e) {
      developer.log('Error getting latest weight: ${e.toString()}', error: e);
      return null;
    }
  }

  // Get health data for a specific category and time period
  Future<List<HealthDataPoint>> getHealthHistory({
    required String category,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final userId = _services.currentUserId;
    if (userId == null) {
      throw Exception('No user is logged in');
    }
    
    try {
      return await _services.healthData.getHealthDataByDateRange(
        userId,
        startDate,
        endDate,
        category,
      );
    } catch (e) {
      developer.log('Error getting health history: ${e.toString()}', error: e);
      throw Exception('Failed to get health history: ${e.toString()}');
    }
  }

  // Stream all health data for a specific category
  Stream<List<HealthDataPoint>> streamHealthCategory(String category) {
    final userId = _services.currentUserId;
    if (userId == null) {
      throw Exception('No user is logged in');
    }
    
    // First get all health data and then filter by category on the client side
    // since Firestore doesn't support combining where clauses with orderBy on different fields
    return _services.healthData.streamUserHealthData(userId)
        .map((dataPoints) => dataPoints
            .where((point) => point.category == category)
            .toList());
  }
}