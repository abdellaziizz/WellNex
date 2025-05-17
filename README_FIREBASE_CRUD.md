# WellNex Firebase CRUD Operations Guide

This guide explains how to use the Firebase integration in the WellNex application to perform CRUD (Create, Read, Update, Delete) operations on various data types.

## Setup

Before using the services, ensure you have the following collections in your Firestore database:

- `users` - Stores user profiles
- `workouts` - Stores workout plans
- `meal_plans` - Stores meal plans
- `health_data` - Stores health metrics

## Repository Pattern

WellNex uses a repository pattern for data access:

1. **Models** - Define the structure of the data
2. **Services** - Handle direct Firebase operations
3. **Repositories** - Provide a higher-level API for operations

## Usage Examples

### Accessing Repositories

Use the main `Repository` class to access all repositories:

```dart
// Get the repository instance
final repository = Repository();

// Access specific repositories
final userRepo = repository.user;
final workoutRepo = repository.workout;
final mealPlanRepo = repository.mealPlan;
```

### User Operations

```dart
// Get the current user
final currentUser = await repository.user.getCurrentUser();

// Update user profile
final updatedUser = currentUser as Beginner;
await repository.user.updateUserProfile(
  updatedUser.copyWith(motivationLevel: 4)
);

// Track a health metric
await repository.user.trackHealthMetric(
  metric: 'kg',
  value: 72.5,
  category: 'weight',
  notes: 'Morning weight'
);

// Get health history
final weightHistory = await repository.user.getHealthHistory(
  category: 'weight',
  startDate: DateTime.now().subtract(Duration(days: 30)),
  endDate: DateTime.now(),
);
```

### Workout Operations

```dart
// Create a new workout
final workout = await repository.workout.createWorkout(
  name: 'Full Body Strength',
  description: 'A complete full body workout targeting all major muscle groups',
  exercises: [
    Exercise(
      name: 'Push-ups',
      muscleGroup: 'chest',
      sets: 3,
      reps: 10,
    ),
    Exercise(
      name: 'Squats',
      muscleGroup: 'legs',
      sets: 3,
      reps: 15,
    ),
  ],
  durationMinutes: 45,
  intensityLevel: 'intermediate',
);

// Get all user workouts
final userWorkouts = await repository.workout.getUserWorkouts();

// Mark a workout as completed
await repository.workout.completeWorkout(workout.id);

// Delete a workout
await repository.workout.deleteWorkout(workout.id);
```

### Meal Plan Operations

```dart
// Create a sample meal plan
final mealPlan = await repository.mealPlan.createSampleMealPlan(
  dietType: 'balanced',
  targetCalories: 2000,
  restrictions: ['dairy', 'gluten'],
);

// Get all user meal plans
final userMealPlans = await repository.mealPlan.getUserMealPlans();

// Get meal plans by diet type
final ketoPlans = await repository.mealPlan.getMealPlansByDietType('keto');

// Update a meal plan
await repository.mealPlan.updateMealPlan(
  mealPlan.copyWith(hydrationGoalLiters: 3.0),
);

// Delete a meal plan
await repository.mealPlan.deleteMealPlan(mealPlan.id);
```

### Health Data Operations

```dart
// Track a health metric
final healthData = await repository.health.createHealthDataPoint(
  value: 72.5,
  metric: 'kg',
  category: 'weight',
  notes: 'Morning weight'
);

// Get latest health data for a category
final latestWeight = await repository.health.getLatestHealthData('weight');

// Get health data history for a date range
final weightHistory = await repository.health.getHealthDataByDateRange(
  'weight',
  DateTime.now().subtract(Duration(days: 30)),
  DateTime.now()
);

// Stream health data for real-time updates
final weightStream = repository.health.getHealthDataStream('weight')
  .listen((dataPoints) {
    // Update UI with new data points
    print('Received ${dataPoints.length} weight records');
  });

// Update a health data point
final updatedDataPoint = healthData.copyWith(
  value: 73.0,
  notes: 'Updated weight'
);
await repository.health.updateHealthData(updatedDataPoint);

// Delete a health data point
await repository.health.deleteHealthData(healthData.id);
```

## Firestore Collection Structure

### Users Collection
```
users/
  {userId}/
    name: String
    age: int
    gender: String
    height: double
    weight: double
    healthGoal: String
    joinDate: Timestamp
    userType: String
    ... (user-specific fields)
```

### Workouts Collection
```
workouts/
  {workoutId}/
    userId: String
    name: String
    description: String
    exercises: Array<Map>
    durationMinutes: int
    intensityLevel: String
    createdAt: Timestamp
    completedAt: Timestamp?
    isCompleted: boolean
```

### Meal Plans Collection
```
meal_plans/
  {mealPlanId}/
    userId: String
    name: String
    dietType: String
    totalCalories: int
    createdAt: Timestamp
    meals: Array<Map>
    proteinGrams: double
    carbsGrams: double
    fatsGrams: double
    hydrationGoalLiters: double
    restrictions: Array<String>
```

### Health Data Collection
```
health_data/
  {dataPointId}/
    userId: String
    date: Timestamp
    value: double
    metric: String
    category: String
    notes: String?
```

## Firebase Security Rules

Here's a starting point for your Firebase security rules to secure this data:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow users to read and write their own data only
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /workouts/{workoutId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    match /meal_plans/{mealPlanId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    match /health_data/{dataPointId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
  }
}
``` 