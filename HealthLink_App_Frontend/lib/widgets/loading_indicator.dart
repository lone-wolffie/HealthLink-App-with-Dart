import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  // constructor
  const LoadingIndicator({
    super.key,

  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(), // shows spinner during loading
    );
  }
}