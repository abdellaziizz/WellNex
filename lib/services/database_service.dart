import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

class DatabaseService {
  final FirebaseFirestore _firestore;

  DatabaseService(this._firestore) {
    // Configure Firestore settings for Windows platform
    if (defaultTargetPlatform == TargetPlatform.windows) {
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        sslEnabled: true,
      );
    }
  }

  FirebaseFirestore get firestore => _firestore;

  // Get user by ID
  Future<User> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        throw Exception('User not found');
      }
      return _userFromFirestore(doc);
    } catch (e) {
      developer.log('Error getting user: ${e.toString()}', error: e);
      
      // For permission errors, still return a minimal user object
      if (e.toString().contains('permission-denied') || 
          e.toString().contains('Missing or insufficient permissions')) {
        developer.log('Permission error detected, returning minimal user');
        return Beginner(
          id: userId,
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
      }
      
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  // Stream user changes
  Stream<User> streamUser(String userId) {
    return _firestore.collection('users').doc(userId)
        .snapshots()
        .map((doc) => _userFromFirestore(doc))
        .handleError((error) {
          developer.log('Error streaming user: $error');
          
          // Return a default user for permission errors
          if (error.toString().contains('permission-denied') || 
              error.toString().contains('Missing or insufficient permissions')) {
            return Beginner(
              id: userId,
              name: 'Default User (Stream)',
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
          }
          
          throw Exception('Failed to stream user: $error');
        });
  }

  // Convert document data to the respective User type with safe null handling
  User _userFromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final type = data['userType'] as String? ?? 'beginner';
      
      // Handle joinDate safely - use current date if field is missing or null
      final DateTime joinDate = data['joinDate'] != null 
          ? (data['joinDate'] is Timestamp 
              ? (data['joinDate'] as Timestamp).toDate() 
              : DateTime.now())
          : DateTime.now();
      
      developer.log('Converting user document to $type object');

      switch (type) {
        case 'beginner':
          return Beginner(
            id: doc.id,
            name: data['name'] as String? ?? 'Unknown User',
            age: data['age'] as int? ?? 25,
            gender: data['gender'] as String? ?? 'Not specified',
            height: (data['height'] as num?)?.toDouble() ?? 170.0,
            weight: (data['weight'] as num?)?.toDouble() ?? 70.0,
            healthGoal: data['healthGoal'] as String? ?? 'General fitness',
            joinDate: joinDate,
            motivationLevel: data['motivationLevel'] as int? ?? 3,
            learningPreferences: data['learningPreferences'] != null
                ? List<String>.from(data['learningPreferences'])
                : <String>['Video tutorials'],
            hasPreviousInjury: data['hasPreviousInjury'] as bool? ?? false,
          );

        case 'weightManagement':
          return WeightMgmtUser(
            id: doc.id,
            name: data['name'] as String? ?? 'Unknown User',
            age: data['age'] as int? ?? 25,
            gender: data['gender'] as String? ?? 'Not specified',
            height: (data['height'] as num?)?.toDouble() ?? 170.0,
            weight: (data['weight'] as num?)?.toDouble() ?? 70.0,
            healthGoal: data['healthGoal'] as String? ?? 'Weight management',
            joinDate: joinDate,
            targetWeight: (data['targetWeight'] as num?)?.toDouble() ?? 65.0,
            dietPreference: data['dietPreference'] as String? ?? 'balanced',
            weeklyGoal: (data['weeklyGoal'] as num?)?.toDouble() ?? 0.5,
            dietaryRestrictions: data['dietaryRestrictions'] != null
                ? List<String>.from(data['dietaryRestrictions'])
                : <String>[],
          );

        case 'fitness':
          return FitnessUser(
            id: doc.id,
            name: data['name'] as String? ?? 'Unknown User',
            age: data['age'] as int? ?? 25,
            gender: data['gender'] as String? ?? 'Not specified',
            height: (data['height'] as num?)?.toDouble() ?? 170.0,
            weight: (data['weight'] as num?)?.toDouble() ?? 70.0,
            healthGoal: data['healthGoal'] as String? ?? 'Build muscle',
            joinDate: joinDate,
            trainingTypes: data['trainingTypes'] != null
                ? List<String>.from(data['trainingTypes'])
                : <String>['strength'],
            fitnessLevel: data['fitnessLevel'] as String? ?? 'intermediate',
            workoutDaysPerWeek: data['workoutDaysPerWeek'] as int? ?? 4,
            currentRoutine: data['currentRoutine'] as String?,
          );

        case 'elder':
          return Elder(
            id: doc.id,
            name: data['name'] as String? ?? 'Unknown User',
            age: data['age'] as int? ?? 65,
            gender: data['gender'] as String? ?? 'Not specified',
            height: (data['height'] as num?)?.toDouble() ?? 170.0,
            weight: (data['weight'] as num?)?.toDouble() ?? 70.0,
            healthGoal: data['healthGoal'] as String? ?? 'Maintain mobility',
            joinDate: joinDate,
            mobilityLevel: data['mobilityLevel'] as String? ?? 'moderate',
            healthConditions: data['healthConditions'] != null
                ? List<String>.from(data['healthConditions'])
                : <String>[],
            usesAssistiveDevice: data['usesAssistiveDevice'] as bool? ?? false,
          );

        case 'busy':
          return BusyUser(
            id: doc.id,
            name: data['name'] as String? ?? 'Unknown User',
            age: data['age'] as int? ?? 30,
            gender: data['gender'] as String? ?? 'Not specified',
            height: (data['height'] as num?)?.toDouble() ?? 170.0,
            weight: (data['weight'] as num?)?.toDouble() ?? 70.0,
            healthGoal: data['healthGoal'] as String? ?? 'Stay active',
            joinDate: joinDate,
            workHoursPerDay: data['workHoursPerDay'] as int? ?? 8,
            availableExerciseTime: data['availableExerciseTime'] as int? ?? 30,
            stressManagementPreference: data['stressManagementPreference'] as String? ?? 'physical',
          );

        default:
          developer.log('Unknown user type: $type, defaulting to beginner');
          return Beginner(
            id: doc.id,
            name: data['name'] as String? ?? 'Unknown User',
            age: data['age'] as int? ?? 25,
            gender: data['gender'] as String? ?? 'Not specified',
            height: (data['height'] as num?)?.toDouble() ?? 170.0,
            weight: (data['weight'] as num?)?.toDouble() ?? 70.0,
            healthGoal: data['healthGoal'] as String? ?? 'General fitness',
            joinDate: joinDate,
            motivationLevel: data['motivationLevel'] as int? ?? 3,
            learningPreferences: <String>['Video tutorials'],
            hasPreviousInjury: false,
          );
      }
    } catch (e) {
      developer.log('Error converting Firestore document to User: ${e.toString()}', error: e);
      // Provide a fallback user when conversion fails
      return Beginner(
        id: doc.id,
        name: 'Default User',
        age: 25,
        gender: 'Not specified',
        height: 170.0,
        weight: 70.0,
        healthGoal: 'General fitness',
        joinDate: DateTime.now(),
        motivationLevel: 3,
        learningPreferences: ['Video tutorials'],
        hasPreviousInjury: false,
      );
    }
  }

  // Save or update user
  Future<void> saveUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.id).set({
        'id': user.id,
        'name': user.name,
        'age': user.age,
        'gender': user.gender,
        'height': user.height,
        'weight': user.weight,
        'healthGoal': user.healthGoal,
        'joinDate': user.joinDate,
        'userType': _getUserType(user),
        ..._getUserSpecificFields(user),
      });
      developer.log('User saved successfully: ${user.id}');
    } catch (e) {
      developer.log('Error saving user: ${e.toString()}', error: e);
      
      // Don't throw for permission errors in development mode
      if (kDebugMode && (e.toString().contains('permission-denied') || 
                          e.toString().contains('Missing or insufficient permissions'))) {
        developer.log('Ignoring permission error when saving user in debug mode');
        return; // Just return without throwing
      }
      
      throw Exception('Failed to save user: ${e.toString()}');
    }
  }

  // Determine user type
  String _getUserType(User user) {
    if (user is Beginner) return 'beginner';
    if (user is WeightMgmtUser) return 'weightManagement';
    if (user is FitnessUser) return 'fitness';
    if (user is Elder) return 'elder';
    if (user is BusyUser) return 'busy';
    throw Exception('Unknown user type');
  }

  // Get user-specific fields
  Map<String, dynamic> _getUserSpecificFields(User user) {
    if (user is Beginner) {
      return {
        'motivationLevel': user.motivationLevel,
        'learningPreferences': user.learningPreferences,
        'hasPreviousInjury': user.hasPreviousInjury,
      };
    } else if (user is WeightMgmtUser) {
      return {
        'targetWeight': user.targetWeight,
        'dietPreference': user.dietPreference,
        'weeklyGoal': user.weeklyGoal,
        'dietaryRestrictions': user.dietaryRestrictions,
      };
    } else if (user is FitnessUser) {
      return {
        'trainingTypes': user.trainingTypes,
        'fitnessLevel': user.fitnessLevel,
        'workoutDaysPerWeek': user.workoutDaysPerWeek,
        'currentRoutine': user.currentRoutine,
      };
    } else if (user is Elder) {
      return {
        'mobilityLevel': user.mobilityLevel,
        'healthConditions': user.healthConditions,
        'usesAssistiveDevice': user.usesAssistiveDevice,
      };
    } else if (user is BusyUser) {
      return {
        'workHoursPerDay': user.workHoursPerDay,
        'availableExerciseTime': user.availableExerciseTime,
        'stressManagementPreference': user.stressManagementPreference,
      };
    }
    return {};
  }
}
