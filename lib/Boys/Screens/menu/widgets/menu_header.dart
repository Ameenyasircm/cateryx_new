import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../Constants/colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class MenuHeader extends StatelessWidget {
  final String boyName,boyID,boyPhone,boyPhoto;
  const MenuHeader({super.key,required this.boyName,required this.boyID,required this.boyPhone,required this.boyPhoto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [

          boyPhoto.isEmpty?
          CircleAvatar(
            radius: 30.r,
            backgroundColor: Colors.black12,
            child: Icon(Icons.person, size: 26,color: blue7E,),
            // backgroundImage: AssetImage('assets/profile.jpg'),
          ):
          CircleAvatar(
            radius: 26.r,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: NetworkImage(boyPhoto,),
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
