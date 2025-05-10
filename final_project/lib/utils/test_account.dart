// Test account credentials for development purposes only
class TestAccount {
  static const String email = 'test@wellnex.com';
  static const String password = 'Test123!';
  
  static final Map<String, dynamic> userData = {
    'name': 'Test User',
    'age': 25,
    'gender': 'Not specified',
    'height': 170.0,
    'weight': 70.0,
    'healthGoal': 'General fitness',
    'userType': 'beginner',
    'motivationLevel': 5,
    'learningPreferences': ['Video tutorials', 'Written guides'],
    'hasPreviousInjury': false,
    
    // Additional fields to prevent null issues
    'email': 'test@wellnex.com',
    'trainingTypes': ['Cardio', 'Strength'],
    'fitnessLevel': 'beginner',
    'workoutDaysPerWeek': 3,
    'targetWeight': 65.0,
    'dietPreference': 'balanced',
    'weeklyGoal': 0.5,
    'dietaryRestrictions': [],
    'mobilityLevel': 'good',
    'healthConditions': [],
    'usesAssistiveDevice': false,
    'workHoursPerDay': 8,
    'availableExerciseTime': 30,
    'stressManagementPreference': 'physical',
  };
} 