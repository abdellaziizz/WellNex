import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
// Hide Firebase's User class
import '../models/user_model.dart' as app_model; // Your User model with alias
import '../services/auth_service.dart';
import '../repositories/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserViewModel with ChangeNotifier {
  final AuthService _authService;
  final UserRepository _userRepository;

  bool _isLoading = false;
  String? _error;
  app_model.User? _user; // Using aliased User model
  bool _forceOfflineMode = false; // New flag to force offline mode

  UserViewModel(this._authService, this._userRepository) {
    // Initialize user data if already logged in
    _initializeAsync();
  }

  // Helper method to initialize asynchronously
  void _initializeAsync() {
    Future.microtask(() async {
      try {
        await initialize();
      } catch (e, stackTrace) {
        developer.log(
          'Error during UserViewModel initialization',
          error: e,
          stackTrace: stackTrace,
        );
      }
    });
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  app_model.User? get user => _user;
  bool get isLoggedIn => _authService.currentUser != null;
  bool get forceOfflineMode => _forceOfflineMode;

  // Method to force offline mode - this will fully bypass Firestore
  void setForceOfflineMode(bool mode) {
    _forceOfflineMode = mode;
    developer.log('Forced offline mode set to: $_forceOfflineMode');
    notifyListeners();
  }
  
  // Method to set user data directly without Firestore
  Future<void> setOfflineUser(app_model.User user) {
    _user = user;
    _forceOfflineMode = true;
    developer.log('Set offline user: ${user.name}');
    notifyListeners();
    return Future.value();
  }
  
  // Convenience method to create a test user
  Future<void> createTestUser() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      throw Exception('No user is signed in');
    }
    
    final testUser = app_model.Beginner(
      id: currentUser.uid,
      name: currentUser.displayName ?? 'Test User',
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
    
    await setOfflineUser(testUser);
    developer.log('Created test user in offline mode: ${testUser.name}');
  }

  Future<void> initialize() async {
    try {
      // Skip Firestore operations if in forced offline mode
      if (_forceOfflineMode) {
        developer.log('Skipping Firebase initialization - in forced offline mode');
        
        // If we're in offline mode but no user is set, create a test user
        if (_user == null && _authService.currentUser != null) {
          await createTestUser();
        }
        return;
      }
      
      if (_authService.currentUser != null) {
        developer.log('Current user found, loading user data');
        await _loadUserData(_authService.currentUser!.uid);
      } else {
        developer.log('No current user found during initialization');
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error initializing UserViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      _setError('Failed to initialize: ${e.toString()}');
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final credential = await _authService.signInWithEmail(email, password);
      
      // In forced offline mode, don't try to access Firestore
      if (_forceOfflineMode) {
        developer.log('Login successful in offline mode, creating test user');
        await createTestUser();
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      try {
        // Try to get the user data from Firestore
        _user = await _userRepository.getUser(credential.user!.uid);
      } catch (e) {
        // If we get a permission error, create a default user
        if (e.toString().contains('permission-denied') || 
            e.toString().contains('Missing or insufficient permissions')) {
          
          developer.log('Permission error when getting user, creating default user');
          
          try {
            // Try to ensure user document exists
            final uid = credential.user!.uid;
            final defaultUser = app_model.Beginner(
              id: uid,
              name: credential.user!.displayName ?? 'Default User',
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
            
            // Use the default user
            _user = defaultUser;
            
            // Enable offline mode automatically when we detect permission errors
            setForceOfflineMode(true);
            developer.log('Automatically enabled offline mode due to permission errors');
            
            // Try to save the default user (this might still fail due to permissions)
            try {
              await _userRepository.saveUser(defaultUser);
              developer.log('Created default user document during login');
            } catch (saveError) {
              developer.log('Could not save default user document: $saveError');
              // We'll continue anyway with the in-memory user object
            }
          } catch (createError) {
            developer.log('Error creating default user: $createError');
            // Just continue with null user
          }
        } else {
          // For other errors, propagate them
          rethrow;
        }
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, Map<String, dynamic> userData) async {
    if (!_validateUserData(userData)) {
      _error = 'Missing required user data fields';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final credential = await _authService.signUpWithEmail(email, password);
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        _error = 'Registration failed: user not authenticated.';
        notifyListeners();
        return false;
      }
      developer.log('Registered user UID: ${firebaseUser.uid}');
      // Create appropriate user type based on userType field
      final user = await _createUserInstance(
        id: firebaseUser.uid,
        userData: {
          ...userData,
          'joinDate': DateTime.now(),
        },
      );
      // Save user with username
      await _userRepository.createUserWithType(
        id: firebaseUser.uid,
        name: user.name,
        age: user.age,
        gender: user.gender,
        height: user.height,
        weight: user.weight,
        healthGoal: user.healthGoal,
        userType: userData['userType'] ?? 'beginner',
        additionalData: _getAdditionalData(user),
        username: userData['username'],
        email: email,
      );
      _user = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  bool _validateUserData(Map<String, dynamic> userData) {
    final requiredFields = [
      'name',
      'age',
      'gender',
      'height',
      'weight',
      'healthGoal',
    ];

    return requiredFields.every((field) => userData[field] != null);
  }

  Future<app_model.User> _createUserInstance({
    required String id,
    required Map<String, dynamic> userData,
  }) async {
    final userType = userData['userType']?.toLowerCase() ?? 'beginner';
    final name = userData['name'] ?? 'New User';
    final age = (userData['age'] ?? 25) as int;
    final gender = userData['gender'] ?? 'Not specified';
    final height = (userData['height'] ?? 170.0).toDouble();
    final weight = (userData['weight'] ?? 70.0).toDouble();
    final healthGoal = userData['healthGoal'] ?? 'General fitness';
    final joinDate = userData['joinDate'] ?? DateTime.now();

    switch (userType) {
      case 'beginner':
        return app_model.Beginner(
          id: id,
          name: name,
          age: age,
          gender: gender,
          height: height,
          weight: weight,
          healthGoal: healthGoal,
          joinDate: joinDate,
          motivationLevel: userData['motivationLevel'] ?? 5,
          learningPreferences: List<String>.from(userData['learningPreferences'] ?? []),
          hasPreviousInjury: userData['hasPreviousInjury'] ?? false,
        );
      case 'weight_management':
        return app_model.WeightMgmtUser(
          id: id,
          name: name,
          age: age,
          gender: gender,
          height: height,
          weight: weight,
          healthGoal: healthGoal,
          joinDate: joinDate,
          targetWeight: (userData['targetWeight'] ?? weight).toDouble(),
          dietPreference: userData['dietPreference'] ?? 'balanced',
          weeklyGoal: (userData['weeklyGoal'] ?? 0.5).toDouble(),
          dietaryRestrictions: List<String>.from(userData['dietaryRestrictions'] ?? []),
        );
      case 'fitness':
        return app_model.FitnessUser(
          id: id,
          name: name,
          age: age,
          gender: gender,
          height: height,
          weight: weight,
          healthGoal: healthGoal,
          joinDate: joinDate,
          trainingTypes: List<String>.from(userData['trainingTypes'] ?? ['general']),
          fitnessLevel: userData['fitnessLevel'] ?? 'intermediate',
          workoutDaysPerWeek: userData['workoutDaysPerWeek'] ?? 3,
          currentRoutine: userData['currentRoutine'],
        );
      case 'elder':
        return app_model.Elder(
          id: id,
          name: name,
          age: age,
          gender: gender,
          height: height,
          weight: weight,
          healthGoal: healthGoal,
          joinDate: joinDate,
          mobilityLevel: userData['mobilityLevel'] ?? 'moderate',
          healthConditions: List<String>.from(userData['healthConditions'] ?? []),
          usesAssistiveDevice: userData['usesAssistiveDevice'] ?? false,
        );
      case 'busy':
        return app_model.BusyUser(
          id: id,
          name: name,
          age: age,
          gender: gender,
          height: height,
          weight: weight,
          healthGoal: healthGoal,
          joinDate: joinDate,
          workHoursPerDay: userData['workHoursPerDay'] ?? 8,
          availableExerciseTime: userData['availableExerciseTime'] ?? 30,
          stressManagementPreference: userData['stressManagementPreference'] ?? 'meditation',
        );
      default:
        return app_model.Beginner(
          id: id,
          name: name,
          age: age,
          gender: gender,
          height: height,
          weight: weight,
          healthGoal: healthGoal,
          joinDate: joinDate,
          motivationLevel: 5,
          learningPreferences: [],
          hasPreviousInjury: false,
        );
    }
  }

  Map<String, dynamic> _getAdditionalData(app_model.User user) {
    if (user is app_model.Beginner) {
      return {
        'motivationLevel': user.motivationLevel,
        'learningPreferences': user.learningPreferences,
        'hasPreviousInjury': user.hasPreviousInjury,
      };
    } else if (user is app_model.WeightMgmtUser) {
      return {
        'targetWeight': user.targetWeight,
        'dietPreference': user.dietPreference,
        'weeklyGoal': user.weeklyGoal,
        'dietaryRestrictions': user.dietaryRestrictions,
      };
    } else if (user is app_model.FitnessUser) {
      return {
        'trainingTypes': user.trainingTypes,
        'fitnessLevel': user.fitnessLevel,
        'workoutDaysPerWeek': user.workoutDaysPerWeek,
        'currentRoutine': user.currentRoutine,
      };
    } else if (user is app_model.Elder) {
      return {
        'mobilityLevel': user.mobilityLevel,
        'healthConditions': user.healthConditions,
        'usesAssistiveDevice': user.usesAssistiveDevice,
      };
    } else if (user is app_model.BusyUser) {
      return {
        'workHoursPerDay': user.workHoursPerDay,
        'availableExerciseTime': user.availableExerciseTime,
        'stressManagementPreference': user.stressManagementPreference,
      };
    }
    return {};
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _user = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String userType,
    required int age,
    required String gender,
    required double height,
    required double weight,
    required String healthGoal,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      developer.log('Attempting signup with email: $email');

      final userCredential = await _authService.signUpWithEmail(email, password);
      if (userCredential.user != null) {
        developer.log('Signup successful, creating user profile');
        try {
          final newUser = await _userRepository.createUserWithType(
            id: userCredential.user!.uid,
            name: name,
            age: age,
            gender: gender,
            height: height,
            weight: weight,
            healthGoal: healthGoal,
            userType: userType,
            additionalData: additionalData,
          );
          _user = newUser;
          notifyListeners();
          return true;
        } catch (e) {
          developer.log('Error creating user profile after signup', error: e);
          // Try to clean up the auth account if profile creation fails
          try {
            // This is a best effort cleanup
            await _authService.signOut();
          } catch (_) {}
          _setError('Account created but failed to set up profile: ${e.toString()}');
          return false;
        }
      }
      _setError('Signup failed: No user returned');
      return false;
    } catch (e, stackTrace) {
      developer.log(
        'Signup error',
        error: e,
        stackTrace: stackTrace,
      );
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle() async {
    throw UnimplementedError('Google Sign-In has been removed from this application');
  }

  Future<void> updateProfile({
    String? name,
    int? age,
    String? gender,
    double? weight,
    double? height,
    String? healthGoal,
    String? userType,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      if (_user == null) {
        _setError('No user logged in');
        return;
      }

      developer.log('Updating profile for user: ${_user!.id}');

      await _userRepository.updateUserFields(
        _user!.id,
        {
          if (name != null) 'name': name,
          if (age != null) 'age': age,
          if (gender != null) 'gender': gender,
          if (weight != null) 'weight': weight,
          if (height != null) 'height': height,
          if (healthGoal != null) 'healthGoal': healthGoal,
          if (userType != null) 'userType': userType,
          if (additionalData != null) ...additionalData,
        },
      );

      await _loadUserData(_user!.id);
      developer.log('Profile updated successfully');
    } catch (e, stackTrace) {
      developer.log(
        'Profile update error',
        error: e,
        stackTrace: stackTrace,
      );
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteAccount() async {
    try {
      _setLoading(true);
      _clearError();

      if (_user == null) {
        _setError('No user logged in');
        return;
      }

      developer.log('Deleting account for user: ${_user!.id}');

      await _userRepository.deleteUser(_user!.id);
      await _authService.signOut();
      _user = null;
      notifyListeners();
      developer.log('Account deleted successfully');
    } catch (e, stackTrace) {
      developer.log(
        'Account deletion error',
        error: e,
        stackTrace: stackTrace,
      );
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadUserData(String uid) async {
    try {
      developer.log('Loading user data for ID: $uid');

      _user = await _userRepository.getUser(uid);

      if (_user == null) {
        developer.log('No user data found for ID: $uid');
        _setError('User data not found');
      } else {
        developer.log('User data loaded successfully');
      }

      notifyListeners();
    } catch (e, stackTrace) {
      developer.log(
        'Error loading user data',
        error: e,
        stackTrace: stackTrace,
      );
      _setError('Failed to load user data: ${e.toString()}');
      rethrow;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // User-specific methods remain unchanged
  String? getUserSpecificAdvice() {
    if (_user == null) return null;

    if (_user is app_model.Beginner) {
      return 'Start with basic exercises and gradually increase intensity';
    } else if (_user is app_model.WeightMgmtUser) {
      final user = _user as app_model.WeightMgmtUser;
      return 'Target weight: ${user.targetWeight}kg. Current: ${user.weight}kg';
    } else if (_user is app_model.FitnessUser) {
      return 'Focus on ${(_user as app_model.FitnessUser).trainingTypes.join(', ')} training';
    } else if (_user is app_model.Elder) {
      return (_user as app_model.Elder).getRecommendedActivities();
    } else if (_user is app_model.BusyUser) {
      return 'Recommended: ${(_user as app_model.BusyUser).getTimeEfficientWorkouts()}';
    }
    return null;
  }

  double? calculateBMI() {
    if (_user == null) return null;
    return _user!.weight / ((_user!.height / 100) * (_user!.height / 100));
  }

  String? getFitnessPlan() {
    if (_user == null) return null;

    if (_user is app_model.Beginner) {
      return '3 days/week full-body workouts';
    } else if (_user is app_model.WeightMgmtUser) {
      return '4 days/week cardio + 2 days/week strength training';
    } else if (_user is app_model.FitnessUser) {
      final user = _user as app_model.FitnessUser;
      return '${user.workoutDaysPerWeek} days/week ${user.fitnessLevel} training';
    } else if (_user is app_model.Elder) {
      return 'Daily mobility exercises + 3 days/week light strength';
    } else if (_user is app_model.BusyUser) {
      return (_user as app_model.BusyUser).getTimeEfficientWorkouts();
    }
    return 'General fitness plan';
  }

  // Add this method to ensure backwards compatibility
  Future<bool> signIn(String email, String password) async {
    // This is just an adapter method to call login
    return await login(email, password);
  }

  // Add missing updateUserProfile method needed by profile_setup_screen.dart
  Future<bool> updateUserProfile(Map<String, dynamic> profileData) async {
    try {
      _setLoading(true);
      _clearError();
      
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        _setError('No user logged in');
        return false;
      }

      // Check if user exists in database
      bool userExists = false;
      try {
        userExists = await _userRepository.userExists(currentUser.uid);
      } catch (e) {
        developer.log('Error checking if user exists', error: e);
        // Continue anyway, we'll try to update or create
      }
      
      if (userExists) {
        // User exists, update profile
        developer.log('Updating existing user profile');
        await _userRepository.updateUserFields(
          currentUser.uid,
          {
            'age': profileData['age'],
            'weight': profileData['weight'],
            'height': profileData['height'],
            'healthGoal': profileData['healthGoal'],
          },
        );
      } else {
        // User doesn't exist in Firestore, create new profile
        developer.log('Creating new user profile');
        final userType = profileData['userType'] ?? 'beginner'; // Default to beginner
        final name = profileData['name'] ?? currentUser.displayName ?? 'New User';
        
        await _userRepository.createUserWithType(
          id: currentUser.uid,
          name: name,
          age: profileData['age'],
          gender: profileData['gender'] ?? 'Not specified',
          height: profileData['height'],
          weight: profileData['weight'],
          healthGoal: profileData['healthGoal'],
          userType: userType,
          additionalData: profileData['additionalData'] ?? {
            'motivationLevel': 5,
            'learningPreferences': [],
            'hasPreviousInjury': false,
          },
        );
      }
      
      // Reload user data
      await _loadUserData(currentUser.uid);
      return true;
    } catch (e) {
      developer.log('Error updating user profile', error: e);
      _setError('Failed to update profile: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check if username is unique
  Future<bool> checkUsernameUnique(String username) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return snapshot.docs.isEmpty;
  }
}