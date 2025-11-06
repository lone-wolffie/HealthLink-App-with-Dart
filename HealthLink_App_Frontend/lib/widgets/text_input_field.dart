import 'package:flutter/material.dart';

class TextInputField extends StatefulWidget {
  final TextEditingController textController;
  final String label;
  final IconData icon;
  final bool hideText;

  const TextInputField({
    super.key,
    required this.textController,
    required this.label,
    required this.icon,
    this.hideText = false,
  });

  @override
  State<TextInputField> createState() => _TextInputFieldState();
}

class _TextInputFieldState extends State<TextInputField> {
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.textController,
      obscureText: widget.hideText ? !showPassword : false,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        prefixIcon: Icon(
          widget.icon,
          color: const Color.fromARGB(255, 121, 118, 118) 
        ),
        labelText: widget.label,
        labelStyle: const TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.w500,
        ),

        // toggle the password
        suffixIcon: widget.hideText
         ? IconButton(
            icon: Icon(
              showPassword ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() => showPassword = !showPassword);
            },
          )
          : null,

        filled: true,
        fillColor: Colors.white,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.grey,
            width: 1.2,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF4B79A1),
            width: 2,
          ),
        ),

        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16
        ),
      ),
    );
  }
}
