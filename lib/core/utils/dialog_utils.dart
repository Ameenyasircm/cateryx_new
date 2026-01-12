
import 'package:flutter/material.dart';

import '../theme/app_typography.dart';

Future<bool> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(title,style: AppTypography.body1,),
        content: Text(message,style: AppTypography.body2),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText,style: AppTypography.body2.copyWith(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
      style: ButtonStyle(backgroundColor:  MaterialStateProperty.all(Colors.white),foregroundColor: MaterialStateProperty.all(Colors.black)),
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText,style: AppTypography.body2.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      );
    },
  );

  return result ?? false;
}
