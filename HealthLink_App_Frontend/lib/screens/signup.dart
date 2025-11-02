import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/styled_reusable_button.dart';
import '../widgets/text_input_field.dart';
import 'login.dart';


class Signup extends StatefulWidget {
  // constructor
  const Signup({
    super.key,
  });

  @override
  State<Signup> createState() => _SignupState(); // links UI to _SignupState
  
}

class _SignupState extends State<Signup> {
  final TextEditingController fullnameController = TextEditingController(); // user's full name
  final TextEditingController emailController = TextEditingController(); // user's email
  final TextEditingController phoneNumberController = TextEditingController(); // user's phone number
  final TextEditingController usernameController = TextEditingController(); // user's username
  final TextEditingController passwordController = TextEditingController(); // user's password

  void _signup() async {
    final fullname = fullnameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneNumberController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (fullname.isEmpty || email.isEmpty || phone.isEmpty || username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields')
        ),
      );
      return;
    }

    try {
      final response = await ApiService.signup(fullname, email, phone, username, password);

      if (!mounted) return;

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup Successful! Please Login')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Login()), // redirect to login screen
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Signup failed')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    // app screen structure
    return Scaffold( 
      appBar: AppBar(title: const Text('Sign Up')), // top of the screen
      body: SingleChildScrollView( // screen scroll
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextInputField(
              textController: fullnameController, 
              label: 'Full Name', 
              icon: Icons.person,
            ),

            const SizedBox(height: 12),
            TextInputField(
              textController: emailController, 
              label: 'Email', 
              icon: Icons.email,
            ),

            const SizedBox(height: 12),
            TextInputField(
              textController: phoneNumberController, 
              label: 'Phone Number', 
              icon: Icons.phone,
            ),

            const SizedBox(height: 12),
            TextInputField(
              textController: usernameController, 
              label: 'Username', 
              icon: Icons.account_circle,
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
              text: 'Create Account', 
              onClick: _signup,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}