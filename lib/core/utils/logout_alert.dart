import 'package:cateryyx/core/theme/app_spacing.dart';
import 'package:cateryyx/core/theme/app_typography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Constants/buttons.dart';
import '../../Constants/colors.dart';

Future<bool?> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor:Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Logout',
              style: AppTypography.body1,
            ),
            AppSpacing.h10,
            Text(
              'Are you sure you want to logout?',
              style: AppTypography.body2,
            ),
            AppSpacing.h14,
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
                    gradientColors:[blue7E,blue7E,],
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ),
              ],
            ),
            AppSpacing.h4,
          ],
        ),
      );
    },
  );
}