import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;

  // constructor
  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,

  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      leading: showBackButton
        ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context), // go back to previous screen/page.
          )
        : null, // if showBackButton = false
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // height = 56px
}