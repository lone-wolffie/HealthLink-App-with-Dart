import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/styled_reusable_button.dart';
import '../widgets/text_input_field.dart';
import 'signup.dart';

class Login extends StatefulWidget {
  const Login({
    super.key
  });

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter username and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.login(username, password);

      if (response['user'] != null) {
        final user = response['user'];
        final int userId = user['id'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt("userId", userId);

        if (!mounted) return;

        // ✅ Redirect to Home and REMOVE Login screen from stack
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/home",
          (route) => false,
          arguments: userId,
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Login failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

            _isLoading
                ? const CircularProgressIndicator()
                : StyledReusableButton(
                    text: 'Login',
                    onClick: _login,
                    color: Colors.blue,
                  ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Signup()),
                );
              },
              child: const Text("Don't have an account? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
