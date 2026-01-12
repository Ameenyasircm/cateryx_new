import 'dart:ui';
import 'package:flutter/src/painting/text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Constants/colors.dart';

class AppTypography {
  // H1 — Large Title
  static TextStyle get h1 => GoogleFonts.poppins(
    textStyle: TextStyle(
      fontSize: 24.sp,
      fontWeight: FontWeight.bold,
      color: clBlack,
    ),
  );

  // H2 — Section Title
  static TextStyle get h2 => GoogleFonts.inter(
    textStyle: TextStyle(
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
      color: clBlack,
    ),
  );

  // Subtitle — Secondary heading
  static TextStyle get subtitle => GoogleFonts.inter(
    textStyle: TextStyle(
      fontSize: 18.sp,
      fontWeight: FontWeight.w500,
      color: clBlack,
    ),
  );

  // Body1 — Main body text
  static TextStyle get body1 => GoogleFonts.inter(
    textStyle: TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: clBlack,
    ),
  );

  // Body2 — Smaller body text
  static TextStyle get body2 => GoogleFonts.inter(
    textStyle: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: clBlack,
    ),
  );

  // Caption — Smallest text
  static TextStyle get caption => GoogleFonts.inter(
    textStyle: TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      color: clBlack,
    ),
  );
}