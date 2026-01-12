import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class WorkCard extends StatelessWidget {
  final String date;
  final String time;
  final String title;
  final String code;
  final String status;
  final bool confirmed;

  const WorkCard({
    super.key,
    required this.date,
    required this.time,
    required this.title,
    required this.code,
    required this.status,
    this.confirmed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.red,
              child: Text(
                code,
                style:AppTypography.caption.copyWith(
                  color: Colors.white
                ),
              ),
            ),
            AppSpacing.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$date   $time',
                    style:AppTypography.caption.copyWith(
                        color: Colors.grey
                    ),
                  ),
                  AppSpacing.h4,
                  Text(
                    title,
                    style:AppTypography.body2.copyWith(
                      fontWeight: FontWeight.w600
                    )
                  ),
                  AppSpacing.h4,
                  Text(
                    status,
                    style:AppTypography.caption.copyWith(
                      color: Colors.green,
                    )

                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
