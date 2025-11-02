import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/styled_reusable_button.dart';
import '../widgets/text_input_field.dart';
import 'signup.dart';
import 'home_screen.dart';

class Login extends StatefulWidget {
  // constructor
  const Login({
    super.key,
  });

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController usernameController = TextEditingController(); 
  final TextEditingController passwordController = TextEditingController(); 

  void _login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter username and password')
        ),
      );
      return;
    }

    try {
      final response = await ApiService.login(username, password);

      if (!mounted) return;

      if (response['success'] == true) {
        final userData = response['user'];
        final userId = userData['id'];

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(userId: userId), // redirect to home screen
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Login failed')
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error')
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextInputField(
              textController: usernameController, 
              label: 'Username', 
              icon: Icons.person,
            ),

            const SizedBox(height: 12),
            TextInputField(
              textController: passwordController, 
              label: 'Password', 
              icon: Icons.lock,
              hideText: true,
            ),

            const SizedBox(height: 24),
            StyledReusableButton(
              text: 'Login', 
              onClick: _login,
              color: Colors.blue,
            ),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => const Signup()
                  ),
                );
              },
              
              child: const Text("Don't have an account? Sign Up"),
            )
          ],
        ),
      ),
    );
  }
}
