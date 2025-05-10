# WellNex - Your Path to Better Health

WellNex is a personalized health and wellness app that offers customized recommendations for diet, exercise, and lifestyle changes based on user profiles. The app features a clean, modern UI with intuitive navigation.

## Firebase Backend Setup

This app uses Firebase for its backend. Follow these steps to set it up:

### 1. Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" and follow the setup wizard
3. Name your project (e.g., "WellNex")
4. Configure Google Analytics (optional but recommended)
5. Wait for the project to be created

### 2. Register Your App with Firebase

#### For Android:

1. In the Firebase console, click on the Android icon
2. Enter your Android package name (e.g., `com.example.wellnex`)
3. Enter app nickname (optional)
4. Enter SHA-1 key (for Google Sign-In functionality)
5. Download the `google-services.json` file
6. Place the file in the `android/app` directory of your Flutter project

#### For iOS:

1. In the Firebase console, click on the iOS icon
2. Enter your iOS bundle ID (e.g., `com.example.wellnex`)
3. Enter app nickname (optional)
4. Download the `GoogleService-Info.plist` file
5. Place the file in the `ios/Runner` directory of your Flutter project

### 3. Update Firebase Options

1. Open `lib/firebase_options.dart`
2. Replace the placeholder values with the actual Firebase configuration values
3. These values can be found in your Firebase project settings

### 4. Enable Firebase Services

#### Authentication:

1. In the Firebase console, go to Authentication
2. Click "Get started"
3. Enable Email/Password sign-in method
4. Enable Google sign-in method (optional)

#### Firestore Database:

1. Go to Firestore Database
2. Click "Create database"
3. Start in production mode or test mode
4. Choose a database location
5. Create the following collections:
   - `users`: Stores user profile information
   - `health_records`: Stores user health data
   - `recommendations`: Stores personalized recommendations

### 5. Set Firestore Security Rules

Go to Firestore Database > Rules and set appropriate security rules. For testing, you can use:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

For production, implement more restrictive rules.

### 6. Deploy Firebase Functions (Optional)

If you need backend functionality like scheduled recommendations or data processing:

1. Initialize Firebase Functions in your project
2. Create necessary functions
3. Deploy them to Firebase

## Running the App

1. Ensure you have Flutter installed and configured
2. Run `flutter pub get` to install dependencies
3. Ensure Firebase configuration files are in place
4. Run `flutter run` to start the app

## UI Customization

The app uses a consistent color scheme with dark green (`Color(0xFF0B4C37)`) as the primary color. All UI components follow this design language for a cohesive user experience.

## Key Features

- User authentication & profile management
- Personalized health recommendations
- Progress tracking with visual graphs
- Educational articles & resources
- Clean, modern UI design

## App Structure

The app follows an MVVM (Model-View-ViewModel) architecture:

- Models: Data models for users, health records, etc.
- Views: UI screens and components
- ViewModels: Business logic and state management
- Services: Firebase integration, API calls, etc.
- Repositories: Data access layer
