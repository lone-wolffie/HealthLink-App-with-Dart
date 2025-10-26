import 'package:flutter/material.dart'; // material design package

class ErrorMessage extends StatelessWidget {
  final String message;

  // constructor
  const ErrorMessage({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(
          color: Color.fromARGB(255, 225, 23, 9),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}