import 'package:cateryyx/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Constants/buttons.dart';
import '../../Constants/colors.dart';
import '../theme/app_spacing.dart';

Future<bool> showConfirmationDialog({
  required BuildContext context,
  String title = 'Confirmation',
  required String message,
  String confirmText = 'Yes',
  String cancelText = 'No',
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(title,style: AppTypography.body1),
        content: Text(message,style: AppTypography.caption),
        actions: [

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(
                    'No',
                    style: AppTypography.body2.copyWith(
                        fontWeight: FontWeight.w600
                    ),
                  ),
                ),
              ),
              AppSpacing.w12,
              Expanded(
                child: GradientButton(
                  height: 45.h,
                  text: 'Yes',
                  borderRadius:10.r,
                  textStyle: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color:Colors.white,
                  ),
                  gradientColors:[buttonColor,buttonColor,],
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ),
            ],
          ),

        ],
      );
    },
  );

  return result ?? false;
}
