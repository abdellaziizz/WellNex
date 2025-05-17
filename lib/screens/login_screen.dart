import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wellnex/services/auth_service.dart';
import 'dart:math' as math;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;
  
  // Animation controllers
  late AnimationController _headerAnimationController;
  late AnimationController _formAnimationController;
  late AnimationController _buttonAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _shakeAnimationController;
  late AnimationController _fieldFocusController;
  
  // Animations
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;
  late Animation<double> _emailFieldAnimation;
  late Animation<double> _passwordFieldAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<Offset> _registerSlideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _shakeAnimation;
  late Animation<double> _focusAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupListeners();
    _playAnimationsSequentially();
  }

  void _initializeAnimations() {
    // Header animations
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _headerSlideAnimation = Tween<double>(
      begin: -50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    // Form animations
    _formAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _emailFieldAnimation = CurvedAnimation(
      parent: _formAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    );
    
    _passwordFieldAnimation = CurvedAnimation(
      parent: _formAnimationController,
      curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic),
    );
    
    // Button and register link animations
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _buttonScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(_buttonAnimationController);
    
    _registerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
    ));

    // Pulse animation for button hover effect
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.05)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_pulseAnimationController);

    // Shake animation for error feedback
    _shakeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
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
    ]).animate(_shakeAnimationController);

    // Field focus animation (reduced scale change to prevent overflow)
    _fieldFocusController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _focusAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02, // Reduced scale to prevent overflow
    ).animate(CurvedAnimation(
      parent: _fieldFocusController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));
  }

  void _setupListeners() {
    _emailFocusNode.addListener(() {
      setState(() {
        _isEmailFocused = _emailFocusNode.hasFocus;
      });
      if (_emailFocusNode.hasFocus) {
        _fieldFocusController.forward();
      } else {
        _fieldFocusController.reverse();
      }
    });

    _passwordFocusNode.addListener(() {
      setState(() {
        _isPasswordFocused = _passwordFocusNode.hasFocus;
      });
      if (_passwordFocusNode.hasFocus) {
        _fieldFocusController.forward();
      } else {
        _fieldFocusController.reverse();
      }
    });
  }

  void _playAnimationsSequentially() {
    Future.delayed(const Duration(milliseconds: 200), () {
      _headerAnimationController.forward().then((_) {
        _formAnimationController.forward().then((_) {
          _buttonAnimationController.forward();
        });
      });
    });
  }

  void _showErrorAnimation() {
    _shakeAnimationController.forward().then((_) {
      _shakeAnimationController.reset();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _headerAnimationController.dispose();
    _formAnimationController.dispose();
    _buttonAnimationController.dispose();
    _pulseAnimationController.dispose();
    _shakeAnimationController.dispose();
    _fieldFocusController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      _showErrorAnimation();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signInWithEmail(
        _emailController.text,
        _passwordController.text,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      if (e.code == 'user-not-found') {
        message = 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        _showErrorAnimation();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
        _showErrorAnimation();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 100,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Back Button with fade-in animation
                          FadeTransition(
                            opacity: _headerFadeAnimation,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Color(0xFF0B4C37),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              padding: EdgeInsets.zero,
                              alignment: Alignment.centerLeft,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Login Header with slide and fade animation
                          Transform.translate(
                            offset: Offset(_headerSlideAnimation.value, 0),
                            child: FadeTransition(
                              opacity: _headerFadeAnimation,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Welcome Back',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Log In',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0B4C37),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Email Field with fade-in animation (no scale)
                          SlideTransition(
                            position: _shakeAnimation,
                            child: FadeTransition(
                              opacity: _emailFieldAnimation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.1, 0),
                                  end: Offset.zero,
                                ).animate(_emailFieldAnimation),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: _isEmailFocused 
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF0B4C37).withOpacity(0.15),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [],
                                  ),
                                  child: TextField(
                                    controller: _emailController,
                                    focusNode: _emailFocusNode,
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      hintText: 'Enter your email',
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF0B4C37),
                                          width: 2,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                          width: 1,
                                        ),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.email_outlined,
                                        color: _isEmailFocused
                                          ? const Color(0xFF0B4C37)
                                          : Colors.grey,
                                        size: _isEmailFocused ? 22 : 20,
                                      ),
                                      floatingLabelStyle: const TextStyle(
                                        color: Color(0xFF0B4C37),
                                      ),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Password Field with fade-in animation (no scale)
                          SlideTransition(
                            position: _shakeAnimation,
                            child: FadeTransition(
                              opacity: _passwordFieldAnimation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.1, 0),
                                  end: Offset.zero,
                                ).animate(_passwordFieldAnimation),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: _isPasswordFocused
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF0B4C37).withOpacity(0.15),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [],
                                  ),
                                  child: TextField(
                                    controller: _passwordController,
                                    focusNode: _passwordFocusNode,
                                    obscureText: !_isPasswordVisible,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      hintText: 'Enter your password',
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF0B4C37),
                                          width: 2,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                          width: 1,
                                        ),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.lock_outline,
                                        color: _isPasswordFocused
                                          ? const Color(0xFF0B4C37)
                                          : Colors.grey,
                                        size: _isPasswordFocused ? 22 : 20,
                                      ),
                                      floatingLabelStyle: const TextStyle(
                                        color: Color(0xFF0B4C37),
                                      ),
                                      suffixIcon: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              _isPasswordVisible 
                                                ? Icons.visibility 
                                                : Icons.visibility_off,
                                              color: _isPasswordVisible
                                                ? const Color(0xFF0B4C37)
                                                : Colors.grey,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isPasswordVisible = !_isPasswordVisible;
                                              });
                                            },
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              // Handle forgot password
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.only(right: 12),
                                              child: Text(
                                                'Forgot?',
                                                style: TextStyle(
                                                  color: Color(0xFF0B4C37),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Bottom section with button and register link
                      Column(
                        children: [
                          // Login Button with scale and pulse animations
                          ScaleTransition(
                            scale: _buttonScaleAnimation,
                            child: MouseRegion(
                              onEnter: (_) => _pulseAnimationController.repeat(),
                              onExit: (_) => _pulseAnimationController.stop(),
                              child: ScaleTransition(
                                scale: _pulseAnimation,
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
                                    onPressed: _isLoading ? null : _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
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
                                            'Log In',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Register Link with slide animation
                          SlideTransition(
                            position: _registerSlideAnimation,
                            child: Center(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/profile-setup');
                                },
                                style: ButtonStyle(
                                  overlayColor: MaterialStateProperty.all(
                                    const Color(0xFF0B4C37).withOpacity(0.05),
                                  ),
                                ),
                                child: RichText(
                                  text: const TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Don't have an account? ",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      TextSpan(
                                        text: "Register",
                                        style: TextStyle(
                                          color: Color(0xFF0B4C37),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom background painter for animated patterns
class BackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  BackgroundPainter({
    required this.animation, 
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final circleCount = 5;
    final startRadius = size.width * 0.1;
    final maxRadius = size.width * 0.3;

    // Draw animated circles
    for (int i = 0; i < circleCount; i++) {
      final progress = (animation.value + i / circleCount) % 1.0;
      final radius = startRadius + progress * maxRadius;
      final opacity = (1.0 - progress) * 0.7;

      paint.color = color.withOpacity(opacity);

      final offsetX = size.width * 0.1 + (math.sin(progress * math.pi * 2) * size.width * 0.05);
      final offsetY = size.height * (0.2 + i * 0.15) + 
                     (math.cos(progress * math.pi * 2) * size.height * 0.02);

      canvas.drawCircle(
        Offset(offsetX, offsetY),
        radius * animation.value,
        paint,
      );
    }

    // Draw some curved lines
    final path = Path();
    final curveOffset = size.width * 0.3 * animation.value;
    
    path.moveTo(size.width * 0.8, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.7, 
      size.height * (0.3 + 0.1 * math.sin(animation.value * math.pi)), 
      size.width * 0.9, 
      size.height * 0.5
    );
    
    final linePaint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
      
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) {
    return animation != oldDelegate.animation || color != oldDelegate.color;
  }
}
