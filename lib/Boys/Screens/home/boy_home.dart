import 'package:cateryyx/Constants/my_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cateryyx/Boys/Screens/home/widgets/profile_header.dart';
import '../../../core/theme/app_spacing.dart';
import '../../Providers/boys_provider.dart';
import 'widgets/work_tabs.dart';

class BoyHome extends StatelessWidget {
  final String boyName, boyID, boyPhone;

  const BoyHome({
    super.key,
    required this.boyName,
    required this.boyID,
    required this.boyPhone,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              AppSpacing.h4,
              ProfileHeader(
                  boyID: boyID,
                  boyName: boyName,
                  boyPhone: boyPhone),
              const WorkTabs(),
              Expanded(
                child: TabBarView(
                  children: [
                    AvailableWorksTab(userId: boyID),
                    ConfirmedWorksTab(userId: boyID),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
