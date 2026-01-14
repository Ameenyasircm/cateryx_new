import 'package:cateryyx/core/theme/app_spacing.dart';
import 'package:cateryyx/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../Constants/colors.dart';

class EventDetailedScreen extends StatefulWidget {
  const EventDetailedScreen({super.key});

  @override
  State<EventDetailedScreen> createState() => _EventDetailedScreenState();
}

class _EventDetailedScreenState extends State<EventDetailedScreen> {
  bool isWorkAllowed = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ---------------- Header ----------------
              Container(
                color: buttonColor,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    AppSpacing.h20,
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white12,
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: clWhite,
                              size: 20,
                            ),
                          ),
                        ),
                        AppSpacing.w16,
                        Text(
                          'Event Details',
                          style: AppTypography.subtitle.copyWith(color: clWhite),
                        )
                      ],
                    ),
                    AppSpacing.h20,
                    _infoTile(
                      icon: Icons.calendar_month,
                      text: '12/01/2026 - 14/01/2026',
                    ),
                    AppSpacing.h10,
                    _infoTile(
                      icon: Icons.location_on_outlined,
                      text: 'Malappuram Raouse launch Auditorium',
                    ),
                    AppSpacing.h20,
                  ],
                ),
              ),

              /// ---------------- Body ----------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSpacing.h10,

                    /// Buttons Row
                    Row(
                      children: [
                        Expanded(
                          child: _primaryButton(
                            text: 'Boys (26/56)',
                            onTap: () {},
                            trailing: const CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.deepOrange,
                              child: Icon(Icons.add, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                        AppSpacing.w10,
                        Expanded(
                          child: _primaryButton(
                            text: 'Make Payment',
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),

                    AppSpacing.h10,

                    Row(
                      children: [
                        Expanded(
                          child: _outlineButton(
                            text: 'Edit Event',
                            icon: Icons.edit_calendar_rounded,
                            onTap: () {},
                          ),
                        ),
                        AppSpacing.w10,
                        Expanded(
                          child: _primaryButton(
                            text: 'Attendance',
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),

                    AppSpacing.h20,

                    /// Work Status
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: _cardDecoration(color: Colors.grey.shade300),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// Left content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Work Status',
                                style: AppTypography.body1.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              AppSpacing.h4, // ✅ fixed (vertical spacing)
                              Text(
                                'This event allows boys to get work',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.caption.copyWith(color: Colors.red),
                              ),
                            ],
                          ),
                        ),

                        AppSpacing.w10,

                        /// Right switch + status
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isWorkAllowed ? 'Active' : 'Inactive',
                              style: AppTypography.body1.copyWith(
                                fontWeight: FontWeight.w600,fontSize: 14,
                                color: isWorkAllowed ? Colors.green : Colors.grey,
                              ),
                            ),
                            AppSpacing.w4,
                            Transform.scale(
                              scale: 0.9, // ✅ cleaner in production
                              child: Switch(
                                value: isWorkAllowed,
                                inactiveTrackColor: Colors.grey.shade400,
                                activeColor: Colors.green,
                                onChanged: (v) {
                                  setState(() => isWorkAllowed = v);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  AppSpacing.h20,

                    _sectionTitle('Event Location'),
                    _detailCard(children: [
                      _detailRow('Venue Name', 'TKM Auditorium'),
                      _divider(),
                      _detailRow(
                        'Address',
                        'Malabar Convention Centre, Mini Bypass Road,\nKottooli, Kozhikode',
                      ),
                      _divider(),
                      _detailRow('Start Time', '11:00 am'),
                    ]),

                    AppSpacing.h20,

                    _sectionTitle('Google Map Location'),
                    _mapBox(),

                    AppSpacing.h20,

                    _sectionTitle('Client Details'),
                    _detailCard(children: [
                      _detailRow('Client Name', 'Jhone'),
                      _divider(),
                      _contactRow('Contact Number', '5656245987'),
                      _divider(),
                      _contactRow('Alternate Contact', '5656245987'),
                      _divider(),
                      _detailRow('Boys Required', '56'),
                      _divider(),
                      _contactRow('Captain', 'Al Wariz P kamarudheen'),
                    ]),

                    AppSpacing.h20,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------------- Reusable Widgets ----------------

  Widget _infoTile({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Icon(icon, color: clWhite),
          AppSpacing.w10,
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body2.copyWith(color: clWhite),
            ),
          ),
        ],
      ),
    );
  }

  Widget _primaryButton({
    required String text,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          height: 42,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              text,
              style: AppTypography.body2.copyWith(
                color: clWhite,
                fontWeight: FontWeight.w500,
                fontSize: 13.sp,
              ),
            ),
          ),
        ),
        if (trailing != null)
          Positioned(
            right: -6,
            top: -6,
            child: trailing,
          ),
      ],
    );
  }

  Widget _outlineButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 42,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _detailCard({required List<Widget> children}) {
    return Container(
      decoration: _cardDecoration(color: Colors.grey.shade300),
      child: Column(children: children),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTypography.caption.copyWith(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.caption,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTypography.caption.copyWith(color: Colors.grey),
            ),
          ),
          Expanded(child: Text(value, style: AppTypography.caption)),
          const Icon(Icons.call, color: Colors.blue, size: 20),
          AppSpacing.w6,
          Image.asset(
            "assets/whatsapp.png",
            width: 24.w,
            height: 30.h,
          ),
        ],
      ),
    );
  }

  Widget _mapBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(color: Colors.grey.shade300),
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(
                child: Text(
                  'https://maps.app.goo.gl/asw1vwnp...',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.open_in_new, color: Colors.blue),
            ],
          ),
          AppSpacing.h10,
          OutlinedButton.icon(
            style:OutlinedButton.styleFrom(
              side: BorderSide(color:Colors.blueAccent )
            ),
            onPressed: () {},
            icon: const Icon(Icons.location_on_outlined, color: Colors.blueAccent),
            label: Text(
              'Open Google Map',
              style: AppTypography.body1.copyWith(color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }

  Divider _divider() => const Divider(thickness: 0.4);

  BoxDecoration _cardDecoration({Color color = Colors.white12}) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 5,
        ),
      ],
    );
  }
}
