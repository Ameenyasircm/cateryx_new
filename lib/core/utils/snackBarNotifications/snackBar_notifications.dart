import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../main.dart';
import '../../theme/app_typography.dart';

class NotificationSnack {
  NotificationSnack._();

  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  static void _showSnackBar(String message, Color color) {
    final messenger = scaffoldMessengerKey.currentState;

    if (messenger == null) return;

    final snackBar = SnackBar(
      content: Text(
        message,
        style: AppTypography.body2.copyWith(
          color: Colors.white,
        ),
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        left: 14.w,
        right: 14.w,
        bottom: 16.h,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      duration: const Duration(seconds: 2),
    );

    messenger
      ..clearSnackBars()
      ..showSnackBar(snackBar);
  }
  // ✅ SUCCESS
  static void showSuccess(String message) {
    _showSnackBar(message, Colors.green);
  }

  // ✅ ERROR
  static void showError(String message) {
    _showSnackBar(message, Colors.red);
  }

  // ✅ WARNING
  static void showWarning(String message) {
    _showSnackBar(message, Colors.orange);
  }

  // ℹ️ NORMAL
  static void showNormal(String message) {
    _showSnackBar(message, Colors.black);
  }
}