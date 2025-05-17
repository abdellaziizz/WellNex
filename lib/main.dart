import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import 'package:wellnex/screens/articles_screen.dart';
import 'package:wellnex/screens/home_screen.dart';
import 'package:wellnex/screens/login_screen.dart';
import 'package:wellnex/screens/profile_setup_screen.dart';
import 'package:wellnex/screens/progress_tracker_screen.dart';
import 'package:wellnex/screens/recommendations_screen.dart';
import 'package:wellnex/screens/splash_screen.dart';
import 'package:wellnex/screens/main_scaffold.dart';
import 'package:wellnex/services/auth_service.dart';
import 'package:wellnex/services/database_service.dart';
import 'package:wellnex/services/firebase_service.dart';
import 'package:wellnex/utils/exceptions.dart';
import 'package:wellnex/viewmodels/user_viewmodel.dart';
import 'package:wellnex/viewmodels/health_viewmodel.dart';
import 'package:wellnex/viewmodels/recommendations_viewmodel.dart';
import 'package:wellnex/viewmodels/health_recommendations_viewmodel.dart';
import 'package:wellnex/repositories/user_repository.dart';
import 'package:wellnex/controllers/navigation_controller.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Configure Firestore
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      sslEnabled: true,
    );
    
    // Initialize services
    final firebaseService = FirebaseService();
    final authService = AuthService(firebaseService);
    final userRepository = UserRepository();
    
    runApp(
      MultiProvider(
        providers: [
          Provider<FirebaseService>.value(value: firebaseService),
          Provider<AuthService>.value(value: authService),
          Provider<UserRepository>.value(value: userRepository),
          ChangeNotifierProvider(create: (_) => NavigationController()),
          ChangeNotifierProvider<UserViewModel>(
            create: (context) => UserViewModel(
              context.read<AuthService>(),
              context.read<UserRepository>(),
            ),
          ),
          ChangeNotifierProxyProvider<UserViewModel, HealthRecommendationsViewModel>(
            create: (context) => HealthRecommendationsViewModel(),
            update: (context, userVM, previousVM) {
              final viewModel = previousVM ?? HealthRecommendationsViewModel();
              developer.log('Updating HealthRecommendationsViewModel - User: ${userVM.user?.id ?? 'null'}');
              if (userVM.user != null) {
                developer.log('Setting user ID in HealthRecommendationsViewModel: ${userVM.user!.id}');
                viewModel.setUserId(userVM.user!.id);
              } else {
                developer.log('No user available in UserViewModel');
              }
              return viewModel;
            },
          ),
          ChangeNotifierProxyProvider<UserViewModel, RecommendationsViewModel>(
            create: (context) => RecommendationsViewModel(),
            update: (context, userVM, previousVM) => 
              previousVM!..updateUserData(userVM.user),
          ),
          ChangeNotifierProxyProvider<UserViewModel, HealthViewModel>(
            create: (context) => HealthViewModel(),
            update: (context, userVM, previousVM) => 
              previousVM!..updateUserData(userVM.user),
          ),
        ],
        child: const WellNexApp(),
      ),
    );
  } catch (e, stack) {
    developer.log('Firebase initialization error', error: e, stackTrace: stack);
    runApp(FirebaseErrorApp(error: e.toString()));
  }
}

class FirebaseErrorApp extends StatelessWidget {
  final String? error;
  
  const FirebaseErrorApp({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF43A047),
                Color(0xFF0B4C37),
              ],
            ),
          ),
          child: Center(
            child: Card(
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFF0B4C37),
                      size: 64,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Firebase Connection Error',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0B4C37),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Unable to connect to Firebase.\n\n${error != null ? 'Error: $error\n\n' : ''}'
                      'Please check:\n'
                      '• Your internet connection\n'
                      '• Firewall settings (run configure_firewall.ps1 as admin)\n'
                      '• API key configuration in firebase_options.dart',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => main(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B4C37),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Retry Connection'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WellNexApp extends StatelessWidget {
  const WellNexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WellNex',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0B4C37),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF0B4C37),
          secondary: const Color(0xFF2A8D6A),
          surface: Colors.white,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0B4C37),
          iconTheme: IconThemeData(color: Color(0xFF0B4C37)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0B4C37), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0B4C37),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF0B4C37),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/profile-setup': (context) => const ProfileSetupScreen(),
        '/home': (context) => const MainScaffold(),
      },
    );
  }
}