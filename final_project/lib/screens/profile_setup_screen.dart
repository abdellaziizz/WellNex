import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wellnex/viewmodels/user_viewmodel.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  String _selectedGoal = 'Lose weight';
  bool _isLoading = false;

  final List<String> _healthGoals = [
    'Lose weight',
    'Gain muscle',
    'Improve fitness',
    'Eat healthier',
    'Reduce stress'
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<bool> _isUsernameUnique(String username) async {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    return await userViewModel.checkUsernameUnique(username);
  }

  void _saveProfile() async {
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _heightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check if username is unique
      final isUnique = await _isUsernameUnique(_usernameController.text.trim());
      if (!isUnique) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Username already taken. Please choose another.')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      final success = await userViewModel.register(
        _emailController.text.trim(),
        _passwordController.text,
        {
          'username': _usernameController.text.trim(),
          'age': int.parse(_ageController.text),
          'weight': double.parse(_weightController.text),
          'height': double.parse(_heightController.text),
          'healthGoal': _selectedGoal,
          'gender': 'Not specified',
          'userType': 'beginner',
          'name': _usernameController.text.trim(),
          'additionalData': {
            'motivationLevel': 5,
            'learningPreferences': <String>[],
            'hasPreviousInjury': false,
          },
        },
      );
      
      if (mounted) {
        if (success) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          final error = userViewModel.error ?? 'Failed to save profile';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username
                const Text('Username', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(hintText: 'Enter a unique username'),
                ),
                const SizedBox(height: 16),
                // Email
                const Text('Email', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(hintText: 'Enter your email'),
                ),
                const SizedBox(height: 16),
                // Password
                const Text('Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: 'Enter your password'),
                ),
                const SizedBox(height: 16),
                // Age
                Row(
                  children: [
                    const Text(
                      'Age',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Weight
                Row(
                  children: [
                    const Text(
                      'Weight',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          suffixText: 'kg',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Height
                Row(
                  children: [
                    const Text(
                      'Height',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          suffixText: 'cm',
                        ),
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
                      ),
                    ),
                    const SizedBox(height: 24),
                    DropdownButton<String>(
                      value: _selectedGoal,
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
                  ],
                ),
                const SizedBox(height: 24),
                // Next Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text('Next'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}