import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;

  // constructor
  const LoadingIndicator({
    super.key,
    this.message,

  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(), // shows spinner during loading
          if (message != null) ... [
            const SizedBox(height: 12),
            Text(
              message!,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}