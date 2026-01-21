import 'package:flutter/material.dart';
import '../widgets/custom_widgets.dart';
import '../utils/error_handler.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'forgot_password_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  String? _usernameError;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateFields() {
    setState(() {
      _usernameError = ValidationHelper.validateUsername(_usernameController.text);
      _emailError = ValidationHelper.validateEmail(_emailController.text);
      _passwordError = ValidationHelper.validatePassword(_passwordController.text);
    });
  }

  Future<void> _handleSignUp() async {
    _validateFields();
    
    if (_usernameError != null || _emailError != null || _passwordError != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Call actual API
      await AuthService.register(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      // Navigate to home screen on success
      if (mounted) {
        ErrorHandler.showSuccess(context, 'Account succesvol aangemaakt!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, ErrorHandler.getErrorMessage(e.toString()));
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
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C2C2C)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: AuthCard(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Account Aanmaken',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    hint: 'Gebruikersnaam...',
                    controller: _usernameController,
                    errorText: _usernameError,
                    onChanged: (value) {
                      if (_usernameError != null) {
                        setState(() {
                          _usernameError = ValidationHelper.validateUsername(value);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    hint: 'Emailadres...',
                    controller: _emailController,
                    errorText: _emailError,
                    onChanged: (value) {
                      if (_emailError != null) {
                        setState(() {
                          _emailError = ValidationHelper.validateEmail(value);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    hint: 'Wachtwoord...',
                    isPassword: true,
                    controller: _passwordController,
                    errorText: _passwordError,
                    onChanged: (value) {
                      if (_passwordError != null) {
                        setState(() {
                          _passwordError = ValidationHelper.validatePassword(value);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Aanmaken',
                    onPressed: _handleSignUp,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomTextButton(
                        text: 'Heb jij al een account?',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomTextButton(
                        text: 'Wachtwoord vergeten?',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}