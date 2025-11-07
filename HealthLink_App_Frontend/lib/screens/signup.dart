import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/styled_reusable_button.dart';
import '../widgets/text_input_field.dart';
import '../widgets/loading_indicator.dart';

class Signup extends StatefulWidget {
  const Signup({
    super.key
  });

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _signup() async {
    final fullname = fullnameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneNumberController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if ([fullname, email, phone, username, password].any((value) => value.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.signup(fullname, email, phone, username, password);

      if (!mounted) return;

      if (response['success'] == true) {
        final userId = response['userId'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', userId);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signup successful'),
            backgroundColor: Colors.green,
          ),
        );
        // Redirect to home screen
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: userId,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Signup failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error')
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    fullnameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF4B79A1),
              Color(0xFF283E51),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Icon(
                  Icons.person_add,
                  size: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 28),

                // Form Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextInputField(
                        textController: fullnameController,
                        label: 'Full Name',
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 14),

                      TextInputField(
                        textController: emailController,
                        label: 'Email',
                        icon: Icons.email,
                      ),
                      const SizedBox(height: 14),

                      TextInputField(
                        textController: phoneNumberController,
                        label: 'Phone Number',
                        icon: Icons.phone,
                      ),
                      const SizedBox(height: 14),

                      TextInputField(
                        textController: usernameController,
                        label: 'Username',
                        icon: Icons.account_circle,
                      ),
                      const SizedBox(height: 14),

                      TextInputField(
                        textController: passwordController,
                        label: 'Password',
                        icon: Icons.lock,
                        hideText: true,
                      ),
                      const SizedBox(height: 24),

                      _isLoading
                          ? const LoadingIndicator()
                          : StyledReusableButton(
                              text: 'Create Account',
                              onClick: _signup,
                              useGradient: true,
                            ),
                      
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account?'),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                '/login'
                              );
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4B79A1),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
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
