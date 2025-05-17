import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final UserRepository _userRepository;
  User? _user;
  String? _error;
  bool _isLoading = false;
  bool _isInitialized = false;

  AuthProvider(this._authService, this._userRepository) {
    _initialize();
  }

  User? get user => _user;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _user != null;

  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      _authService.authStateChanges.listen((firebaseUser) async {
        try {
          if (firebaseUser != null) {
            _user = await _userRepository.getUser(firebaseUser.uid);
            _error = _user == null ? 'Complete your profile' : null;
          } else {
            _user = null;
          }
        } catch (e) {
          _error = 'Error loading user data';
          _user = null;
        }
        notifyListeners();
      });

      _isInitialized = true;
    } catch (e) {
      _error = 'Failed to initialize authentication';
      _isInitialized = false;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential = await _authService.signInWithEmail(email, password);
      if (userCredential.user != null) {
        _user = await _userRepository.getUser(userCredential.user!.uid);
        if (_user == null) {
          _error = 'Please complete your profile setup';
          return false;
        }
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential = await _authService.signUpWithEmail(email, password);
      if (userCredential.user != null) {
        await _userRepository.createUserWithType(
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
        _user = await _userRepository.getUser(userCredential.user!.uid);
        return true;
      }
      _error = 'Signup failed';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _user = null;
      return true;
    } catch (e) {
      _error = 'Sign out failed';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}