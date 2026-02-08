import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../Constants/colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class ProfileHeader extends StatelessWidget {
  String boyName,boyID,boyPhone,boyPhoto;
   ProfileHeader({super.key,required this.boyName,required this.boyID,required this.boyPhone,required this.boyPhoto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          boyPhoto.isEmpty?
           CircleAvatar(
            radius: 26.r,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                  boyName,
                  style: AppTypography.body1,
                ),
                AppSpacing.h2,
                 Text(
                   boyPhone ,
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}


