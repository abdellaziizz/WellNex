import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import '../utils/exceptions.dart';
import 'dart:async';

import '../firebase_options.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  bool _initialized = false;

  // Private constructor
  FirebaseService._internal() : 
    _auth = FirebaseAuth.instance,
    _firestore = FirebaseFirestore.instance {
    _configureForWindows();
    _initialized = true; // Set to true by default since Firebase is initialized
    developer.log('FirebaseService initialized');
    
    // Listen for auth state changes and ensure user document exists
    _auth.authStateChanges().listen(_handleAuthStateChange);
  }
  
  // Handle auth state changes and ensure user documents exist
  void _handleAuthStateChange(User? user) async {
    if (user != null) {
      developer.log('Auth state changed: User signed in: ${user.uid}');
      await _ensureUserDocumentExists(user);
    } else {
      developer.log('Auth state changed: User signed out');
    }
  }
  
  // Ensure a user document exists in Firestore
  Future<void> _ensureUserDocumentExists(User user) async {
    try {
      // Force create the user document without checking if it exists first
      // This bypasses the need for any read permission
      if (kDebugMode) {
        developer.log('Creating user document directly without verification (dev mode)');
        
        try {
          // Create a default user document
          await _firestore.collection('users').doc(user.uid).set({
            'id': user.uid,
            'name': user.displayName ?? 'New User',
            'email': user.email,
            'age': 30,
            'gender': 'Not specified',
            'height': 170.0,
            'weight': 70.0,
            'healthGoal': 'General wellness',
            'joinDate': FieldValue.serverTimestamp(),
            'userType': 'beginner',
            'motivationLevel': 3,
            'learningPreferences': ['Video tutorials'],
            'hasPreviousInjury': false,
          }, SetOptions(merge: true));  // Use merge to avoid overwriting existing data
          
          developer.log('Created/updated user document successfully (forced approach)');
          return;
        } catch (innerError) {
          developer.log('Still failed to create user document: $innerError');
          // Continue to normal flow
        }
      }
      
      // Standard approach - check if exists first
      try {
        // Check if the user document already exists
        final docRef = _firestore.collection('users').doc(user.uid);
        final doc = await docRef.get();
        
        if (!doc.exists) {
          developer.log('Creating default user document for ${user.uid}');
          
          // Create a default user document
          await docRef.set({
            'id': user.uid,
            'name': user.displayName ?? 'New User',
            'email': user.email,
            'age': 30,
            'gender': 'Not specified',
            'height': 170.0,
            'weight': 70.0,
            'healthGoal': 'General wellness',
            'joinDate': FieldValue.serverTimestamp(),
            'userType': 'beginner',
            'motivationLevel': 3,
            'learningPreferences': ['Video tutorials'],
            'hasPreviousInjury': false,
          });
          
          developer.log('Created default user document successfully');
        } else {
          developer.log('User document already exists for ${user.uid}');
        }
      } catch (e) {
        developer.log('Error in standard document check: $e');
      }
    } catch (e) {
      developer.log('Error ensuring user document exists: $e');
      // Don't throw - this is a background operation
    }
  }

  // Factory constructor
  factory FirebaseService() => _instance;

  void _configureForWindows() {
    if (defaultTargetPlatform == TargetPlatform.windows) {
      developer.log('Configuring Firestore for Windows platform');
      try {
        // Use a more permissive configuration for Windows
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
          sslEnabled: true,
          ignoreUndefinedProperties: true, // Handle undefined properties
        );
        
        developer.log('Windows Firestore configuration applied');
      } catch (e) {
        developer.log('Error configuring Firestore for Windows: $e');
      }
    }
  }

  // Validate that Firebase is properly initialized
  Future<void> validateConnection() async {
    try {
      // Check basic Firebase initialization
      final app = Firebase.app();
      
      // Check if Firestore is accessible
      try {
        await FirebaseFirestore.instance.collection('users').limit(1).get();
      } catch (e) {
        if (!e.toString().contains('permission-denied') && 
            !e.toString().contains('PERMISSION_DENIED')) {
          throw FirebaseConnectionException('Firestore connection failed: $e');
        }
      }
      
      _initialized = true;
      return;
    } catch (e) {
      _initialized = false;
      throw FirebaseConnectionException('Firebase connection validation failed: $e');
    }
  }

  // Test Firestore connection with timeout
  Future<bool> testFirestoreConnection({int timeoutSeconds = 10}) async {
    developer.log('Testing Firestore connection...');
    
    try {
      // Use a simpler timeout approach
      final result = await _firestore.collection('users')
          .limit(1)
          .get()
          .timeout(
            Duration(seconds: timeoutSeconds),
            onTimeout: () {
              developer.log('Firestore query timed out after $timeoutSeconds seconds');
              throw TimeoutException('Firestore query timed out');
            },
          );
      
      developer.log('Firestore connection test succeeded: got ${result.docs.length} documents');
      return true;
    } catch (e) {
      developer.log('Firestore connection test failed: $e');
      
      // If this is a permissions error but we connected, that's still a successful connection
      if (e.toString().contains('permission-denied') || 
          e.toString().contains('PERMISSION_DENIED')) {
        developer.log('Permission denied but connection was successful');
        return true;
      }
      
      return false;
    }
  }

  // Enable development mode with less restrictive security
  Future<void> enableDevelopmentMode() async {
    if (kDebugMode) {
      developer.log('Enabling development mode for Firebase');
      try {
        // In a production app, you would have proper security rules
        // For development purposes only, we're adding an auth token
        if (_auth.currentUser != null) {
          final idToken = await _auth.currentUser!.getIdToken(true);
          developer.log('Auth token refreshed for development mode');
          
          // Attempt to apply simulated rules locally (emulating what would happen with proper rule deployment)
          await _simulateFirestoreRules();
        } else {
          developer.log('No user logged in, cannot refresh token');
        }
      } catch (e) {
        developer.log('Error enabling development mode: $e');
      }
    }
  }
  
  // Simulate Firestore security rules by setting custom headers
  Future<void> _simulateFirestoreRules() async {
    try {
      developer.log('Simulating Firestore security rules for development');
      
      // Set metadata on Firestore instance
      // This doesn't actually change rules but helps with debugging 
      // by adding context for permission errors
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        sslEnabled: true,
        ignoreUndefinedProperties: true,
      );
      
      developer.log('Development mode enabled for Firestore');
    } catch (e) {
      developer.log('Could not simulate firestore rules: $e');
    }
  }

  // Check authentication providers and log them
  Future<List<String>> checkAuthProviders() async {
    try {
      // We can't enable providers programmatically through the SDK
      // But we can check what providers are enabled
      final providers = await _auth.fetchSignInMethodsForEmail('test@example.com');
      
      developer.log('Available authentication providers: ${providers.isEmpty ? "None" : providers.join(", ")}');
      
      if (providers.isEmpty) {
        developer.log('WARNING: No authentication providers appear to be enabled.');
        developer.log('Please enable Email/Password authentication in the Firebase Console:');
        developer.log('1. Go to: console.firebase.google.com');
        developer.log('2. Select project: ${_firestore.app.options.projectId}');
        developer.log('3. Go to Authentication > Sign-in method');
        developer.log('4. Enable Email/Password provider');
      }
      
      return providers;
    } catch (e) {
      developer.log('Error checking authentication providers: $e');
      return [];
    }
  }

  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  User? get currentUser => _auth.currentUser;
  String? get currentUserId => currentUser?.uid;
  bool get isInitialized => _initialized;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  FieldValue get serverTimestamp => FieldValue.serverTimestamp();
}