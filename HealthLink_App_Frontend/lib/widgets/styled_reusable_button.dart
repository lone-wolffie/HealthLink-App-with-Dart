import 'package:flutter/material.dart';

class StyledReusableButton extends StatelessWidget {
  final String text;
  final void Function() onClick;
  final Color? color;
  final bool useGradient;

  const StyledReusableButton({
    super.key,
    required this.text,
    required this.onClick,
    this.color,
    this.useGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onClick,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 28,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: useGradient
              ? const LinearGradient(
                  colors: [
                    Color(0xFF4B79A1),
                    Color(0xFF283E51),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: useGradient ? null : (color ?? Colors.blue),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 79, 76, 76),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}
