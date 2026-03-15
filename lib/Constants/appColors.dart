import 'package:flutter/material.dart';

class AppColors {
  // Main Branding
  static const Color deepBlue = Color(0xFF2C2CB4); // Deep background blue
  static const Color vibrantTeal = Color(0xFF00D2B4); // Bright teal/green
  static const Color mintGreen = Color(0xFF80FFDB); // Light mint accent

  // Text & UI
  static const Color white = Colors.white;
  static const Color lightGray = Color(0xFFF5F7FA);
  static const Color textBody = Color(0xFF4A4A4A);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2C2CB4), Color(0xFF4A4AE2)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [vibrantTeal, mintGreen],
  );
}