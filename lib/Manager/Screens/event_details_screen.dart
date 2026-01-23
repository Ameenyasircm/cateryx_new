import 'package:cateryyx/Constants/my_functions.dart';
import 'package:cateryyx/Manager/Providers/EventDetailProvider.dart';
import 'package:cateryyx/Manager/Providers/EventDetailProvider.dart';
import 'package:cateryyx/Manager/Providers/ManagerProvider.dart';
import 'package:cateryyx/Manager/Screens/create_new_event.dart';
import 'package:cateryyx/Manager/Screens/work_wise_boys_screen.dart';
import 'package:cateryyx/core/theme/app_spacing.dart';
import 'package:cateryyx/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../Constants/colors.dart';
import '../../core/utils/confirm_dialog_utils.dart';
import '../Models/event_model.dart';
import 'attendence_screen.dart';
import 'event_payment_screen.dart';

class EventDetailedScreen extends StatefulWidget {
  final String eventID;

  const EventDetailedScreen({super.key, required this.eventID});

  @override
  State<EventDetailedScreen> createState() => _EventDetailedScreenState();
}

class _EventDetailedScreenState extends State<EventDetailedScreen> {
  bool isWorkAllowed = true;

  @override
  Widget build(BuildContext context) {
    EventDetailsProvider eventDetailsProvider = Provider.of<EventDetailsProvider>(context);
    ManagerProvider managerProvider = Provider.of<ManagerProvider>(context);
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// ---------------- Header ----------------
              Consumer<EventDetailsProvider>(
                builder: (contexsst,provider,child) {
                  return Container(
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
                            Expanded(
                              child: Text(
                                provider.eventModel!.eventName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.subtitle.copyWith(color: clWhite),
                              ),
                            )
                          ],
                        ),
                        AppSpacing.h20,

                        /// Event Date
                        _infoTile(
                          icon: Icons.calendar_month,
                          text: provider.eventModel!.eventDate,
                        ),

                        AppSpacing.h10,

                        /// Location
                        _infoTile(
                          icon: Icons.location_on_outlined,
                          text: provider.eventModel!.locationName,
                        ),

                        AppSpacing.h20,
                      ],
                    ),
                  );
                }
              ),

              /// ---------------- Body ----------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Center(
                  child: Consumer<EventDetailsProvider>(
                    builder: (contexts,provider,child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          AppSpacing.h10,

                          /// Buttons Row
                        Row(
                          children: [
                            Expanded(
                              child: _primaryButton(
                                text: 'Boys (${provider.eventModel!.boysTaken}/${provider.eventModel!.boysRequired})',
                                onTap: () {
                                  callNext(EventAllBoys(eventId: provider.eventModel!.eventId,eventDate: provider.eventModel!.eventDate,eventLocation: provider.eventModel!.locationName,), context);
                                },
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
                                onTap: () {
                                  callNext(EventPaymentScreen(eventId: provider.eventModel!.eventId), context);
                                },
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
                                  onTap: () {
                                    managerProvider.loadEventForEdit(provider.eventModel!.eventId);
                                    callNext(CreateEventScreen(eventId: provider.eventModel!.eventId,isEdit: true,), context);
                                  },
                                ),
                              ),
                              AppSpacing.w10,
                              Expanded(
                                child: _primaryButton(
                                  text: 'Attendance',
                                  onTap: () {
                                    callNext(EventAttendanceScreen(eventId: provider.eventModel!.eventId), context);
                                  },
                                ),
                              ),
                            ],
                          ),

                          AppSpacing.h20,
                        Row(
                          children: [
                            Expanded(
                              child: _outlineButton(
                                text: 'Close Event',
                                textColor: Colors.black,
                                onTap: () async {
                                  final isConfirmed = await showConfirmationDialog(
                                    context: context,
                                    title: 'Close Event',
                                    message: 'Are you sure you want to close this event?',
                                    confirmText: 'Close',
                                    cancelText: 'Cancel',
                                  );

                                  if (!isConfirmed) return;

                                  managerProvider.closeEvent(
                                    provider.eventModel!.eventId,
                                  );
                                  finish(context);


                                },
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
                            children: [
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
                                    AppSpacing.h4,
                                    Text(
                                      isWorkAllowed ? 'ACTIVE' : 'DEACTIVE',
                                      style: AppTypography.caption.copyWith(
                                        color: isWorkAllowed ? Colors.green : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isWorkAllowed ? 'Active' : 'Inactive',
                                    style: AppTypography.body1.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: isWorkAllowed ? Colors.green : Colors.grey,
                                    ),
                                  ),
                                  AppSpacing.w4,
                                  Transform.scale(
                                    scale: 0.9,
                                    child: Switch(
                                      value: isWorkAllowed,
                                      inactiveTrackColor: Colors.grey.shade400,
                                      activeColor: Colors.green,
                                      onChanged: (v) async {
                                        setState(() => isWorkAllowed = v);

                                        await context
                                            .read<EventDetailsProvider>()
                                            .updateWorkActiveStatus(
                                          eventId: provider.eventModel!.eventId,
                                          isActive: v,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                          AppSpacing.h20,

                          /// Event Location
                          _sectionTitle('Event Location'),
                          _detailCard(children: [
                            _detailRow('Location', provider.eventModel!.locationName),
                            _divider(),
                            _detailRow('Meal Type', provider.eventModel!.mealType),
                            _divider(),
                            _detailRow('Event Date', provider.eventModel!.eventDate),
                          ]),

                          AppSpacing.h20,

                          /// Google Map
                          _sectionTitle('Google Map Location'),
                          _mapBox(provider.eventModel!.latitude, provider.eventModel!.longitude,context),

                          AppSpacing.h20,

                          /// Event Details
                          _sectionTitle(''
                              'Event Details'),
                          _detailCard(children: [
                            _detailRow('Description', provider.eventModel!.description),
                            _divider(),
                            _detailRow('Boys Required', provider.eventModel!.boysRequired.toString()),
                            _divider(),
                            _detailRow('Status', provider.eventModel!.status),
                          ]),

                          AppSpacing.h20,
                        ],
                      );
                    }
                  ),
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

  Widget _mapBox(double lat, double lng,BuildContext context) {
    EventDetailsProvider eventDetailsProvider = Provider.of<EventDetailsProvider>(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(color: Colors.grey.shade300),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  lat == 0 && lng == 0
                      ? 'Location not available'
                      : 'Lat: $lat , Lng: $lng',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.open_in_new, color: Colors.blue),
            ],
          ),
          AppSpacing.h10,
          OutlinedButton.icon(
            onPressed: lat == 0 && lng == 0 ? null : () {
              eventDetailsProvider.openGoogleMap(lat, lng);
            },
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
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: AppTypography.body2.copyWith(
                color: clWhite,
                fontWeight: FontWeight.w500,
                fontSize: 13.sp,
              ),
            ),
          ),
        ),

        /// 🔹 Trailing widget (ex: + icon)
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
     IconData? icon,
     Color textColor=buttonColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 42,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon:icon!=null? Icon(
          icon,
          size: 18,
          color: buttonColor,
        ):null,
        label: Text(
          text,
          style: AppTypography.body2.copyWith(
            color: textColor,
            fontWeight: FontWeight.w500,
            fontSize: 13.sp,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: buttonColor, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

}




