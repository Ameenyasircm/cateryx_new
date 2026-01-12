
import 'package:flutter/material.dart';

import '../../Constants/colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

Future<void> showSuccessAlert({
  required BuildContext context,
  required String title,
  required String message,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 30),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/gif/success.gif",height: 180,width: 200,),
            AppSpacing.h10,
            Text(message,textAlign: TextAlign.center,
              style: AppTypography.body2.copyWith(color: Colors.grey,
            ),),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue7E,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child:  Text('Done',style: AppTypography.body1.copyWith(
                    color: Colors.white
                  )),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
