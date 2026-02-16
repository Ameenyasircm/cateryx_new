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
import 'package:url_launcher/url_launcher.dart';

import '../../Constants/colors.dart';
import '../../core/utils/confirm_dialog_utils.dart';
import '../Models/event_model.dart';
import '../widgets/event_details_widgets.dart';
import 'attendence_screen.dart';
import 'event_payment_screen.dart';
import 'note_screen.dart';

class EventDetailedScreen extends StatefulWidget {
  final String eventID;
  final String fromWhere;

  const EventDetailedScreen({super.key, required this.eventID, required this.fromWhere});

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
                        infoTile(
                          icon: Icons.calendar_month,
                          text: provider.eventModel!.eventDate,
                        ),

                        AppSpacing.h10,

                        /// Location
                        infoTile(
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
                            if(widget.fromWhere=="upcoming")
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: _outlineButton(
                                  text: 'Publish Now',
                                  textColor: red22,
                                  onTap: () async {
                                    final isConfirmed = await showConfirmationDialog(
                                      context: context,
                                      title: 'Publish Event',
                                      message: 'Are you sure you want to publish this event?',
                                      confirmText: 'Yes',
                                      cancelText: 'No',
                                    );

                                    if (!isConfirmed) return;

                                    managerProvider.publishEvent(
                                      provider.eventModel!.eventId,context
                                    );
                                    finish(context);


                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: _outlineButton(
                                text: 'Complete Event',
                                textColor: Colors.black,
                                onTap: () async {
                                  final isConfirmed = await showConfirmationDialog(
                                    context: context,
                                    title: 'Complete Event',
                                    message: 'Are you sure you want to Complete this event?',
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
                            SizedBox(width: 10,),
                            Expanded(
                              child: _outlineButton(
                                text: 'Add Notes',
                                textColor: Colors.black,
                                onTap: () async {
                                  provider.listenNotes( provider.eventModel!.eventId);
                                  callNext(NotesScreen(eventId:  provider.eventModel!.eventId,), context);
                                },
                              ),
                            ),
                          ],
                        ),

                        AppSpacing.h20,

                          /// Work Status
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: cardDecoration(color: Colors.grey.shade300),
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
                          sectionTitle('Event Location'),
                          detailCard(children: [
                            detailRow('Location', provider.eventModel!.locationName),
                            divider(),
                            detailRow('Meal Type', provider.eventModel!.mealType),
                            divider(),
                            detailRow('Event Date', provider.eventModel!.eventDate),
                          ]),

                          AppSpacing.h20,

                          /// Google Map
                          sectionTitle('Google Map Location'),
                          mapBox(provider.eventModel!.latitude, provider.eventModel!.longitude,context),

                          AppSpacing.h20,

                          /// Event Details
                          sectionTitle('Event Details'),
                          detailCard(children: [
                            detailRow('Description', provider.eventModel!.description),
                            divider(),

                            detailRow('Boys Required', provider.eventModel!.boysRequired.toString()),
                            divider(),

                            /// 👉 Client Name
                            detailRow('Client Name', provider.eventModel!.clientName),
                            divider(),

                            /// 👉 Client Phone
                            detailRow('Client Phone', provider.eventModel!.clientPhone),
                            divider(),

                            /// 👉 CALL + WHATSAPP Buttons
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  // CALL button
                                  ElevatedButton.icon(
                                    onPressed: provider.eventModel!.clientPhone.isEmpty
                                        ? null
                                        : () {
                                      final phone = provider.eventModel!.clientPhone;
                                      launchUrl(Uri.parse("tel:$phone"));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    ),
                                    icon: const Icon(Icons.call, color: Colors.white),
                                    label: const Text("Call", style: TextStyle(color: Colors.white)),
                                  ),

                                  // WHATSAPP button
                                  ElevatedButton.icon(
                                    onPressed: provider.eventModel!.clientPhone.isEmpty
                                        ? null
                                        : () {
                                      final phone = provider.eventModel!.clientPhone;
                                      launchUrl(Uri.parse("https://wa.me/$phone"));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    ),
                                    icon:   Image.asset('assets/whsp.png',
                                        color: Colors.white, scale: 12),
                                    label: const Text("WhatsApp", style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            ),

                            divider(),
                            detailRow('Status', provider.eventModel!.status),
                          ]),


                          AppSpacing.h20,
                        ],
                      );
                    }
                  ),
                ),
              ),
              SizedBox(height: 10,),
        Center(
          child: GestureDetector(
            onTap: () {
              showCancelDialog(context);
            },
            child: Container(
              height: 48,
              width: MediaQuery.of(context).size.width * 0.45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [Colors.redAccent, Colors.red],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Cancel Work',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ) ,
              SizedBox(height: 20,),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------------- Reusable Widgets ----------------



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
            fontWeight: FontWeight.w600,
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

  Future<void> showCancelDialog(BuildContext context) async {
    final eventDetailsProvider =
    Provider.of<EventDetailsProvider>(context, listen: false);
    final managerProvider =
    Provider.of<ManagerProvider>(context, listen: false);

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "Are you sure?",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: const Text(
            "Do you really want to cancel this work?",
            style: TextStyle(fontSize: 15),
          ),
          actionsPadding: const EdgeInsets.only(bottom: 10, right: 10),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "No",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final eventDetailsProvider =
                Provider.of<EventDetailsProvider>(context, listen: false);
                final managerProvider =
                Provider.of<ManagerProvider>(context, listen: false);

                // 🔥 1. Check if boys are assigned
                bool boysExist =
                await eventDetailsProvider.hasConfirmedBoys(widget.eventID);

                if (boysExist) {
                  Navigator.pop(context); // close dialog

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("You cannot cancel! Boys already confirmed for this work."),
                      backgroundColor: Colors.orange,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                // 🔥 2. Proceed with cancellation (no boys found)
                await eventDetailsProvider.cancelEvent(widget.eventID);
                managerProvider.cancelWorkRemoveList(widget.eventID);

                // 🔥 Close the Alert Dialog
                Navigator.pop(context);

                // 🔥 Close the previous screen (2nd pop)
                Navigator.pop(context);

                // 🟢 Show success SnackBar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Work has been canceled successfully"),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Submit",
                style: TextStyle(fontSize: 16),
              ),
            )
,
          ],
        );
      },
    );
  }

}




