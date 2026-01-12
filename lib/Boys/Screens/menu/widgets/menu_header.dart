import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../Constants/colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class MenuHeader extends StatelessWidget {
  const MenuHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
           CircleAvatar(
            radius: 30.r,
            backgroundColor: grey2c,
            // backgroundImage: AssetImage('assets/profile.jpg'),
          ),
          AppSpacing.w12,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                'spine test boy onne',
                style: AppTypography.body1,
              ),
              AppSpacing.h4,
               Text(
                '9058001001',
                 style: AppTypography.caption,
              ),
            ],
          )
        ],
      ),
    );
  }
}
