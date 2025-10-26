import 'package:flutter/material.dart'; // material design package

class StyledReusableButton extends StatelessWidget { // appearance doesn’t change
  final String text; // what button displays
  final void Function() onClick; // button clicked function
  final Color color;

  // constructor
  const StyledReusableButton({
    super.key,
    required this.text,
    required this.onClick,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton( // base material button widget
      style: ElevatedButton.styleFrom(
        backgroundColor: color, // blue
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // 12px 
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 24
        ),
      ),
      onPressed: onClick,
      child: Text( // what appears inside the button
        text,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),

    );
   
  }
}