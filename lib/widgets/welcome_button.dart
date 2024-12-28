import 'package:flutter/material.dart';

class WelcomeButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback? onTap; // Change this to accept a function
  final Color color;
  final Color textColor;

  const WelcomeButton({
    required this.buttonText,
    required this.onTap,
    required this.color,
    required this.textColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap, // Use the onTap function here
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      child: Text(buttonText),
    );
  }
}
