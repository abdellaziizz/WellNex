# WellNex Firebase Setup Guide

This guide provides step-by-step instructions for setting up the Firebase collections needed for the WellNex application.

## Prerequisites

1. A Firebase project created in the [Firebase Console](https://console.firebase.google.com/)
2. Flutter Firebase SDK packages installed in your project
3. Flutter application connected to Firebase (using `firebase_options.dart`)

## Setting Up Collections

### 1. Creating the Users Collection

1. Go to the Firebase Console > Firestore Database
2. Create collection named `users`
3. Create a test user document:

```
Collection: users
Document ID: (auto-generated or use a test user ID)
Fields:
- name: "Test User" (string)
- age: 30 (number)
- gender: "Not specified" (string)
- height: 175.0 (number)
- weight: 70.0 (number)
- healthGoal: "General fitness" (string)
- joinDate: (timestamp - current date)
- userType: "beginner" (string)
- motivationLevel: 3 (number)
- learningPreferences: ["Video tutorials"] (array)
- hasPreviousInjury: false (boolean)
```

### 2. Creating the Workouts Collection

1. Create collection named `workouts`
2. Create a sample workout:

```
Collection: workouts
Document ID: (auto-generated)
Fields:
- userId: (same as the test user ID) (string)
- name: "Beginner Full Body" (string)
- description: "Simple full body workout for beginners" (string)
- exercises: [
    {
      name: "Push-ups",
      muscleGroup: "chest",
      sets: 3,
      reps: 10,
      isCompleted: false
    },
    {
      name: "Squats",
      muscleGroup: "legs",
      sets: 3,
      reps: 15,
      isCompleted: false
    }
  ] (array of maps)
- durationMinutes: 30 (number)
- intensityLevel: "beginner" (string)
- createdAt: (timestamp - current date)
- isCompleted: false (boolean)
```

### 3. Creating the Meal Plans Collection

1. Create collection named `meal_plans`
2. Create a sample meal plan:

```
Collection: meal_plans
Document ID: (auto-generated)
Fields:
- userId: (same as the test user ID) (string)
- name: "Balanced Meal Plan" (string)
- dietType: "balanced" (string)
- totalCalories: 2000 (number)
- createdAt: (timestamp - current date)
- meals: [
    {
      name: "Breakfast",
      mealType: "breakfast",
      calories: 500,
      foodItems: [
        {
          name: "Oatmeal",
          quantity: 1,
          unit: "cup",
          calories: 300,
          proteinGrams: 10,
          carbsGrams: 50,
          fatsGrams: 5
        },
        {
          name: "Banana",
          quantity: 1,
          unit: "medium",
          calories: 100,
          proteinGrams: 1,
          carbsGrams: 25,
          fatsGrams: 0
        }
      ],
      recipe: "Cook oatmeal and top with sliced banana."
    }
  ] (array of maps)
- proteinGrams: 140.0 (number)
- carbsGrams: 250.0 (number)
- fatsGrams: 65.0 (number)
- hydrationGoalLiters: 2.5 (number)
- restrictions: [] (array)
```

### 4. Creating the Health Data Collection

1. Create collection named `health_data`
2. Create a sample health data point:

```
Collection: health_data
Document ID: (auto-generated)
Fields:
- userId: (same as the test user ID) (string)
- date: (timestamp - current date)
- value: 70.0 (number)
- metric: "kg" (string)
- category: "weight" (string)
```

## Testing the Setup

After creating these collections, you can test your application by:

1. Logging in with the test user
2. Verifying that the user data loads correctly
3. Creating new workouts and meal plans
4. Tracking health metrics

## Firebase Indexes

For complex queries to work properly, you may need to create the following composite indexes:

### Workouts Collection

Index 1:
- Collection: workouts
- Fields to index:
  - userId (Ascending)
  - createdAt (Descending)

Index 2:
- Collection: workouts
- Fields to index:
  - userId (Ascending)
  - intensityLevel (Ascending)
  - createdAt (Descending)

### Meal Plans Collection

Index 1:
- Collection: meal_plans
- Fields to index:
  - userId (Ascending)
  - createdAt (Descending)

Index 2:
- Collection: meal_plans
- Fields to index:
  - userId (Ascending)
  - dietType (Ascending)
  - createdAt (Descending)

Index 3:
- Collection: meal_plans
- Fields to index:
  - userId (Ascending)
  - totalCalories (Ascending)

### Health Data Collection

Index 1:
- Collection: health_data
- Fields to index:
  - userId (Ascending)
  - date (Descending)

Index 2:
- Collection: health_data
- Fields to index:
  - userId (Ascending)
  - category (Ascending)
  - date (Descending)

Index 3:
- Collection: health_data
- Fields to index:
  - userId (Ascending)
  - date (Ascending)

## Security Rules

Implement the security rules from the CRUD guide to ensure data is properly secured. 