import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wellnex/viewmodels/user_viewmodel.dart';
import 'package:wellnex/viewmodels/health_recommendations_viewmodel.dart';
import 'package:flutter/services.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> with TickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  String _selectedGoal = 'Lose weight';
  String _selectedGender = 'Not specified';
  bool _isLoading = false;
  
  // Field validation
  String? _ageError;
  String? _weightError;
  String? _heightError;
  
  // Field constraints
  static const int minAge = 13;
  static const int maxAge = 120;
  static const double minWeight = 30.0;
  static const double maxWeight = 300.0;
  static const double minHeight = 100.0;
  static const double maxHeight = 250.0;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _buttonController;
  late List<AnimationController> _fieldControllers;
  late AnimationController _shakeController;
  
  // Animations
  late Animation<double> _buttonScaleAnimation;
  late List<Animation<double>> _fieldAnimations;
  late Animation<Offset> _shakeAnimation;

  final List<String> _healthGoals = [
    'Lose weight',
    'Gain muscle',
    'Improve fitness',
    'Eat healthier',
    'Reduce stress'
  ];

  final List<String> _genderOptions = [
    'Not specified',
    'Male',
    'Female',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupFieldListeners();
    _playAnimations();
  }

  void _initializeAnimations() {
    // Overall fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Button animation
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _buttonScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
    ]).animate(_buttonController);
    
    // Shake animation for validation errors
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _shakeAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(begin: Offset.zero, end: const Offset(0.05, 0)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(0.05, 0), end: const Offset(-0.05, 0)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(-0.05, 0), end: const Offset(0.05, 0)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero),
        weight: 25,
      ),
    ]).animate(_shakeController);

    // Field animations - one for each field group
    _fieldControllers = List.generate(
      6, // 6 field groups: username, email, password, age, weight/height, gender/goal
      (index) => AnimationController(
        duration: Duration(milliseconds: 400 + (index * 100)),
        vsync: this,
      ),
    );

    _fieldAnimations = _fieldControllers.map((controller) {
      return CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      );
    }).toList();
  }
  
  void _setupFieldListeners() {
    _ageController.addListener(_validateAge);
    _weightController.addListener(_validateWeight);
    _heightController.addListener(_validateHeight);
  }
  
  void _validateAge() {
    setState(() {
      if (_ageController.text.isNotEmpty) {
        try {
          final age = int.parse(_ageController.text);
          if (age < minAge) {
            _ageError = 'Min age is $minAge';
          } else if (age > maxAge) {
            _ageError = 'Max age is $maxAge';
          } else {
            _ageError = null;
          }
        } catch (_) {
          _ageError = 'Enter a valid number';
        }
      } else {
        _ageError = null;
      }
    });
  }
  
  void _validateWeight() {
    setState(() {
      if (_weightController.text.isNotEmpty) {
        try {
          final weight = double.parse(_weightController.text);
          if (weight < minWeight) {
            _weightError = 'Min $minWeight kg';
          } else if (weight > maxWeight) {
            _weightError = 'Max $maxWeight kg';
          } else {
            _weightError = null;
          }
        } catch (_) {
          _weightError = 'Enter a valid number';
        }
      } else {
        _weightError = null;
      }
    });
  }
  
  void _validateHeight() {
    setState(() {
      if (_heightController.text.isNotEmpty) {
        try {
          final height = double.parse(_heightController.text);
          if (height < minHeight) {
            _heightError = 'Min $minHeight cm';
          } else if (height > maxHeight) {
            _heightError = 'Max $maxHeight cm';
          } else {
            _heightError = null;
          }
        } catch (_) {
          _heightError = 'Enter a valid number';
        }
      } else {
        _heightError = null;
      }
    });
  }
  
  void _showValidationError() {
    _shakeController.forward().then((_) {
      _shakeController.reset();
    });
  }

  void _playAnimations() {
    // Stagger the animations
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
      
      for (int i = 0; i < _fieldControllers.length; i++) {
        Future.delayed(Duration(milliseconds: 150 * i), () {
          _fieldControllers[i].forward();
        });
      }

      Future.delayed(Duration(milliseconds: 150 * (_fieldControllers.length + 1)), () {
        _buttonController.forward();
      });
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    
    _fadeController.dispose();
    _buttonController.dispose();
    _shakeController.dispose();
    for (var controller in _fieldControllers) {
      controller.dispose();
    }
    
    super.dispose();
  }

  Future<bool> _isUsernameUnique(String username) async {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    return await userViewModel.checkUsernameUnique(username);
  }

  bool _validateAllFields() {
    bool isValid = true;
    
    // Validate required fields
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _heightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      _showValidationError();
      return false;
    }
    
    // Check for validation errors
    _validateAge();
    _validateWeight();
    _validateHeight();
    
    if (_ageError != null || _weightError != null || _heightError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix all validation errors')),
      );
      _showValidationError();
      return false;
    }
    
    return isValid;
  }

  void _saveProfile() async {
    if (!_validateAllFields()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // First register the user with Firebase Auth
      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      final success = await userViewModel.register(
        _emailController.text.trim(),
        _passwordController.text,
        {
          'username': _usernameController.text.trim(),
          'name': _usernameController.text.trim(),
          'age': int.parse(_ageController.text),
          'weight': double.parse(_weightController.text),
          'height': double.parse(_heightController.text),
          'healthGoal': _selectedGoal,
          'gender': _selectedGender,
          'userType': 'beginner',
        },
      );

      if (!mounted) return;

      if (success) {
        // Only calculate health metrics after successful registration
        final healthRecommendationsVM = Provider.of<HealthRecommendationsViewModel>(context, listen: false);
        await healthRecommendationsVM.calculateHealthMetrics(
          weight: double.parse(_weightController.text),
          height: double.parse(_heightController.text),
          age: int.parse(_ageController.text),
          gender: _selectedGender,
          healthGoal: _selectedGoal,
        );

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        final error = userViewModel.error ?? 'Failed to save profile';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Widget _buildAnimatedField(int index, Widget child) {
    return FadeTransition(
      opacity: _fieldAnimations[index],
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 0.05),
          end: Offset.zero,
        ).animate(_fieldAnimations[index]),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: FadeTransition(
            opacity: _fadeController,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Title with animation
                  FadeTransition(
                    opacity: _fadeController,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(-0.1, 0),
                        end: Offset.zero,
                      ).animate(_fadeController),
                      child: const Text(
                        'Create Your Profile',
                        style: TextStyle(
                          fontSize: 28, 
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B4C37),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Username - Field 1
                  _buildAnimatedField(
                    0,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Username', 
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0B4C37),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            hintText: 'Enter a unique username',
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF0B4C37),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  
                  // Email - Field 2
                  _buildAnimatedField(
                    1,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Email', 
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0B4C37),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Enter your email',
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF0B4C37),
                                width: 2,
                              ),
                            ),
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Color(0xFF0B4C37),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  
                  // Password - Field 3
                  _buildAnimatedField(
                    2,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Password', 
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0B4C37),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF0B4C37),
                                width: 2,
                              ),
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFF0B4C37),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  
                  // Age - Field 4
                  _buildAnimatedField(
                    3,
                    SlideTransition(
                      position: _ageError != null ? _shakeAnimation : const AlwaysStoppedAnimation(Offset.zero),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Age',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF0B4C37),
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 120,
                                child: TextField(
                                  controller: _ageController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(3),
                                  ],
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    filled: true,
                                    fillColor: _ageError != null ? Colors.red[50] : Colors.grey[50],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: _ageError != null ? Colors.red[300]! : Colors.grey[300]!,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: _ageError != null ? Colors.red : const Color(0xFF0B4C37),
                                        width: 2,
                                      ),
                                    ),
                                    hintText: '$minAge-$maxAge',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_ageError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    _ageError!,
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Weight & Height - Field 5
                  _buildAnimatedField(
                    4,
                    Column(
                      children: [
                        // Weight field with validation
                        SlideTransition(
                          position: _weightError != null ? _shakeAnimation : const AlwaysStoppedAnimation(Offset.zero),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Weight',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF0B4C37),
                                    ),
                                  ),
                                  const Spacer(),
                                  SizedBox(
                                    width: 120,
                                    child: TextField(
                                      controller: _weightController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      textAlign: TextAlign.center,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
                                      ],
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                        suffixText: 'kg',
                                        filled: true,
                                        fillColor: _weightError != null ? Colors.red[50] : Colors.grey[50],
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: _weightError != null ? Colors.red[300]! : Colors.grey[300]!,
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: _weightError != null ? Colors.red : const Color(0xFF0B4C37),
                                            width: 2,
                                          ),
                                        ),
                                        hintText: '$minWeight-$maxWeight',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (_weightError != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4, left: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        _weightError!,
                                        style: TextStyle(
                                          color: Colors.red[700],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Height field with validation
                        SlideTransition(
                          position: _heightError != null ? _shakeAnimation : const AlwaysStoppedAnimation(Offset.zero),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Height',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF0B4C37),
                                    ),
                                  ),
                                  const Spacer(),
                                  SizedBox(
                                    width: 120,
                                    child: TextField(
                                      controller: _heightController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      textAlign: TextAlign.center,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
                                      ],
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                        suffixText: 'cm',
                                        filled: true,
                                        fillColor: _heightError != null ? Colors.red[50] : Colors.grey[50],
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: _heightError != null ? Colors.red[300]! : Colors.grey[300]!,
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: _heightError != null ? Colors.red : const Color(0xFF0B4C37),
                                            width: 2,
                                          ),
                                        ),
                                        hintText: '$minHeight-$maxHeight',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (_heightError != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4, left: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        _heightError!,
                                        style: TextStyle(
                                          color: Colors.red[700],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Gender & Health Goal - Field 6
                  _buildAnimatedField(
                    5,
                    Column(
                      children: [
                        // Gender Selection
                        Row(
                          children: [
                            const Text(
                              'Gender',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF0B4C37),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: DropdownButton<String>(
                                value: _selectedGender,
                                underline: const SizedBox(),
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Color(0xFF0B4C37),
                                ),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedGender = newValue;
                                    });
                                  }
                                },
                                items: _genderOptions.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Health Goal
                        Row(
                          children: [
                            const Text(
                              'Health Goal',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF0B4C37),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: DropdownButton<String>(
                                value: _selectedGoal,
                                underline: const SizedBox(),
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Color(0xFF0B4C37),
                                ),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedGoal = newValue;
                                    });
                                  }
                                },
                                items: _healthGoals.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Create Profile Button with animation
                  ScaleTransition(
                    scale: _buttonScaleAnimation,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF0B4C37),
                            Color(0xFF0B6C47),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0B4C37).withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Create Profile',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}