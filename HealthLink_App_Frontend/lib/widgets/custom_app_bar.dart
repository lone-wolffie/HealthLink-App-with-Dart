import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget> actions;

  // constructor
  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true, 
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 23,
          ),
        ),
      centerTitle: true,
      leading: showBackButton
        ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
          )
        : null, // if showBackButton = false
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // height = 56px
}