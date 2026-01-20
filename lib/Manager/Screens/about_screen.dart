import 'package:cateryyx/core/theme/app_spacing.dart';
import 'package:cateryyx/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Constants/colors.dart';
import '../../core/utils/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title:Text("About",style: AppTypography.subtitle),
        centerTitle: true,
      ),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final info = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // -------------------- Logo & App Info --------------------
              Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/codematesLogo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  AppSpacing.h16,
                   Text(
                    "Cateryx",
                    style: AppTypography.h2,
                  ),
                  AppSpacing.h6,
                  Text(
                    "Version ${info.version}+${info.buildNumber}",
                    style: AppTypography.body2.copyWith(
                      color: Colors.grey,fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              ),

              AppSpacing.h20,
              const Divider(thickness: 0.4,),

              // -------------------- Company --------------------
              _aboutTile(
                icon: Icons.business_outlined,
                title: "Company",
                subtitle: "Codemates Solutions",
              ),

              // -------------------- Email --------------------
              _aboutTile(
                icon: Icons.email_outlined,
                title: "Email",
                subtitle: "codematessolution@gmail.com",
                onTap: launchEmail,
              ),

              // -------------------- Phone --------------------
              _aboutTile(
                icon: Icons.phone_outlined,
                title: "Phone",
                subtitle: "+91 80867 83125",
                onTap: launchPhone,
              ),

              // -------------------- Website --------------------
              _aboutTile(
                icon: Icons.language_outlined,
                title: "Website",
                subtitle: "codematessolutions.netlify.app",
                onTap: launchWebsite,
              ),

              AppSpacing.h16,
              const Divider(thickness: 0.4,),

              // -------------------- Licenses --------------------
              _aboutTile(
                icon: Icons.description_outlined,
                title: "Open Source Licenses",
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: "Cateryx",
                    applicationVersion:
                    "${info.version}+${info.buildNumber}",
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // -------------------- Reusable Tile --------------------

  Widget _aboutTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon,color: clBlack,),
      title: Text(title,style: AppTypography.body1.copyWith(
        fontWeight: FontWeight.w500
      ),),
      subtitle: subtitle != null ? Text(subtitle,style: AppTypography.caption.copyWith(
          fontWeight: FontWeight.w500
      ),) : null,
      trailing: onTap != null
          ? const Icon(Icons.arrow_forward_ios_rounded, size: 16,color: clBlack,)
          : null,
      onTap: onTap,
    );
  }
}
