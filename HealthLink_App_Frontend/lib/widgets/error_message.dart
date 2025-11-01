import 'package:flutter/material.dart'; // material design package

class ErrorMessage extends StatelessWidget {
  final String message;
  final void Function()? onClick;

  // constructor
  const ErrorMessage({
    super.key,
    required this.message,
    this.onClick,
    
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color.fromARGB(255, 225, 23, 9),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),
            if (onClick != null)
              ElevatedButton (
                onPressed: onClick,
                child: const Text('Retry'),
              ),
          ],
        ),
      ),
    );
  }
}