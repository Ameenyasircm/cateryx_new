
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool showIcon;
  final VoidCallback onTap;

  const MenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.showIcon=true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 26),
           AppSpacing.w14,
            Expanded(
              child: Text(
                title,
                style: AppTypography.body1.copyWith(
                  fontSize: 15.sp,fontWeight: FontWeight.w500
                )
              ),
            ),
            if(showIcon)
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black87,
            ),
          ],
        ),
      ),
    );
  }
}
