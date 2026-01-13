import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../Constants/colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class MenuHeader extends StatelessWidget {
  final String boyName,boyID,boyPhone;
  const MenuHeader({super.key,required this.boyName,required this.boyID,required this.boyPhone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
           CircleAvatar(
            radius: 30.r,
             backgroundColor: Colors.black12,
             child: Icon(Icons.person, size: 26,color: blue7E,),
            // backgroundImage: AssetImage('assets/profile.jpg'),
          ),
          AppSpacing.w12,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                boyName,
                style: AppTypography.body1,
              ),
              AppSpacing.h4,
              Text(
                boyPhone,
                style: AppTypography.caption,
              ),
            ],
          )
        ],
      ),
    );
  }
}
